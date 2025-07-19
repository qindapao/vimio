" autocmd/vimio/ui.vim
" ------------
" User interaction logic.
" Includes quick operations such as line type switching, cross strategy 
" switching, and character copy and paste.
"
" Contents:
" - vimio#ui#switch_visual_block_popup_type()
" - vimio#ui#visual_block_move(direction)
" - vimio#ui#visual_block_mouse_move_start()
" - vimio#ui#visual_block_mouse_move_cancel()
" - vimio#ui#switch_cross_style()
" - vimio#ui#switch_line_style(is_just_show)
" - vimio#ui#switch_line_style_by_char_under_cursor()
" - vimio#ui#copy_char_under_cursor_to_clip()



" vim enters visual mode and selects an area the same size as the x register
" ctrl j k h l move this selection area
function! vimio#ui#visual_block_move(direction)
    " Move cursor
    if a:direction != 'null'
        execute 'silent! normal! 1' . a:direction
    endif

    call vimio#popup#update_cross_block()
endfunction

function! vimio#ui#visual_block_mouse_move_start()
    let g:vimio_state_save_ctrl_mouseleft = maparg('<C-LeftMouse>', 'n')
    let g:vimio_state_save_ctrl_mouseright = maparg('<C-RightMouse>', 'n')

    nnoremap <silent> <C-LeftMouse> :call vimio#replace#paste_block_clip(1)<CR>
    nnoremap <silent> <C-RightMouse> :call vimio#replace#paste_block_clip(0)<CR>

    set mouse=n
    augroup VimioUiVisualBlockMouseMove
        autocmd!
        autocmd CursorMoved * call vimio#popup#update_cross_block()
    augroup END

    call vimio#popup#update_cross_block()
endfunction

function! vimio#ui#visual_block_mouse_move_cancel()
    if exists('g:vimio_state_save_ctrl_mouseleft')
        execute 'nnoremap <silent> <C-LeftMouse> ' . g:vimio_state_save_ctrl_mouseleft
    endif

    if exists('g:vimio_state_save_ctrl_mouseright')
        " :TODO: It is currently found that the previous operation has not been restored normally.
        execute 'nnoremap <silent> <C-RightMouse> ' . g:vimio_state_save_ctrl_mouseright
    endif

    augroup VimioUiVisualBlockMouseMove
        autocmd!
    augroup END
    set mouse=a

    " Close the pop-up window here
    call vimio#popup#close_block()
endfunction

function! vimio#ui#smart_line_continue_draw() abort
    " record start point
    call vimio#drawline#init()
    call g:vimio_drawline_smart_line['continue_draw']()

    augroup VimioUiSmartLineCursorMove
        autocmd!
        autocmd CursorMoved * call g:vimio_drawline_smart_line['draw']()
    augroup END
endfunction

function! vimio#ui#smart_line_draw_end() abort
    augroup VimioUiSmartLineCursorMove
        autocmd!
    augroup END

    if exists('g:vimio_drawline_smart_line') && g:vimio_drawline_smart_line['in_draw_context'] == v:true
        call g:vimio_drawline_smart_line['end']()
    endif
endfunction

function! vimio#ui#smart_line_start_arrow_show_flip() abort
    if exists('g:vimio_drawline_smart_line') && g:vimio_drawline_smart_line['in_draw_context'] == v:true
        call g:vimio_drawline_smart_line['start_arrow_show_flip']()
    endif
endfunction

function! vimio#ui#smart_line_end_arrow_show_flip() abort
    if exists('g:vimio_drawline_smart_line') && g:vimio_drawline_smart_line['in_draw_context'] == v:true
        call g:vimio_drawline_smart_line['end_arrow_show_flip']()
    endif
endfunction

function! vimio#ui#smart_line_diagonal_flip() abort
    if exists('g:vimio_drawline_smart_line') && g:vimio_drawline_smart_line['in_draw_context'] == v:true
        call g:vimio_drawline_smart_line['diagonal_flip']()
    endif
endfunction

function! vimio#ui#smart_line_arrow_flip_start_end() abort
    if exists('g:vimio_drawline_smart_line') && g:vimio_drawline_smart_line['in_draw_context'] == v:true
        call g:vimio_drawline_smart_line['flip_arrow_start_end']()
    endif
