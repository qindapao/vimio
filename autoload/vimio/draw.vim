" autoload/vimio/draw.vim
" --------------
" Drawing core logic.
" Includes horizontal, vertical, and diagonal drawing functions, eraser 
" function, and boundary character judgment logic.
"
" Contents:
" - vimio#draw#line_left_right(direction)
" - vimio#draw#line_eraser(direction,...)
" - vimio#draw#line_up_down(direction)
" - vimio#draw#traverse_rectangle()
" - vimio#draw#draw_slash_line(direction)

" Draw a line and decide on the border characters
" :TODO: The drawing mode cannot handle tabs. If there are tabs in the text, 
"       they need to be removed first.
" :TODO: The following should be extracted as a UI module (user behavior key 
"       binding) draw (drawing behavior)
function! vimio#draw#line_left_right(direction)
    " let start_time = reltime()
    call vimio#state#draw_line_auto_group_record_pre_pos_set()
    let row = line('.')
    " :TODO: Does not support Arabic or other languages with zero width characters

    let [line_chars_array, index] = vimio#utils#get_line_cells(row)

    if strdisplaywidth(line_chars_array[index]) == 0
        " CJK first replaced with two spaces
        let line_chars_array[index-1] = ' '
        let line_chars_array[index] = ' '
        if a:direction == 'l'
            let index -= 1
        endif
    endif

    let [up_line_chars_array, up_index] = vimio#utils#get_line_cells(row-1)
    let [down_line_chars_array, down_index] = vimio#utils#get_line_cells(row+1)

    let col = len(join(line_chars_array[0:index], ''))

    " Get the character above, below, left, and right of the previous character
    if a:direction == 'l'
        let pre_right = g:vimio_config_draw_line_styles[g:vimio_state_draw_line_index][0]
        let pre_left = (index>1)?get(line_chars_array, index-2, ''):''
        let pre_up = (up_index>0)?get(up_line_chars_array, up_index-1, ''):''
        let pre_down = (down_index>0)?get(down_line_chars_array, down_index-1, ''):''
    elseif a:direction == 'h'
        let pre_left = g:vimio_config_draw_line_styles[g:vimio_state_draw_line_index][0]
        let pre_right = get(line_chars_array, index+2, '')
        let pre_up = get(up_line_chars_array, up_index+1, '')
        let pre_down = get(down_line_chars_array, down_index+1, '')
    endif

    let pre_index = index + (a:direction == 'l' ? -1 : 1)
    if pre_index >= 0 && pre_index < len(line_chars_array)
        let pre_char = line_chars_array[index+(a:direction=='l'?-1:1)]
        if has_key(g:vimio_config_draw_cross_chars, pre_char)
            for table_param in g:vimio_config_draw_normal_char_funcs_map
                if call(table_param[1], [pre_up, pre_down, pre_left, pre_right, table_param[2]])
                    if has_key(g:vimio_config_draw_cross_styles[g:vimio_state_cross_style_index], table_param[0])
                        let line_chars_array[pre_index] = g:vimio_config_draw_cross_styles[g:vimio_state_cross_style_index][table_param[0]]
                    else
                        let line_chars_array[pre_index] = table_param[0]
                    endif
                    call vimio#utils#set_line_str(line_chars_array, row, row, col)
                    break
                endif
            endfor
        endif
    endif

    " Get the character above, below, left, and right of the current character
    let left = (index>0)?get(line_chars_array, index-1, ''):''
    let right = get(line_chars_array, index+1, '')
    let up = get(up_line_chars_array, up_index, '')
    let down = get(down_line_chars_array, down_index, '')

    let entered_if = 0
    for table_param in g:vimio_config_draw_normal_char_funcs_map
        if call(table_param[1], [up, down, left, right, table_param[2]])
            if has_key(g:vimio_config_draw_cross_styles[g:vimio_state_cross_style_index], table_param[0])
                let line_chars_array[index] = g:vimio_config_draw_cross_styles[g:vimio_state_cross_style_index][table_param[0]]
            else
                let line_chars_array[index] = table_param[0]
            endif
            let entered_if = 1
            break
        endif
    endfor

    if entered_if == 0
        let line_chars_array[index] = g:vimio_config_draw_line_styles[g:vimio_state_draw_line_index][0]
    endif

    let col = len(join(line_chars_array[0:index], ''))

    call vimio#utils#set_line_str(line_chars_array, row, row, (a:direction=='l')?col+1:col-len(line_chars_array[index]))
    " let elapsed_time = reltimefloat(reltime(start_time)) * 1000
    " echo "left right exec time: " . elapsed_time . " ms"
