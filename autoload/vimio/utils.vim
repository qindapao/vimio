" autoload/vimio/utils.vim
" ---------------
" Collection of utility functions.
" Includes general functions such as character line processing, wide character 
" detection, and clipboard reading.
"
" Contents:
" - vimio#utils#get_reg(reg_name)
" - vimio#utils#get_doublewidth_cols(row,...)
" - vimio#utils#get_doublewidth_cols_old(row,...)
" - vimio#utils#get_doublewidth_cols_new(row,...)
" - vimio#utils#get_line_cells(row,...)
" - vimio#utils#get_plugin_root()
" - vimio#utils#set_line_str(line_list,line,jumpline,jumpcol)
" - vimio#utils#hide_cursor()
" - vimio#utils#restore_cursor()
" - vimio#utils#is_single_char_text(textlist)

function! vimio#utils#get_reg(reg_name)
    let regcontent = getreg(a:reg_name)
    let attempts = 0
    while empty(regcontent) && attempts < 20
        sleep 1m
        let regcontent = getreg(a:reg_name)
        let attempts += 1
    endwhile
    echo "read reg: " . a:reg_name . "times: " . attempts . ';' 
    return regcontent
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

    " \u1100-\u115F: Hangul alphabet
    " \u2E80-\u2EFF: CJK Radicals Supplement
    " \u2F00-\u2FDF: Kangxi radicals;
    " \u3000-\u303F: CJK punctuation marks;
    " \u31C0-\u31EF: CJK strokes;
    " \u3200-\u32FF: CJK letters and months
    " \u3300-\u33FF: CJK Special Characters (Date Merge)
    " \u3400-\u4DBF: CJK Unified Ideographs Extension-A
    " \u4DC0-\u4DFF: The Sixty-four Hexagrams of the I Ching
    " \u4E00-\u9FBF: CJK (Chinese, Japanese, Korean) Unified Ideographs
    " \uAC00-\uD7A3: Hangul phonetic system
    " \uF900-\uFAFF: CJK Compatibility Ideographs
    " \uFE30-\uFE4F: CJK Compatibility Symbols (vertical variant, underline, comma);
    " \uFF00-\uFFEF: Full-width ASCII, full-width Chinese and English punctuation, half-width katakana, half-width hiragana, half-width Korean letters;
    " \uFFE0-\uFFE6: Full-width symbols (such as full-width currency symbols)

    " Use regular expressions to match characters with a width of 2
    " let l:pattern = '[\u1100-\u115F\u2E80-\u2EFF\u2F00-\u2FDF\u3000-\u303F\u31C0-\u31EF\u3200-\u32FF\u3300-\u33FF\u3400-\u4DBF\u4DC0-\u4DFF\u4E00-\u9FFF\uAC00-\uD7A3\uF900-\uFAFF\uFE30-\uFE4F\uFF00-\uFF60\uFFE0-\uFFE6]'
    " The following is not rigorous but is fast and covers most cases.
    let l:pattern = '[\u1100-\u115F\u2E80-\uA4CF\uAC00-\uD7A3\uF900-\uFAFF\uFE30-\uFE4F\uFF00-\uFF60\uFFE0-\uFFE6]'

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

    let l:old = call('vimio#utils#get_line_cells_insert_double_char', args)
    " let l:new = call('vimio#utils#get_line_cells_common', args)
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
        " echom "[vimio] saved guicursor: " . g:vimio_state_saved_guicursor
        let g:vimio_state_saved_cursor_highlight = matchstr(execute('silent! highlight Cursor'), 'xxx\s\+\zs.*')
        let g:vimio_state_saved_lcursor_highlight = matchstr(execute('silent! highlight lCursor'), 'xxx\s\+\zs.*')
        highlight Cursor guifg=NONE guibg=NONE gui=NONE ctermfg=NONE ctermbg=NONE cterm=NONE
        highlight lCursor guifg=NONE guibg=NONE gui=NONE ctermfg=NONE ctermbg=NONE cterm=NONE 

        " Set the 'guicursor' option to make the cursor effectively invisible in all modes.
        " 'a' applies the setting to all modes (normal, insert, visual, etc.)
        " 'Cursor/lCursor' defines empty or minimal highlight groups for the cursor,
        " which can result in a hidden or transparent cursor depending on the environment.
        let &guicursor = 'a:Cursor/lCursor'
        " echom "[vimio] guicursor set to hidden"
    endif
endfunction

function! vimio#utils#restore_cursor() abort
    " echom "[vimio] restore_cursor called"
    if exists('g:vimio_state_saved_guicursor')
        if exists('g:vimio_state_saved_cursor_highlight')
            execute 'highlight Cursor ' . g:vimio_state_saved_cursor_highlight
            unlet g:vimio_state_saved_cursor_highlight
        endif

        if exists('g:vimio_state_saved_lcursor_highlight')
            execute 'highlight lCursor ' . g:vimio_state_saved_lcursor_highlight
            unlet g:vimio_state_saved_lcursor_highlight
        endif    

        " echom "[vimio] restoring guicursor: " . g:vimio_state_saved_guicursor
        let &guicursor = g:vimio_state_saved_guicursor
        unlet g:vimio_state_saved_guicursor
    " else
    "     echom "[vimio] g:vimio_state_saved_guicursor does not exist"
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

