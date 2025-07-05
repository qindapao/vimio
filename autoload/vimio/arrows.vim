" autoload/vimio/arrows.vim
" ----------------
" Arrow character mapping and automatic addition logic.
" Function that automatically inserts an arrow based on the direction of the 
" cursor movement.
"
" Contents:
" - vimio#arrows#get_arrow_char(pre_char, direction)
" - vimio#arrows#auto_add_arrow()

function! vimio#arrows#get_arrow_char(pre_char, direction)
    return get(get(g:vimio_config_arrow_chars_map, a:direction, {}), a:pre_char, '')
endfunction

" Automatic arrow addition function in drawing
function! vimio#arrows#auto_add_arrow()
    " Failed location record group
    call vimio#state#draw_line_auto_group_record_pre_pos_clear()
    " Determine the direction of movement
    if !exists("g:vimio_state_prev_cursor_pos")
        return
    endif

    let [row, col] = [line('.'), virtcol('.')]
    let [pre_row, pre_col] = g:vimio_state_prev_cursor_pos

    if pre_row == row && col > pre_col
        let direction = 'right'
    elseif pre_row == row && col < pre_col
        let direction = 'left'
    elseif pre_col == col && row > pre_row
        let direction = 'down'
        " To be consistent with the strategy on the left and right
        let row -= 1
    elseif pre_col == col && row < pre_row
        " To be consistent with the strategy on the left and right
        let direction = 'up'
        let row += 1
    else
        return
    endif

    " Get the character at the previous position
    let [chars_array, index] = vimio#utils#get_line_cells(pre_row, pre_col)
    let pre_char = chars_array[index]
    let arraw_char = vimio#arrows#get_arrow_char(pre_char, direction)
    if empty(arraw_char)
        return
    endif
    let [cur_chars_array, cur_index] = vimio#utils#get_line_cells(row, col)
    let cur_chars_array[index] = arraw_char
    let jumpcol = len(join(cur_chars_array[0:index], ''))
    call vimio#utils#set_line_str(cur_chars_array, row, row, jumpcol)
endfunction