endfunction

function! vimio#draw#line_eraser(direction, ...)

    let row = get(a:, 1, line('.'))
    let virtcol = get(a:, 2, virtcol('.'))
    " By default, the eraser replaces spaces. If a character is passed, the passed character is used.
    let replace_char = get(a:, 3, ' ')

    let [line_chars_arr, index] = vimio#utils#get_line_cells(row, virtcol)
    let [up_line_chars_arr, up_index] = vimio#utils#get_line_cells(row-1, virtcol)
    let [down_line_chars_arr, down_index] = vimio#utils#get_line_cells(row+1, virtcol)

    let index_char_phylen = strdisplaywidth(line_chars_arr[index])
    if index_char_phylen == 2
        if strdisplaywidth(replace_char) == 2
            let line_chars_arr[index] = replace_char
        else
            let line_chars_arr[index] = repeat(replace_char, 2)
        endif
    elseif index_char_phylen == 1
        if strdisplaywidth(replace_char) == 2
            let line_chars_arr[index] = replace_char
            let line_chars_arr[index+1] = ''
        else
            let line_chars_arr[index] = replace_char
        endif
    elseif index_char_phylen == 0
        if strdisplaywidth(replace_char) == 2
            let line_chars_arr[index-1] = replace_char
        else
            let line_chars_arr[index-1] = repeat(replace_char, 2)
        endif
    endif

    call setline(row, join(line_chars_arr, ''))

    if a:direction != 'null'
        let [line_chars_arr, index] = vimio#utils#get_line_cells(row, virtcol)
        let [up_line_chars_arr, up_index] = vimio#utils#get_line_cells(row-1, virtcol)
        let [down_line_chars_arr, down_index] = vimio#utils#get_line_cells(row+1, virtcol)
        let col = len(join(line_chars_arr[0:index], ''))

        if a:direction == 'l'
            call cursor(row, col+1)
        elseif a:direction == 'h'
            call cursor(row, col-1)
        elseif a:direction == 'j'
            let next_col = len(join(down_line_chars_arr[0:down_index], ''))
            call cursor(row+1, next_col)
        elseif a:direction == 'k'
            let next_col = len(join(up_line_chars_arr[0:up_index], ''))
            call cursor(row-1, next_col)
        endif
    endif
endfunction


