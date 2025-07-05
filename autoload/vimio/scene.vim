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

function! vimio#scene#unicode(up, down, left, right, char_category_indexs)
    for char_index in a:char_category_indexs
        if has_key(g:vimio_config_draw_index_map_left, char_index)
            if ! has_key(g:vimio_config_draw_cross_chars, a:left)
                return 0
            endif
            if ! has_key(g:vimio_config_draw_unicode_cross_chars[char_index], a:left)
                return 0
            endif
        elseif has_key(g:vimio_config_draw_index_map_right, char_index)
            if ! has_key(g:vimio_config_draw_cross_chars, a:right)
                return 0
            endif
            if ! has_key(g:vimio_config_draw_unicode_cross_chars[char_index], a:right)
                return 0
            endif
        elseif has_key(g:vimio_config_draw_index_map_up, char_index)
            if ! has_key(g:vimio_config_draw_cross_chars, a:up)
                return 0
            endif
            if ! has_key(g:vimio_config_draw_unicode_cross_chars[char_index], a:up)
                return 0
            endif
        else
            if ! has_key(g:vimio_config_draw_cross_chars, a:down)
                return 0
            endif
            if ! has_key(g:vimio_config_draw_unicode_cross_chars[char_index], a:down)
                return 0
            endif
        endif
    endfor

    return 1
endfunction

" Scenes suitable for drawing a plus sign
function! vimio#scene#cross(up, down, left, right, char_category_indexs)
    " Check whether the parameter is defined
    if a:up == '' || a:down == '' || a:left == '' || a:right == ''
        return 0
    endif

    " Dictionary defining valid characters
    let valid_chars = {
    \ 'up': {'|': 1, '.': 1, "'": 1, '+': 1, '^': 1, ')': 1},
    \ 'down': {'|': 1, '.': 1, "'": 1, '+': 1, 'v': 1, ')': 1},
    \ 'left': {'-': 1, '.': 1, "'": 1, '+': 1, '<': 1},
    \ 'right': {'-': 1, '.': 1, "'": 1, '+': 1, '>': 1}
    \ }

    return has_key(valid_chars['up'], a:up) && has_key(valid_chars['down'], a:down) && has_key(valid_chars['left'], a:left) && has_key(valid_chars['right'], a:right)
endfunction

" Drawing the scene of the point number
function! vimio#scene#dot(up, down, left, right, char_category_indexs)
    " Check whether the parameters are defined and meet the conditions.
    if ( a:up == '|' || a:up == ')' ) && ( a:down == '|' || a:down == ')' ) && a:left == '-' && a:right == '-'
        return 0
    endif

    " Check if the lower left or lower right satisfies the condition
    return ((a:left == '-' && ( a:down == '|' || a:down == ')' )) || (a:right == '-' && ( a:down == '|' || a:down == ')' )))
endfunction

" Draw a scene with single quotes
function! vimio#scene#apostrophe(up, down, left, right, char_category_indexs)
    if ((( a:up == '|' || a:up == ')' ) && a:right == '-') && ( a:down != '|' && a:down != ')' ))
        return 1
    endif

    return (( a:up == '|' || a:up == ')' ) && a:left == '-' && !(( a:down == '|' || a:down == ')' ) || ( a:right == '|' || a:right == ')' )))
endfunction

