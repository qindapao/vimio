" autoload/vimio/popup.vim
" ---------------
" Pop-up window preview module.
" A floating window used to display the contents of the clipboard, supporting 
" masking, transparency, position updating, etc.
"
" Contents:
" - vimio#popup#update_block()
" - vimio#popup#close_block()

function! vimio#popup#update_block()

    " Check if the highlighted group exists and has not been cleared
    let l:highlight_info = execute('highlight VimioVirtualText')
    if l:highlight_info =~ 'xxx cleared'
        " Redefine Highlight Group
        highlight VimioVirtualText ctermfg=LightGray guifg=#D3D3D3 ctermbg=NONE guibg=NONE
    endif

    " Obtain the content and type of the register. Since the system clipboard 
    " is currently being used, it may be slower, so a delay is added to 
    " stabilize the pop-up. Although using the system register may be slow, it 
    " allows for convenient cross-Vim entity copy and paste. If speed becomes 
    " a concern later, consider using other registers. It's also possible that 
    " the pop-up cannot respond to requests too quickly, so the update is made 
    " slower here.
    let regcontent = vimio#utils#get_reg('+')

    let l:new_text = split(regcontent, "\n")
    if vimio#utils#is_single_char_text(l:new_text)
        call vimio#utils#hide_cursor()
    else
        call vimio#utils#restore_cursor()
    endif
    
    let mask = []
    " Transparent space
    if g:vimio_config_visual_block_popup_types[g:vimio_state_visual_block_popup_types_index] == 'overlay'
        " Get the longest row (use copy to ensure the original list is not modified)
        let l:max_display_length = max(map(copy(l:new_text), 'strdisplaywidth(v:val)'))
        " Fill in the blanks if necessary
        for i in range(0, len(l:new_text)-1)
            let l:line_length = strdisplaywidth(l:new_text[i])
            if l:line_length < l:max_display_length
                let l:new_text[i] .= repeat(' ', l:max_display_length - l:line_length)
            endif
        endfor 

        for i in range(len(l:new_text))
            let line = l:new_text[i]
            let j = 0
            for char in split(line, '\zs')
                if char == ' '
                    call add(mask, [j + 1, j + 1, i + 1, i + 1])
                endif
                let j += strdisplaywidth(char)
            endfor
        endfor
    endif

    if exists('g:vimio_state_block_popup_id') && g:vimio_state_block_popup_id != 0
        try
            let l:pos = popup_getpos(g:vimio_state_block_popup_id)
            if empty(l:pos)
                throw 'Popup closed'
            endif
        catch
            " The pop-up window does not exist
            let g:vimio_state_block_popup_id = 0
        endtry
    endif

    if exists('g:vimio_state_block_popup_id') && g:vimio_state_block_popup_id != 0
        " Update the text in the pop-up window
        call popup_settext(g:vimio_state_block_popup_id, l:new_text)

        " Update the position of the pop-up window
        call popup_move(g:vimio_state_block_popup_id, {
            \ 'line': 'cursor',
            \ 'col': 'cursor'
            \ })

        " Update the transparency mask and other properties of the pop-up window
        call popup_setoptions(g:vimio_state_block_popup_id, {
            \ 'mask': mask,
            \ 'highlight': 'VimioVirtualText',
            \ 'moved': 'any',
            \ 'zindex': 100
            \ })
    else
        let g:vimio_state_block_popup_id = popup_create(l:new_text, {
            \ 'line': 'cursor',
            \ 'col': 'cursor',
            \ 'zindex': 100,
            \ 'highlight': 'VimioVirtualText',
            \ 'moved': 'any',
            \ 'mask': mask,
            \ 'callback': function('vimio#popup#on_block_popup_close')
            \ })
    endif
endfunction

function! vimio#popup#on_block_popup_close(id, result) abort
  call vimio#utils#restore_cursor()
  let g:vimio_state_block_popup_id = 0
endfunction

function vimio#popup#close_block()
    if exists('g:vimio_state_block_popup_id') && g:vimio_state_block_popup_id != 0
        call popup_close(g:vimio_state_block_popup_id)
        call vimio#popup#on_block_popup_close(g:vimio_state_block_popup_id, v:null)
    endif
endfunction

