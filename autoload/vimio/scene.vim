" autoload/vimio/scene.vim
" ---------------
" Set of scene judgment functions.
" Used to determine whether a character is suitable for use as a crosspoint, 
" connection point, etc., in a particular context.
"
" Contents:
" - vimio#scene#unicode(up,down,left,right,char_category_indexs)
" - vimio#scene#cross(up,down,left,right,char_category_indexs)
" - vimio#scene#dot(up,down,left,right,char_category_indexs)
" - vimio#scene#apostrophe(up,down,left,right,char_category_indexs)
" - vimio#scene#get_cross_chars(cross_point,all_chars)
" - vimio#scene#clear_cross_cache()


let s:vimio_scene_cross_cache = {}

function! vimio#scene#unicode(up, down, left, right, char_category_indexs)
    for char_index in a:char_category_indexs
        if has_key(g:vimio_config_draw_index_map_left, char_index)
            if vimio#utils#chars_some_not_in(g:vimio_config_draw_cross_chars, a:left)
                return 0
            endif
            if vimio#utils#chars_all_not_in(g:vimio_config_draw_unicode_cross_chars[char_index], a:left)
                return 0
            endif
        elseif has_key(g:vimio_config_draw_index_map_right, char_index)
            if vimio#utils#chars_some_not_in(g:vimio_config_draw_cross_chars, a:right)
                return 0
            endif
            if vimio#utils#chars_all_not_in(g:vimio_config_draw_unicode_cross_chars[char_index], a:right)
                return 0
            endif
        elseif has_key(g:vimio_config_draw_index_map_up, char_index)
            if vimio#utils#chars_some_not_in(g:vimio_config_draw_cross_chars, a:up)
                return 0
            endif
            if vimio#utils#chars_all_not_in(g:vimio_config_draw_unicode_cross_chars[char_index], a:up)
                return 0
            endif
        else
            if vimio#utils#chars_some_not_in(g:vimio_config_draw_cross_chars, a:down)
                return 0
            endif
            if vimio#utils#chars_all_not_in(g:vimio_config_draw_unicode_cross_chars[char_index], a:down)
                return 0
            endif
        endif
    endfor

    return 1
endfunction

" Scenes suitable for drawing a plus sign
function! vimio#scene#cross(up, down, left, right, char_category_indexs)
    " Check whether the parameter is defined
    if a:up == [''] || a:down == [''] || a:left == [''] || a:right == ['']
        return 0
    endif

    " Dictionary defining valid characters
    let valid_chars = {
    \ 'up': {'|': 1, '.': 1, "'": 1, '+': 1, '^': 1, ')': 1},
    \ 'down': {'|': 1, '.': 1, "'": 1, '+': 1, 'v': 1, ')': 1},
    \ 'left': {'-': 1, '.': 1, "'": 1, '+': 1, '<': 1},
    \ 'right': {'-': 1, '.': 1, "'": 1, '+': 1, '>': 1}
    \ }

    return vimio#utils#chars_any_in(valid_chars['up'], a:up)
                \ && vimio#utils#chars_any_in(valid_chars['down'], a:down) 
                \ && vimio#utils#chars_any_in(valid_chars['left'], a:left) 
                \ && vimio#utils#chars_any_in(valid_chars['right'], a:right)
endfunction

" Drawing the scene of the point number
" :TODO: Should the judgment regarding the use of "dot" and "apostrophe" be more lenient?
function! vimio#scene#dot(up, down, left, right, char_category_indexs)
    " Check whether the parameters are defined and meet the conditions.
    if (index(a:up, '|') >= 0 || index(a:up, ')') >= 0 || index(a:up, '^') >= 0)
        \ && (index(a:down, '|') >= 0 || index(a:down, ')') >= 0 || index(a:down, 'v') >= 0)
        \ && (index(a:left, '-') >= 0 || index(a:left, '<') >= 0)
        \ && (index(a:right, '-') >= 0 || index(a:right, '>') >= 0)
        return 0
    endif

    " Check if the lower left or lower right satisfies the condition
    return ((index(a:left, '-') >= 0 || index(a:left, '<') >= 0) && (index(a:down, '|') >= 0 || index(a:down, ')') >= 0 || index(a:down, 'v') >= 0)) ||
            \ ((index(a:right, '-') >= 0 || index(a:right, '>') >= 0) && (index(a:down, '|') >= 0 || index(a:down, ')') >= 0 || index(a:down, 'v') >= 0))
