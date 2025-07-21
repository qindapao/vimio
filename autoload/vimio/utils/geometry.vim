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

