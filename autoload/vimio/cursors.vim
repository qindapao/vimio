" autoload/vimio/cursors.vim
" -----------------
" Implementation of multi-cursor system.
" Support adding, removing, and clearing cursors, support mouse dragging to 
" add/remove cursors
" Also supports generating rectangular shapes from multi-cursor areas.
"
" Contents:
" - vimio#cursors#vhl_apply()
" - vimio#cursors#vhl_remove(...)
" - vimio#cursors#vhl_remove_all()
" - vimio#cursors#vrow_vcol_to_row_col(row,virtcol)
" - vimio#cursors#vhl_add(...)
" - vimio#cursors#vhl_add_screen_point(point)
" - vimio#cursors#vhl_add_points(points)
" - vimio#cursors#vhl_add_points_and_apply(points)
" - vimio#cursors#vhl_add_and_move(direction,...)
" - vimio#cursors#vhl_remove_and_move(direction,...)
" - vimio#cursors#visual_block_highlight_cell(row,screenCol)
" - vimio#cursors#visual_block_unhighlight_cell(row,screenCol)
" - vimio#cursors#visual_block_add_cursor()
" - vimio#cursors#visual_block_remove_cursor()
" - vimio#cursors#add_cursor_mouse_move_start()
" - vimio#cursors#remove_cursor_mouse_move_start()
" - vimio#cursors#disable_cursor_mouse_move()
" - vimio#cursors#clear_cursors()
" - vimio#cursors#create_rectangle_string(points,delete_original,replace_char,is_update_clip)
" - s:erase_original_batch(points,replace_char)
" - vimio#cursors#replace_highlight_group_to_clip()

let s:cursor_cross_cache = {}
let s:cursor_delete_cross_cache = {}

function! vimio#cursors#vhl_apply() abort
    if g:vimio_state_vhl_match_id !=# -1
        call matchdelete(g:vimio_state_vhl_match_id)
    endif
    if empty(g:vimio_state_vhl_segments)
        let g:vimio_state_vhl_match_id = -1
        return
    endif
    let t1 = reltime()
    let g:vimio_state_vhl_match_id = matchaddpos(
                \ 'VimioCursorsMultiCursor',
                \ g:vimio_state_vhl_segments
                \ )
    let t2 = reltime()
    " echomsg printf('⏱ vimio#cursors#vhl_apply: %.2f ms', reltimefloat(reltime(t1, t2)) * 1000)
endfunction

function! vimio#cursors#vhl_remove(...) abort
    " 1) Locate row & virtcol
    let row     = get(a:, 1, line('.'))
    let virtcol = get(a:, 2, virtcol('.'))

    " 2) Fetch cells & screen_cols
    let cells       = vimio#utils#get_row_cells(row)
    let screen_cols = map(copy(cells), 'v:val.screen_col')

    " 3) Find idx, handle wide-tail
    let idx = index(screen_cols, virtcol)
    if idx < 0
        return
    endif

    let is_double_width_char = v:false
    if cells[idx].width ==# 0 && idx > 0
        let idx -= 1
        let is_double_width_char = v:true
    elseif cells[idx].width > 1 && idx > 0
        let is_double_width_char = v:true
    endif

    let byte_col = cells[idx].byte_col
    let char_virtcol = cells[idx].screen_col

    " 4) Filter out this cursor from multi_cursors
    let g:vimio_state_multi_cursors = filter(
                \ g:vimio_state_multi_cursors,
                \ 'v:val[1] != row || v:val[2] != char_virtcol')
    if is_double_width_char
        let g:vimio_state_multi_cursors = filter(
                    \ g:vimio_state_multi_cursors,
                    \ 'v:val[1] != row || v:val[2] != char_virtcol+1')
    endif

    let g:vimio_state_vhl_segments = filter(
                \ g:vimio_state_vhl_segments,
                \ 'v:val[0] != row || v:val[1] != byte_col')

    " vimio#debug#log("vhl_remove called in (%d,%d)", row, virtcol)
    " vimio#debug#log_obj('vimio_state_vhl_segments', vimio_state_vhl_segments, '--vimio_state_vhl_segments--')
    " vimio#debug#log_obj('vimio_state_multi_cursors', vimio_state_multi_cursors, '--vimio_state_multi_cursors--')