endfunction

" Draw a scene with single quotes
function! vimio#scene#apostrophe(up, down, left, right, char_category_indexs)
    if (index(a:up, '|') >= 0 || index(a:up, ')') >= 0 || index(a:up, '^') >= 0)
        \ && (index(a:right, '-') >= 0 || index(a:right, '>') >= 0)
        \ && index(a:down, '|') < 0 && index(a:down, ')') < 0 && index(a:down, 'v') < 0
        return 1
    endif

    return (index(a:up, '|') >= 0 || index(a:up, ')') >= 0 || index(a:up, '^') >= 0)
        \ && (index(a:left, '-') >= 0 || index(a:left, '<') >= 0)
        \ && !(
        \   (index(a:down, '|') >= 0 || index(a:down, ')') >= 0 || index(a:down, 'v') >= 0)
        \   || (index(a:right, '|') >= 0 || index(a:right, ')') >= 0 || index(a:right, '>') >= 0)
        \ )
endfunction

function! vimio#scene#horizontal_line(up, down, left, right,  char_category_indexs)
    if index(a:left, '-') >= 0
        return 1
    endif
    if index(a:right, '-') >= 0
        return 1
    endif

    return 0
endfunction

function! vimio#scene#vertical_line(up, down, left, right,  char_category_indexs)
    if index(a:up, '|') >= 0
        return 1
    endif
    if index(a:down, '|') >= 0
        return 1
    endif

    return 0
endfunction

function! vimio#scene#thin_horizontal_dashed_line(up, down, left, right,  char_category_indexs)
    if index(a:left, '┄') >= 0
        return 1
    endif
    if index(a:right, '┄') >= 0
        return 1
    endif

    return 0
endfunction

function! vimio#scene#thin_vertical_dashed_line(up, down, left, right,  char_category_indexs)
    if index(a:up, '┆') >= 0
        return 1
    endif
    if index(a:down, '┆') >= 0
        return 1
    endif

    return 0
endfunction

function! vimio#scene#bold_horizontal_dashed_line(up, down, left, right,  char_category_indexs)
    if index(a:left, '┅') >= 0
        return 1
    endif
    if index(a:right, '┅') >= 0
        return 1
    endif

    return 0
endfunction

function! vimio#scene#bold_vertical_dashed_line(up, down, left, right,  char_category_indexs)
    if index(a:up, '┇') >= 0
        return 1
    endif
    if index(a:down, '┇') >= 0
        return 1
    endif

    return 0
endfunction

function! vimio#scene#get_cross_chars(cross_point, all_chars) abort
    let result = {}

    for [key, cross_chars] in items(a:cross_point)
        let [row, col] = map(split(key, ','), 'str2nr(v:val)')

        "     col
        " row  x
        let left = (col>1) ? get(a:all_chars, row . ',' . (col-1), ['']) : ['']
        let right  = get(a:all_chars, row. ',' . (col+1), [''])
        let up = (row>1) ? get(a:all_chars, (row-1) . ',' . col, ['']) : ['']
        let down = get(a:all_chars, (row+1) . ',' . col, [''])
        let cache_key = join(up, '') . '=' . join(down, '') . '=' . join(left, '') . '=' . join(right, '') . '=' . join(cross_chars, '')
        if !has_key(s:vimio_scene_cross_cache, cache_key)
            let is_cross_not_found = v:true

            if s:is_cross_point_chars_unicode_ascii_not_mix(cross_chars)
                for table_param in g:vimio_config_draw_normal_char_funcs_map
                    if call(table_param[1], [up, down, left, right, table_param[2]])
                        let is_cross_not_found = v:false
                        if has_key(g:vimio_config_draw_cross_styles[g:vimio_state_cross_style_index], table_param[0])
                            let s:vimio_scene_cross_cache[cache_key] = g:vimio_config_draw_cross_styles[g:vimio_state_cross_style_index][table_param[0]]
                        else
                            let s:vimio_scene_cross_cache[cache_key] = table_param[0]
                        endif
                        break
                    endif
                endfor
            endif

            if is_cross_not_found
                let s:vimio_scene_cross_cache[cache_key] = ''
            endif

        endif

        let cache_value = s:vimio_scene_cross_cache[cache_key]
        if cache_value != ''
            let result[key] = cache_value
        endif
    endfor

    return result
