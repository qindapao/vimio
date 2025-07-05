" autoload/vimio/cursors.vim
" -----------------
" Implementation of multi-cursor system.
" Support adding, removing, and clearing cursors, support mouse dragging to 
" add/remove cursors
" Also supports generating rectangular shapes from multi-cursor areas.
"
" Contents:
" - vimio#cursors#add_cursor(direction,...)
" - vimio#cursors#visual_block_add_cursor()
" - vimio#cursors#visual_block_remove_cursor()
" - vimio#cursors#remove_cursor(direction,...)
" - vimio#cursors#add_cursor_mouse_move_start()
" - vimio#cursors#remove_cursor_mouse_move_start()
" - vimio#cursors#disable_cursor_mouse_move()
" - vimio#cursors#clear_cursors()
" - vimio#cursors#create_rectangle_string(data,is_delate_ori_data,replace_char)
" - vimio#cursors#replace_highlight_group_to_clip()

"
" Function to add a cursor
function! vimio#cursors#add_cursor(direction, ...)
    let row = get(a:, 1, line('.'))
    let virtcol = get(a:, 2, virtcol('.'))
    let [chars_arr, index] = vimio#utils#get_line_cells(row, virtcol)
    let col = len(join(chars_arr[0:index], ''))

    let length = len(chars_arr[index])
    let dis_length = strdisplaywidth(chars_arr[index])
    if length == 0
        let length = len(chars_arr[index-1])
        let col -= 2
        let add_char = chars_arr[index-1]
        let add_row = row
        let add_col = virtcol - 1
    else
        if dis_length == 1 && length != 1
            let col -= 2
        endif
        let add_char = chars_arr[index]
        let add_row = row
        let add_col = virtcol
    endif

    " Check if the highlighted group exists and has not been cleared
    let l:highlight_info = execute('highlight VimioCursorsMultiCursor')
    if l:highlight_info =~ 'xxx cleared'
        " Redefine Highlight Group
        highlight VimioCursorsMultiCursor cterm=reverse gui=reverse guibg=Yellow guifg=Black
    endif

    let match_id = matchaddpos('VimioCursorsMultiCursor', [[row, col, length]])
    call add(g:vimio_state_multi_cursors, [add_char, add_row, add_col, match_id])

    if a:direction == 'l'
        normal! l
    elseif a:direction == 'h'
        normal! h
    elseif a:direction == 'j'
        normal! j
    elseif a:direction == 'k'
        normal! k
    endif
endfunction

function! vimio#cursors#visual_block_add_cursor() range
    let row_left = line("'<")
    let row_right = line("'>")
    let col_left= virtcol("'<")
    let col_right = virtcol("'>")

    for row in range(row_left, row_right)
        for col in range(col_left, col_right-1)
            let [chars_arr, index] = vimio#utils#get_line_cells(row, col)

            if strdisplaywidth(chars_arr[index]) != 2
                call vimio#cursors#add_cursor('null', row, col)
                call cursor(row, len(join(chars_arr[0:index], '')))
            endif
        endfor
    endfor
endfunction

function! vimio#cursors#visual_block_remove_cursor() range
    let row_left = line("'<")
    let row_right = line("'>")
    let col_left= virtcol("'<")
    let col_right = virtcol("'>")

    for row in range(row_left, row_right)
        for col in range(col_left, col_right-1)
            let [chars_arr, index] = vimio#utils#get_line_cells(row, col)

            if strdisplaywidth(chars_arr[index]) != 2
                call vimio#cursors#remove_cursor('null', row, col)
                call cursor(row, len(join(chars_arr[0:index], '')))
            endif
        endfor
    endfor

endfunction

" Function to remove a cursor
function! vimio#cursors#remove_cursor(direction, ...)
    let row = get(a:, 1, line('.'))
    let virtcol = get(a:, 2, virtcol('.'))
    let [chars_arr, index] = vimio#utils#get_line_cells(row, virtcol)

    let length = len(chars_arr[index])
    let new_multi_cursors = []
    for cursor in g:vimio_state_multi_cursors
        if length == 0
            if !(cursor[1] == row && cursor[2] == virtcol - 1)
                call add(new_multi_cursors, cursor)
            else
                call matchdelete(cursor[3])
            endif
        else
            if !(cursor[1] == row && cursor[2] == virtcol)
                call add(new_multi_cursors, cursor)
            else
                call matchdelete(cursor[3])
            endif
        endif
    endfor
    let g:vimio_state_multi_cursors = new_multi_cursors

    if a:direction == 'l'
        normal! l
    elseif a:direction == 'h'
        normal! h
    elseif a:direction == 'j'
        normal! j
    elseif a:direction == 'k'
        normal! k
    endif
