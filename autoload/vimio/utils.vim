" autoload/vimio/utils.vim
" ---------------
" Collection of utility functions.
" Includes general functions such as character line processing, wide character 
" detection, and clipboard reading.
"
" Contents:
" - vimio#utils#get_reg(reg_name)
" - vimio#utils#get_doublewidth_cols(row,...)
" - vimio#utils#get_line_cells(row,...)
" - vimio#utils#get_plugin_root()
" - vimio#utils#set_line_str(line_list,line,jumpline,jumpcol)

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

function! vimio#utils#get_doublewidth_cols(row, ...)
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

function! vimio#utils#get_line_cells(row, ...)
    " In vim, virtcol returns the display column, taking into account the actual
    " display width of tabs and multibyte characters.
    " col returns a column based on bytes
    " virtcol2col Convert virtual column to byte column
    if a:row < 0
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

