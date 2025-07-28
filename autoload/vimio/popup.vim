" autoload/vimio/popup.vim
" ---------------
" Pop-up window preview module.
" A floating window used to display the contents of the clipboard, supporting 
" masking, transparency, position updating, etc.
"
" Contents:
" - vimio#popup#update_cross_block(...)
" - vimio#popup#update_block(...)
" - vimio#popup#clear_overlay_timer()
" - vimio#popup#schedule_overlay_mask(lines)
" - s:build_mask(new_text)
" - vimio#popup#update_overlay_mask(new_text)
" - vimio#popup#switch_visual_block_popup_type()
" - vimio#popup#on_block_popup_close(id,result)
" - vimio#popup#close_block()


" ======================Global pop-up for uniqueness===========================
let s:popup_mask_dirty = v:false
let s:popup_last_text = ''

function! vimio#popup#update_cross_block(...)
    let opts = get(a:, 1, {})
    let anchor = get(opts, 'anchor', 'topleft')

    let preview_text = vimio#utils#get_current_paste_text(opts)

    call vimio#popup#update_block({
                \ 'new_text': preview_text,
                \ 'anchor': anchor,
                \}
                \)
endfunction

function! vimio#popup#switch_popup_type() abort
    let g:vimio_state_visual_block_popup_types_index = (g:vimio_state_visual_block_popup_types_index + 1) % len(g:vimio_config_visual_block_popup_types)
endfunction

