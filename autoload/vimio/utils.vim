" autoload/vimio/utils.vim
" ---------------
" Collection of utility functions.
" Includes general functions such as character line processing, wide character 
" detection, and clipboard reading.
"
" Contents:
" - vimio#utils#get_reg(reg_name)
" - vimio#utils#get_current_paste_text(...)
" - vimio#utils#get_doublewidth_cols_new(row,...)
" - vimio#utils#get_doublewidth_cols_old(row,...)
" - vimio#utils#get_doublewidth_cols(row,...)
" - vimio#utils#get_line_cells(row,...)
" - vimio#utils#get_line_cells_insert_double_char(row,...)
" - vimio#utils#get_line_cells_common(row,...)
" - vimio#utils#get_plugin_root()
" - vimio#utils#set_line_str(line_list,line,jumpline,jumpcol)
" - vimio#utils#hide_cursor()
" - vimio#utils#restore_cursor()
" - vimio#utils#is_single_char_text(textlist)
" - vimio#utils#flat_list_equal(list1,list2)
" - vimio#utils#get_char(r,c)
" - vimio#utils#get_row_cells(row)
" - vimio#utils#get_row_cells_normal(row)
" - vimio#utils#get_row_cells_regex(row)
" - vimio#utils#uniq_nested_lists(list)
" - vimio#utils#resolve_coords(keys,coords)
" - vimio#utils#resolve_coords_excluding(keys,coords)
" - vimio#utils#build_graph(coords,keyfn)
" - vimio#utils#build_select_graph(coords)
" - vimio#utils#uniq_dicts_by_key(dicts)
" - vimio#utils#uniq_select_dicts(dicts)
" - vimio#utils#uniq_dicts_by(dicts,keyfn)
" - vimio#utils#merge_dicts(...)
" - vimio#utils#list_set_value_safe(list,index,value)
" - vimio#utils#list_get_item_screen_len(list,index)
" - vimio#utils#merge_sparse_values(dict1,dict2)
" - vimio#utils#get_sparse_intersections(dict1,dict2)
" - vimio#utils#build_preview_chars(text_lines,pos_start)
" - vimio#utils#get_rect_txt_for_single_width_char(preview_text,cross_enable,pos)
" - vimio#utils#get_editor_rect(pos,width,height,is_just_cross_char)
" - vimio#utils#chars_all_not_in(dict,list)
" - vimio#utils#chars_some_not_in(dict,list)
" - vimio#utils#chars_any_in(dict,list)
" - vimio#utils#cursor_jump(row,col)



function! vimio#utils#get_reg(reg_name)
    let regcontent = getreg(a:reg_name)
    let attempts = 0
    while empty(regcontent) && attempts < 20
        sleep 1m
        let regcontent = getreg(a:reg_name)
        let attempts += 1
    endwhile
    " echom "read reg: " . a:reg_name . "times: " . attempts . ';' 
    " TAB replace to 4 blanks
    return substitute(regcontent, '\t', '    ', 'g')
endfunction