function! vimio#draw#line_up_down(direction)
    " let start_time = reltime()
    call vimio#state#draw_line_auto_group_record_pre_pos_set()
    let row = line('.')

    let [line_chars_array, index] = vimio#utils#get_line_cells(row)

    if strdisplaywidth(line_chars_array[index]) == 0
        let line_chars_array[index-1] = ' '
        let line_chars_array[index] = ' '

        if exists("g:vimio_state_prev_cursor_pos")
            let cur_col = virtcol('.')
            let [prev_row, prev_col] = g:vimio_state_prev_cursor_pos
            if prev_col != cur_col
                let index -= 1
                " And fix the current column (this implementation is very strange, 
                " so it is best to manually delete the Chinese characters first)
                " This is to prevent vimio#state#draw_line_record_pre_pos get vimio_state_current_cursor_pos
                let g:vimio_state_current_cursor_pos = copy(g:vimio_state_prev_cursor_pos)
            endif
        endif
    endif


    let [up1_line_chars_array, up1_index] = vimio#utils#get_line_cells(row-1)
    let [up2_line_chars_array, up2_index] = vimio#utils#get_line_cells(row-2)
    let [down1_line_chars_array, down1_index] = vimio#utils#get_line_cells(row+1)
    let [down2_line_chars_array, down2_index] = vimio#utils#get_line_cells(row+2)

    " Get the character above, below, left, and right of the previous character
    if a:direction == 'j'
        let pre_down = g:vimio_config_draw_line_styles[g:vimio_state_draw_line_index][1]
        let pre_up = get(up2_line_chars_array, up2_index, '')
        let pre_left = (up1_index>0)?get(up1_line_chars_array, up1_index-1, ''):''
        let pre_right = get(up1_line_chars_array, up1_index+1, '')
    elseif a:direction == 'k'
        let pre_down = get(down2_line_chars_array, down2_index, '')
        let pre_up = g:vimio_config_draw_line_styles[g:vimio_state_draw_line_index][1]
        let pre_left = (index>0)?get(down1_line_chars_array, down1_index-1, ''):''
        let pre_right = get(down1_line_chars_array, down1_index+1, '')
    endif

    if a:direction == 'j'
        let pre_char = get(up1_line_chars_array, up1_index, '')
    else
        let pre_char = get(down1_line_chars_array, down1_index, '')
    endif

    if has_key(g:vimio_config_draw_cross_chars, pre_char)

        let entered_if = 0
        for table_param in g:vimio_config_draw_normal_char_funcs_map
            if call(table_param[1], [pre_up, pre_down, pre_left, pre_right, table_param[2]])
                if has_key(g:vimio_config_draw_cross_styles[g:vimio_state_cross_style_index], table_param[0])
                    let result_char = g:vimio_config_draw_cross_styles[g:vimio_state_cross_style_index][table_param[0]]
                else
                    let result_char = table_param[0]
                endif
                let entered_if = 1
                break
            endif
        endfor

        if entered_if == 1
            if a:direction == 'j'
                if row > 0
                    let up1_line_chars_array[up1_index] = result_char
                    call vimio#utils#set_line_str(up1_line_chars_array, row-1, row, len(join(up1_line_chars_array[0:up1_index], '')))
                endif
            else
                let down1_line_chars_array[down1_index] = result_char
                call vimio#utils#set_line_str(down1_line_chars_array, row+1, row, len(join(down1_line_chars_array[0:down1_index], '')))
            endif
        endif
    endif

    " Get the character above, below, left, and right of the current character
    let down = get(down1_line_chars_array, down1_index, '')
    let up = get(up1_line_chars_array, up1_index, '')
    let left = (index>0)?get(line_chars_array, index-1, ''):''
    let right = get(line_chars_array, index+1, '')

    let entered_if = 0
    for table_param in g:vimio_config_draw_normal_char_funcs_map
        if call(table_param[1], [up, down, left, right, table_param[2]])
            if has_key(g:vimio_config_draw_cross_styles[g:vimio_state_cross_style_index], table_param[0])
                let line_chars_array[index] = g:vimio_config_draw_cross_styles[g:vimio_state_cross_style_index][table_param[0]]
            else
                let line_chars_array[index] = table_param[0]
            endif
            let entered_if = 1
            break
        endif
    endfor

    if entered_if == 0
        let line_chars_array[index] = g:vimio_config_draw_line_styles[g:vimio_state_draw_line_index][1]
    endif

    if a:direction == 'j'
        let next_col = len(join(down1_line_chars_array[0:down1_index], ''))
        let set_row = row+1
    else
        let next_col = len(join(up1_line_chars_array[0:up1_index], ''))
        let set_row = row-1
    endif

    call vimio#utils#set_line_str(line_chars_array, row, set_row, next_col)
    " let elapsed_time = reltimefloat(reltime(start_time)) * 1000
    " echo "up down exec time: " . elapsed_time . " ms"
