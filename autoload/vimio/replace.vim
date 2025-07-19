" autoload/vimio/replace.vim
" -----------------
" Character replacement and paste logic.
" Includes clipboard-based character paste, visual area replacement, and 
" character replacement under the cursor.
"
" Contents:
" - vimio#replace#paste_block_clip(is_space_replace)
" - vimio#replace#replace_char_under_cursor_from_clip(direction)
" - vimio#replace#visual_replace_to_space()
" - vimio#replace#visual_replace_char()

function! vimio#replace#paste_block_clip(is_space_replace, ...)
    let opts = get(a:, 1, {})
    " Get data from the clip register
    let regcontent = vimio#utils#get_current_paste_text(opts)

    let reg_text = split(regcontent, "\n")

    " Empty elements are filled with a space
    for i in range(len(reg_text))
        if empty(reg_text[i])
            let reg_text[i] = ' '
        endif
    endfor

    " Obtain a character array based on physical rows. If it is a wide 
    " character, place two copies, but only take one copy when merging. This is 
    " a two-dimensional array, where the first dimension is the row, and the 
    " second dimension is the characters in each row. Another two-dimensional 
    " array corresponds to record the physical length of each character.
    let reg_x_chars = []
    let reg_x_phy_lens = []
    let row_chars = []
    let row_phy_lens = []

    let start_row = get(opts, 'row', line('.'))
    let col = get(opts, 'col', virtcol('.'))

    let [chars_arr, index] = vimio#utils#get_line_cells(start_row, col)
    if get(chars_arr, index, '') ==# ''
        let col -= 1
    endif

    for i in range(len(reg_text))
        let row = start_row + i
        let [chars_arr, index] = vimio#utils#get_line_cells(row, col)

        if i == 0
            " If a space is inserted here, the cursor position needs to be filled correctly.
            call vimio#utils#set_line_str(chars_arr, row, row, len(join(chars_arr[0:index], '')))
        endif

        let reg_line = reg_text[i]
        let j = 0
        for ch in split(reg_line, '\zs')
            " Performance-sensitive: faster than `get()` due to simpler control
            " flow & minimal function overhead
            let char_phy_len = strdisplaywidth(ch)


            if len(reg_x_chars) <= i
                call add(reg_x_chars, [])
                call add(reg_x_phy_lens, [])
            endif

            if char_phy_len == 2
                call extend(reg_x_chars[i], [ch, ''])
                call extend(reg_x_phy_lens[i], [2, 0])
            else
                call extend(reg_x_chars[i], [ch])
                call extend(reg_x_phy_lens[i], [1])
            endif
            let j += char_phy_len
        endfor

        let k = 0

        let k_index = index

        " echom "k_index: " . string(k_index)
        " echom "chars_arr: " . string(chars_arr)
        while 1
            let top = reg_x_chars[i][k]

            if k_index >= len(chars_arr)
                call add(chars_arr, top)
                
                let k += 1
                if k >= j
                    break
                endif
                let k_index += 1
                continue
            endif

            let bottom = chars_arr[k_index]
            let top_width = reg_x_phy_lens[i][k]
            let bottom_width = strdisplaywidth(bottom)

             " top     0                   
             " bottom  0     current slot -> ' '
             "               pre slot     -> ' '
             " top     0
             " bottom  1     current slot -> ' '
             "                          .- 0  pre slot     -> ' ' 
             "                          |     pre pre slot -> ' '
             "               pre slot --'- 1  pre slot     -> ' '
             " top     0
             " bottom  2     current slot -> ' '
             "               next slot    -> ' '
             "                          .- 0  pre slot     ->  ' '
             "                          |     pre pre slot ->  ' '
             "               pre slot---'- 1  pre slot     ->  ' '
             " top     1
             " bottom  0     current slot -> top
             "               pre slot     -> ' '
             " top     1
             " bottom  1     current slot -> top
             " top     1
             " bottom  2     current slot -> top
             "               next slot    -> ' '
             " top     2
             " bottom  0     current slot -> top
             "               pre slot     -> ' '
             "                           .- 2   next slot   -> ''
             "                           |      next next slot -> ' '
             "               next slot---'- 1/0 next slot   -> ''
             " top     2
             " bottom  1     current slot -> top
             "                           .- 2   next slot -> ''
             "                           |      next next slot -> ' '
             "               next slot---'- 1/0 next slot -> ''
             " top     2
             " bottom  2     current slot -> top

            " If the overlay character is not a space, overlay
            if top != ' ' || a:is_space_replace
                if top_width == 1
                    let chars_arr[k_index] = top
                    if bottom_width == 0
                        let chars_arr[k_index-1] = ' '
                    elseif bottom_width == 2
                        call vimio#utils#list_set_value_safe(chars_arr, k_index+1, ' ')
                    endif
                elseif top_width == 2
                    let chars_arr[k_index] = top
                    if bottom_width == 0
                        let chars_arr[k_index-1] = ' '
                        let next_width = vimio#utils#list_get_item_screen_len(chars_arr, k_index+1)
                        call vimio#utils#list_set_value_safe(chars_arr, k_index+1, '')
                        if next_width == 2
                            call vimio#utils#list_set_value_safe(chars_arr, k_index+2, ' ')
                        endif
                    elseif bottom_width == 1
                        let next_width = vimio#utils#list_get_item_screen_len(chars_arr, k_index+1)
                        call vimio#utils#list_set_value_safe(chars_arr, k_index+1, '')
                        if next_width == 2
                            call vimio#utils#list_set_value_safe(chars_arr, k_index+2, ' ')
                        endif
                    endif
                endif
            endif

            let k += 1
            if k >= j
                break
            endif
            let k_index += 1
        endwhile

        " Reset this row
        call setline(row, join(chars_arr, ''))
    endfor