function! vimio#utils#get_current_paste_text(...) abort
    " let t1 = reltime()
    let opts = get(a:, 1, {})
    let raw_str = get(opts, 'new_text', vimio#utils#get_reg('+'))
    " let t2 = reltime()
    let pos = get(opts, 'pos_start', [line('.'), virtcol('.')])
    let pop_up_type = get(opts, 'pop_up_type', g:vimio_config_visual_block_popup_types[g:vimio_state_visual_block_popup_types_index])

    let raw_lines = split(raw_str, "\n")
    " let t3 = reltime()
    if exists('g:vimio_state_paste_preview_cross_mode') && g:vimio_state_paste_preview_cross_mode
        let preview_opts = g:Vimio_BuildPreviewCharsFunc(raw_lines, v:true, pos)
        " let t3_0 = reltime()
        " let preview_opts_0 = vimio#utils#BuildPreviewChars(raw_lines, v:true, pos)
        " let t4 = reltime()
        let preview_chars_and_cross = g:Vimio_GetRectTxtForSingleWidthCharFunc([[]], v:true, pos, pop_up_type, preview_opts)
        " let t4_0 = reltime()
        " let preview_chars_and_cross_0 = vimio#utils#get_rect_txt_for_single_width_char([[]], v:true, pos, pop_up_type, preview_opts)
        " let t5 = reltime()

        " call vimio#debug#log(
        "             \ "get text from clip: %.2f;"
        "             \ . "text split to lines: %.2f;"
        "             \ . "prview chars new: %.2f;"
        "             \ . "prview chars old: %.2f;"
        "             \ . "get_rect_txt_for_single_width_char new: %.2f;"
        "             \ . "get_rect_txt_for_single_width_char old: %.2f;",
        "             \ vimio#debug#time_ms(t1, t2),
        "             \ vimio#debug#time_ms(t2, t3),
        "             \ vimio#debug#time_ms(t3, t3_0),
        "             \ vimio#debug#time_ms(t3_0, t4),
        "             \ vimio#debug#time_ms(t4, t4_0),
        "             \ vimio#debug#time_ms(t4_0, t5)
        "             \)

        " if preview_opts != preview_opts_0
        "     call vimio#debug#log('preview_opts diff! %s', 
        "                 \ vimio#debug#diff_pretty_lcs(preview_opts, preview_opts_0, 4, 1))
        " endif

        " if preview_chars_and_cross != preview_chars_and_cross_0
        "     call vimio#debug#log('preview_chars_and_cross diff! %s', 
        "                 \ vimio#debug#diff_pretty_lcs(preview_chars_and_cross, preview_chars_and_cross_0, 4, 1))
        " endif

        return preview_chars_and_cross
    endif
    " let t4 = reltime()
    " call vimio#debug#log(
    "             \ "get text from clip: %.2f;"
    "             \ . "text split to lines: %.2f;"
    "             \ . "no cross deal: %.2f;",
    "             \ vimio#debug#time_ms(t1, t2),
    "             \ vimio#debug#time_ms(t2, t3),
    "             \ vimio#debug#time_ms(t3, t4)
    "             \)
    return raw_str
endfunction


" Although this algorithm does not rely on character sets, 
" it is relatively slow.
function! vimio#utils#get_doublewidth_cols_new(row, ...) abort
    " Extract the line content for the given row
    let line = getline(a:row)

    " Count the number of characters (not bytes) in the line
    let charcount = strchars(line)

    " Prepare to map each character index to its byte offset
    let byteidx = 0
    let char_byte_offsets = []
    let chars = []

    " First pass: build a list of byte offsets for each character
    for charidx in range(charcount)
        call add(char_byte_offsets, byteidx)
        " Extract a single character correctly using the character index
        let ch = strcharpart(line, charidx, 1)
        call add(chars, ch)
        let byteidx += strlen(ch)
    endfor

    " Second pass: identify double-width characters and record their screen columns
    let l:cols = []
    for charidx in range(charcount)
        let ch = chars[charidx]
        
        " Performance-sensitive: faster than `get()` due to simpler control
        " flow & minimal function overhead
        let w = strdisplaywidth(ch)

        if w > 1
            let bidx = char_byte_offsets[charidx]
            call add(cols, virtcol([a:row, bidx + 1]))
        endif
    endfor

    return cols
endfunction

" Although it may not be entirely accurate, it is very fast.
function! vimio#utils#get_doublewidth_cols_old(row, ...)
    let l:cols = []
    let l:col = 1
    let l:line = get(a:, 1, getline(a:row))
    let l:len = len(l:line)

    let l:pattern = g:vimio_doublewidth_pattern

    while l:col <= l:len
        " Find the next matching character position
        let l:pos = matchstrpos(l:line, l:pattern, l:col - 1)
        if empty(l:pos) || l:pos[1] == -1
            break
        endif

        " Here, you must add 1 to make it a formal byte column.
        call add(l:cols, virtcol([a:row, l:pos[1]+1]))

        " :TODO: The 3 here is hardcoded, and can be changed later to len(pos[0])
        " Update the current column position, skipping matching characters
        let l:col = l:pos[1] + 3
    endwhile
    
    return l:cols
endfunction

" get_doublewidth_cols() - Shadow wrapper for validating the new implementation.
"
" This function runs both the old and new versions of get_doublewidth_cols,
" compares their results, and echoes a warning if they differ.
" It always returns the result from the old implementation to ensure stability.
function! vimio#utils#get_doublewidth_cols(row, ...) abort
    let l:args = [a:row] + a:000

    " let t1 = reltime()
    let l:old = call('vimio#utils#get_doublewidth_cols_old', l:args)
    " let t2 = reltime()
    " let l:new = call('vimio#utils#get_doublewidth_cols_new', l:args)
    " let t3 = reltime()

    " let time_old = reltimefloat(reltime(t1, t2)) * 1000
    " let time_new = reltimefloat(reltime(t2, t3)) * 1000
    " call vimio#debug#log("old: %.3f ms; new: %.3f ms", time_old, time_new)

    " if !vimio#utils#flat_list_equal(l:old, l:new)
    "     echom '[vimio] Mismatch in get_doublewidth_cols:'
    "     echom '   -> row: ' . a:row
    "     echom '   -> old: ' . string(l:old)
    "     echom '   -> new: ' . string(l:new)
    " endif

    return l:old
endfunction


function! vimio#utils#get_line_cells(row, ...) abort
    let args = [a:row] + a:000

    " let t1 = reltime()
    let l:old = call(g:Vimio_GetLineCellsFunc, args)
    " let t2 = reltime()
    " let l:new = call('vimio#utils#get_line_cells_common', args)
    " let t3 = reltime()

    " call vimio#debug#log("old:%.3f; new:%.3f;", 
    "             \ vimio#debug#time_ms(t1, t2),
    "             \ vimio#debug#time_ms(t2, t3))

    return l:old
endfunction


function! vimio#utils#get_line_cells_insert_double_char(row, ...)
    " In vim, virtcol returns the display column, taking into account the actual
    " display width of tabs and multibyte characters.
    " col returns a column based on bytes
    " virtcol2col Convert virtual column to byte column
    if a:row < 1 || a:row > line('$')
        return [[], 0]
    endif

    let line_str = getline(a:row)
    " Get the incoming phy_col parameter, and if not passed, use virtcol('').
    let phy_col = get(a:, 1, virtcol('.'))

    " virtcol([a:row, '$']) - 1 and strdisplaywidth(line_str) The execution efficiency is not necessarily higher.
    " There is no test at the moment
    let real_phy_width = virtcol([a:row, '$'])-1
    let max_width = max([phy_col, real_phy_width])

    let line_chars_array = split(line_str, '\zs')

    for insert_index in vimio#utils#get_doublewidth_cols(a:row, line_str)
        " Here, you must subtract 1 to get the real array index.
        call insert(line_chars_array, '', insert_index-1)
    endfor

    call extend(line_chars_array, repeat([' '], max_width-real_phy_width))
    return [line_chars_array, phy_col - 1]
endfunction

" this function is slow
function! vimio#utils#get_line_cells_common(row, ...)
    if a:row < 1 || a:row > line('$')
        return [[], 0]
    endif

    let phy_col = get(a:, 1, virtcol('.'))
    let cells = vimio#utils#get_row_cells(a:row)

    let chars = []
    for cell in cells
        call add(chars, cell.char)
    endfor

    let real_phy_width = virtcol([a:row, '$'])-1
    let max_width = max([phy_col, real_phy_width])
    call extend(chars, repeat([' '], max_width-real_phy_width))
    
    return [chars, phy_col - 1]
endfunction


function! vimio#utils#get_plugin_root() abort
    if exists('s:vimio_cached_plugin_root') && !empty(s:vimio_cached_plugin_root)
        return s:vimio_cached_plugin_root
    endif

    let plugin_file = globpath(&runtimepath, 'plugin/vimio.vim')
    let plugin_root = fnamemodify(plugin_file, ':h:h')

    let s:vimio_cached_plugin_root = plugin_root
    return plugin_root
endfunction

function! vimio#utils#set_line_str(line_list, line, jumpline, jumpcol)
    let line_str = join(a:line_list, '')
    call setline(a:line, line_str)
    " This is set to list directly.
    call cursor(a:jumpline, a:jumpcol)
endfunction

function! vimio#utils#hide_cursor() abort
    if exists('&guicursor') && !exists('g:vimio_state_saved_guicursor')
        let g:vimio_state_saved_guicursor = &guicursor

        let cursor_line = execute('silent! highlight Cursor')
        let lcursor_line = execute('silent! highlight lCursor')

        " :TODO: bug In certain cases, the output of an attribute may span multiple lines.
        " Cursor xxx guifg=bg guibg=fg
        "            links to JBCursor
        if cursor_line =~# 'links to'
            let g:vimio_state_saved_cursor_link = matchstr(cursor_line, 'links to \zs\S\+')
        else
            let g:vimio_state_saved_cursor_highlight = matchstr(cursor_line, 'xxx\s\+\zs.*')
        endif

        if lcursor_line =~# 'links to'
            let g:vimio_state_saved_lcursor_link = matchstr(lcursor_line, 'links to \zs\S\+')
        else
            let g:vimio_state_saved_lcursor_highlight = matchstr(lcursor_line, 'xxx\s\+\zs.*')
        endif

        highlight Cursor guifg=NONE guibg=NONE gui=NONE ctermfg=NONE ctermbg=NONE cterm=NONE
        highlight lCursor guifg=NONE guibg=NONE gui=NONE ctermfg=NONE ctermbg=NONE cterm=NONE
        let &guicursor = 'a:Cursor/lCursor'
    endif
endfunction

function! vimio#utils#restore_cursor() abort
    if exists('g:vimio_state_saved_cursor_link')
        execute 'highlight! link Cursor ' . g:vimio_state_saved_cursor_link
        unlet g:vimio_state_saved_cursor_link
    elseif exists('g:vimio_state_saved_cursor_highlight')
        execute 'highlight Cursor ' . g:vimio_state_saved_cursor_highlight
        unlet g:vimio_state_saved_cursor_highlight
    endif

    if exists('g:vimio_state_saved_lcursor_link')
        execute 'highlight! link lCursor ' . g:vimio_state_saved_lcursor_link
        unlet g:vimio_state_saved_lcursor_link
    elseif exists('g:vimio_state_saved_lcursor_highlight')
        execute 'highlight lCursor ' . g:vimio_state_saved_lcursor_highlight
        unlet g:vimio_state_saved_lcursor_highlight
    endif

    if exists('g:vimio_state_saved_guicursor')
        let &guicursor = g:vimio_state_saved_guicursor
        unlet g:vimio_state_saved_guicursor
    endif
endfunction

function! vimio#utils#is_single_char_text(textlist) abort
  return len(a:textlist) == 1 && strchars(a:textlist[0]) == 1
endfunction


" flat_list_equal() - Compare two flat (1-dimensional) lists for exact equality.
"
" This function checks whether two lists have the same length and contain
" the same elements in the same order. It is intended for simple, flat lists
" of strings or numbers. It does not support nested lists or dictionaries.
"
" Returns:
"   v:true  if the lists are equal
"   v:false if they differ in length or any element
function! vimio#utils#flat_list_equal(list1, list2) abort
    if len(a:list1) != len(a:list2)
        return v:false
    endif
    for i in range(len(a:list1))
        if a:list1[i] !=# a:list2[i]
            return v:false
        endif
    endfor
    return v:true
endfunction

" Get the character at row r, column c. Return '' if out of bounds
function! vimio#utils#get_char(r, c) abort
    if a:r < 1 || a:r > line('$')
        return ''
    endif
    let l = getline(a:r)
        if a:c < 1 || a:c > strlen(l)
        return ''
    endif
    return l[a:c - 1]
endfunction

function! vimio#utils#get_row_cells(row) abort
    let old = vimio#utils#get_row_cells_normal(a:row)
    " let new = vimio#utils#get_row_cells_regex(a:row)

    " call vimio#debug#log_obj('old', old, '----old----')
    " call vimio#debug#log_obj('new', new, '----new----')

    return old
endfunction


" The prerequisite for efficiency is that a single line of data should not
" contain too much characters.
function! vimio#utils#get_row_cells_normal(row) abort
    if a:row < 1 || a:row > line('$')
        return [[], []]
    endif

    let cells    = []

    " The current byte column, starting at 1
    let bcol = 1
    let screen_col = 1
    for ch in split(getline(a:row), '\zs')
        " Performance-sensitive: faster than `get()` due to simpler control
        " flow & minimal function overhead
        let w = strdisplaywidth(ch)

        call add(cells, {
                    \ 'row': a:row,
                    \ 'byte_col': bcol,
                    \ 'width': w,
                    \ 'char': ch,
                    \ 'screen_col': screen_col
                    \ })
        if w > 1
            " :TODO: screen_col + 1?
            call add(cells, {
                        \ 'row': a:row,
                        \ 'byte_col': bcol+1,
                        \ 'width': 0,
                        \ 'char': '',
                        \ 'screen_col': screen_col+1
                        \ })
        endif

        " Advance byte column
        let bcol += strlen(ch)
        let screen_col += w
    endfor

    return cells
endfunction


function! vimio#utils#get_row_cells_regex(row) abort
    if a:row < 1 || a:row > line('$')
        return [[], []]
    endif

    let cells = []
    let line_str = getline(a:row)

    " 字符分割
    let chars = split(line_str, '\zs')

    " 获取双宽字符的显示列号列表（VirtCol）
    let double_cols = vimio#utils#get_doublewidth_cols(a:row, line_str)
    " The obtained is the second half of the double-width character, perform a
    " subtract one operation.
    let double_cols = map(double_cols, 'v:val - 1')
    
    let double_col_set = {}
    for col in double_cols
        let double_col_set[col] = 1
    endfor

    " call vimio#debug#log_obj("double_cols", double_cols)
    " call vimio#debug#log_obj("double_col_set", double_col_set)

    let bcol = 1
    let screen_col = 1
    for ch in chars
        let virtcol = screen_col

        " 判断是否为双宽字符（根据屏幕列）
        if has_key(double_col_set, screen_col)
            call add(cells, {
                        \ 'row': a:row,
                        \ 'byte_col': bcol,
                        \ 'width': 2,
                        \ 'char': ch,
                        \ 'screen_col': screen_col
                        \ })
            call add(cells, {
                        \ 'row': a:row,
                        \ 'byte_col': bcol + 1,
                        \ 'width': 0,
                        \ 'char': '',
                        \ 'screen_col': screen_col + 1
                        \ })
        else
            call add(cells, {
                        \ 'row': a:row,
                        \ 'byte_col': bcol,
                        \ 'width': 1,
                        \ 'char': ch,
                        \ 'screen_col': screen_col
                        \ })
        endif

        let bcol += strlen(ch)
        let screen_col += has_key(double_col_set, virtcol) ? 2 : 1
    endfor

    return cells
endfunction


" Function: vimio#utils#uniq_nested_lists
" Purpose:
"   Removes duplicate nested lists (e.g., [[10, 5], [12, 3], [10, 5]]) from a list.
"   This is useful when working with coordinate pairs or other structured data.
"
" Parameters:
"   a:list - A list of nested lists (e.g., [[row, col], [row, col], ...])
"
" Returns:
"   A new list with duplicate nested lists removed.
"
" Example:
"   Input:  [[10, 5], [12, 3], [10, 5]]
"   Output: [[10, 5], [12, 3]]
function! vimio#utils#uniq_nested_lists(list) abort
  " Step 1: Make a copy of the input list to avoid modifying the original
  " Step 2: Convert each nested list to a string (e.g., [10, 5] → "[10, 5]")
  " Step 3: Use uniq() to remove duplicate strings
  " Step 4: Convert each string back to a list using eval()
  return map(
        \ uniq(map(copy(a:list), {_, v -> string(v)})),
        \ {_, s -> eval(s)}
        \ )
endfunction

" let keys = ['3,5', '4,6']
" let coords = [
"       \ {'row': 3, 'screen_col': 5, 'char': 'A', ...},
"       \ {'row': 4, 'screen_col': 6, 'char': 'B', ...},
"       \ {'row': 5, 'screen_col': 7, 'char': 'C', ...}
"       \ ]

" let result = vimio#utils#resolve_coords(keys, coords)
" result => [{'row': 3, 'screen_col': 5, 'char': 'A'}, {'row': 4, 'screen_col': 6, 'char': 'B'}]
function! vimio#utils#resolve_coords(keys, coords) abort
    let coord_map = {}
    for coord in a:coords
        let k = coord.row . ',' . coord.screen_col
        let coord_map[k] = coord
    endfor

    return map(copy(a:keys), 'copy(get(coord_map, v:val, {}))')
endfunction

"==============================================================================
" resolve_coords_excluding(keys, coords) abort
"==============================================================================
function! vimio#utils#resolve_coords_excluding(keys, coords) abort
    " 1) build a set of excluded keys
    let excluded = {}
    for k in a:keys
        let excluded[k] = 1
    endfor

    " 2) collect all coords whose 'row,screen_col' 不在 excluded 里
    let result = []
    for c in a:coords
        let key = c.row . ',' . c.screen_col
        if !has_key(excluded, key)
            call add(result, copy(c))
        endif
    endfor

    return result
endfunction


function! vimio#utils#build_graph(coords, keyfn) abort
    let graph = {}
    for coord in a:coords
        let key = call(a:keyfn, [coord])
        let graph[key] = []
    endfor
    return graph
endfunction


" Build an adjacency graph from a list of coordinate dictionaries.
" Each key is "row,screen_col", and the value is an empty list
" to be filled with neighbor keys later.
function! vimio#utils#build_select_graph(coords) abort
    return vimio#utils#build_graph(a:coords, {c -> c.row . ',' . c.screen_col})
endfunction


" Remove duplicate dictionaries based on selected keys (e.g., row + screen_col)
function! vimio#utils#uniq_dicts_by_key(dicts) abort
    let seen = {}
    let result = []

    for item in a:dicts
        let key = item.row . ',' . item.screen_col
        if !has_key(seen, key)
            let seen[key] = 1
            call add(result, item)
        endif
    endfor

    return result
endfunction

function! vimio#utils#uniq_select_dicts(dicts) abort
    return vimio#utils#uniq_dicts_by(a:dicts, {c -> c.row . ',' . c.screen_col})
endfunction


" Remove duplicate dictionaries based on a user-defined key function.
" Example: call uniq_dicts_by(cells, {c -> c.row . ',' . c.screen_col})
function! vimio#utils#uniq_dicts_by(dicts, keyfn) abort
    let seen = {}
    let result = []

    for item in a:dicts
        let key = call(a:keyfn, [item])
        if !has_key(seen, key)
            let seen[key] = 1
            call add(result, item)
        endif
    endfor

    return result
endfunction

function! vimio#utils#merge_dicts(...) abort
    let merged = {}
    for d in a:000
        call extend(merged, copy(d))
    endfor
    return merged
endfunction

" safe add list 
function! vimio#utils#list_set_value_safe(list, index, value)
    if len(a:list) <= a:index
        call extend(a:list, repeat([''], a:index + 1 - len(a:list)))
    endif
    let a:list[a:index] = a:value
endfunction

function! vimio#utils#list_get_item_screen_len(list, index)
    if len(a:list) <= a:index
        return 0
    endif
    return strdisplaywidth(a:list[a:index])
endfunction

function! vimio#utils#merge_sparse_values(dict1, dict2, pop_up_type) abort
    let result = {}

    " First, add all the key-value pairs from dict1.
    for key in keys(a:dict1)
        if has_key(g:vimio_config_draw_cross_chars, a:dict1[key])
            let result[key] = [a:dict1[key]]
        endif
    endfor

    " Only merge the keys in dict2 that are not present in dict1.
    if g:vimio_config_cross_algorithm == 'multi'
        for key in keys(a:dict2)
            if a:pop_up_type == 'cover' && has_key(a:dict1, key)
                continue
            endif
            let current = get(result, key, [])
            call add(current, a:dict2[key])
            let result[key] = current
        endfor
    else
        for key in keys(a:dict2)
            if !has_key(a:dict1, key)
                let result[key] = [a:dict2[key]]
            else
                if a:pop_up_type == 'overlay' && a:dict1[key] == ' '
                    let result[key] = [a:dict2[key]]
                endif
            endif
        endfor
    endif

    return result
endfunction

function! vimio#utils#get_sparse_intersections(dict1, dict2) abort
    let result = {}

    for key in keys(a:dict1)
        if has_key(a:dict2, key) && a:dict1[key] != ' '
            let result[key] = [a:dict1[key], a:dict2[key]]
        endif
    endfor

    return result
endfunction


" Generate a text matrix for preview
function! vimio#utils#BuildPreviewChars(text_lines, cross_enable, pos_start) abort
    let rect_opts = {
                \ 'min_row': a:pos_start[0], 'max_row': a:pos_start[0]+len(a:text_lines)-1,
                \ 'min_col': a:pos_start[1], 'max_col': a:pos_start[1]+max(map(copy(a:text_lines), 'strdisplaywidth(v:val)'))-1,
                \ 'rect': [], 'rect_cross_chars': {},
                \ }
    let row = a:pos_start[0]

    let rect = []
    let rect_cross_chars = {}
    let blank_row = repeat([' '], rect_opts.max_col - rect_opts.min_col + 1)
    for _ in range(rect_opts.min_row, rect_opts.max_row)
        call add(rect, copy(blank_row))
    endfor

    for line in a:text_lines
        let col = a:pos_start[1]
        
        let row_offset = row-rect_opts.min_row
        for char in split(line, '\zs')
            let width = strdisplaywidth(char)
            let rect[row_offset][col-rect_opts.min_col] = char

            if a:cross_enable
                let rect_cross_chars[row . ',' . col] = char
            end

            if width == 2
                let rect[row_offset][col+1-rect_opts.min_col] = ''
            endif

            let col += width
        endfor
        let row += 1
    endfor

    let rect_opts.rect = rect
    let rect_opts.rect_cross_chars = rect_cross_chars

    return rect_opts
endfunction


" preview_text
" [[5,6,'a'], [7,8,'b']]
" :TODO: The current graphics performance is slightly subpar, but it is still
"       acceptable. It can be optimized in the future.
function! vimio#utils#get_rect_txt_for_single_width_char(preview_text, cross_enable, pos, pop_up_type, ...) abort
    " let t0 = reltime()
    let opts = get(a:, 1, {})
    if !empty(opts)
        let rect = opts.rect
        let rect_cross_chars = opts.rect_cross_chars
        let min_row = opts.min_row
        let max_row = opts.max_row
        let min_col = opts.min_col
        let max_col = opts.max_col
    else
        let rows = map(copy(a:preview_text), 'v:val[0]')
        let cols = map(copy(a:preview_text), 'v:val[1]')
        let min_row = min(rows)
        let max_row = max(rows)
        let min_col = min(cols)
        let max_col = max(cols)
        " let t0_1 = reltime()

        let rect = []
        let rect_cross_chars = {}
        for _ in range(min_row, max_row)
            call add(rect, repeat([' '], max_col - min_col + 1))
        endfor
        " let t0_2 = reltime()

        for item in a:preview_text
            let [row, col, ch] = item
            let rect[row - min_row][col - min_col] = ch
            if a:cross_enable
                let rect_cross_chars[row . ',' . col] = ch
            end
        endfor
        " let t0_3 = reltime()
        " call vimio#debug#log(
        "             \ "before t0_1: %.2f;"
        "             \ . "before t0_2: %.2f;"
        "             \ . "before t0_3: %.2f;",
        "             \ vimio#debug#time_ms(t0, t0_1),
        "             \ vimio#debug#time_ms(t0_1, t0_2),
        "             \ vimio#debug#time_ms(t0_2, t0_3)
        "             \)
    endif

    if a:cross_enable
        " let t1 = reltime()
        let [pos_row, pos_col] = a:pos
        let min_row_ext = max([pos_row - 1, 1])
        let max_row_ext = min([pos_row + (max_row - min_row) + 1, line('$')])
        let min_col_ext = max([pos_col - 1, 1])
        let max_col_ext = pos_col + (max_col - min_col) + 1
        let editor_chars = vimio#utils#get_editor_rect(
                    \ [min_row_ext, min_col_ext],
                    \ max_col_ext - min_col_ext + 2,
                    \ max_row_ext - min_row_ext + 2,
                    \ v:true
                    \)
        " let t2 = reltime()
        let all_chars = vimio#utils#merge_sparse_values(rect_cross_chars, editor_chars, a:pop_up_type)
        " let t3 = reltime()
        let cross_point = vimio#utils#get_sparse_intersections(rect_cross_chars, editor_chars)
        " let t4 = reltime()
        let cross_chars = vimio#scene#get_cross_chars(cross_point, all_chars)
        " let t5 = reltime()

        for [key, ch] in items(cross_chars)
            let [r, c] = map(split(key, ','), 'str2nr(v:val)')
            let rect[r - min_row][c - min_col] = ch
        endfor
        " let t6 = reltime()
        " call vimio#debug#log(
        "             \ "before: %.2f;"
        "             \ . "filter_editor_chars: %.2f;"
        "             \ . "all_chars: %.2f;"
        "             \ . "cross_point: %.2f;"
        "             \ . "cross_chars: %.2f;"
        "             \ . "filter_rect: %.2f;",
        "             \ vimio#debug#time_ms(t0, t1),
        "             \ vimio#debug#time_ms(t1, t2),
        "             \ vimio#debug#time_ms(t2, t3),
        "             \ vimio#debug#time_ms(t3, t4),
        "             \ vimio#debug#time_ms(t4, t5),
        "             \ vimio#debug#time_ms(t5, t6)
        "             \)
    endif

    let lines = map(copy(rect), 'join(v:val, "")')
    return join(lines, "\n")