endfunction

function! vimio#scene#clear_cross_cache() abort
    let s:vimio_scene_cross_cache = {}
endfunction

function! s:is_cross_point_chars_unicode_ascii_not_mix(cross_chars) abort
    "This is somewhat special because the four ASCII arrow Unicode characters
    "are also applicable, so they are not considered during the judgment. 
    let ignored_chars = {'<': 1, '>': 1, '^': 1, 'v': 1}


    let has_ascii    = v:false
    let has_unicode  = v:false
    for ch in a:cross_chars
        if has_key(ignored_chars, ch)
            continue
        endif
        if has_key(g:vimio_config_draw_ascii_cross_chars, ch)
            let has_ascii = v:true
        else
            let has_unicode = v:true
        endif

        if has_ascii && has_unicode
            return v:false
        endif
    endfor

    return v:true
endfunction

function! s:GetSafeCell(cache, row, col) abort
    try
        return a:cache[a:row][a:col]
    catch
        return ''
    endtry
endfunction

function! vimio#scene#calculate_cross_points(points, cache_ref, cache_table, cross_style_table, cross_style_index, result_ref) abort
    let row_chars_cache = {}

    for point in a:points
        " Skip non-crossing characters
        if !has_key(g:vimio_config_draw_cross_chars, point[0])
            continue
        endif

        " Cache line characters (current three lines above and below)
        for delta in [-1, 0, 1]
            let row_idx = point[1] + delta
            if row_idx < 1 || row_idx > line('$')
                continue
            endif

            if !has_key(row_chars_cache, row_idx)
                let [row_chars_cache[row_idx], _] = vimio#utils#get_line_cells(row_idx, point[2])
                call map(row_chars_cache[row_idx], {i, val -> has_key(g:vimio_config_draw_cross_chars, val) ? val : ''})
            endif
        endfor

        " Retrieve characters from above, below, left, and right
        let up    = [s:GetSafeCell(row_chars_cache, point[1]-1, point[2]-1)]
        let down  = [s:GetSafeCell(row_chars_cache, point[1]+1, point[2]-1)]
        let left  = [s:GetSafeCell(row_chars_cache, point[1],   point[2]-2)]
        let right = [s:GetSafeCell(row_chars_cache, point[1],   point[2])]

        let cache_key = up[0] . '=' . down[0] . '=' . left[0] . '=' . right[0]

        " If it already exists in the cache, skip it.
        if !has_key(a:cache_ref, cache_key)
            let is_cross_not_found = v:true

            for table_param in a:cache_table
                if call(table_param[1], [up, down, left, right, table_param[2]])
                    let is_cross_not_found = v:false
                    let result = has_key(a:cross_style_table[a:cross_style_index], table_param[0]) ?
                                \ a:cross_style_table[a:cross_style_index][table_param[0]] :
                                \ table_param[0]
                    let a:cache_ref[cache_key] = result
                    break
                endif
            endfor

            if is_cross_not_found
                let a:cache_ref[cache_key] = ''
            endif
        endif

        if a:cache_ref[cache_key] !=# ''
            call add(a:result_ref, [a:cache_ref[cache_key], point[1], point[2]])
        endif
    endfor
endfunction

