" autoload/vimio/hintline.vim
" ---------------
" Preview the graphic's guideline to facilitate users in easily identifying
" the boundaries of the graphic.
"
" Contents:
" - s:text_botright()
" - s:text_botleft(width)
" - s:text_topright(height)
" - s:text_topleft(width,height)
" - vimio#hintline#new(...)

" hintline
"
"
"
"         │      │
"         │      │
"  ───────▓━━━━━━╅──────
"         ┃      ┃
"  ───────╄━━━━━━╃──────
"         │      │
"         │      │
"         │      │
" As shown in the figure above, the hit line should be divided into four 
" parts, each implemented with a different pop-up window.
"   1.       │                   
"            │                   
"     ───────▓                     anchor: botright
"                               
"   2.              │      
"                   │      
"            ▓       ──────        anchor: botleft 
"                                 
"   3.                      
"                           
"            ▓              
"                                  anchor: topright
"     ───────               
"            │              
"            │              
"            │              
"
"   4.                         
"                              
"            ▓                 
"                              
"                    ──────        anchor: topleft 
"                   │      
"                   │      
"                   │      
"

let s:hintline_x_char = '.'
let s:hintline_y_char = '.'

function! s:text_botright(coordinates)
    let up_len = a:coordinates.row - a:coordinates.row_top
    let left_len = a:coordinates.virtcol - a:coordinates.virtcol_top

    let text = []
    for y in range(up_len)
        if y != up_len-1
            call add(text, repeat(' ', left_len-1) . s:hintline_y_char)
        else
            call add(text, repeat(s:hintline_x_char, left_len-1))
        endif
    endfor
    return join(text, "\n")
endfunction

function! s:text_botleft(coordinates, width)
    let up_len = a:coordinates.row - a:coordinates.row_top
    let right_len = a:coordinates.virtcol_bot - a:coordinates.virtcol - a:width
    let right_len = max([right_len, 1])

    let text = []
    for y in range(up_len)
        if y != up_len-1
            call add(text, repeat(' ', a:width-1) . s:hintline_y_char . repeat(' ', right_len-1))
        else
            call add(text, repeat(' ', a:width) . repeat(s:hintline_x_char, right_len-1))
        endif
    endfor
    return join(text, "\n")
endfunction

function! s:text_topright(coordinates, height)
    let down_len = a:coordinates.row_bot - a:coordinates.row - a:height
    let down_len = max([down_len, 1])
    let left_len = a:coordinates.virtcol - a:coordinates.virtcol_top

    let text = []
    for y in range(a:height)
        if y != a:height-1
            call add(text, ' ')
        else
            call add(text, repeat(s:hintline_x_char, left_len-1))
        endif
    endfor
    
    for y in range(down_len)
        call add(text, repeat(' ', left_len-1) . s:hintline_y_char)
    endfor

    return join(text, "\n")
endfunction

function! s:text_topleft(coordinates, width, height)
    let right_len = a:coordinates.virtcol_bot - a:coordinates.virtcol - a:width
    let right_len = max([right_len, 0])
    let down_len = a:coordinates.row_bot - a:coordinates.row - a:height
    let down_len = max([down_len, 1])

    let text = []
    for y in range(a:height)
        if y != a:height-1
            call add(text, ' ')
        else
            call add(text, repeat(' ', a:width) . repeat(s:hintline_x_char, right_len-1))
        endif
    endfor

    for y in range(down_len)
        call add(text, repeat(' ', a:width-1) . s:hintline_y_char)
    endfor
    
    return join(text, "\n")
endfunction

function! vimio#hintline#new(opts)
    let new_text = a:opts.new_text
    let hintline_obj = {}
    let hintline_obj.HEIGHT = len(new_text)
    let hintline_obj.WIDTH = max(map(copy(new_text), 'strdisplaywidth(v:val)'))
    let coordinates = vimio#utils#get_window_coordinates()
    let hintline_obj.botright_part = vimio#popup#new({
                \ 'new_text': s:text_botright(coordinates),
                \ 'anchor': 'botright',
                \ 'type': 'overlay',
                \ })
    let hintline_obj.botleft_part = vimio#popup#new({
                \ 'new_text': s:text_botleft(coordinates, hintline_obj.WIDTH),
                \ 'anchor': 'botleft',
                \ 'type': 'overlay',
                \ })
    let hintline_obj.topright_part = vimio#popup#new({
                \ 'new_text': s:text_topright(coordinates, hintline_obj.HEIGHT),
                \ 'anchor': 'topright',
                \ 'type': 'overlay',
                \ })
    let hintline_obj.topleft_part = vimio#popup#new({
                \ 'new_text': s:text_topleft(coordinates, hintline_obj.WIDTH, hintline_obj.HEIGHT),
                \ 'anchor': 'topleft',
                \ 'type': 'overlay',
                \ })
    for method in ['update', 'close']
        let hintline_obj[method] = function('s:' . method, hintline_obj)
    endfor

    return hintline_obj
endfunction

function! s:update(opts) dict abort 
    let new_text = a:opts.new_text
    let self.HEIGHT = len(new_text)
    let self.WIDTH = max(map(copy(new_text), 'strdisplaywidth(v:val)'))
    let coordinates = vimio#utils#get_window_coordinates()
    call self.botright_part.update({
                \ 'new_text': s:text_botright(coordinates),
                \ 'type': 'overlay'
                \ })
    call self.botleft_part.update({
                \ 'new_text': s:text_botleft(coordinates, self.WIDTH),
                \ 'type': 'overlay'
                \ })
    call self.topright_part.update({
                \ 'new_text': s:text_topright(coordinates, self.HEIGHT),
                \ 'type': 'overlay'
                \ })
    call self.topleft_part.update({
                \ 'new_text': s:text_topleft(coordinates, self.WIDTH, self.HEIGHT),
                \ 'type': 'overlay'
                \ })
endfunction

function! s:close() dict abort
    call self.botright_part.popup_close_self()
    call self.botleft_part.popup_close_self()
    call self.topright_part.popup_close_self()
    call self.topleft_part.popup_close_self()
endfunction