endfunction

function! vimio#utils#get_editor_rect(pos, width, height, is_just_cross_char) abort
    let [start_row, start_col] = a:pos
    let result = {}

    for row in range(start_row, start_row + a:height - 1)
        if row > line('$')
            continue
        endif

        let [chars, _] = vimio#utils#get_line_cells(row, start_col+a:width)
        let col = start_col
        for col in range(start_col, start_col+a:width-1)
            let ch = chars[col - 1]
            if a:is_just_cross_char && !has_key(g:vimio_config_draw_cross_chars, ch)
                continue
            endif
            let result[row . ',' . col] = ch
        endfor
    endfor

    " call vimio#debug#log_obj('result', result, 4, '--result--')
    return result
endfunction

" None of the characters in the list are in the dictionary.
function! vimio#utils#chars_all_not_in(dict, list) abort
    for ch in a:list
        if has_key(a:dict, ch)
            return 0
        endif
    endfor
    return 1
endfunction

" Check if any character in the list is NOT a key in the dictionary
function! vimio#utils#chars_some_not_in(dict, list) abort
    for ch in a:list
        if !has_key(a:dict, ch)
            return 1
        endif
    endfor
    return 0
endfunction

" Check if any character in the list IS a key in the dictionary
function! vimio#utils#chars_any_in(dict, list) abort
    for ch in a:list
        if has_key(a:dict, ch)
            return 1
        endif
    endfor
    return 0
endfunction

function! vimio#utils#cursor_jump(row, col) abort
    let [start_chars_arr, start_index] = vimio#utils#get_line_cells(a:row, a:col)
    let col_byte_start = len(join(start_chars_arr[0:start_index], ''))
    call cursor(a:row, col_byte_start)
endfunction

function! vimio#utils#get_window_coordinates() abort
    let coordinates = {}
    let coordinates.row_top = line('w0')
    let coordinates.row_bot = line('w$')
    let coordinates.row = line('.')
    let coordinates.virtcol_top = 4
    let coordinates.virtcol_bot = winwidth(0)
    let coordinates.virtcol = wincol()
    
    return coordinates
endfunction

function! vimio#utils#clean_lines(lines) abort
    " Remove trailing spaces at the end of each line
    let cleaned = map(a:lines, 'substitute(v:val, ''\s\+$'', '''', '''')')

    " Remove empty lines or lines consisting entirely of whitespace starting from the end.
    while !empty(cleaned) && cleaned[-1] =~ '^\s*$'
        call remove(cleaned, -1)
    endwhile

    return cleaned
endfunction