endfunction



function! vimio#cursors#vhl_remove_all() abort
    let g:vimio_state_multi_cursors = []
    let g:vimio_state_vhl_segments = []
    call vimio#cursors#vhl_apply()
endfunction

function! vimio#cursors#vrow_vcol_to_row_col(row, virtcol) abort
    let [chars_arr, index] = vimio#utils#get_line_cells(a:row, a:virtcol)

    " Compute byte-column and highlight width
    let byte_col = len(join(chars_arr[0:index], ''))

    let ch_len = len(chars_arr[index])
    let dis_length = strdisplaywidth(chars_arr[index])

    " Handle second-half cells or multibyte quirks
    if ch_len == 0
        let ch_len = len(chars_arr[index-1])
        let byte_col -= 2
        let add_char = chars_arr[index-1]
        let add_row = a:row
        let add_col = a:virtcol - 1
    else
        " some multibyte chars report width 1 but length>1
        if dis_length == 1 && ch_len != 1
            let byte_col -= 2
        endif
        let add_char = chars_arr[index]
        let add_row = a:row
        let add_col = a:virtcol
    endif

    " The width of the highlight is the display width of the character.
    return [a:row, byte_col, dis_length, add_char, add_row, add_col]
endfunction

function! vimio#cursors#vhl_add(...) abort
    " 1) Locate row and virtcol arguments (or use cursor defaults)
    let row = get(a:, 1, line('.'))
    let virtcol = get(a:, 2, virtcol('.'))

    " 2) Fetch the raw cells for this row
    let cells = vimio#utils#get_row_cells(row)

    " 3) Find the cell whose screen_col matches virtcol
    let screen_cols = map(copy(cells), 'v:val.screen_col')


    let idx = index(screen_cols, virtcol)
    if idx < 0
        return
    endif

    let is_double_width_char = v:false
    " 3) If this is the second half of a wide character (width == 0), revert to the first half.
    if l:cells[l:idx].width ==# 0 && l:idx > 0
        let l:idx -= 1
        let is_double_width_char = v:true
    elseif l:cells[l:idx].width > 1 && idx > 0
        let is_double_width_char = v:true
    endif

    " 4) Extract cell info
    let cell       = cells[idx]

    " echomsg "cell: " . string(cell)
    let start_byte = cell.byte_col
    let disp_len   = strdisplaywidth(cell.char)

    call add(g:vimio_state_vhl_segments, [row, start_byte, disp_len])
    call add(g:vimio_state_multi_cursors, [cell.char, row, cell.screen_col, -1])
    if is_double_width_char
        call add(g:vimio_state_multi_cursors, ['', row, cell.screen_col+1, -1])
    endif

    " vimio#debug#log("vhl_add called in (%d,%d)", row, virtcol)
    " vimio#debug#log_obj('vimio_state_vhl_segments', vimio_state_vhl_segments, '--vimio_state_vhl_segments--')
    " vimio#debug#log_obj('vimio_state_multi_cursors', vimio_state_multi_cursors, '--vimio_state_multi_cursors--')
endfunction

function! vimio#cursors#vhl_add_screen_point(point) abort
    call add(g:vimio_state_vhl_segments, [a:point.row, a:point.byte_col, a:point.width])
    call add(g:vimio_state_multi_cursors, [a:point.char, a:point.row, a:point.screen_col, -1])
endfunction

function! vimio#cursors#vhl_add_points(points) abort
    for point in a:points
        call vimio#cursors#vhl_add_screen_point(point)
    endfor
endfunction

function! vimio#cursors#vhl_add_points_and_apply(points) abort
    let t1 = reltime()
    let unique_points = vimio#utils#uniq_select_dicts(a:points)
    let t2 = reltime()
    call vimio#cursors#vhl_add_points(unique_points)
    let t3 = reltime()
    " echomsg printf('⏱ uniq_nested_lists: %.2f ms', reltimefloat(reltime(t1, t2)) * 1000)
    " echomsg printf('⏱ vhl_add_points: %.2f ms', reltimefloat(reltime(t2, t3)) * 1000)
    call vimio#cursors#vhl_apply()
endfunction