endfunction

function! vimio#draw#traverse_rectangle()
    " Get the start and end positions of the selected visual block
    let [line_start, col_start] = [g:vimio_state_initial_pos_before_enter_visual[0], g:vimio_state_initial_pos_before_enter_visual[1]]
    
    let line_left = line("'<")
    let line_right = line("'>")
    let line_end = (line_left==line_start)?line_right:line_left

    let col_left= virtcol("'<")
    let col_right = virtcol("'>")
    let col_end = (col_left==col_start)?col_right:col_left

    let [start_chars_arr, start_index] = vimio#utils#get_line_cells(line_start, col_start)
    let col_byte_start = len(join(start_chars_arr[0:start_index], ''))
    call cursor(line_start, col_byte_start)

    " Downward
    if col_start == col_end && line_start < line_end
        for col in range(line_start, line_end - 1)
            call vimio#draw#line_up_down('j')
        endfor
        call vimio#draw#line_up_down('k')
        call vimio#draw#line_up_down('j')
    " Upward
    elseif col_start == col_end && line_start > line_end
        for col in range(line_end, line_start - 1)
            call vimio#draw#line_up_down('k')
        endfor
        call vimio#draw#line_up_down('j')
        call vimio#draw#line_up_down('k')
    " Turn right
    elseif line_start == line_end && col_start < col_end
        for col in range(col_start, col_end - 2)
            call vimio#draw#line_left_right('l')
        endfor
        call vimio#draw#line_left_right('h')
        call vimio#draw#line_left_right('l')
    " Turn left
    elseif line_start == line_end && col_start > col_end
        for col in range(col_end, col_start - 2)
            call vimio#draw#line_left_right('h')
        endfor
        call vimio#draw#line_left_right('l')
        call vimio#draw#line_left_right('h')
    " Rectangle to the right
    elseif line_start < line_end && col_start < col_end
        " Right bottom left top
        for col in range(col_start, col_end - 2)
            call vimio#draw#line_left_right('l')
        endfor
        for col in range(line_start, line_end - 1)
            call vimio#draw#line_up_down('j')
        endfor
        for col in range(col_start, col_end - 2)
            call vimio#draw#line_left_right('h')
        endfor
        for col in range(line_start, line_end - 1)
            call vimio#draw#line_up_down('k')
        endfor
        call vimio#draw#line_left_right('l')
        call vimio#draw#line_left_right('h')
    else
        " Left top, right bottom
        for col in range(col_end, col_start - 2)
            call vimio#draw#line_left_right('h')
        endfor
        for col in range(line_end, line_start - 1)
            call vimio#draw#line_up_down('k')
        endfor
        for col in range(col_end, col_start - 2)
            call vimio#draw#line_left_right('l')
        endfor
        for col in range(line_end, line_start - 1)
            call vimio#draw#line_up_down('j')
        endfor
        call vimio#draw#line_left_right('h')
        call vimio#draw#line_left_right('l')
    endif
endfunction

" :TODO: If a more suitable connecting character is found in the future, the 
" intersection character of a diagonal line and a straight line or two diagonal 
" lines can be determined based on the orientation of the last three 
" coordinates, similar to the principle of automatic arrows, but it might be 
" too complex, so it is not implemented for drawing diagonal lines 
" (a simple direct implementation is used).
function! vimio#draw#draw_slash_line(direction)
    if a:direction == 'u'
        normal! h
        normal! k
        normal! r\
    elseif a:direction == 'n'
        normal! h
        normal! j
        normal! r/
    elseif a:direction == 'i'
        normal! l
        normal! k
        normal! r/
    elseif a:direction == 'm'
        normal! l
        normal! j
        normal! r\
    endif
endfunction

