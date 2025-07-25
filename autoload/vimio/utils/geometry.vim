" autoload/vimio/utils/geometry.vim
" ----------------
" Geometric figure recognition
"
" Contents:
" - vimio#utils#geometry#points_to_matrix(points)
" - vimio#utils#geometry#get_bounds(points)
" - vimio#utils#geometry#is_rect(matrix,bounds)

" ['a', row, col, -1]
function! vimio#utils#geometry#points_to_matrix(points) abort
    let matrix = {}
    for point in a:points
        let [ch, row, col, _] = point
        if !has_key(matrix, row)
            let matrix[row] = {}
        endif
        if ch !=# ''
            let matrix[row][col] = ch
        endif
    endfor
    return matrix
endfunction

function! vimio#utils#geometry#get_bounds(points) abort
    let rows = map(copy(a:points), 'v:val[1]')
    let cols = map(copy(a:points), 'v:val[2]')
    return [min(rows), max(rows), min(cols), max(cols)]
endfunction

function! vimio#utils#geometry#is_rect(matrix, bounds) abort
    let [min_row, max_row, min_col, max_col] = a:bounds

    " Check if the top and bottom edges are intact
    for r in [min_row, max_row]
        for c in range(min_col, max_col)
            if !has_key(a:matrix, r) || !has_key(a:matrix[r], c)
                return v:false
            endif
        endfor
    endfor

    " Check whether the left and right sides are complete
    for r in range(min_row, max_row)
        for c in [min_col, max_col]
            if !has_key(a:matrix, r) || !has_key(a:matrix[r], c)
                return v:false
            endif
        endfor
    endfor

    return v:true
endfunction


" =============================================================================
" input:
" let coords = [
"       \ ['X', 0, 0],
"       \ ['Y', 1, 1],
"       \ ['Z', 2, 2],
"       \]
" let cursor = [2, 2]
"
" output:
"
" {
"   'points': [
"     {
"       'pos':      [0, 0, 'X'],                " startpoint（row, col, char）  
"       'dir':      {'primary':'down',          " startpoint -> cursor main direction
"                     'secondary':'right'},     " (If there is a corner, then there is secondary)
"       'diagonal': 1                           " is diagonal line(0 or 1)
"       'style_idx': 2,
"     },
"     {
"       'pos':      [2, 2, 'X'],
"       'dir':      {'primary':'up', 'secondary':'left'},
"       'diagonal': 1
"       'style_idx': 0,
"     }
"   ]
" }
function! vimio#utils#geometry#analyze_line_shape(coords, cursor) abort
    if empty(a:coords)
        return {}
    endif

    " Constructing an Adjacency Graph & Coordinate Mapping
    let graph     = {}
    let coord_map = {}
    for rowcol in a:coords
        " rowcol = [char, row, col]
        let key = rowcol[1] . ',' . rowcol[2]
        let graph[key]     = []
        let coord_map[key] = [rowcol[1], rowcol[2], rowcol[0]]
    endfor

    " Directions Adjacent
    let dirs = [[-1,0],[1,0],[0,-1],[0,1],[-1,-1],[-1,1],[1,-1],[1,1]]
    for key in keys(graph)
        let [r, c] = map(split(key, ','), 'str2nr(v:val)')
        for d in dirs
            let nk = (r + d[0]) . ',' . (c + d[1])
            if has_key(graph, nk)
                call add(graph[key], nk)
            endif
        endfor
    endfor

    " Find all endpoints (degree == 1)
    let endpoints = filter(keys(graph), 'len(graph[v:val]) == 1')
    if len(endpoints) < 2
        return {}
    endif

    " Change the cursor to key
    let cursor_key = a:cursor[0] . ',' . a:cursor[1]

    " Constructing a Points List
    let points = []
    for ep in endpoints
        let pt = coord_map[ep]
        let nb = graph[ep][0]
 
        "  Shape Local Direction: neighbor → endpoint
        let shape_dir = s:dir2pts(nb, ep)

        "  Endpoint → Cursor Direction: Shortest Path
        let path_to_cursor = s:find_path(graph, ep, cursor_key)
        if empty(path_to_cursor)
            let cursor_dir = s:dir2pts(ep, cursor_key)
        else
            let cursor_dir = s:get_direction(path_to_cursor)
        endif

        if len(path_to_cursor) >= 2
            " The cursor is the endpoint, so the second-to-last point is taken
            " as the neighbor point.
            let cursor_nb_point = path_to_cursor[len(path_to_cursor) - 2]
            let cursor_nb = cursor_nb_point[0] . ',' . cursor_nb_point[1]
        else
            let cursor_nb = cursor_key
        endif
        let cursor_local_dir = s:dir2pts(cursor_nb, cursor_key)

        "  Is this endpoint itself a slash?
        let is_diag_ep = shape_dir.secondary !=# 'invalid' ? 1 : 0
        let is_cursor_diag = cursor_local_dir.secondary !=# 'invalid' ? 1 : 0
        let is_diag = (is_diag_ep || is_cursor_diag) ? 1 : 0

        let style_idx = -1
        for key2 in path_to_cursor
            let key2_str = key2[0] . ',' .key2[1]
            if !has_key(coord_map, key2_str)
                continue
            endif

            let ch = coord_map[key2_str][2]
            " :TODO: This is not rigorous; if diagonal types are added later,
            "   additional judgment logic will need to be incorporated here.
            for i in range(len(g:vimio_config_draw_line_styles))
                if index(g:vimio_config_draw_line_styles[i], ch) >= 0
                    let style_idx = i
                    break
                endif
            endfor
            if style_idx >= 0
                break
            endif
        endfor

        let style_idx = (style_idx == -1) ? 0 : style_idx

        call add(points, {
                    \ 'pos':       pt,
                    \ 'dir':       cursor_dir,
                    \ 'diagonal':  is_diag,
                    \ 'style_idx':  style_idx,
                    \})
    endfor

    return {'points': points}