endfunction

function! vimio#replace#replace_char_under_cursor_from_clip(direction)
    " Get the content of the current row
    let l:line = getline('.')
    let cursor_char = matchstr(l:line, '\%' . col('.') . 'c.')

    let reg_content = getreg('+')
    let cleaned_reg_content = substitute(reg_content, '\s\+', '', 'g')

    if exists("g:vimio_state_replace_char_under_cursor_chars")
        " Check whether the contents of the register have changed
        let prev_content = join(g:vimio_state_replace_char_under_cursor_chars['value'], '')

        if cleaned_reg_content != prev_content
            " Update saved content
            let g:vimio_state_replace_char_under_cursor_chars['value'] = split(cleaned_reg_content, '\zs')
            let g:vimio_state_replace_char_under_cursor_chars['index'] = 0
        else
            " Update index
            let g:vimio_state_replace_char_under_cursor_chars['index'] = (g:vimio_state_replace_char_under_cursor_chars['index']+1) % len(g:vimio_state_replace_char_under_cursor_chars['value'])
        endif
    else
        let g:vimio_state_replace_char_under_cursor_chars = {'index': 0, 'value': []}
        let g:vimio_state_replace_char_under_cursor_chars['value'] = split(cleaned_reg_content, '\zs')
    endif

    let now_char_index = g:vimio_state_replace_char_under_cursor_chars['index']
    let now_char = g:vimio_state_replace_char_under_cursor_chars['value'][now_char_index]

    " Replace the character at the target position
    execute "normal! r" . now_char

    " Get the width of the replaced character
    let new_char_width = strdisplaywidth(now_char)
    let cursor_char_width = strdisplaywidth(cursor_char)

    if cursor_char_width == 0
        let cursor_char_width = 1
    endif

    " If the replacement is a wide character, remove extra spaces.
    if cursor_char_width != new_char_width
        if new_char_width > 1
            " Try moving the cursor to the right
            " Move the cursor to the right and delete the character
            execute "normal! l"
            execute "normal! x"
            " Move the cursor to the left to restore the position
            execute "normal! h"

            if a:direction == 'l'
                execute "normal! l"
            elseif a:direction == 'h'
                execute "normal! hh"
            elseif a:direction == 'j'
                execute "normal! j"
            elseif a:direction == 'k'
                execute "normal! k"
            endif
        else
            " After replacing, add a space.
             call feedkeys("a \<Esc>h", 'n')
        endif
    else
        if a:direction == 'l'
            execute "normal! l"
        elseif a:direction == 'h'
            execute "normal! h"
        elseif a:direction == 'j'
            execute "normal! j"
        elseif a:direction == 'k'
            execute "normal! k"
        endif

    endif
endfunction

function! vimio#replace#visual_replace_to_space()
    " Re-select the visible box
    execute "normal! gv"
    " call feedkeys("r ")
    " Replace all characters with spaces ('feedkeys' does not take effect 
    " immediately, 'normal!' takes effect immediately)
    execute "normal! r "
endfunction

function! vimio#replace#visual_replace_char() range
    let [line_start, col_start] = [g:vimio_state_initial_pos_before_enter_visual[0], g:vimio_state_initial_pos_before_enter_visual[1]]
    let [start_chars_arr, start_index] = vimio#utils#get_line_cells(line_start, col_start)

    let char = getreg('+')
    let char = empty(char) ? ' ' : strcharpart(char, 0, 1)

    " Get the currently selected text range
    execute "normal! gv"
    " Enter command mode and perform the replacement operation.
    let char_screen_width = strdisplaywidth(char)

    if char_screen_width == 2
        execute "normal! :s/\\%V  /" . char . "/g\<CR>"
    elseif char_screen_width == 1 && len(char) != 1
        execute "normal! :s/\\%V /" . char . "/g\<CR>"
    else
        execute "normal! :s/\\%V /" . '\' . char . "/g\<CR>"
    endif
    
    let [start_chars_arr, start_index] = vimio#utils#get_line_cells(line_start, col_start)
    let col_byte_start = len(join(start_chars_arr[0:start_index], ''))
    call cursor(line_start, col_byte_start)
endfunction

