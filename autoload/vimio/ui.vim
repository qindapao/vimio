" autocmd/vimio/ui.vim
" ------------
" User interaction logic.
" Includes quick operations such as line type switching, cross strategy 
" switching, and character copy and paste.
"
" Contents:
" - vimio#ui#visual_block_move(direction)
" - vimio#ui#visual_block_mouse_move_start()
" - vimio#ui#visual_block_mouse_move_cancel()
" - vimio#ui#smart_line_continue_draw()
" - vimio#ui#smart_line_draw_end()
" - vimio#ui#smart_line_start_arrow_show_flip()
" - vimio#ui#smart_line_end_arrow_show_flip()
" - vimio#ui#smart_line_diagonal_flip()
" - vimio#ui#smart_line_arrow_flip_start_end()
" - vimio#ui#smart_line_flip_cross()
" - vimio#ui#smart_line_cancel()
" - vimio#ui#switch_cross_style()
" - vimio#ui#switch_line_style(is_just_show)
" - vimio#ui#paste_flip_cross_mode()
" - vimio#ui#switch_line_style_by_char_under_cursor()
" - vimio#ui#copy_char_under_cursor_to_clip()
" - vimio#ui#box_suround()
" - vimio#ui#shapes_change_type()
" - vimio#ui#shapes_resize_start()
" - vimio#ui#shapes_resize_move()
" - vimio#ui#shapes_resize_end()


let s:shape_obj = {}

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

    if x == 0 && y == 0
        let [y, x] = [line('.'), virtcol('.')]
    endif

    let box = vimio#shapes#box#new({
                \ 'X': x,
                \ 'Y': y,
                \ 'TEXT_ONLY': text_only,
                \ 'TITLE': '',
                \ 'BOX_TYPE': deepcopy(g:vimio_config_shapes_box_types_switch[g:vimio_state_draw_line_index]),
                \ 'END_X': 5,
                \ 'END_Y': 5
                \ })

    call vimio#replace#paste_block_clip(1, {
                \ 'row': y - box.TEXT_BEGIN_Y,
                \ 'col': x - box.TEXT_BEGIN_X,
                \ 'new_text': box.TEXT,
                \ 'pos_start': [y, x]
                \})
    " :TODO: Should the highlight remain after insertion? It might be necessary
    " to move or change the border type.
endfunction

function! vimio#ui#shapes_change_type() abort
    let shape_obj = vimio#shapes#detect#from_points(g:vimio_state_multi_cursors, 0)
    if empty(shape_obj)
        return
    endif

    let shape_type = deepcopy(g:shape_name_config_map[shape_obj.NAME][g:vimio_state_draw_line_index])
    call shape_obj.set_box_type(shape_type)

    " delete original shape
    call vimio#cursors#create_rectangle_string(g:vimio_state_multi_cursors, 1, ' ', 1)

    call vimio#replace#paste_block_clip(1, {
                \ 'row': shape_obj.Y,
                \ 'col': shape_obj.X,
                \ 'new_text': shape_obj.TEXT,
                \ 'pos_start': [shape_obj.Y, shape_obj.X]
                \})
endfunction


function! vimio#ui#shapes_resize_start() abort
    let s:shape_obj = vimio#shapes#detect#from_points(g:vimio_state_multi_cursors, 1)
    " call vimio#debug#log_obj('s:shape_obj', s:shape_obj, 4, '--s:shape_obj--')
    " call vimio#debug#log("start_row: %d;start_col: %d;", s:shape_obj['Y'], s:shape_obj['X'])
    if empty(s:shape_obj)
        return
    endif

    " move the cursor to the botright, create a smallest shape
    call vimio#utils#cursor_jump(s:shape_obj['Y']+s:shape_obj["HEIGH"]-1, s:shape_obj['X']+s:shape_obj['WIDTH']-1)

    augroup VimioUiShapesResizeCursorMove
        autocmd!
        autocmd CursorMoved * call vimio#ui#shapes_resize_move()
    augroup END

    call vimio#ui#shapes_resize_move()
endfunction

function! vimio#ui#shapes_resize_move() abort
    if empty(s:shape_obj)
        augroup VimioUiShapesResizeCursorMove
            autocmd!
        augroup END
        return
    endif
    let [ current_row, current_col ] = [ line('.'), virtcol('.') ]
    " a b
    " 1 3
    " 3 - 1 + 1 = 3
    let end_x = current_col - s:shape_obj['X'] + 1
    let end_y = current_row - s:shape_obj['Y'] + 1

    let end_x = max([end_x, s:shape_obj['MIN_WIDTH']])
    let end_y = max([end_y, s:shape_obj['MIN_HEIGH']])

    " echom "end_x: " . end_x . ";end_y:" . end_y . ";"

    call s:shape_obj['resize'](end_x, end_y)

    let [ current_y, current_x ] = [ line('.'), virtcol('.') ]
    let need_cursor_jump = v:false
    let jump_y = current_y
    let jump_x = current_x
    if current_y < s:shape_obj['Y'] + s:shape_obj['MIN_HEIGH'] - 1
        let need_cursor_jump = v:true
        let jump_y = s:shape_obj['Y'] + s:shape_obj['MIN_HEIGH'] -1
    endif

    if current_x < s:shape_obj['X'] + s:shape_obj['MIN_WIDTH'] - 1
        let need_cursor_jump = v:true
        let jump_x = s:shape_obj['X'] + s:shape_obj['MIN_WIDTH'] -1
    endif

    if need_cursor_jump
        call vimio#utils#cursor_jump(jump_y, jump_x)
    endif

    " call vimio#debug#log("TEXT: %s;X: %s;Y: %s;col: %s;row: %s;", s:shape_obj['TEXT'], end_x, end_y, current_col, current_row)
    call vimio#popup#update_cross_block({
                \ 'new_text': s:shape_obj['TEXT'],
                \ 'anchor': 'botright',
                \ 'pos_start': [s:shape_obj['Y'], s:shape_obj['X']]
                \ })
endfunction


function! vimio#ui#shapes_resize_end() abort
    augroup VimioUiShapesResizeCursorMove
        autocmd!
    augroup END

    if empty(s:shape_obj)
        return
    endif

    " delete original shape
    call vimio#cursors#create_rectangle_string(g:vimio_state_multi_cursors, 1, ' ', 1)

    call vimio#replace#paste_block_clip(1, {
                \ 'row': s:shape_obj['Y'],
                \ 'col': s:shape_obj['X'],
                \ 'new_text': s:shape_obj.TEXT,
                \ 'pos_start': [s:shape_obj['Y'], s:shape_obj['X']]
                \})
    let s:shape_obj = {}
endfunction