endfunction


" BFS to find the shortest path: the graph is an adjacency list constructed from analyze_line_shape.
function! s:find_path(graph, start, target) abort
    let queue   = [[a:start]]
    let visited = { a:start: 1 }

    while !empty(queue)
        let path = remove(queue, 0)
        let node = path[-1]
        if node ==# a:target
            return path
        endif

        for nb in a:graph[node]
            if !has_key(visited, nb)
                let visited[nb] = 1
                call add(queue, path + [nb])
            endif
        endfor
    endwhile

    return []
endfunction

" ------------------------------------------------------------------------
" Simple two-point directional split: neighbor → endpoint
function! s:dir2pts(from, to) abort
    let [r1, c1] = map(split(a:from, ','), 'str2nr(v:val)')
    let [r2, c2] = map(split(a:to,   ','), 'str2nr(v:val)')

    let dr = r2 - r1
    let dc = c2 - c1

    if dr ==# 0 && dc ==# 0
        return {'primary': 'invalid', 'secondary': 'invalid'}
    endif
    if dr ==# 0
        return {'primary': dc > 0 ? 'right' : 'left', 'secondary': 'invalid'}
    endif
    if dc ==# 0
        return {'primary': dr > 0 ? 'down' : 'up',   'secondary': 'invalid'}
    endif

    " Slope: Vertical first, horizontal second
    let v = dr > 0 ? 'down' : 'up'
    let h = dc > 0 ? 'right': 'left'
    return {'primary': v, 'secondary': h}
endfunction

" ------------------------------------------------------------------------
" Multi-point path direction determination: Endpoint → Cursor's complete path
function! s:get_direction(path) abort
    if len(a:path) < 2
        return {'primary': 'unknown', 'secondary': 'invalid'}
    endif

    " Remove all points
    let pts = map(a:path, {_,v->map(split(v,','),'str2nr(v:val)')})
    let [r1, c1] = pts[0]
    let [r2, c2] = pts[-1]
    let dr = r2 - r1
    let dc = c2 - c1

    " Straight line
    if dr ==# 0
        return {'primary': dc > 0 ? 'right' : 'left', 'secondary': 'invalid'}
    endif
    if dc ==# 0
        return {'primary': dr > 0 ? 'down'  : 'up',   'secondary': 'invalid'}
    endif

    " Slope: Calculate the total vector first.
    let vdir = dr > 0 ? 'down' : 'up'
    let hdir = dc > 0 ? 'right': 'left'

    " Determine the sequence based on the midpoint.
    let same_row = 0
    let same_col = 0
    if len(pts) > 2
        for p in pts[1 : len(pts)-2]
            if p[0] ==# r1    " There is a horizontal segment at the starting point.
                let same_row = 1
            endif
            if p[1] ==# c2    " There is a vertical segment in the final column.
                let same_col = 1
            endif
            if same_row || same_col
                break
            endif
        endfor
    endif

    if same_row || same_col
        return {'primary': hdir, 'secondary': vdir}
    else
        return {'primary': vdir, 'secondary': hdir}
    endif
endfunction