endfunction

function! vimio#cursors#add_cursor_mouse_move_start()
    augroup VimioCursorsRemoveCursorMouseMove
        autocmd!
    augroup END

    set mouse=n

    augroup VimioCursorsAddCursorMouseMove
        autocmd!
        autocmd CursorMoved * call vimio#cursors#add_cursor('null')
    augroup END
endfunction

function! vimio#cursors#remove_cursor_mouse_move_start()
    augroup VimioCursorsAddCursorMouseMove
        autocmd!
    augroup END

    set mouse=n

    augroup VimioCursorsRemoveCursorMouseMove
        autocmd!
        autocmd CursorMoved * call vimio#cursors#remove_cursor('null')
    augroup END
endfunction

function! vimio#cursors#disable_cursor_mouse_move()
    augroup VimioCursorsRemoveCursorMouseMove
        autocmd!
    augroup END

    augroup VimioCursorsAddCursorMouseMove
        autocmd!
    augroup END
    
    set mouse=a
endfunction

" Function to delete all cursors
function! vimio#cursors#clear_cursors()
    let g:vimio_state_multi_cursors = []
    call clearmatches()
    augroup VimioCursorsAddCursorMouseMove
        autocmd!
    augroup END
    augroup VimioCursorsRemoveCursorMouseMove
        autocmd!
    augroup END
    set mouse=a
endfunction

function! vimio#cursors#create_rectangle_string(data, is_delate_ori_data, replace_char)
    " Get the minimum and maximum row and column of the rectangle
    let min_row = min(map(copy(a:data), 'v:val[1]'))
    let max_row = max(map(copy(a:data), 'v:val[1]'))
    let min_col = min(map(copy(a:data), 'v:val[2]'))
    let max_col = max(map(copy(a:data), 'v:val[2]'))

    " Initialize the rectangular string as a two-dimensional matrix
    let rectangle = []
    for i in range(min_row, max_row + 1)
        let row = []
        for j in range(min_col, max_col+1)
            call add(row, ' ')
        endfor
        call add(rectangle, row)
    endfor

    " Traverse the data and insert characters into the rectangular string
    for item in a:data
        let [char, row, col] = [item[0], item[1], item[2]]
        let rectangle[row - min_row][col - min_col] = char
        " 如果是宽字符那么后面的字符设置为空
        if strdisplaywidth(char) == 2
            let rectangle[row - min_row][col - min_col+1] = ''
        endif
    endfor

    " Convert a two-dimensional matrix to a string
    let result = []
    for row in rectangle
        let row = join(row, '')
        " :TODO: Here is a problem: after deleting all trailing spaces, the 
        " overwrite mode may also lack trailing padding spaces. So here, 
        " just delete the last space. The specific strategy can be adjusted 
        " according to the business.
        " let row = substitute(row, '\s\+$', '', '')
        let row = substitute(row, '\s$', '', '')
        call add(result, row)
    endfor

    " Put it into the clip register for drawing
    let @+ = join(result, "\n")

    " Delete original characters or not
    if a:is_delate_ori_data
        for item in a:data
            let [row, col] = [item[1], item[2]]
            call vimio#draw#line_eraser('null', row, col, a:replace_char)
        endfor
    endif

    call vimio#cursors#clear_cursors()

endfunction

" Replace the character in the highlighted character group with the first 
" character in the register (if the register is empty, replace it with a space)
function! vimio#cursors#replace_highlight_group_to_clip()
    let char = getreg('+')
    let char = empty(char) ? ' ' : strcharpart(char, 0, 1)
    call vimio#cursors#create_rectangle_string(g:vimio_state_multi_cursors, 1, char)
endfunction