function! vimio#cursors#vhl_add_and_move(direction, ...) abort
    let row = get(a:, 1, line('.'))
    let virtcol = get(a:, 2, virtcol('.'))

    call vimio#cursors#vhl_add(row, virtcol)
    call vimio#cursors#vhl_apply()

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

function! vimio#cursors#vhl_remove_and_move(direction, ...) abort
    let row = get(a:, 1, line('.'))
    let virtcol = get(a:, 2, virtcol('.'))

    call vimio#cursors#vhl_remove(row, virtcol)
    call vimio#cursors#vhl_apply()

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


" ============================================================================
" vimio#cursors#visual_block_highlight_cell(row, screenCol)
"
" Given a buffer line (row) and a Vim “screen column” (virtcol, 1-based),
" decide whether this cell should spawn a new cursor/highlight.
" This function:
"  1. Calls get_line_cells() to split the line into “screen cells”:
"     - Each ASCII or blank is one cell
"     - Each double-width char is two adjacent identical cells
"  2. Computes the zero-based index in the cells[] array for screenCol
"  3. Skips over the *first* half of any double-width char (width==2)
"     so we only add one cursor per wide char
"  4. If the cell is a “drawable” (non-blank, not first half of wide char),
"     calls add_cursor() to highlight it and places the real cursor
"     at the byte-column computed by get_line_cells()
"
" Parameters:
"   row        Vim buffer line number (1-based)
"   screenCol  Virtcol('.') value (1-based screen column)
"
" Usage:
"   for r in row_left .. row_right
"     for sc in col_left .. col_right-1
"       call vimio#cursors#visual_block_highlight_cell(r, sc)
"     endfor
"   endfor
" ============================================================================  
function! vimio#cursors#visual_block_highlight_cell(row, screenCol) abort
    " 1) Split the line into screen cells & find the array index
    let [cells, idx] = vimio#utils#get_line_cells(a:row, a:screenCol)

    " 2) Out-of-bounds guard
    if idx < 0 || idx >= len(cells)
        return
    endif

    " :TODO: may be change later
    " " 3) black skip highlight
    " if cells[idx] ==# ' '
    "     return
    " endif

    " 4) Only proceed if this cell is NOT the *first* half of a 2-width char
    if strdisplaywidth(cells[idx]) != 2
        " 5a) Delegate to add_cursor(): it handles
        "     - mapping screenCol→byteCol
        "     - computing highlight length
        "     - storing match_id in g:vimio_state_multi_cursors
        call vimio#cursors#vhl_add_and_move('null', a:row, a:screenCol)

        " 5b) Move the real cursor to the byte-column of this cell
        "     so subsequent operations (e.g. sel update) see the correct position
        call cursor(a:row, len(join(cells[0:idx], '')))
    endif
endfunction

function! vimio#cursors#visual_block_unhighlight_cell(row, screenCol) abort
    let [cells, idx] = vimio#utils#get_line_cells(a:row, a:screenCol)

    if idx < 0 || idx >= len(cells)
        return
    endif

    if strdisplaywidth(cells[idx]) != 2
        call vimio#cursors#vhl_remove_and_move('null', a:row, a:screenCol)
        call cursor(a:row, len(join(cells[0:idx], '')))
    endif
endfunction


" :TODO: function is very slow! Refer to select.vim
function! vimio#cursors#visual_block_add_cursor() range
    let row_left = line("'<")
    let row_right = line("'>")
    let col_left= virtcol("'<")
    let col_right = virtcol("'>")

    " call vimio#debug#log("visual_block_add_cursor: (%d->%d)", col_left, col_right)

    for row in range(row_left, row_right)
        for col in range(col_left, col_right-1)
            call vimio#cursors#visual_block_highlight_cell(row, col)
        endfor
    endfor
endfunction

" :TODO: function is very slow! Refer to select.vim
function! vimio#cursors#visual_block_remove_cursor() range
    let row_left = line("'<")
    let row_right = line("'>")
    let col_left= virtcol("'<")
    let col_right = virtcol("'>")

    for row in range(row_left, row_right)
        for col in range(col_left, col_right-1)
            call vimio#cursors#visual_block_unhighlight_cell(row, col)
        endfor
    endfor
endfunction

