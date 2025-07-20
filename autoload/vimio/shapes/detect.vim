" autoload/vimio/shapes/detect.vim
" ---------------
" Identify specific graphics based on points
"
"
" Contents:
" - vimio#shapes#detect#from_points(points,is_space_strip)


" ['a', row, col, -1]
function! vimio#shapes#detect#from_points(points, is_space_strip) abort
    let detect_funcs = [
                \ function('s:detect_ellipse'),
                \ function('s:detect_box'),
                \]

    for Detect_func in detect_funcs
        let shape_obj = Detect_func(a:points, a:is_space_strip)
        if !empty(shape_obj)
            break
        endif
    endfor

    return shape_obj
endfunction


" :TODO: TITLE has not been processed yet, only TEXT_ONLY has been processed
function! s:detect_box(points, is_space_strip) abort
    let matrix = vimio#utils#geometry#points_to_matrix(a:points)
    let bounds = vimio#utils#geometry#get_bounds(a:points)

    if !vimio#utils#geometry#is_rect(matrix, bounds)
        return {}
    endif

    let [min_row, max_row, min_col, max_col] = bounds
    let content = []

    for r in range(min_row + 1, max_row - 1)
        let line = ''
        for c in range(min_col + 1, max_col - 1)
            let line .= get(matrix[r], c, ' ')
        endfor
        let stripped = line
        if a:is_space_strip
            let stripped = substitute(line, '^\s\+', '', '')
            let stripped = substitute(stripped, '\s\+$', '', '')
        else
            " The text inside the box is special, with a space around it.
            " Remove the leading and trailing spaces
            let stripped = substitute(line, '^\s', '', '')
            let stripped = substitute(stripped, '\s$', '', '')
        endif
        
        if stripped !=# ''
            call add(content, stripped)
        endif
    endfor

    let left_corner_char = matrix[min_row][min_col]
    let box_type = get(g:vimio_config_shapes_box_types, left_corner_char, g:vimio_config_shapes_box_type_default)

    return vimio#shapes#box#new({
                \ 'X': min_col,
                \ 'Y': min_row,
                \ 'TEXT_ONLY': join(content, "\n"),
                \ 'TITLE': '',
                \ 'BOX_TYPE': deepcopy(box_type),
                \ 'END_X': -1,
                \ 'END_Y': -1,
                \ })
endfunction

function! s:detect_ellipse(points, is_space_strip) abort
    return {}
endfunction


