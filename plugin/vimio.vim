" plugin/vimio.vim
" ----------------
" Entry point for the vimio plugin.
" Initializes configuration, commands, mappings, and loads shape templates.

let g:vimio_version = '1.0.1'

if exists('g:vimio_loaded')
    finish
endif
let g:vimio_loaded = 1

" Load default config (if not set by user)
if !exists('g:vimio_enable_default_mappings')
    let g:vimio_enable_default_mappings = 1
endif

" Load config and character sets
runtime autoload/vimio/config.vim
runtime autoload/vimio/state.vim

highlight VimioVirtualText ctermfg=LightGray guifg=#D3D3D3 ctermbg=NONE guibg=NONE
highlight VimioCursorsMultiCursor cterm=reverse gui=reverse guibg=Yellow guifg=Black


command! VimioToggleDebug call vimio#debug#toggle()
command! VimioTodoId call vimio#todo#find_max_braced_number()
command! VimioTodoSummary call vimio#todo#collect_sorted_todo_items()

if g:vimio_enable_default_mappings
    " =========================Switch drawing mode==============================
    nnoremap <Leader>vea :set ve=all<CR>| " Open virtual text editing mode
    nnoremap <Leader>ven :set ve=<CR>| " Close virtual text editing mode

    " Highlight current col
    nnoremap <silent> <leader>scsc :set cursorcolumn<cr>
    " Cancel highlight current col
    nnoremap <silent> <leader>sncsc :set nocursorcolumn<cr>


    " ===============================draw line and rectangle====================
    " draw line to the right
    nnoremap <silent> <M-l> :call vimio#draw#line_left_right('l')<CR>
    " draw line to the left
    nnoremap <silent> <M-h> :call vimio#draw#line_left_right('h')<CR>
    " draw line to the down
    nnoremap <silent> <M-j> :call vimio#draw#line_up_down('j')<CR>
    " draw line to the up
    nnoremap <silent> <M-k> :call vimio#draw#line_up_down('k')<CR>
    " draw diagonal line in the up left
    nnoremap <silent> <m-U> :call vimio#draw#draw_slash_line('u')<cr>
    " draw diagonal line in the down left
    nnoremap <silent> <m-N> :call vimio#draw#draw_slash_line('n')<cr>
    " draw diagonal line in the up right
    nnoremap <silent> <m-I> :call vimio#draw#draw_slash_line('i')<cr>
    " draw diagonal line in the down right
    nnoremap <silent> <m-M> :call vimio#draw#draw_slash_line('m')<cr>
    " Automatically add arrows based on the current scene
    nnoremap <silent> sa :call vimio#arrows#auto_add_arrow()<CR>
    " draw a rectangle based on the current line.
    vnoremap <silent>sw <Esc>:call vimio#draw#traverse_rectangle()<cr>
    " smart line draw start
    nnoremap <silent> sms :call vimio#ui#smart_line_continue_draw()<cr>
    nnoremap <silent> sme :call vimio#ui#smart_line_draw_end()<cr>
    nnoremap <silent> smas :call vimio#ui#smart_line_start_arrow_show_flip()<cr>
    nnoremap <silent> smae :call vimio#ui#smart_line_end_arrow_show_flip()<cr>
    nnoremap <silent> smd :call vimio#ui#smart_line_diagonal_flip()<cr>
    nnoremap <silent> smaf :call vimio#ui#smart_line_arrow_flip_start_end()<cr>
    nnoremap <silent> smx :call vimio#ui#smart_line_flip_cross()<cr>
    nnoremap <silent> smc :call vimio#ui#smart_line_cancel()<cr>
    " smart line draw end

    " =========================free edit========================================
    " 'R' is fine in normal mode, no need for special mapping

    " ================================Paste ====================================
    " visual block Replace(The character to be replaced needs to be entered.)
    vnoremap xc "+ygvgr
    " Paste the characters from the clip to the current cursor
    nnoremap <silent> sp :call vimio#replace#replace_char_under_cursor_from_clip('n')<CR>
    " Replace the the visible block area with the character in the clip
    vnoremap <silent> sr :<C-u>call vimio#replace#visual_replace_to_space()<cr> \| :call vimio#replace#visual_replace_char()<cr>
    " Paste the characters from the clip and move to the right
    nnoremap <silent> <C-S-Right> :call vimio#replace#replace_char_under_cursor_from_clip('l')<CR>
    " Paste the characters from the clip and move to the left
    nnoremap <silent> <C-S-Left> :call vimio#replace#replace_char_under_cursor_from_clip('h')<CR>
    " Paste the characters from the clip and move to the up
    nnoremap <silent> <C-S-Up> :call vimio#replace#replace_char_under_cursor_from_clip('k')<CR>
    " Paste the characters from the clip and move to the down
    nnoremap <silent> <C-S-Down> :call vimio#replace#replace_char_under_cursor_from_clip('j')<CR>
    " Paste the shape from the clip and completely cover the same area
    nnoremap <silent> <C-M-Space> :call vimio#replace#paste_block_clip(1)<CR>
    " Paste the shape from the clip and cover the same area ignore spaces
    nnoremap <silent> <C-S-Space> :call vimio#replace#paste_block_clip(0)<CR>
    " Paste Switch Cross Mode
    nnoremap <silent> sxm :call vimio#ui#paste_flip_cross_mode()<CR>

    " ===============================cut========================================
    vnoremap xx "+ygvgr | " visual block cut(the space in the end cannot be missing.)

    " ===============================copy=======================================
    " Copy visible block to clip
    vnoremap xy "+y
    " Copy the character under the cursor to the clip
    nnoremap <silent> sy :call vimio#ui#copy_char_under_cursor_to_clip()<CR>


    " ===============================Eraser=====================================
    " Erase to the right
    nnoremap <silent> <C-M-l> :call vimio#draw#line_eraser('l')<CR>
    " Erase to the left
    nnoremap <silent> <C-M-h> :call vimio#draw#line_eraser('h')<CR>
    " Erase to the down
    nnoremap <silent> <C-M-j> :call vimio#draw#line_eraser('j')<CR>
    " Erase to the up
    nnoremap <silent> <C-M-k> :call vimio#draw#line_eraser('k')<CR>

    " =============================draw line style control======================
    " Cycle to change the current linetype
    nnoremap <silent> sl :call vimio#ui#switch_line_style(0)<CR>
    " Displays the current linetype
    nnoremap <silent> ss :call vimio#ui#switch_line_style(1)<CR>
    " Change line type based on the character under the current cursor
    nnoremap <silent> su :call vimio#ui#switch_line_style_by_char_under_cursor()<CR>

    " =============================Cross mode control===========================
    " Switch cross character category
    nnoremap <silent> sxs :call vimio#ui#switch_cross_style()<CR>

    " ===========================Preview control================================
    " Controls whether the preview window ignores spaces (transparent or opaque)
    nnoremap <silent> st :call vimio#popup#switch_visual_block_popup_type()<CR>
    " Cursor tracking preview mode on (always show preview)
    " Quickly insert shape in clip(C-MouseLeft) Note: This is only effective in cursor tracking preview mode
    nnoremap <silent> so :call vimio#ui#visual_block_mouse_move_start()<CR>
    " Cursor tracking preview mode off (preview only when needed)
    nnoremap <silent> sq :call vimio#ui#visual_block_mouse_move_cancel()<CR>
    " Preview shows the shape to be inserted
    nnoremap <silent>sv :call vimio#ui#visual_block_move("null")<cr>
    " Keep the preview open and move the cursor to the down
    nnoremap <silent> <C-j> :call vimio#ui#visual_block_move("j")<cr>
    " Keep the preview open and move the cursor to the up
    nnoremap <silent> <C-k> :call vimio#ui#visual_block_move("k")<cr>
    " Keep the preview open and move the cursor to the left
    nnoremap <silent> <C-h> :call vimio#ui#visual_block_move("h")<cr>
    " Keep the preview open and move the cursor to the right
    nnoremap <silent> <C-l> :call vimio#ui#visual_block_move("l")<cr>


    " =======================Shape Template Library Operations==================
    " Switch template set type
    nnoremap <silent> sg :call vimio#shapes#switch_define_graph_set(1)<CR>
    " Switch template set lev1 forward
    nnoremap <silent> sf :call vimio#shapes#switch_lev1_index(1)<CR>
    " Switch template set lev1 reverse
    nnoremap <silent> sb :call vimio#shapes#switch_lev1_index(-1)<CR>
    " Switch template set lev2 forward(M-MouseScrollDown)
    nnoremap <silent> <M-u> :call vimio#shapes#switch_lev2_index(1)<CR>
    nnoremap <silent> <M-ScrollWheelDown> :call vimio#shapes#switch_lev2_index(1)<CR>
    " Switch template set lev2 reverse(M-MouseScrollUp)
    nnoremap <silent> <M-y> :call vimio#shapes#switch_lev2_index(-1)<CR>
    nnoremap <silent> <M-ScrollWheelUp> :call vimio#shapes#switch_lev2_index(-1)<CR>
    " Preview current template shape
    nnoremap <silent> <M-t> :call vimio#shapes#switch_lev2_index(0)<CR>
    " Switch shape index (width and height switch)
    nnoremap <silent> sk :let g:vimio_state_switch_lev2_step_index = !g:vimio_state_switch_lev2_step_index<CR>

    " =======Smart selection and multi-cursor control with highlighting=========
    " Highlights the character under the cursor without moving
    nnoremap <silent> <C-S-N> :call vimio#cursors#vhl_add_and_move('null')<CR>
    " Highlight the character under the cursor and move down
    nnoremap <silent> <C-S-J> :call vimio#cursors#vhl_add_and_move('j')<CR>
    " Highlight the character under the cursor and move up
    nnoremap <silent> <C-S-K> :call vimio#cursors#vhl_add_and_move('k')<CR>
    " Highlight the character under the cursor and move right
    nnoremap <silent> <C-S-L> :call vimio#cursors#vhl_add_and_move('l')<CR>
    " Highlight the character under the cursor and move left
    nnoremap <silent> <C-S-H> :call vimio#cursors#vhl_add_and_move('h')<CR>
    " Start free highlighting in normal mode
    nnoremap <silent> si :call vimio#cursors#add_cursor_mouse_move_start()<CR>
    " Start free highlighting in visual block mode
    vnoremap <silent> si :call vimio#cursors#visual_block_add_cursor()<CR>
    " Clear highlight in normal mode
    nnoremap <silent> sj :call vimio#cursors#remove_cursor_mouse_move_start()<CR>
    " Clear highlight in visual block mode
    vnoremap <silent> sj :call vimio#cursors#visual_block_remove_cursor()<CR>
    " Clear all highlights on the screen and disable highlighting
    nnoremap <silent> <C-S-C> :call vimio#cursors#clear_cursors()<CR>
    " Disable highlighting
    nnoremap <silent> sd :call vimio#cursors#disable_cursor_mouse_move()<CR>
    " Copy all highlighted characters to a rectangle
    nnoremap <silent> <C-x> :call vimio#cursors#create_rectangle_string(g:vimio_state_multi_cursors, 0, ' ', 1)<CR>
    " Cut all highlighted characters to a rectangle
    nnoremap <silent> <C-S-X> :call vimio#cursors#create_rectangle_string(g:vimio_state_multi_cursors, 1, ' ', 1)<CR>
    " Replace all highlighted characters with character in the clip
    nnoremap <silent> <C-S-G> :call vimio#cursors#replace_highlight_group_to_clip()<CR>
    " Use the mouse to easily select a rectangle(noremap <M-LeftMouse> <C-S-V>)

    " Solid area selection
    " 4 direction
    nnoremap <silent> <leader>s4 :call vimio#select#solid_select(v:false)<CR>
    " 8 direction
    nnoremap <silent> <leader>s8 :call vimio#select#solid_select(v:true)<CR>

    " border area selection
    " 4 direction
    nnoremap <silent> <leader>b4 :call vimio#select#border_select(v:false, 'min')<CR>
    nnoremap <silent> <leader>bm4 :call vimio#select#border_select(v:false, 'max')<CR>
    " 8 direction
    nnoremap <silent> <leader>b8 :call vimio#select#border_select(v:true, 'min')<CR>
    nnoremap <silent> <leader>bm8 :call vimio#select#border_select(v:true, 'max')<CR>

    " line selection
    nnoremap <silent> <leader>l4 :call vimio#select#line_select(v:false, v:false)<CR>
    nnoremap <silent> <leader>p4 :call vimio#select#line_select(v:false, v:true)<CR>
    nnoremap <silent> <leader>l8 :call vimio#select#line_select(v:true, v:false)<CR>
    nnoremap <silent> <leader>p8 :call vimio#select#line_select(v:true, v:true)<CR>

    " border inner selection
    nnoremap <silent> <leader>i4 :call vimio#select#highlight_inside_border(v:false, v:false, 'min')<CR>
    nnoremap <silent> <leader>im4 :call vimio#select#highlight_inside_border(v:false, v:false, 'max')<CR>
    nnoremap <silent> <leader>i8 :call vimio#select#highlight_inside_border(v:true, v:false, 'min')<CR>
    nnoremap <silent> <leader>im8 :call vimio#select#highlight_inside_border(v:true, v:false, 'max')<CR>

    " border and inner selection
    nnoremap <silent> <leader>a4 :call vimio#select#highlight_inside_border(v:false, v:true, 'min')<CR>
    nnoremap <silent> <leader>am4 :call vimio#select#highlight_inside_border(v:false, v:true, 'max')<CR>
    nnoremap <silent> <leader>a8 :call vimio#select#highlight_inside_border(v:true, v:true, 'min')<CR>
    nnoremap <silent> <leader>am8 :call vimio#select#highlight_inside_border(v:true, v:true, 'max')<CR>

    " Box selection based on penetration lines
    nnoremap <silent> <leader>lb :call vimio#select#highlight_inside_line()<CR>

    nnoremap <silent> <leader>s :call vimio#select#extract_outgoing_spokes(v:false)<CR>
    nnoremap <silent> <leader>sm :call vimio#select#extract_outgoing_spokes(v:true)<CR>

    " select all related
    nnoremap <silent> <leader>r4 :call vimio#select#highlight_all_related(v:false)<CR>
    nnoremap <silent> <leader>r8 :call vimio#select#highlight_all_related(v:true)<CR>

    " select text only
    nnoremap <silent> <leader>t4 :call vimio#select#highlight_text(v:false)<CR>
    nnoremap <silent> <leader>t8 :call vimio#select#highlight_text(v:true)<CR>

    " draw box
    nnoremap <silent> <leader>db :call vimio#ui#box_suround()<CR>

    " =====================================mouse===============================
    " Quickly insert shape in clip
    " C-MouseLeft
endif

" Autocommands (e.g. record visual mode entry)
augroup VimioStateVisualModeMappings
    autocmd!
    autocmd ModeChanged *:[vV\x16]* let g:vimio_state_initial_pos_before_enter_visual = [line('.'), virtcol('.')]
augroup END

" fix for [bug]{0004}
augroup VimioVhlCleanup
    autocmd!
    autocmd BufLeave * call vimio#cursors#vhl_remove_all()
augroup END

" Show Vimio version
command! VimioVersion echo "Vimio version: " . g:vimio_version