" Support parameter specifies the starting point and text.
" { 'new_text': 'xxxyy', 'pos_start': [row, virtcol] }
function! vimio#popup#update_block(...)

    " " Check if the highlighted group exists and has not been cleared
    " let l:highlight_info = execute('highlight VimioVirtualText')
    " if l:highlight_info =~ 'xxx cleared'
    "     " Redefine Highlight Group
    "     highlight VimioVirtualText ctermfg=LightGray guifg=#D3D3D3 ctermbg=NONE guibg=NONE
    " endif

    " Obtain the content and type of the register. Since the system clipboard 
    " is currently being used, it may be slower, so a delay is added to 
    " stabilize the pop-up. Although using the system register may be slow, it 
    " allows for convenient cross-Vim entity copy and paste. If speed becomes 
    " a concern later, consider using other registers. It's also possible that 
    " the pop-up cannot respond to requests too quickly, so the update is made 
    " slower here.
    let opts = get(a:, 1, {})
    let regcontent = get(opts, 'new_text', vimio#utils#get_reg('+'))
    let anchor = get(opts, 'anchor', 'topleft')

    let l:new_text = split(regcontent, "\n")
    if vimio#utils#is_single_char_text(l:new_text)
        call vimio#utils#hide_cursor()
    else
        call vimio#utils#restore_cursor()
    endif
    
    " let t2 = reltime()
    " echomsg printf('⏱ overlay create: %.2f ms', reltimefloat(reltime(t1, t2)) * 1000)

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
        if vimio#utils#flat_list_equal(s:popup_last_text, l:new_text)
            let s:popup_mask_dirty = v:false
        else
            let s:popup_mask_dirty = v:true
        endif
        let s:popup_last_text = copy(l:new_text)

        " Update the text in the pop-up window
        call popup_settext(g:vimio_state_block_popup_id, l:new_text)

        " Update the position of the pop-up window
        call popup_setoptions(g:vimio_state_block_popup_id, { 'pos': anchor })
        call popup_move(g:vimio_state_block_popup_id, {
            \ 'line': 'cursor',
            \ 'col': 'cursor',
            \ })

        " Update the transparency mask and other properties of the pop-up window
        " The pop-up window needs to be updated promptly; otherwise, it will flicker.
        if g:vimio_config_visual_block_popup_types[g:vimio_state_visual_block_popup_types_index] ==# 'overlay'
            call popup_setoptions(g:vimio_state_block_popup_id, {
                        \ 'highlight': 'VimioVirtualText',
                        \ 'moved': 'any',
                        \ 'zindex': 100,
                        \ 'pos': anchor,
                        \ })
        else
            call popup_setoptions(g:vimio_state_block_popup_id, {
\ 'mask': [],
                        \ 'highlight': 'VimioVirtualText',
                        \ 'moved': 'any',
                        \ 'zindex': 100,
                        \ 'pos': anchor,
                        \ })
        endif
    else
        let g:vimio_state_block_popup_id = popup_create(l:new_text, {
            \ 'line': 'cursor',
            \ 'col': 'cursor',
            \ 'zindex': 100,
            \ 'highlight': 'VimioVirtualText',
            \ 'moved': 'any',
            \ 'pos': anchor,
            \ 'callback': function('vimio#popup#on_block_popup_close')
            \ })
    endif

    " Asynchronous Mask Update (Effective Only in Overlay Mode)
    call vimio#popup#schedule_overlay_mask(l:new_text)

    " let t3 = reltime()
    " echomsg printf('⏱ popup create: %.2f ms', reltimefloat(reltime(t2, t3)) * 1000)
endfunction


function! vimio#popup#clear_overlay_timer() abort
    if exists('s:overlay_timer_id')
        call timer_stop(s:overlay_timer_id)
        unlet s:overlay_timer_id
    endif
endfunction

function! vimio#popup#schedule_overlay_mask(lines) abort
    if g:vimio_config_visual_block_popup_types[g:vimio_state_visual_block_popup_types_index] !=# 'overlay'
        return
    endif
    call vimio#popup#clear_overlay_timer()
    let s:overlay_timer_id = timer_start(5, {-> vimio#popup#update_overlay_mask(a:lines)})
endfunction

function! s:build_mask(new_text) abort
    let mask = []
    let new_text = copy(a:new_text)

    " Get the longest row (use copy to ensure the original list is not modified)
    " let l:max_display_length = max(map(copy(new_text), {_, ch -> strdisplaywidth(ch)}))
    " The original construction method is faster than lambda expressions.
    let l:max_display_length = max(map(copy(new_text), 'strdisplaywidth(v:val)'))

    " Fill in the blanks if necessary
    for i in range(0, len(new_text)-1)
        let l:line_length = strdisplaywidth(new_text[i])
        if l:line_length < l:max_display_length
            let new_text[i] .= repeat(' ', l:max_display_length - l:line_length)
        endif
    endfor

    for i in range(len(new_text))
        let line = new_text[i]
        if line !~# ' '
            continue
        endif

        let j = 0
        " Add mask for space; if underlying cell contains wide char tail,
        " may cause visual residue
        for char in split(line, '\zs')
            if char == ' '
                call add(mask, [j + 1, j + 1, i + 1, i + 1])
            endif
            let j += strdisplaywidth(char)
        endfor
    endfor

    return mask
endfunction


function! vimio#popup#update_overlay_mask(new_text) abort
    if g:vimio_config_visual_block_popup_types[g:vimio_state_visual_block_popup_types_index] !=# 'overlay'
        return
    endif

    if !exists('s:popup_cached_mask')
        let s:popup_cached_mask = s:build_mask(a:new_text)
    else
        " If the text changes, it also needs to be updated.
        if s:popup_mask_dirty == v:true
            let s:popup_cached_mask = s:build_mask(a:new_text)
        endif
    endif

    let mask = s:popup_cached_mask

    if exists('g:vimio_state_block_popup_id') && g:vimio_state_block_popup_id != 0
        call popup_setoptions(g:vimio_state_block_popup_id, {
                    \ 'mask': mask,
                    \ })
    endif
endfunction

function! vimio#popup#switch_visual_block_popup_type()
    call vimio#popup#clear_overlay_timer()
    call vimio#popup#switch_popup_type()

    " Update pop-up window
    call vimio#popup#update_cross_block()
endfunction

function! vimio#popup#on_block_popup_close(id, result) abort
    call vimio#utils#restore_cursor()
    let g:vimio_state_block_popup_id = 0
    call vimio#popup#clear_overlay_timer()
    unlet! s:popup_cached_mask
    let s:popup_mask_dirty = v:false
    let s:popup_last_text = ''
endfunction

function vimio#popup#close_block()
    if exists('g:vimio_state_block_popup_id') && g:vimio_state_block_popup_id != 0
        call popup_close(g:vimio_state_block_popup_id)
        call vimio#popup#on_block_popup_close(g:vimio_state_block_popup_id, v:null)
    endif
endfunction

" ==============Multiple pop-up windows support object management==============     

function! vimio#popup#null_filter(winid, key) abort
    " 0 stand for do not close popup
    return 0
endfunction


function! vimio#popup#new(popup_definition)
    let popup_obj = {}
    let popup_obj.TEXT = ''
    let popup_obj.ANCHOR = 'topleft'
    let popup_obj.MASK_DIRTY = v:true
    let popup_obj.MASK = []
    let popup_obj.TYPE = g:vimio_config_visual_block_popup_types[g:vimio_state_visual_block_popup_types_index]
    let popup_obj.ID = 0
    let popup_obj.OVERLAY_TIMER_ID = -1
    let popup_obj.FILTER = function('vimio#popup#null_filter')

    for method in ['update', 'schedule_overlay_mask', 'clear_overlay_timer',
                \ 'update_popup_type', 'popup_close_self'
                \]
        let popup_obj[method] = function('s:' . method, popup_obj)
    endfor
    call popup_obj.update(a:popup_definition)
    return popup_obj
endfunction

function! s:update(popup_definition) dict abort
    let new_text = get(a:popup_definition, 'new_text', self.TEXT)
    let self.ANCHOR = get(a:popup_definition, 'anchor', self.ANCHOR) 
    let self.FILTER = get(a:popup_definition, 'filter', self.FILTER)
    call self.update_popup_type()

    if self.ID != 0
        if self.TEXT ==# new_text
            let self.MASK_DIRTY = v:false
        else
            let self.MASK_DIRTY = v:true
        endif

        let self.TEXT = new_text
        call popup_settext(self.ID, split(self.TEXT, "\n"))
        call popup_setoptions(self.ID, { 
                    \ 'pos': self.ANCHOR,
                    \ })
        call popup_move(self.ID, {
                    \ 'line': 'cursor',
                    \ 'col': 'cursor',
                    \ })
        if self.TYPE ==# 'overlay'
            call popup_setoptions(self.ID, {
                        \ 'highlight': 'VimioVirtualText',
                        \ 'moved': 'any',
                        \ 'zindex': 100,
                        \ 'pos': self.ANCHOR,
                        \ })
        else
            call popup_setoptions(self.ID, {
                        \ 'mask': [],
                        \ 'highlight': 'VimioVirtualText',
                        \ 'moved': 'any',
                        \ 'zindex': 100,
                        \ 'pos': self.ANCHOR,
                        \ })
        endif
    else
        let self.TEXT = new_text
        let self.ID = popup_create(split(self.TEXT, "\n"), {
            \ 'line': 'cursor',
            \ 'col': 'cursor',
            \ 'zindex': 100,
            \ 'highlight': 'VimioVirtualText',
            \ 'moved': 'any',
            \ 'pos': self.ANCHOR,
            \ 'filter': self.FILTER,
            \ 'callback': {-> s:on_popup_close(self)},
            \ 'filtermode': 'n',
            \ })
        let g:vimio_popup_all_popups[self.ID] = self
    endif

    call self.schedule_overlay_mask()
endfunction

function! s:on_popup_close(obj) abort
    call a:obj.clear_overlay_timer()
    let a:obj.MASK = []
    let a:obj.MASK_DIRTY = v:true
    let a:obj.TEXT = ''
    let a:obj.OVERLAY_TIMER_ID = -1
    if a:obj.ID != 0
        call remove(g:vimio_popup_all_popups, a:obj.ID)
    endif
    let a:obj.ID = 0
endfunction

function! s:schedule_overlay_mask() dict abort
    if self.TYPE !=# 'overlay'
        return
    endif
    call self.clear_overlay_timer()
    let self.OVERLAY_TIMER_ID = timer_start(5, {-> s:update_overlay_mask(self)}) 
endfunction

function! s:clear_overlay_timer() dict abort
    if self.OVERLAY_TIMER_ID != -1
        call timer_stop(self.OVERLAY_TIMER_ID)
        let self.OVERLAY_TIMER_ID = -1
    endif
endfunction

function! s:update_overlay_mask(obj) abort
    if a:obj.TYPE !=# 'overlay'
        return
    endif

    if len(a:obj.MASK) == 0
        let a:obj.MASK = s:build_mask(split(a:obj.TEXT, "\n"))
    else
        if a:obj.MASK_DIRTY
            let a:obj.MASK = s:build_mask(split(a:obj.TEXT, "\n"))
        endif
    endif

    if a:obj.ID != 0
        call popup_setoptions(a:obj.ID, { 'mask': a:obj.MASK })
    endif
endfunction

function! s:update_popup_type() dict abort
    let self.TYPE = g:vimio_config_visual_block_popup_types[g:vimio_state_visual_block_popup_types_index]
endfunction

function s:popup_close_self() dict abort
    if self.ID != 0
        call popup_close(self.ID)
        call s:on_popup_close(self)
    endif
endfunction