endfunction

function! vimio#ui#smart_line_flip_cross() abort
    if exists('g:vimio_drawline_smart_line') && g:vimio_drawline_smart_line['in_draw_context'] == v:true
        call g:vimio_drawline_smart_line['cross_flip']()
    endif
endfunction

function! vimio#ui#smart_line_cancel() abort
    augroup VimioUiSmartLineCursorMove
        autocmd!
    augroup END

    if exists('g:vimio_drawline_smart_line') && g:vimio_drawline_smart_line['in_draw_context'] == v:true
        call g:vimio_drawline_smart_line['cancel']()
    endif
endfunction

function! vimio#ui#switch_cross_style()
    call vimio#scene#clear_cross_cache()
    let g:vimio_state_cross_style_index = (g:vimio_state_cross_style_index + 1) % len(g:vimio_config_draw_cross_styles)
    if exists('g:vimio_drawline_smart_line') && g:vimio_drawline_smart_line['in_draw_context'] == v:true
        call g:vimio_drawline_smart_line['update_preview']()
    endif
    echo "now index: " . g:vimio_state_cross_style_index
endfunction

function! vimio#ui#switch_line_style(is_just_show)
    if !a:is_just_show
        let g:vimio_state_draw_line_index = (g:vimio_state_draw_line_index + 1) % len(g:vimio_config_draw_line_styles)
    endif

    if exists('g:vimio_drawline_smart_line') && g:vimio_drawline_smart_line['in_draw_context'] == v:true
        call g:vimio_drawline_smart_line['update_preview']()
    endif
    echo "now line type:" . string(g:vimio_config_draw_line_styles[g:vimio_state_draw_line_index])
endfunction

function! vimio#ui#paste_flip_cross_mode()
    let val = g:vimio_state_paste_preview_cross_mode
    let g:vimio_state_paste_preview_cross_mode = !val
endfunction

" Get the line type under the current cursor and switch to it
function! vimio#ui#switch_line_style_by_char_under_cursor()
    let smart_char_to_index = {'-': 0, '|': 0, '─': 1, '│': 1, '━': 2, '┃': 2, '═': 3, '║': 3, '┅': 4, '┇': 4, '┄': 5, '┆': 5}
    let current_char = matchstr(getline('.'), '\%' . col('.') . 'c.')

    if has_key(smart_char_to_index, current_char)
        let g:vimio_state_draw_line_index = smart_char_to_index[current_char]
    endif
    echo "now line type:" . string(g:vimio_config_draw_line_styles[g:vimio_state_draw_line_index])
endfunction

function! vimio#ui#copy_char_under_cursor_to_clip()
    " Copy the character under the current cursor to clip
    let current_char = matchstr(getline('.'), '\%' . col('.') . 'c.')
    let @+ = current_char
endfunction

" Generate a box based on the currently highlighted content and remove 
" the highlight.
function! vimio#ui#box_suround()
    let [text_only, y, x] = vimio#cursors#create_rectangle_string(g:vimio_state_multi_cursors, 1, ' ', 0)

    let box_type = [
            \ [1 , 'top'             , '.'  , '-' , '.']  ,
            \ [0 , 'title separator' , '|'  , '-' , '|']  ,
            \ [1 , 'body separator'  , '| ' , '|' , ' |'] ,
            \ [1 , 'bottom'          , "'"  , '-' , "'"]  ,
            \ [1 , 'fill-character'  , ''   , ' ' , '']   ,
            \ ]

    let box = vimio#shapes#box#new({
                \ 'TEXT_ONLY': text_only,
                \ 'TITLE': '',
                \ 'BOX_TYPE': box_type,
                \ 'END_X': 5,
                \ 'END_Y': 5
                \ })
    
    if x == 0 && y == 0
        let [y, x] = [line('.'), virtcol('.')]
    endif

    call vimio#replace#paste_block_clip(1, {
                \ 'row': y - box.TEXT_BEGIN_Y,
                \ 'col': x - box.TEXT_BEGIN_X,
                \ 'new_text': box.TEXT,
                \ 'pos_start': [y, x]
                \})
    " :TODO: Should the highlight remain after insertion? It might be necessary to move or change the border type.
endfunction