function! vimio#cursors#add_cursor_mouse_move_start()
    augroup VimioCursorsRemoveCursorMouseMove
        autocmd!
    augroup END

    set mouse=n

    augroup VimioCursorsAddCursorMouseMove
        autocmd!
        autocmd CursorMoved * call vimio#cursors#vhl_add_and_move('null')
    augroup END
endfunction

function! vimio#cursors#remove_cursor_mouse_move_start()
    augroup VimioCursorsAddCursorMouseMove
        autocmd!
    augroup END

    set mouse=n

    augroup VimioCursorsRemoveCursorMouseMove
        autocmd!
        autocmd CursorMoved * call vimio#cursors#vhl_remove_and_move('null')
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
    call vimio#cursors#vhl_remove_all()
    augroup VimioCursorsAddCursorMouseMove
        autocmd!
    augroup END
    augroup VimioCursorsRemoveCursorMouseMove
        autocmd!
    augroup END
    set mouse=a
endfunction

"==============================================================================
" Create a rectangular string from a set of (char, row, col) points,
" copy it to the clipboard, and optionally erase the originals in batch.
"==============================================================================


function! vimio#cursors#clear_cursor_cross_cache() abort
    let s:cursor_cross_cache = {}
    let s:cursor_delete_cross_cache = {}
endfunction

" Generate a rectangular text through several points.
function! vimio#cursors#create_rectangle_string_only(points) abort
    " 1) Compute bounding box
    let rows    = map(copy(a:points), 'v:val[1]')
    let cols    = map(copy(a:points), 'v:val[2]')
    let min_row = min(rows)
    let max_row = max(rows)
    let min_col = min(cols)
    let max_col = max(cols)

    " 2) Build an empty matrix of spaces
    let height = max_row - min_row + 1
    let width  = (max_col - min_col + 1) + 1
    let matrix = []
    for _ in range(height)
        let row = []
        for _ in range(width)
            call add(row, ' ')
        endfor
        call add(matrix, row)
    endfor

    " 3) Fill in characters, with lazy width check
    for pt in a:points
        let ch = pt[0]
        let r  = pt[1] - min_row
        let c  = pt[2] - min_col
        let matrix[r][c] = ch

        let w = strdisplaywidth(ch)
        if w ==# 2
            let matrix[r][c+1] = ''
        endif
    endfor

    " 4) Convert each row of the matrix into a string
    let lines = []
    for row in matrix
        let line = join(row, '')
        " remove exactly one trailing space
        let line = substitute(line, '\s$', '', '')
        call add(lines, line)
    endfor

    return [ lines, min_row, min_col ]
endfunction

" Update the characters in list1 based on the coordinates in list2.
" let list1 = [['a', 5, 19], ['b', 4, 1]]
" let list2 = [['x', 5, 19], ['b', 6, 9]]
" let result = UpdateListWithOverlay(list1, list2)
" result:
"   [['x', 5, 19], ['b', 4, 1]]
function! s:UpdateListWithOverlay(list1, list2)
    for item2 in a:list2
        let char2 = item2[0]
        let x2 = item2[1]
        let y2 = item2[2]

        for i in range(len(a:list1))
            let item1 = a:list1[i]
            if item1[1] == x2 && item1[2] == y2
                let a:list1[i][0] = char2
            endif
        endfor
    endfor
    return a:list1
endfunction


