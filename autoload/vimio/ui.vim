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


function! vimio#ui#switch_visual_block_popup_type()
    let g:vimio_state_visual_block_popup_types_index = (g:vimio_state_visual_block_popup_types_index + 1) % len(g:vimio_config_visual_block_popup_types)

    " Update pop-up window
    call vimio#popup#update_block()
endfunction

" vim enters visual mode and selects an area the same size as the x register
" ctrl j k h l move this selection area
function! vimio#ui#visual_block_move(direction)
    " Move cursor
    if a:direction != 'null'
        execute 'silent! normal! 1' . a:direction
    endif

    call vimio#popup#update_block()
endfunction

function! vimio#ui#visual_block_mouse_move_start()
    let g:vimio_state_save_ctrl_mouseleft = maparg('<C-LeftMouse>', 'n')
    let g:vimio_state_save_ctrl_mouseright = maparg('<C-RightMouse>', 'n')

    nnoremap <silent> <C-LeftMouse> :call vimio#replace#paste_block_clip(1)<CR>
    nnoremap <silent> <C-RightMouse> :call vimio#replace#paste_block_clip(0)<CR>

    set mouse=n
    augroup VimioUiVisualBlockMouseMove
        autocmd!
        autocmd CursorMoved * call vimio#popup#update_block()
    augroup END

    call vimio#popup#update_block()
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

function! vimio#ui#switch_cross_style()
    let g:vimio_state_cross_style_index = (g:vimio_state_cross_style_index + 1) % len(g:vimio_config_draw_cross_styles)
    echo "now index: " . g:vimio_state_cross_style_index
endfunction

function! vimio#ui#switch_line_style(is_just_show)
    if !a:is_just_show
        let g:vimio_state_draw_line_index = (g:vimio_state_draw_line_index + 1) % len(g:vimio_config_draw_line_styles)
    endif
    echo "now line type:" . string(g:vimio_config_draw_line_styles[g:vimio_state_draw_line_index])
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

