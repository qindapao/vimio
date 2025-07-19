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
    if (index(a:up, '|') >= 0 || index(a:up, ')') >= 0)
        \ && (index(a:down, '|') >= 0 || index(a:down, ')') >= 0)
        \ && index(a:left, '-') >= 0
        \ && index(a:right, '-') >= 0
        return 0
    endif

    " Check if the lower left or lower right satisfies the condition
    return (index(a:left, '-') >= 0 && (index(a:down, '|') >= 0 || index(a:down, ')') >= 0)) ||
            \ (index(a:right, '-') >= 0 && (index(a:down, '|') >= 0 || index(a:down, ')') >= 0))
endfunction

" Draw a scene with single quotes
function! vimio#scene#apostrophe(up, down, left, right, char_category_indexs)
    if (index(a:up, '|') >= 0 || index(a:up, ')') >= 0)
        \ && index(a:right, '-') >= 0
        \ && index(a:down, '|') < 0 && index(a:down, ')') < 0
        return 1
    endif

    return (index(a:up, '|') >= 0 || index(a:up, ')') >= 0)
        \ && index(a:left, '-') >= 0
        \ && !(
        \   (index(a:down, '|') >= 0 || index(a:down, ')') >= 0)
        \   || (index(a:right, '|') >= 0 || index(a:right, ')') >= 0)
        \ )
endfunction


function! vimio#scene#get_cross_chars(cross_point, all_chars) abort
    let result = {}

    for [key, val] in items(a:cross_point)
        let [row, col] = map(split(key, ','), 'str2nr(v:val)')

        "     col
        " row  x
        let left = (col>1) ? get(a:all_chars, row . ',' . (col-1), ['']) : ['']
        let right  = get(a:all_chars, row. ',' . (col+1), [''])
        let up = (row>1) ? get(a:all_chars, (row-1) . ',' . col, ['']) : ['']
        let down = get(a:all_chars, (row+1) . ',' . col, [''])
        let cache_key = join(up, '') . '=' . join(down, '') . '=' . join(left, '') . '=' . join(right, '')
        if !has_key(s:vimio_scene_cross_cache, cache_key)
            let is_cross_not_found = v:true
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