function! vimio#cursors#create_rectangle_string(points, delete_original, replace_char, is_update_clip) abort

    let [lines, min_row, min_col] = vimio#cursors#create_rectangle_string_only(a:points)

    let lines_str = join(lines, "\n")
    if a:is_update_clip
        let @+ = lines_str
    endif

    " If it is in cross-replacement mode, then the intersection situation
    " for each point needs to be calculated.
    let cross_points = []
    if g:vimio_state_paste_preview_cross_mode
        call vimio#scene#calculate_cross_points(
                    \ a:points,
                    \ s:cursor_cross_cache,
                    \ g:vimio_config_draw_normal_char_funcs_map,
                    \ g:vimio_config_draw_cross_styles,
                    \ g:vimio_state_cross_style_index,
                    \ cross_points
                    \ )
    endif

    " If the cursor is different before and after deletion, 
    " then a jump to locate is required.
    let cursor_before = [ line('.'), virtcol('.') ]
    if a:delete_original
        call s:erase_original_batch(a:points, a:replace_char)
    endif

    if g:vimio_state_paste_preview_cross_mode

        let cross_points_after = []
        let combined_table = g:vimio_config_draw_normal_char_funcs_map + g:vimio_config_draw_delete_chars_funcs_map
        if a:delete_original
            call vimio#scene#calculate_cross_points(
                        \ cross_points,
                        \ s:cursor_delete_cross_cache,
                        \ combined_table,
                        \ g:vimio_config_draw_cross_styles,
                        \ g:vimio_state_cross_style_index,
                        \ cross_points_after
                        \ )

            if len(cross_points_after) != 0
                " The new crossover character is pasted back in place.
                let [lines_cross, min_row_cross, min_col_cross] = vimio#cursors#create_rectangle_string_only(cross_points_after)
                call vimio#replace#paste_block_clip(0, {
                            \ 'new_text': join(lines_cross, "\n"),
                            \ 'pos_start': [min_row_cross, min_col_cross]
                            \})
            endif
        endif

        " The points in the clipboard also need to be updated.
        let cross_preview = []
        call vimio#scene#calculate_cross_points(
                    \ cross_points,
                    \ s:cursor_delete_cross_cache,
                    \ combined_table,
                    \ g:vimio_config_draw_cross_styles,
                    \ g:vimio_state_cross_style_index,
                    \ cross_preview,
                    \ a:points,
                    \ )

        let cross_preview_after = s:UpdateListWithOverlay(a:points, cross_preview)
        let [lines, min_row, min_col] = vimio#cursors#create_rectangle_string_only(cross_preview_after)

        let lines_str = join(lines, "\n")
        if a:is_update_clip
            let @+ = lines_str
        endif

        let cursor_after = [ line('.'), virtcol('.') ]
        if !vimio#utils#flat_list_equal(cursor_before, cursor_after)
            call vimio#utils#cursor_jump(cursor_before[0], cursor_before[1])
        endif
    endif

    " 7) Clear any temporary cursors
    call vimio#cursors#clear_cursors()
    return [lines_str, min_row, min_col]
endfunction


"==============================================================================
" Batch-erase a list of (char,row,virtcol) points, per-row, one setline each.
"==============================================================================
function! s:erase_original_batch(points, replace_char) abort
    if empty(a:points)
        return
    endif

    " 1) Group points by row (dict key is string of row number)
    let row_map = {}
    for pt in a:points
        if type(pt) !=# v:t_list || len(pt) < 3
            continue
        endif
        let ch  = pt[0]
        let row = pt[1]
        let vc  = pt[2]
        let key = string(row)
        if !has_key(row_map, key)
            let row_map[key] = []
        endif
        call add(row_map[key], [ch, vc])
    endfor

    " 2) Process each row once
    for key in keys(row_map)
        let row  = str2nr(key)
        let pts  = row_map[key]
        let cells       = vimio#utils#get_row_cells(row)
        let screen_cols = map(copy(cells), 'v:val.screen_col')
        let cell_cnt    = len(cells)

        " overwrite each target cell
        for pair in pts
            let ch = pair[0]
            let vc = pair[1]
            let idx = index(screen_cols, vc)
            if idx < 0
                continue
            endif

            " compute widths (lazy ASCII-fast check)
            let old_w = strdisplaywidth(cells[idx].char)

            " overwrite main cell: always one replace_char
            let cells[idx].char = a:replace_char

            " if it was a double-width char, clear its trailing slot
            if old_w ==# 2
                let tail = idx + 1
                if tail < cell_cnt
                    let cells[tail].char = ''
                endif
            endif
        endfor

        " 3) Write back the entire row once
        let new_line = join(map(cells, 'v:val.char'), '')
        call setline(row, new_line)
    endfor
endfunction

" Replace the character in the highlighted character group with the first 
" character in the register (if the register is empty, replace it with a space)
function! vimio#cursors#replace_highlight_group_to_clip()
    let char = getreg('+')
    let char = empty(char) ? ' ' : strcharpart(char, 0, 1)
    call vimio#cursors#create_rectangle_string(g:vimio_state_multi_cursors, 1, char, 1)
endfunction

