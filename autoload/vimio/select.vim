" autoload/vimio/select.vim
" -----------------
"
" Contents:

" Line character buffer
let s:row_cache = {}

function! vimio#select#_clear_row_cache() abort
    let s:row_cache = {}
endfunction

function! vimio#select#flood_fill_solid(sr, sc, use_diagonal) abort
    return s:flood_fill_by_predicate(a:sr, a:sc, { ch -> ch !=# ' ' }, a:use_diagonal)
endfunction

function! vimio#select#flood_fill_border_only(sr, sc, use_diagonal) abort
    return s:flood_fill_by_predicate(a:sr, a:sc, { ch -> has_key(g:vimio_config_border_chars, ch) }, a:use_diagonal)
endfunction

function! vimio#select#flood_fill_text(sr, sc, use_diagonal) abort
    return s:flood_fill_by_predicate(a:sr, a:sc, { ch -> !has_key(g:vimio_config_non_text_borders, ch) }, a:use_diagonal)
endfunction

" function! s:flood_fill_by_predicate(sr, sc, predicate, use_diagonal) abort
"     let start1 = reltime()
"     let result_old =  s:flood_fill_by_predicate_old(a:sr, a:sc, a:predicate, a:use_diagonal)
"     let delta1 = reltime(start1)

"     let start2 = reltime()
"     let result_new =  s:flood_fill_by_predicate_new(a:sr, a:sc, a:predicate, a:use_diagonal)
"     let delta2 = reltime(start2)
"       " 打印结果
"   echomsg "old: " . reltimestr(delta1)
"   echomsg "new: " . reltimestr(delta2)
"     return result_old
" endfunction


" General flood-fill: Determines whether diffusion is possible based on the predicate, supporting 4-way or 8-way expansion.
function! s:flood_fill_by_predicate_new(sr, sc, predicate, use_diagonal) abort
    " 1) 预先构造方向数组
    let dirs = [[0,1],[0,-1],[1,0],[-1,0]]
    if a:use_diagonal
        call extend(dirs, [[1,1],[1,-1],[-1,1],[-1,-1]])
    endif

    " 2) 初始化队列、访问记录、行缓存
    let queue     = [[a:sr, a:sc]]
    let head      = 0
    let visited   = {}
    let result    = []

    let max_row = line('$')

    " 3) 主循环，用 head 指针避免 remove(queue,0)
    while head < len(queue)
        let [r, c] = queue[head]
        let head += 1

        let key = r . ',' . c
        if has_key(visited, key)
            continue
        endif
        let visited[key] = 1

        " 4) 行边界检查
        if r < 1 || r > max_row
            continue
        endif

        " 5) 缓存本行字符列表
        if !has_key(s:row_cache, r)
            let s:row_cache[r] = vimio#utils#get_row_cells(r)
        endif
        let line_cells = s:row_cache[r]

        " 6) 列边界检查
        if c < 1 || c > len(line_cells)
            continue
        endif

        " 7) 调用 predicate 判断是否可扩散
        let ch = line_cells[c - 1]['char']
        if !call(a:predicate, [ch])
            continue
        endif

        " 8) 记录当前点，并扩散四/八向
        call add(result, copy(line_cells[c-1]))
        for d in dirs
            call add(queue, [r + d[0], c + d[1]])
        endfor
    endwhile

    return result
endfunction

" General flood-fill: Determines whether diffusion is possible based on the predicate, supporting 4-way or 8-way expansion.
function! s:flood_fill_by_predicate(sr, sc, predicate, use_diagonal) abort
    let visited   = {}
    let coords    = []
    let queue     = [[a:sr, a:sc]]

    let directions = [[0,1],[0,-1],[1,0],[-1,0]]
    if a:use_diagonal
        call extend(directions, [[1,1],[1,-1],[-1,1],[-1,-1]])
    endif

    while !empty(queue)
        let [r, c] = remove(queue, 0)
        let key = r . ',' . c
        if has_key(visited, key)
            continue
        endif
        let visited[key] = 1

        if r < 1 || r > line('$')
            continue
        endif
        if !has_key(s:row_cache, r)
            let s:row_cache[r] = vimio#utils#get_row_cells(r)
        endif
        let cells = s:row_cache[r]
        if c < 1 || c > len(cells)
            continue
        endif

        let ch = cells[c - 1]['char']
        if call(a:predicate, [ch])
            call add(coords, copy(cells[c-1]))
            for d in directions
                call add(queue, [r + d[0], c + d[1]])
            endfor
        endif
    endwhile
    return coords
endfunction



function! vimio#select#flood_fill_solid_with_degrees(sr, sc, use_diagonal) abort
  " Step 1: Run flood-fill using the solid predicate
  let coords = vimio#select#flood_fill_solid(a:sr, a:sc, a:use_diagonal)

  " Step 2: Build adjacency graph
  let graph = s:build_spoke_graph(coords, a:use_diagonal)

  " Step 3: Filter high-degree points
  let high_degree = []
  for key in keys(graph)
    if len(graph[key]) >= 3
      call add(high_degree, map(split(key, ','), 'str2nr(v:val)'))
    endif
  endfor

  return [coords, high_degree]
endfunction


"    .--------------------------------------------------------------.
"    | extract_closed_loop(coords, use_diagonal, mode)              |
"    '--------------------------.-----------------------------------'
"                               |
"                               v
"    .--------------------------------------------------------------.
"    | 0. PARAMETER CHECKS                                          |
"    | * If coords empty         -> return []                       |
"    | * If mode not "min"/"max" -> throw error                     |
"    '--------------------------.-----------------------------------'
"                               |
"                               v
"    .--------------------------------------------------------------.
"    | 1. INITIALIZE DATA                                           |
"    | * Determine start_key (argument or cursor position)          |
"    | * Build adjacency graph for all coords                       |
"    | * nbrs = graph[start_key]                                    |
"    | * Build nbrSet for O(1) neighbor lookups                     |
"    '--------------------------.-----------------------------------'
"                               |
"                               v
"    .--------------------------------------------------------------.
"    | 2. SETUP BEST-CYCLE TRACKING                                 |
"    | * best     = []                                              |
"    | * best_len = 1000000000 if mode="min" else -1 if mode="max"  |
"    '--------------------------.-----------------------------------'
"                               |
"                               v
"                      .-------------------------.
"                      | 3. MODE CHECK           |
"                      | * mode == "min"?        |
"                      '-.--------------------.--'
"                        |yes                 |no
"                        |                    |
"                        |                    '------.
"                        v                           v
"    .----------------------------------------.   .--------------------------------------------------.
"    | 4a. SHORTEST-CYCLE VIA BFS             |   | 4b. LONGEST-CYCLE VIA EXPLICIT-STACK DFS + TIME  |
"    .----------------------------------------.   .--------------------------------------------------.
"    | For each neighbor v in nbrs:           |   | * echomsg "Searching maximum cycle..."           |
"    | * init queue, parent map, visited set  |   | * timed_out = 0                                  |
"    | * while queue not empty:               |   |                                                  |
"    |     - dequeue u                        |   |   For each neighbor v in nbrs:                   |
"    |     - if u ∈ nbrSet and u ≠ v:         |   |    - if elapsed_time > limit                     |
"    |         * reconstruct path v→…→u       |   |        * timed_out = 1; break outer loop         |
"    |         * form cycle & update best     |   |    - init stack frame for v                      |
"    |         * break (found shortest for v) |   |    - while stack not empty:                      |
"    |     - else expand u’s neighbors        |   |        * check timeout -> break                  |
"    | * if best_len ≤ 4 -> break outer loop  |   |        * pop/backtrack when done                 |
"    '----------------------------------------'   |        * record cycles or push deeper frames     |
"                        |                        '--------------------------------------------------'
"                        |                                             |
"                        '-----------------.---------------------------'
"                                          |
"                                          v
"    .--------------------------------------------------------------.
"    | 5. RETURN FINAL CYCLE                                        |
"    | * Convert best ["r,c",…] to [[r,c],…]                        |
"    | * Return the list of coordinate pairs                        |
"    '--------------------------------------------------------------'
function! vimio#select#extract_closed_loop(coords, use_diagonal, mode, is_collect_all, ...) abort
    " --------------------------------------------------------------------------------
    " STEP 0: Parameter Validation
    " --------------------------------------------------------------------------------
    " Check if the list of coordinates is empty.
    " If we have no points, we cannot form any cycle, so immediately return an empty list.
    if empty(a:coords)
        return []
    endif

    " Verify that the 'mode' argument is either 'min' or 'max'.
    " If it is anything else, throw an error to alert the user.
    if index(['min', 'max'], a:mode) == -1
        throw 'Invalid mode: must be "min" or "max"'
    endif

    let all_cycles = []

    " --------------------------------------------------------------------------------
    " STEP 0.1: Timeout Initialization
    " --------------------------------------------------------------------------------
    " Record the starting time of this function call.
    " We will allow at most 10 seconds for the expensive 'max' search before we abort.
    let start_time = reltime()
    let time_limit = 10.0

    " --------------------------------------------------------------------------------
    " STEP 1: Determine the Starting Point
    " --------------------------------------------------------------------------------
    " If the caller passed an explicit starting coordinate as the fourth argument,
    " use that. Otherwise default to the current cursor position (line, column).
    let start      = (a:0 >= 1) ? a:1 : [line('.'), virtcol('.')]
    let start_key  = join(start, ',')

    " --------------------------------------------------------------------------------
    " STEP 2: Build the Adjacency List (graph)
    " --------------------------------------------------------------------------------
    " Create an empty dictionary where each key is "row,col" and the value will be
    " a list of neighbor keys that are one step away in the allowed directions.

    " Initialize an empty neighbor list for every coordinate in 'coords'.
    let graph = vimio#utils#build_select_graph(a:coords)

    " Define the four cardinal directions.
    let dirs = [[-1,0],[1,0],[0,-1],[0,1]]
    " If diagonal expansion is allowed, add the four diagonal offsets.
    if a:use_diagonal
        call extend(dirs, [[-1,-1],[-1,1],[1,-1],[1,1]])
    endif

    " For each point in the graph, look at all possible neighbor offsets.
    " If a neighbor also exists in 'graph', add it to the adjacency list.
    for key in keys(graph)
        " Split the key "r,c" back into numbers r and c.
        let [r, c] = map(split(key, ','), 'str2nr(v:val)')
        " Try each direction.
        for d in dirs
            let nk = (r + d[0]) . ',' . (c + d[1])
            " If that neighbor coordinate is also in our graph, record the edge.
            if has_key(graph, nk)
                call add(graph[key], nk)
            endif
        endfor
    endfor

    " --------------------------------------------------------------------------------
    " STEP 3: Find the Neighbors of the Start Point
    " --------------------------------------------------------------------------------
    " Retrieve the list of immediate neighbors of our start_key.
    let nbrs = get(graph, start_key, [])
    " If there are fewer than 2 neighbors, we cannot form any closed loop.
    if len(nbrs) < 2
        return []
    endif
    " Build a set (dictionary) of neighbors for constant-time membership checks.
    let nbrSet = {}
    for v in nbrs
        let nbrSet[v] = 1
    endfor

    " --------------------------------------------------------------------------------
    " STEP 4: Initialize Best Cycle Tracking
    " --------------------------------------------------------------------------------
    " 'best' will hold the best cycle found so far as a list of "r,c" keys.
    let best     = []
    let best_len = (a:mode ==# 'min') ? 1000000000 : -1

    " --------------------------------------------------------------------------------
    " STEP 5a: When mode is 'min', Use BFS to Find the Shortest Cycle
    " --------------------------------------------------------------------------------
    if a:mode ==# 'min'
        " For each neighbor 'v' of the start, perform a BFS.
        for v in nbrs
            " 'queue' holds nodes to visit, each with a parent pointer for path reconstruction.
            let queue   = [v]
            " 'parent' maps each visited node to its predecessor in the search tree.
            let parent  = {}
            let parent[v] = ''
            " 'visited' tracks which nodes have been enqueued already.
            let visited = {}
            let visited[v] = 1

            " Continue until there are no more nodes in the queue.
            while !empty(queue)
                let u = remove(queue, 0)

                " If we see another neighbor 'u' of the start that is not 'v' itself,
                " we have found a closed loop: v → ... → u → start.
                if has_key(nbrSet, u) && u !=# v
                    " Reconstruct the path from v to u using the 'parent' map.
                    let path = [u]
                    let x    = u
                    while parent[x] !=# ''
                        let x = parent[x]
                        call add(path, x)
                    endwhile
                    " Reverse so that path goes from v to u in order.
                    call reverse(path)

                    " Build the full cycle: start → v → ... → u → start.
                    let cycle = [start_key] + path + [start_key]
                    let L     = len(cycle)
                    " If this cycle is shorter than any we have stored, replace it.
                    if L < best_len
                        let best     = cycle
                        let best_len = L
                    endif
                    " Break out of the BFS since the first encountered loop is the shortest.
                    break
                endif
                " Otherwise, expand the BFS frontier.
                for w in graph[u]
                    " Never revisit the start_key in the middle of the path.
                    if w ==# start_key
                        continue
                    endif
                    if !has_key(visited, w)
                        let visited[w] = 1
                        let parent[w]  = u
                        call add(queue, w)
                    endif
                endfor
            endwhile

            " If we found the absolute smallest possible loop (4 points) we can stop early.
            if best_len <= 4
                break
            endif
        endfor

    " --------------------------------------------------------------------------------
    " STEP 5b: When mode is 'max', Use an Explicit-Stack DFS to Find the Longest Cycle
    " --------------------------------------------------------------------------------
    else
        " Show a single informational message in the command area without pausing.
        redraw
        echomsg "Searching maximum cycle..."

        " Keep track of whether we timed out.
        let timed_out = 0

        " For each neighbor v, we start a manual DFS.
        for v in nbrs
            " Check the timeout before digging into this neighbor.
            if reltimefloat(reltime(start_time)) > time_limit
                let timed_out = 1
                break
            endif

            " Prepare the initial DFS stack frame as a dictionary:
            "   'u'       - the current node being expanded
            "   'visited' - which nodes have been visited on this path
            "   'path'    - the list of nodes from v down to the current 'u'
            "   'next_i'  - which neighbor index of 'u' we will try next
            " create an empty dict and set the dynamic key
            let visited0 = {}
            let visited0[v] = 1
            let frame0 = {
                        \ 'u':       v,
                        \ 'visited': visited0,
                        \ 'path':    [v],
                        \ 'next_i':  0
                        \ }
            let stack = [frame0]

            " Continue until the manual stack is empty or we run out of time.
            while !empty(stack)
                " Timeout check inside the inner loop as well.
                if reltimefloat(reltime(start_time)) > time_limit
                    let timed_out = 1
                    break
                endif

                " Peek at the top frame without removing it.
                let frame = stack[-1]
                let u     = frame.u
                let nei   = graph[u]

                " If we have tried all neighbors of 'u', pop the frame to backtrack.
                if frame.next_i >= len(nei)
                    call remove(stack, -1)
                    continue
                endif

                " Otherwise, select the next neighbor 'w' to explore.
                let idx = frame.next_i
                let w   = nei[idx]
                " Increment 'next_i' so next time we'll try the following neighbor.
                let stack[-1].next_i = idx + 1

                " CASE 1: If w is exactly the start_key, we close a cycle back to start.
                if w ==# start_key
                    let cycle = [start_key] + frame.path + [start_key]
                    let L = len(cycle)
                    if L > best_len
                        let best     = cycle
                        let best_len = L
                    endif
                    " Continue in this frame to try the next neighbor.
                    if a:is_collect_all
                        call add(all_cycles, copy(cycle))
                    endif
                    continue
                endif

                " CASE 2: If w is another neighbor of start (but not the one we began with),
                " we also have a valid cycle: start → v → ... → u → w → start.
                if has_key(nbrSet, w) && w !=# frame.path[0]
                    let cycle = [start_key] + frame.path + [w] + [start_key]
                    let L = len(cycle)
                    if L > best_len
                        let best     = cycle
                        let best_len = L
                    endif
                    
                    if a:is_collect_all
                        call add(all_cycles, copy(cycle))
                    endif

                    continue
                endif

                " CASE 3: Otherwise, if w is not the start and not yet visited on this path,
                " push a new frame to descend deeper.
                if w !=# start_key && !has_key(frame.visited, w)
                    " Copy the visited map and path list for the new branch.
                    let new_visited = copy(frame.visited)
                    let new_path    = copy(frame.path)
                    call add(new_path, w)
                    let new_visited[w] = 1
                    " Create the new frame for node w.
                    let new_frame = {
                                \ 'u':       w,
                                \ 'visited': new_visited,
                                \ 'path':    new_path,
                                \ 'next_i':  0
                                \ }
                    " Push it onto our manual stack.
                    call add(stack, new_frame)
                endif
            endwhile

            if timed_out
                " If we timed out, break out of the outer loop too.
                break
            endif
        endfor

        " Optionally inform the user that we gave up due to timeout.
        if timed_out
            echomsg "Maximum cycle search timed out after " . time_limit . "s"
        else
            echomsg "Maximum cycle search completed in " .
                        \ printf('%.2f', reltimefloat(reltime(start_time))) . "s"
            redraw
        endif
    endif

    " --------------------------------------------------------------------------------
    " STEP 6: Convert the best cycle from string keys back to [row, col] lists
    " --------------------------------------------------------------------------------
    if a:is_collect_all
        return vimio#utils#resolve_coords(flatten(all_cycles), a:coords)
    else
        return vimio#utils#resolve_coords(best, a:coords)
    endif
endfunction

function! vimio#select#flood_fill_line_only(sr, sc, use_diagonal) abort
    return s:flood_fill_by_predicate(a:sr, a:sc, { ch -> has_key(g:vimio_config_line_chars, ch) }, a:use_diagonal)
endfunction

"==============================================================================
" Core walker: Walks in a straight line from the starting point until blocked
"  a:graph     - Adjacency list, key "r,c" -> list of neighbor keys
"  a:start_key - Starting position as string "r,c"
"  a:prev_key  - Previous position (where we came from) as string "r,c"
"  a:penetrate - Whether to allow straight-line traversal through junctions (0/1)
"==============================================================================
function! s:walk_line(graph, start_key, prev_key, penetrate) abort
    let seq  = []                   " Sequence of visited nodes
    let cur  = a:start_key
    let prv  = a:prev_key
    let seen = { cur:1, prv:1 }     " Prevent revisiting nodes (avoid loops)

    while 1
        " 1) Add current node to the sequence
        call add(seq, cur)

        " 2) Get all neighbors excluding the one we came from
        let nbrs = get(a:graph, cur, [])
        let cands = filter(copy(nbrs), {_,w -> w !=# prv})

        " 3) If there's only one candidate, follow it
        if len(cands) == 1
            let next = cands[0]
        " 4) If multiple branches, try to continue straight
        elseif len(cands) > 1
            " 4.1) Compute forward direction vector (dr, dc)
            let [r_cur,c_cur] = map(split(cur, ','), 'str2nr(v:val)')
            let [r_prv,c_prv] = map(split(prv, ','), 'str2nr(v:val)')
            let dr = r_cur - r_prv
            let dc = c_cur - c_prv

            " 4.2) Look for a neighbor in the same direction
            let next = ''
            for w in cands
                let [r_w,c_w] = map(split(w, ','), 'str2nr(v:val)')
                if r_w - r_cur == dr && c_w - c_cur == dc
                    let next = w
                    break
                endif
            endfor

            " 4.3) Only proceed if a straight path is found and penetrate=1
            if next ==# '' || !a:penetrate
                break
            endif
        " 5) No valid moves or unmatched case — stop
        else
            break
        endif

        " 6) Loop guard: stop if the next node has already been visited
        if has_key(seen, next)
            break
        endif

        " 7) Update state and continue
        let seen[next] = 1
        let prv        = cur
        let cur        = next
    endwhile

    return seq
endfunction

"==============================================================================
" Extract a single straight line from a set of flood-filled points
" a:coords       - Result of flood-fill (list of [row, col] points)
" a:use_diagonal - Whether to allow diagonal neighbors
" a:penetrate    - Whether to allow traversal through junctions
"==============================================================================
function! vimio#select#extract_line(coords, use_diagonal, penetrate) abort
    if empty(a:coords)
        return {}
    endif

    " Start point = last cursor position
    let start = [line('.'), virtcol('.')]
    let skey  = join(start, ',')

    " Build adjacency graph
    let graph = vimio#utils#build_select_graph(a:coords)

    let dirs = [[-1,0],[1,0],[0,-1],[0,1]]
    if a:use_diagonal
        call extend(dirs, [[-1,-1],[-1,1],[1,-1],[1,1]])
    endif
    for key in keys(graph)
        let [r,c] = map(split(key, ','), 'str2nr(v:val)')
        for d in dirs
            let nk = (r + d[0]) . ',' . (c + d[1])
            if has_key(graph, nk)
                call add(graph[key], nk)
            endif
        endfor
    endfor

    " Check degree of start point to determine if a line can be formed
    let nbrs = get(graph, skey, [])
    let deg  = len(nbrs)
    if deg < 2 || deg == 3
        return vimio#utils#resolve_coords([skey], a:coords)
    endif

    " Select two endpoints (if deg == 2), or choose a straight pair from 4-way junction
    if deg == 2
        let sel = nbrs
    else
        let priorities = [
                    \ [[0,1],[0,-1]],
                    \ [[1,0],[-1,0]],
                    \ [[1,1],[-1,-1]],
                    \ [[1,-1],[-1,1]],
                    \ ]
        let delta = {}
        for n in nbrs
            let [nr,nc] = map(split(n, ','), 'str2nr(v:val)')
            let delta[n] = [nr - start[0], nc - start[1]]
        endfor
        let sel = []
        for pair in priorities
            if !a:use_diagonal && abs(pair[0][0])+abs(pair[0][1])==2
                continue
            endif
            let tmp = []
            for vec in pair
                for n in keys(delta)
                    if delta[n] ==# vec
                        call add(tmp, n)
                        break
                    endif
                endfor
            endfor
            if len(tmp)==2
                let sel = tmp
                break
            endif
        endfor
        if empty(sel)
            let sel = [nbrs[0]]
        endif
    endif

    " Walk from both ends toward the center; merge paths to form full line
    let p1 = s:walk_line(graph, sel[0], skey, a:penetrate)
    if len(sel)==2
        let p2      = s:walk_line(graph, sel[1], skey, a:penetrate)
        let keys_seq = reverse(p1) + [skey] + p2
    else
        let keys_seq = [skey] + p1
    endif

    " Convert keys back to [[row, col], ...] format and return
    return vimio#utils#resolve_coords(keys_seq, a:coords)
endfunction


" Given a list of "row,col" keys, return full coord dicts by scanning each row once.
function! s:resolve_coords_by_rowscan(keys) abort
    " Convert a list of "row,col" strings into a list of [row, col] integer pairs.
    " Example: ['10,14', '5,6'] → [[10, 14], [5, 6]]
    let coords = map(copy(a:keys), {_, k -> map(split(k, ','), 'str2nr(v:val)')})
    let row_map = {}
    for [r, c] in coords
        if !has_key(row_map, r)
            let row_map[r] = []
        endif
        call add(row_map[r], c)
    endfor

    let result = []
    for r in keys(row_map)
        if !has_key(s:row_cache, r)
            let s:row_cache[r] = vimio#utils#get_row_cells(r)
        endif
        let cells = s:row_cache[r]

        let colset = {}
        for c in row_map[r]
            let colset[c] = 1
        endfor
        for cell in cells
            if has_key(colset, cell.screen_col)
                call add(result, cell)
            endif
        endfor
    endfor

    return result
endfunction

"================================================================================
" Obtain coordinates inside any closed shape: First, 
" find "internal neighbors" as seeds, suitable for irregular boundaries.
"================================================================================
function! vimio#select#get_closed_loop_interior_coords(closed_border, use_diagonal) abort
    if empty(a:closed_border)
        return []
    endif

    " 1) Construct boundary set & bounding box
    let borderSet = {}
    let rows = []
    let cols = []

    for coord in a:closed_border
        let key = (coord.row) . ',' . (coord.screen_col)
        let borderSet[key] = 1
        call add(rows, coord.row)
        call add(cols, coord.screen_col)
    endfor

    let rmin = min(rows) | let rmax = max(rows)
    let cmin = min(cols) | let cmax = max(cols)

    " 2) Select seeds: prioritize boundary neighboring points, otherwise choose the box center.
    let dirs4 = [[0,1],[0,-1],[1,0],[-1,0]]
    let dirs  = copy(dirs4)
    if a:use_diagonal
        call extend(dirs, [[1,1],[1,-1],[-1,1],[-1,-1]])
    endif

    let seed = []

    for coord in a:closed_border
        let r = coord.row
        let c = coord.screen_col
        for d in dirs
            let nr = r + d[0]
            let nc = c + d[1]
            let key = nr . ',' . nc
            if nr > rmin && nr < rmax && nc > cmin && nc < cmax && !has_key(borderSet, key)
                let seed = [nr, nc]
                break
            endif
        endfor

        if !empty(seed)
            break
        endif
    endfor

    if empty(seed)
        let sr = float2nr((rmin + rmax) / 2)
        let sc = float2nr((cmin + cmax) / 2)
        if !has_key(borderSet, sr . ',' . sc)
            let seed = [sr, sc]
        else
            return []
        endif
    endif

    " 3) BFS flood-fill: Limit within the box; skip when encountering boundaries/corner blocks.
    let visited  = {}
    let interior = []
    let queue    = [seed]

    while !empty(queue)
        let [r, c] = remove(queue, 0)
        let key    = r . ',' . c
        if has_key(visited, key) | continue | endif
        let visited[key] = 1

        " Jump when crossing the boundary or hitting the edge.
        if r <= rmin || r >= rmax || c <= cmin || c >= cmax
            continue
        endif
        if has_key(borderSet, key)
            continue
        endif

        call add(interior, key)

        " Diffusion: 4-way unconditional, 8-way requires "corner blocking" detection
        for d in dirs
            let [dr, dc] = d
            let nr = r + dr
            let nc = c + dc
            " Corner Blocking: When crossing diagonally across a corner, neither
            " side must be a boundary.
            if abs(dr) == 1 && abs(dc) == 1
                if has_key(borderSet, (r+dr) . ',' . c) || has_key(borderSet, r . ',' . (c+dc))
                    continue
                endif
            endif
            call add(queue, [nr, nc])
        endfor
    endwhile

    return s:resolve_coords_by_rowscan(interior)
endfunction


"==============================================================================
"    Build an adjacency graph (4-directional or 8-directional)
"    Input:  coords - List of [row, col] points (from flood_fill_line_only)
"    Output: graph  - Dictionary mapping "r,c" -> List of neighbor "r,c" strings
"==============================================================================
function! s:build_spoke_graph(coords, use_diagonal) abort
    let graph = {}

    for coord in a:coords
        let key = (coord.row) . ',' . (coord.screen_col)
        let graph[key] = []
    endfor

    let dirs = [[-1,0],[1,0],[0,-1],[0,1]]
    if a:use_diagonal
        call extend(dirs, [[-1,-1],[-1,1],[1,-1],[1,1]])
    endif

    for key in keys(graph)
        let [r,c] = map(split(key,','), 'str2nr(v:val)')
        for d in dirs
            let nk = (r + d[0]) . ',' . (c + d[1])
            if has_key(graph, nk)
                call add(graph[key], nk)
            endif
        endfor
    endfor
    return graph
endfunction

" TODO: Currently using 4-directional graph for cycle detection to avoid
"       false positives in 8-directional mode (e.g. diagonal connections forming
"       pseudo-cycles like '-.' or '\./'). This simplifies logic and ensures
"       stable behavior for most practical use cases.
"
"       ! As a result, even large closed loops formed entirely by diagonal
"       connections (e.g. diamond-shaped cycles) will NOT be detected as cycles.
"
"       In the future, consider implementing a more robust cycle detection
"       algorithm that supports 8-directional graphs while filtering out
"       small or invalid diagonal loops (e.g. by enforcing minimum cycle length
"       or geometric constraints).
function! s:filter_spoke_cycles(coords, use_diagonal) abort
    if empty(a:coords)
        return []
    endif

    " Enforce the use of a 4-way graph construction to avoid false loops formed by diagonals.
    let graph = s:build_spoke_graph(a:coords, 0)
    let visited = {}
    let in_cycle = {}

    for start in keys(graph)
        if has_key(visited, start)
            continue
        endif

        let stack = [[start, '', []]]

        while !empty(stack)
            let [u, parent, path] = remove(stack, -1)

            if has_key(visited, u)
                continue
            endif

            let visited[u] = 1
            call add(path, u)

            for v in graph[u]
                if v ==# parent
                    continue
                endif
                if has_key(visited, v)
                    let idx = index(path, v)
                    if idx >= 0
                        for i in range(idx, len(path) - 1)
                            let in_cycle[path[i]] = 1
                        endfor
                    endif
                else
                    call add(stack, [v, u, copy(path)])
                endif
            endfor
        endwhile
    endfor

    return vimio#utils#resolve_coords_excluding(keys(in_cycle), a:coords)
endfunction

"==============================================================================
" Extract all outward "spoke" branches from a flood-filled region (excluding loops)
"
" This function identifies all linear branches that extend outward from the
" current cursor position, ignoring any closed loops or internal cycles.
"
" Parameters:
"   raw_coords     - List of [row, col] points or a Dict of "r,c" -> 1
"                    (typically from flood_fill_line_only)
"   use_diagonal   - 0 or 1; whether to include diagonal neighbors
"
" Returns:
"   List of List<[row, col]> — each inner list is a single spoke branch
"
" Algorithm:
"   1. Get the current cursor position (must match the flood-fill origin)
"   2. Remove all cycles from the input region using filter_spoke_cycles()
"   3. Build an adjacency graph from the remaining points
"   4. Find all immediate neighbors of the cursor — these are branch roots
"   5. For each root, perform BFS to collect the full branch (no backtracking)
"
" Notes:
"   - Only branches directly connected to the cursor are considered
"   - Cycles are removed to ensure only outward paths are returned
"   - Each branch is returned as a list of [row, col] coordinates
"
" Example use case:
"   Given a cross-shaped structure, this will return the four arms as separate
"   branches, excluding any closed loops or internal intersections.
"==============================================================================
function! vimio#select#extract_spokes(raw_coords, use_diagonal) abort
    " 1) Get the current cursor position (must match the one passed in flood_fill_line_only).
    let sr = line('.')
    let sc = virtcol('.')      " flood_fill_line_only 用的也是 virtcol()

    " 2) Ring stripping filtration
    let clean = s:filter_spoke_cycles(a:raw_coords, a:use_diagonal)
    if empty(clean)
        echom "extract_spokes: clean empty, no rings→no spokes"
        return []
    endif

    " 3) Reconstructing the Adjacency List Without Cycles
    let graph = s:build_spoke_graph(clean, a:use_diagonal)

    " 4) Find all line points immediately adjacent to the cursor as branch roots.
    let dirs = [[-1,0],[1,0],[0,-1],[0,1]]
    if a:use_diagonal
        call extend(dirs, [[-1,-1],[-1,1],[1,-1],[1,1]])
    endif

    let roots = []
    for [dr,dc] in dirs
        let key = (sr + dr) . ',' . (sc + dc)
        if has_key(graph, key)
            call add(roots, key)
        endif
    endfor
    if empty(roots)
        echom "extract_spokes: no adjacent roots found"
        return []
    endif

    " 5) Perform BFS on each root: do not backtrack, avoid cycles, and collect 
    "     the entire branch.
    let spokes = []
    for root in roots
        let q       = [root]
        let visited = { (sr . ',' . sc):1, root:1 }
        let branch  = [root]

        while !empty(q)
            let cur = remove(q, 0)
            for nb in graph[cur]
                if !has_key(visited, nb)
                    let visited[nb] = 1
                    call add(branch, nb)
                    call add(q, nb)
                endif
            endfor
        endwhile
        call extend(spokes, branch)
    endfor

    return vimio#utils#resolve_coords(spokes, a:raw_coords)
endfunction

function! vimio#select#extract_all_closed_loops(coords, use_diagonal, mode) abort
    if empty(a:coords)
        return []
    endif

    let graph     = s:build_spoke_graph(a:coords, a:use_diagonal)
    let visited   = {}
    let all_loops = []
    let seen_keys = {}

    for start in keys(graph)
        if has_key(visited, start)
            continue
        endif

        let stack = [[start, '', []]]
        while !empty(stack)
            let [u, parent, path] = remove(stack, -1)
            if has_key(visited, u)
                continue
            endif

            let visited[u] = 1
            call add(path, u)

            for v in graph[u]
                if v ==# parent
                    continue
                endif

                if has_key(visited, v)
                    let idx = index(path, v)
                    if idx < 0 || len(path) - idx < 4
                        continue
                    endif

                    let loop = path[idx : ]
                    if type(loop) != 3
                        continue
                    endif

                    " Normalize for deduplication: sort the list of key-strings
                    let sorted = sort(copy(loop))
                    let key = join(sorted, '|')
                    if !has_key(seen_keys, key)
                        let seen_keys[key] = 1
                        call add(all_loops, vimio#utils#resolve_coords(loop, a:coords))
                    endif
                else
                    call add(stack, [v, u, copy(path)])
                endif
            endfor
        endwhile
    endfor

    return all_loops
endfunction

function! vimio#select#solid_select(use_diagonal) abort
    call vimio#select#_clear_row_cache()
    let row = line('.')
    let col = col('.')

    let g:vimio_state_select_shape_state.last_pos = [row, col]

    let ch = vimio#utils#get_char(row, col)
    " Non-printable or unprintable characters → Clear and exit
    if ch ==# '' || (ch !=# ' ' && strdisplaywidth(ch) == 0)
        return
    endif

    let sc = virtcol('.')

    let pos_list = vimio#select#flood_fill_solid(line('.'), sc, a:use_diagonal)

    call vimio#cursors#vhl_add_points_and_apply(pos_list)
endfunction

" Border Selection Mode
function! vimio#select#border_select(use_diagonal, mode) abort
    call vimio#select#_clear_row_cache()
    let row = line('.')
    let col = col('.')

    let g:vimio_state_select_shape_state.last_pos = [row, col]

    let ch = vimio#utils#get_char(row, col)
    " Non-printable or unprintable characters -> Clear and exit
    if ch ==# '' || (ch !=# ' ' && strdisplaywidth(ch) == 0)
        return
    endif

    let sc = virtcol('.')
    " Step 1: flood-fill Spread only on the border characters
    let border_coords = vimio#select#flood_fill_border_only(row, sc, a:use_diagonal)

    " Step 2: Extracting Closed Graph Cycles
    let closed_border = vimio#select#extract_closed_loop(border_coords, a:use_diagonal, a:mode, v:false)

    " Step 3: Highlight the closed border (if present)
    call vimio#cursors#vhl_add_points_and_apply(closed_border)
endfunction


function! vimio#select#line_select(use_diagonal, is_penetrate, ...) abort
    
    let is_apply_highlight = get(a:, 1, v:true)

    call vimio#select#_clear_row_cache()
    let row = line('.')
    let sc  = virtcol('.')
    let g:vimio_state_select_shape_state.last_pos = [row, sc]

    let ch = vimio#utils#get_char(row, col('.'))
    if ch ==# '' || (ch !=# ' ' && strdisplaywidth(ch) == 0)
        return
    endif

    " 1) flood-fill Line segment
    let coords = vimio#select#flood_fill_line_only(row, sc, a:use_diagonal)

    " 2) Extract the complete single line starting from the origin
    let line = vimio#select#extract_line(coords, a:use_diagonal, a:is_penetrate)

    " 3) Highlight the entire line
    if is_apply_highlight
        call vimio#cursors#vhl_add_points_and_apply(line)
    endif

    return line
endfunction

function! vimio#select#highlight_inside_border(use_diagonal, is_select_all, mode) abort
    call vimio#select#_clear_row_cache()
    " Save Starting Point
    let row = line('.')
    let sc  = virtcol('.')
    let g:vimio_state_select_shape_state.last_pos = [row, sc]

    " 1) flood‐fill Border
    let border_coords = vimio#select#flood_fill_border_only(row, sc, a:use_diagonal)

    " 2) Extract the shortest closed loop
    let closed_border = vimio#select#extract_closed_loop(border_coords, a:use_diagonal, a:mode, v:false)
    if empty(closed_border)
        " echohl WarningMsg | echo "No closed loop found" | echohl None
        return
    endif

    let all_points = []
    if a:is_select_all
        call extend(all_points, closed_border)
    endif

    " 3) Calculate internal coordinates (supports irregular boundaries)
    let interior = vimio#select#get_closed_loop_interior_coords(closed_border, a:use_diagonal)
    if empty(interior)
        echohl WarningMsg | echo "No interior to highlight" | echohl None
        return
    endif

    " 4) Highlight all internal cells at once
    call extend(all_points, interior)
    call vimio#cursors#vhl_add_points_and_apply(all_points)
endfunction


function! vimio#select#highlight_inside_line() abort
    call vimio#select#_clear_row_cache()
    let coords = vimio#select#line_select(v:false, v:true)

    " 1) Calculate internal coordinates (supports irregular boundaries)
    let interior = vimio#select#get_closed_loop_interior_coords(coords, v:false)
    if empty(interior)
        echohl WarningMsg | echo "No interior to highlight" | echohl None
        return
    endif

    " 2) Highlight all internal cells at once
    call vimio#cursors#vhl_add_points_and_apply(interior)
endfunction

function! vimio#select#highlight_inside_line_without_border() abort
    call vimio#select#_clear_row_cache()
    let coords = vimio#select#line_select(v:false, v:true, v:false)

    " 1) Calculate internal coordinates (supports irregular boundaries)
    let interior = vimio#select#get_closed_loop_interior_coords(coords, v:false)
    if empty(interior)
        echohl WarningMsg | echo "No interior to highlight" | echohl None
        return
    endif

    " 2) Highlight all internal cells at once
    call vimio#cursors#vhl_add_points_and_apply(interior)
endfunction


function! vimio#select#extract_outgoing_spokes(use_diagonal) abort
    call vimio#select#_clear_row_cache()
    let row = line('.')
    let sc  = virtcol('.')
    let g:vimio_state_select_shape_state.last_pos = [row, sc]

    let ch = vimio#utils#get_char(row, col('.'))
    if ch ==# '' || (ch !=# ' ' && strdisplaywidth(ch) == 0)
        return
    endif

    " 1) flood-fill Line segment
    let coords = vimio#select#flood_fill_line_only(row, sc, a:use_diagonal)

    " 2) Extract all outgoing connections (including T/cross nodes) from 
    "   the current frame/node (row, col).
    let all_lines = vimio#select#extract_spokes(coords, a:use_diagonal)

    " If there are branches, make sure to include the starting point as well.
    if !empty(all_lines)
        let sr = line('.')
        let sc = virtcol('.')
        let [sr, byte_col, width, add_char, add_row, screen_col] = vimio#cursors#vrow_vcol_to_row_col(sr, sc)
        call add(all_lines, {
                    \ 'row': sr,
                    \ 'byte_col': byte_col,
                    \ 'width': width,
                    \ 'char': add_char,
                    \ 'screen_col': screen_col
                    \})
    endif

    " 3) highlight
    call vimio#cursors#vhl_add_points_and_apply(all_lines)
endfunction

function! vimio#select#highlight_all_related(use_diagonal) abort
    call vimio#select#_clear_row_cache()
    " Save Starting Point
    let t_start = reltime()
    let row = line('.')
    let sc  = virtcol('.')
    let g:vimio_state_select_shape_state.last_pos = [row, sc]

    " 1) flood‐fill Border
    let t1 = reltime()
    let solid_coords = vimio#select#flood_fill_solid(row, sc, a:use_diagonal)
    let t2 = reltime()

    let all_points = []
    call extend(all_points, solid_coords)

    " 3) Extract all closed loops from the solid region
    " echomsg "highlighting all related area,please wait..."
    let t3 = reltime()
    " Here, it is necessary to return two layers of data. Cannot be flattened
    let closed_border = vimio#select#extract_all_closed_loops(solid_coords, a:use_diagonal, 'max')
    let t4 = reltime()
    for cycle in closed_border
        let interior = vimio#select#get_closed_loop_interior_coords(cycle, a:use_diagonal)
        call extend(all_points, interior)
    endfor
    let t5 = reltime()
    call vimio#cursors#vhl_add_points_and_apply(all_points)
    let t6 = reltime()
    " echomsg printf('⏱ flood_fill: %.2f ms', reltimefloat(reltime(t1, t2)) * 1000)
    " echomsg printf('⏱ extract_loops: %.2f ms', reltimefloat(reltime(t3, t4)) * 1000)
    " echomsg printf('⏱ collect_interior: %.2f ms', reltimefloat(reltime(t4, t5)) * 1000)
    " echomsg printf('⏱ apply_highlight: %.2f ms', reltimefloat(reltime(t5, t6)) * 1000)
    " echomsg printf('⏱ total: %.2f ms', reltimefloat(reltime(t_start, t6)) * 1000)
endfunction

" Border Selection Mode
function! vimio#select#highlight_text(use_diagonal) abort
    call vimio#select#_clear_row_cache()
    let row = line('.')
    let col = col('.')

    let g:vimio_state_select_shape_state.last_pos = [row, col]

    let ch = vimio#utils#get_char(row, col)
    " Non-printable or unprintable characters → Clear and exit
    if ch ==# '' || (ch !=# ' ' && strdisplaywidth(ch) == 0)
        return
    endif

    let sc = virtcol('.')

    let pos_list = vimio#select#flood_fill_text(line('.'), sc, a:use_diagonal)

    call vimio#cursors#vhl_add_points_and_apply(pos_list)
endfunction


