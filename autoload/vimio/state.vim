" autocmd/vimio/state.vim
" ---------------
" Plugin runtime state management.
" Used to record cursor position, drawing mode status, popup ID, 
" and other shared states.
"
" Contents:
" - g:vimio_state_visual_block_popup_types_index
" - g:vimio_state_draw_line_index
" - g:vimio_state_cross_style_index
" - g:vimio_state_switch_lev2_step_index
" - g:vimio_state_multi_cursors
" - g:vimio_state_prev_cursor_pos
" - g:vimio_state_current_cursor_pos
" - vimio#state#draw_line_record_pre_pos()
" - vimio#state#draw_line_auto_group_record_pre_pos_set()
" - vimio#state#draw_line_auto_group_record_pre_pos_clear()


let g:vimio_state_visual_block_popup_types_index = 0
let g:vimio_state_draw_line_index = 0
let g:vimio_state_cross_style_index = 0
let g:vimio_state_switch_lev2_step_index = 0
let g:vimio_state_multi_cursors = []
let g:vimio_state_shapes_sub_funcs = []


function! vimio#state#draw_line_record_pre_pos()
    if exists("g:vimio_state_current_cursor_pos")
        let g:vimio_state_prev_cursor_pos = copy(g:vimio_state_current_cursor_pos)
    endif
    let g:vimio_state_current_cursor_pos = [line('.'), virtcol('.')]
endfunction

" Record the previous position of the movement to determine the direction 
" and type of the arrow.
function! vimio#state#draw_line_auto_group_record_pre_pos_set()
    augroup VimioStateDrawLineAutoGroupRecordPrePos
        autocmd!
        autocmd CursorMoved * call vimio#state#draw_line_record_pre_pos()
    augroup END
endfunction

function! vimio#state#draw_line_auto_group_record_pre_pos_clear()
    augroup VimioStateDrawLineAutoGroupRecordPrePos
        autocmd!
    augroup END
endfunction

