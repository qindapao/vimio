" autoload/vimio/drawline.vim
" --------------
" Drawing core logic.
" Includes horizontal, vertical, and diagonal drawing functions, eraser 
" function, and boundary character judgment logic.
"
" Contents:
" - vimio#drawline#init()
" - vimio#drawline#new()
" - vimio#drawline#reset()
" - vimio#drawline#start()
" - vimio#drawline#record_end_point()
" - vimio#drawline#flip_arrow_start_end()
" - vimio#drawline#is_start_end_point_same()
" - vimio#drawline#update_direction_for_arrow_start_end_flip()
" - vimio#drawline#update_direction()
" - vimio#drawline#get_corner_char(direction)
" - vimio#drawline#get_diagonal_corner_char(direction,start_point_class)
" - vimio#drawline#plan_diagonal_path(start,end,direction)
" - vimio#drawline#update_preview()
" - vimio#drawline#draw()
" - vimio#drawline#start_arrow_show_flip()
" - vimio#drawline#end_arrow_show_flip()
" - vimio#drawline#diagonal_flip()
" - vimio#drawline#cross_flip()
" - vimio#drawline#end()
" - vimio#drawline#cancel()
" - vimio#drawline#continue_draw()


let s:direction = {
            \ 'invalid'   : -1,
            \ 'up'        : 0,
            \ 'down'      : 1,
            \ 'left'      : 2,
            \ 'right'     : 3,
            \}

let s:smart_line_template = {
            \ 'in_draw_context': v:false,
            \ 'start_point': [-1, -1],
            \ 'end_point'  : [-1, -1],
            \ 'direction'  : {
            \   'primary'  : s:direction.invalid,
            \   'secondary': s:direction.invalid,
            \   },
            \ 'diagonal_enable': 0,
            \ 'cross'   : {
            \   'enable': 1,
            \   },
            \ 'arrow'          : {
            \   'start': { 'enable': 0, 'char': '' },
            \   'end'  : { 'enable': 1, 'char': '' },
            \   'is_flip_start_end': v:false,
            \   },
            \ 'pop_up': {
            \   'pos' : [],
            \   'anchor': 'topleft',
            \   'id'  : -1,
            \   'txt' : '',
            \   'mask': []
            \   }
            \}



function! vimio#drawline#init() abort
    if !exists('g:vimio_drawline_smart_line')
        let g:vimio_drawline_smart_line = vimio#drawline#new()
    endif
endfunction

function! vimio#drawline#new() abort
    " Deep copy template to ensure each instance is independent.
    let obj = deepcopy(s:smart_line_template)

    " Mounting method, and bind self
    for method in ['reset', 'start', 'record_end_point',
                \ 'is_start_end_point_same', 'update_direction',
                \ 'get_corner_char', 'update_preview', 'draw', 'end',
                \ 'start_arrow_show_flip', 'end_arrow_show_flip',
                \ 'continue_draw', 'get_diagonal_corner_char',
                \ 'diagonal_flip', 'flip_arrow_start_end',
                \ 'update_direction_for_arrow_start_end_flip',
                \ 'cross_flip', 'cancel'
                \]
        let obj[method] = function('vimio#drawline#' . method, obj)
    endfor

    return obj
endfunction

function! vimio#drawline#reset() dict abort

    let save_diag = self.diagonal_enable
    let save_arrow_start_enable = self.arrow.start.enable
    let save_arrow_end_enable = self.arrow.end.enable
    let save_cross_enable = self.cross.enable

    " 1. Copy the top-level fields of the template to self
    for key in keys(s:smart_line_template)
        let self[key] = deepcopy(s:smart_line_template[key])
    endfor

    " 2. The method has already been mounted on self, no need to touch.

    " 3. cover save field
    let self.diagonal_enable    = save_diag
    let self.arrow.start.enable = save_arrow_start_enable
    let self.arrow.end.enable   = save_arrow_end_enable
    let self.cross.enable = save_cross_enable
endfunction

"           .------.     |
"           |      |     |
"           |      █-----'
"           '------'
" Record the starting point
function! vimio#drawline#start() dict abort
    " force overlay
    call self.reset()
    let self.in_draw_context = v:true
    let g:vimio_state_visual_block_popup_types_index = 1
    let self.start_point = [line('.'), virtcol('.')]
endfunction

" Record the endpoint
" :TODO: There is a bug here: when previewing, if the endpoint of the arrow is 
" on a double-width character, the entire preview will be shifted one space to
" the left.
" Fixing this issue may lead to inconsistencies in software design, so it will
" not be fixed for now.
function! vimio#drawline#record_end_point() dict abort
    let self.end_point = [line('.'), virtcol('.')]
endfunction

function! vimio#drawline#flip_arrow_start_end() dict abort
    let self.arrow.is_flip_start_end = v:true
    call self.update_preview()
endfunction


" 判断起点和终点是否相同
function! vimio#drawline#is_start_end_point_same() dict abort
    return self.start_point[0] == self.end_point[0] && self.start_point[1] == self.end_point[1]
endfunction


function! vimio#drawline#update_direction_for_arrow_start_end_flip() dict abort
    let self.end_point = copy(self.start_point)
    let self.start_point = [line('.'), virtcol('.')]

    let [cur_chars_array, index] = vimio#utils#get_line_cells(self.end_point[0], self.end_point[1])
    let jumpcol = len(join(cur_chars_array[0:index], ''))
    " Move the cursor position to the end point.
    call cursor(self.end_point[0], jumpcol)

    let self.arrow.is_flip_start_end = v:false
    
    let direction_status_change_table = {
                \ s:direction.invalid : s:direction.invalid,
                \ s:direction.up : s:direction.down,
                \ s:direction.down : s:direction.up,
                \ s:direction.left : s:direction.right,
                \ s:direction.right : s:direction.left,
                \}
    let primary_save = self.direction.primary
    let self.direction.primary = self.direction.secondary
    let self.direction.secondary = primary_save
    let self.direction.primary = direction_status_change_table[self.direction.primary]
    let self.direction.secondary = direction_status_change_table[self.direction.secondary]
endfunction


" 1. If only one coordinate (either the x-coordinate or the y-coordinate) 
"   changes between the endpoint and the starting point, then update the 
"   primary direction. the secondary direction need to be set invalid.
" 2. both the x-coordinate and y-coordinate change, then update the secondary 
"   direction. If primary coordinate is invalid, set a default value.
"   If the primary direction is not within the current interval, then fix a 
"   specified primary direction within this interval.
function! vimio#drawline#update_direction() dict abort
    " If the head and tail of the arrow switch, then switch them symmetrically.
    if self.arrow.is_flip_start_end
        call self.update_direction_for_arrow_start_end_flip()
        return
    endif

    if self.start_point[0] == self.end_point[0]
        let self.direction.primary = (self.end_point[1]>self.start_point[1]) ? s:direction.right : s:direction.left
        let self.direction.secondary = s:direction.invalid
    elseif self.start_point[1] == self.end_point[1]
        let self.direction.primary = (self.end_point[0]>self.start_point[0]) ? s:direction.down : s:direction.up
        let self.direction.secondary = s:direction.invalid
    else
        "    row(0)
        " |  \|/
        " | --+--col(1)
        " v  /|\  --------> 
        if self.end_point[0] > self.start_point[0] && self.end_point[1] < self.start_point[1]
            " left down
            if index([s:direction.left, s:direction.down], self.direction.primary) < 0
                let self.direction.primary = s:direction.left
            endif

            if self.direction.primary == s:direction.left
                let self.direction.secondary = s:direction.down
            elseif self.direction.primary == s:direction.down
                let self.direction.secondary = s:direction.left
            endif
        elseif self.end_point[0] < self.start_point[0] && self.end_point[1] < self.start_point[1]
            " left up
            if index([s:direction.left, s:direction.up], self.direction.primary) < 0
                let self.direction.primary = s:direction.left
            endif

            if self.direction.primary == s:direction.left
                let self.direction.secondary = s:direction.up
            elseif self.direction.primary == s:direction.up
                let self.direction.secondary = s:direction.left
            endif
        elseif self.end_point[0] > self.start_point[0] && self.end_point[1] > self.start_point[1]
            " right down
            if index([s:direction.right, s:direction.down], self.direction.primary) < 0
                let self.direction.primary = s:direction.right
            endif

            if self.direction.primary == s:direction.right
                let self.direction.secondary = s:direction.down
            elseif self.direction.primary == s:direction.down
                let self.direction.secondary = s:direction.right
            endif
        elseif self.end_point[0] < self.start_point[0] && self.end_point[1] > self.start_point[1]
            " right up
            if index([s:direction.right, s:direction.up], self.direction.primary) < 0
                let self.direction.primary = s:direction.right
            endif
            if self.direction.primary == s:direction.right
                let self.direction.secondary = s:direction.up
            elseif self.direction.primary == s:direction.up
                let self.direction.secondary = s:direction.right
            endif
        endif
    endif
endfunction

function! vimio#drawline#get_corner_char(direction) dict abort
    let corner_char = g:vimio_config_line_and_box_corner_chars[a:direction][g:vimio_state_draw_line_index]
    let cross_style_dict = g:vimio_config_draw_cross_styles[g:vimio_state_cross_style_index]
    return get(cross_style_dict, corner_char, corner_char)
endfunction


" The diagonal line currently does not support cross mode.
function! vimio#drawline#get_diagonal_corner_char(direction, start_point_class) dict abort
    let search_key = a:direction . '-' . a:start_point_class
    return g:vimio_config_diagonal_line_corner_chars[search_key][g:vimio_state_draw_line_index]
endfunction

" start : [4, 4, '/']
" end : [8, 6, '-']
" corner : [6, 6]
" points: [[5, 5, '/']]
function! vimio#drawline#plan_diagonal_path(start, end, direction) abort
    let result = {
                \ 'start': [a:start[0], a:start[1], ''],
                \ 'end': [a:end[0], a:end[1], ''],
                \ 'corner': [],
                \ 'points': []
                \}
    " right-up and down-left
    if a:direction ==# 'right-up'
        let delta_row = a:start[0] - a:end[0]
        let delta_col = a:end[1] - a:start[1]

        if delta_row == delta_col
            let result.start[2] = '/'
            let result.end[2]='/'

            for i in range(1, delta_row-1)
                let row = a:end[0] + i
                let col = a:end[1] - i
                call add(result.points, [row, col, '/'])
            endfor
        elseif delta_row > delta_col
            "      1234
            "     1   │e       delta_row = 7
            "     2   │        delta_col = 3
            "     3   │        real_step_row = 7 - 3 = 4
            "     4   │
            "     5   '
            "     6  /
            "     7 /
            "     8/
            "     s
            let result.start[2] = '/'
            let result.end[2] = '|'

            let real_step_row = delta_row - delta_col
            for row in range(a:end[0]+1, a:end[0]+real_step_row-1)
                call add(result.points, [row, a:end[1], '|'])
            endfor
            let result.corner = [a:end[0]+real_step_row, a:end[1]]

            for i in range(1, delta_col-1)
                let row = result.corner[0] + i
                let col = result.corner[1] - i
                call add(result.points, [row, col, '/'])
            endfor
        elseif delta_row < delta_col
            "    123456789e
            "   1        /       delta_col = 8
            "   2       /        delta_row = 4
            "   3      /         real_step_col = 8 - 4 = 4
            "   4     /
            "   5----'
            "    s
            let result.start[2] = '-'
            let result.end[2] = '/'
            let real_step_col = delta_col - delta_row
            for i in range(1, delta_row-1)
                let row = a:end[0] + i
                let col = a:end[1] - i
                call add(result.points, [row, col, '/'])
            endfor
            let result.corner = [a:start[0], a:start[1]+real_step_col]
            for col in range(a:start[1]+1, a:start[1]+real_step_col-1)
                call add(result.points, [a:start[0], col, '-'])
            endfor
        endif
    elseif a:direction ==# 'up-left'
        let delta_row = a:start[0] - a:end[0]
        let delta_col = a:start[1] - a:end[1]

        "   123456789      e123    e 1234
        "  1----.          1\      1 \     
        "  2e    \         2 \     2  \    
        "  3      \        3  '    3   \   
        "  4       \       4  |    4    \  
        "  5       s       5  |s         s 
        if delta_row == delta_col
            let result.start[2] = '\'
            let result.end[2] = '\'
            for i in range(1, delta_row-1)
                let row = a:end[0] + i
                let col = a:end[1] + i
                call add(result.points, [row, col, '\'])
            endfor
        elseif delta_row > delta_col
            let result.start[2] = '|'
            let result.end[2] = '\'
            for i in range(1, delta_col-1)
                let row = a:end[0] + i
                let col = a:end[1] + i
                call add(result.points, [row, col, '\'])
            endfor
            let result.corner = [a:end[0]+delta_col, a:start[1]]
            for row in range(a:end[0]+delta_col+1, a:start[0]-1)
                call add(result.points, [row, a:start[1], '|'])
            endfor
        elseif delta_row < delta_col
            let result.start[2] = '\'
            let result.end[2] = '-'
            let real_step_col = delta_col - delta_row
            for col in range(a:end[1]+1, a:end[1]+real_step_col-1)
                call add(result.points, [a:end[0], col, '-'])
            endfor
            let result.corner = [a:end[0], a:end[1]+real_step_col]
            for i in range(1, delta_row-1)
                let row = a:end[0] + i
                let col = a:end[1]+real_step_col + i
                call add(result.points, [row, col, '\'])
            endfor
        endif
    elseif a:direction ==# 'right-down'
        let delta_row = a:end[0] - a:start[0]
        let delta_col = a:end[1] - a:start[1]

        if delta_row == delta_col
            let result.start[2] = '\'
            let result.end[2] = '\'
            for i in range(1, delta_row-1)
                let row = a:start[0] + i
                let col = a:start[1] + i
                call add(result.points, [row, col, '\'])
            endfor
        elseif delta_row > delta_col
            let result.start[2] = '\'
            let result.end[2] = '|'
            for i in range(1, delta_col - 1)
                let row = a:start[0] + i
                let col = a:start[1] + i
                call add(result.points, [row, col, '\'])
            endfor
            let result.corner = [a:start[0]+delta_col, a:end[1]]
            for row in range(a:start[0]+delta_col+1, a:end[0]-1)
                call add(result.points, [row, a:end[1], '|'])
            endfor
        elseif delta_row < delta_col
            let result.start[2] = '-'
            let result.end[2] = '\'
            let real_step_col = delta_col - delta_row
            for col in range(a:start[1]+1, a:start[1]+real_step_col-1)
                call add(result.points, [a:start[0], col, '-'])
            endfor
            let result.corner = [a:start[0], a:start[1]+real_step_col]
            for i in range(1, delta_row-1)
                let row = a:start[0] +i
                let col = a:start[1] + real_step_col + i
                call add(result.points, [row, col, '\'])
            endfor
        endif
    elseif a:direction ==# 'left-down'
        let delta_row = a:end[0] - a:start[0]
        let delta_col = a:start[1] - a:end[1]

        if delta_row == delta_col
            let result.start[2] = '/'
            let result.end[2] = '/'
            for i in range(1, delta_row-1)
                let row = a:start[0] + i
                let col = a:start[1] - i
                call add(result.points, [row, col, '/'])
            endfor
        elseif delta_row > delta_col
            let result.start[2] = '/'
            let result.end[2] = '|'
            for i in range(1, delta_col-1)
                let row = a:start[0] + i
                let col = a:start[1] - i
                call add(result.points, [row, col, '/'])
            endfor
            let result.corner = [a:start[0]+delta_col, a:end[1]]
            for row in range(a:start[0]+delta_col+1, a:end[0]-1)
                call add(result.points, [row, a:end[1], '|'])
            endfor
        elseif delta_row < delta_col
            let result.start[2] = '-'
            let result.end[2] = '/'
            let real_step_col = delta_col - delta_row
            for i in range(1, delta_row-1)
                let row = a:end[0] - i
                let col = a:end[1] + i
                call add(result.points, [row, col, '/'])
            endfor
            let result.corner = [a:start[0], a:end[1]+delta_row]
            for col in range(a:end[1]+delta_row+1, a:start[1]-1)
                call add(result.points, [a:start[0], col, '-'])
            endfor
        endif
    elseif a:direction ==# 'up-right' 
        let delta_row = a:start[0] - a:end[0]
        let delta_col = a:end[1] - a:start[1]

        if delta_row == delta_col
            let result.start[2] = '/'
            let result.end[2] = '/'
            for i in range(1, delta_row-1)
                let row = a:end[0] + i
                let col = a:end[1] - i
                call add(result.points, [row, col, '/'])
            endfor
        elseif delta_row > delta_col
            let result.start[2] = '|'
            let result.end[2] = '/'
            for i in range(1, delta_col-1)
                let row = a:end[0] + i
                let col = a:end[1] - i
                call add(result.points, [row, col, '/'])
            endfor
            let result.corner = [a:end[0]+delta_col, a:start[1]]
            for row in range(a:end[0]+delta_col+1, a:start[0]-1)
                call add(result.points, [row, a:start[1], '|'])
            endfor
        elseif delta_row < delta_col
            let result.start[2] = '/'
            let result.end[2] = '-'
            let real_step_col = delta_col - delta_row
            for i in range(1, delta_row-1)
                let row = a:start[0] - i
                let col = a:start[1] + i
                call add(result.points, [row, col, '/'])
            endfor
            let result.corner = [a:end[0], a:start[1]+delta_row]
            for col in range(a:start[1]+delta_row+1, a:end[1]-1)
                call add(result.points, [a:end[0], col, '-'])
            endfor
        endif
    elseif a:direction ==# 'down-left'
        let delta_row = a:end[0] - a:start[0]
        let delta_col = a:start[1] - a:end[1]

        if delta_row == delta_col
            let result.start[2] = '/'
            let result.end[2]='/'

            for i in range(1, delta_row-1)
                let row = a:start[0] + i
                let col = a:start[1] - i
                call add(result.points, [row, col, '/'])
            endfor
        elseif delta_row > delta_col
            let result.start[2] = '|'
            let result.end[2] = '/'

            let real_step_row = delta_row - delta_col
            for row in range(a:start[0]+1, a:start[0]+real_step_row-1)
                call add(result.points, [row, a:start[1], '|'])
            endfor
            let result.corner = [a:start[0]+real_step_row, a:start[1]]

            for i in range(1, delta_col-1)
                let row = result.corner[0] + i
                let col = result.corner[1] - i
                call add(result.points, [row, col, '/'])
            endfor
        elseif delta_row < delta_col
            let result.start[2] = '/'
            let result.end[2] = '-'
            let real_step_col = delta_col - delta_row
            for i in range(1, delta_row-1)
                let row = a:start[0] + i
                let col = a:start[1] - i
                call add(result.points, [row, col, '/'])
            endfor
            let result.corner = [a:end[0], a:end[1]+real_step_col]
            for col in range(a:end[1]+1, a:end[1]+real_step_col-1)
                call add(result.points, [a:end[0], col, '-'])
            endfor
        endif
    elseif a:direction ==# 'left-up'
        let delta_row = a:start[0] - a:end[0]
        let delta_col = a:start[1] - a:end[1]
        if delta_col == delta_row
            let result.start[2] = '\'
            let result.end[2] = '\'
            for i in range(1, delta_row-1)
                let row = a:end[0] + i
                let col = a:end[1] + i
                call add(result.points, [row, col, '\'])
            endfor
        elseif delta_row > delta_col
            let result.start[2] = '\'
            let result.end[2] = '|'
            let real_step_row = delta_row - delta_col
            for row in range(a:end[0]+1, a:end[0]+real_step_row-1)
                call add(result.points, [row, a:end[1], '|'])
            endfor
            let result.corner = [ a:end[0]+real_step_row, a:end[1] ]
            for i in range(1, delta_col-1)
                let row = a:end[0]+real_step_row + i
                let col = a:end[1] + i
                call add(result.points, [row, col, '\'])
            endfor
        elseif delta_row < delta_col
            let result.start[2] = '-'
            let result.end[2] = '\'
            let real_step_col = delta_col - delta_row
            for i in range(1, delta_row-1)
                let row = a:end[0] + i
                let col = a:end[1] + i
                call add(result.points, [row, col, '\'])
            endfor
            let result.corner = [a:start[0], a:end[1]+delta_row]
            for col in range(a:end[1]+delta_row+1, a:start[1]-1)
                call add(result.points, [a:start[0], col, '-'])
            endfor
        endif
    elseif a:direction ==# 'down-right'
        let delta_row = a:end[0] - a:start[0]
        let delta_col = a:end[1] - a:start[1]
        if delta_col == delta_row
            let result.start[2] = '\'
            let result.end[2] = '\'
            for i in range(1, delta_row-1)
                let row = a:start[0] + i
                let col = a:start[1] + i
                call add(result.points, [row, col, '\'])
            endfor
        elseif delta_row > delta_col
            let result.end[2] = '\'
            let result.start[2] = '|'
            let real_step_row = delta_row - delta_col
            for row in range(a:start[0]+1, a:start[0]+real_step_row-1)
                call add(result.points, [row, a:start[1], '|'])
            endfor
            let result.corner = [ a:start[0]+real_step_row, a:start[1] ]
            for i in range(1, delta_col-1)
                let row = a:start[0]+real_step_row + i
                let col = a:start[1] + i
                call add(result.points, [row, col, '\'])
            endfor
        elseif delta_row < delta_col
            let result.end[2] = '-'
            let result.start[2] = '\'
            let real_step_col = delta_col - delta_row
            for i in range(1, delta_row-1)
                let row = a:start[0] + i
                let col = a:start[1] + i
                call add(result.points, [row, col, '\'])
            endfor
            let result.corner = [a:end[0], a:start[1]+delta_row]
            for col in range(a:start[1]+delta_row+1, a:end[1]-1)
                call add(result.points, [a:end[0], col, '-'])
            endfor
        endif
    endif

    return result
endfunction


" =============================================================================================================
" * Angle = arctangent(|Δy / Δx|)
" . When the angle = 45° → Diagonal line → Only a diagonal line is needed
" . When the angle < 45° → More horizontal → First a horizontal line, then a diagonal line to add height
" . When the angle > 45° → More vertical → First a diagonal line, then a vertical line to add height
"
"   Other situations are similar.
"  ┌───────────────────────────────────────┬─────────────────────────────────┐
"  │          e    e    |s-----.      s    │      .------s  s|e          e   │
"  │         /     |    |       \      \   │     /         / | \         |   │                
"  │        /      |    |        \      \  │    /         '  |  \        |   │                
"  │ s-----'       '    |         e      ' │   e          |  |   '------s'   │                
"  │              /     |                │ │              |  |            \  │                
"  │(right-up)   s      | (right-down)   e │ (left-down)  e  |(left-up)    s │
"  ├────────────────────|──────────────────┼─────────────────|───────────────┤
"  │  e    e---.        |                e │                 | s             │ 
"  │   \        \       |     .----e    /  │    s        s   | │             │ 
"  │    '        \      |    /         /   │    │        /   | '  s          │ 
"  │    |         \     |   /         '    │    │       /    |  \  \         │
"  │    |          s    |  s          │    │    '      /     |   e  \        │
"  │    s               |             s    │   /   e──'      |       '----e  │
"  │  (up-left)         | (up-right)       │  e (down-left)  |(down-right)   │
"  └───────────────────────────────────────┴─────────────────────────────────┘
"  If it is a diagonal at a 45-degree angle, then simply draw a slanted line.
" Generate preview characters; if there are overlaps, take an additional step.
"     123456789
"    .------------------------------
"   1| start_point
"   2|  A----.       
"   3| (2,3) |       
"   4|       v       
"   5|       B end_point       
"   6|      (5,8)
function! vimio#drawline#update_preview() dict abort

    
    call self.update_direction()

    " Four fundamental directions
    let preview_text = []
    let line_x_style = g:vimio_config_draw_line_styles[g:vimio_state_draw_line_index][0]
    let line_y_style = g:vimio_config_draw_line_styles[g:vimio_state_draw_line_index][1]

    let line_diagonal_style_0 = g:vimio_config_draw_diagonal_line_styles[g:vimio_state_draw_line_index][0]
    let line_diagonal_style_1 = g:vimio_config_draw_diagonal_line_styles[g:vimio_state_draw_line_index][1]

    let line_styles = {
                \ '-': line_x_style,
                \ '|': line_y_style,
                \ '/': line_diagonal_style_0,
                \ '\': line_diagonal_style_1
                \}

    if self.direction.primary == s:direction.up && self.direction.secondary == s:direction.invalid
        if self.arrow.start.enable
            call add(preview_text, [self.start_point[0], self.start_point[1], g:vimio_config_arrow_chars_map.down[line_y_style]])
        else
            call add(preview_text, [self.start_point[0], self.start_point[1], line_y_style])
        endif

        if self.arrow.end.enable
            call add(preview_text, [self.end_point[0], self.end_point[1], g:vimio_config_arrow_chars_map.up[line_y_style]])
        else
            call add(preview_text, [self.end_point[0], self.end_point[1], line_y_style])
        endif

        for row in range(self.end_point[0] + 1, self.start_point[0] - 1)
            call add(preview_text, [row, self.start_point[1], line_y_style])
        endfor

        let self.pop_up.anchor = 'topleft'
        let self.pop_up.pos = copy(self.end_point)
    elseif self.direction.primary == s:direction.down && self.direction.secondary == s:direction.invalid
        if self.arrow.start.enable
            call add(preview_text, [self.start_point[0], self.start_point[1], g:vimio_config_arrow_chars_map.up[line_y_style]])
        else
            call add(preview_text, [self.start_point[0], self.start_point[1], line_y_style])
        endif

        if self.arrow.end.enable
            call add(preview_text, [self.end_point[0], self.end_point[1], g:vimio_config_arrow_chars_map.down[line_y_style]])
        else
            call add(preview_text, [self.end_point[0], self.end_point[1], line_y_style])
        endif

        for row in range(self.start_point[0] + 1, self.end_point[0] - 1)
            call add(preview_text, [row, self.start_point[1], line_y_style])
        endfor
        let self.pop_up.anchor = 'botleft'
        let self.pop_up.pos = copy(self.start_point)
    elseif self.direction.primary == s:direction.left && self.direction.secondary == s:direction.invalid
        if self.arrow.start.enable
            call add(preview_text, [self.start_point[0], self.start_point[1], g:vimio_config_arrow_chars_map.right[line_x_style]])
        else
            call add(preview_text, [self.start_point[0], self.start_point[1], line_x_style])
        endif

        if self.arrow.end.enable
            call add(preview_text, [self.end_point[0], self.end_point[1], g:vimio_config_arrow_chars_map.left[line_x_style]])
        else
            call add(preview_text, [self.end_point[0], self.end_point[1], line_x_style])
        endif

        for col in range(self.end_point[1] + 1, self.start_point[1] - 1)
            call add(preview_text, [self.start_point[0], col, line_x_style])
        endfor
        let self.pop_up.anchor = 'topleft'
        let self.pop_up.pos = copy(self.end_point)
    elseif self.direction.primary == s:direction.right && self.direction.secondary == s:direction.invalid
        if self.arrow.start.enable
            call add(preview_text, [self.start_point[0], self.start_point[1], g:vimio_config_arrow_chars_map.left[line_x_style]])
        else
            call add(preview_text, [self.start_point[0], self.start_point[1], line_x_style])
        endif

        if self.arrow.end.enable
            call add(preview_text, [self.end_point[0], self.end_point[1], g:vimio_config_arrow_chars_map.right[line_x_style]])
        else
            call add(preview_text, [self.end_point[0], self.end_point[1], line_x_style])
        endif

        for col in range(self.start_point[1] + 1, self.end_point[1] - 1)
            call add(preview_text, [self.start_point[0], col, line_x_style])
        endfor
        let self.pop_up.anchor = 'topright'
        let self.pop_up.pos = copy(self.start_point)
    elseif self.direction.primary == s:direction.up && self.direction.secondary == s:direction.left
        " B<----.(corner)                                 
        "(end)  |                                         
        "       |                                         
        "       A (start)                                 
        if self.diagonal_enable
            let points = vimio#drawline#plan_diagonal_path(self.start_point, self.end_point, 'up-left')
            
            " echom "points: " . string(points)
            " echo "vimio_config_arrow_chars_map: " . string(g:vimio_config_arrow_chars_map.down)


            let start_char = (self.arrow.start.enable) ? g:vimio_config_arrow_chars_map.down[line_styles[points.start[2]]] : line_styles[points.start[2]]
            call add(preview_text, [self.start_point[0], self.start_point[1], start_char])

            let end_char = (self.arrow.end.enable) ? g:vimio_config_arrow_chars_map.left[line_styles[points.end[2]]] : line_styles[points.end[2]]
            call add(preview_text, [self.end_point[0], self.end_point[1], end_char])

            " 添加拐点
            let corner_key = (points.start[2] == '-' || points.start[2] == '|') ? 's' : 'd'

            if !empty(points.corner)
                call add(preview_text, [points.corner[0], points.corner[1], self.get_diagonal_corner_char('up-left', corner_key)])
            endif

            " 添加直线和斜线部分
            for point in points.points
                call add(preview_text, [point[0], point[1], line_styles[point[2]]])
            endfor

        else
            if self.arrow.start.enable
                call add(preview_text, [self.start_point[0], self.start_point[1], g:vimio_config_arrow_chars_map.down[line_y_style]])
            else
                call add(preview_text, [self.start_point[0], self.start_point[1], line_y_style])
            endif
            if self.arrow.end.enable
                call add(preview_text, [self.end_point[0], self.end_point[1], g:vimio_config_arrow_chars_map.left[line_x_style]])
            else
                call add(preview_text, [self.end_point[0], self.end_point[1], line_x_style])
            endif
            
            call add(preview_text, [self.end_point[0], self.start_point[1], self.get_corner_char('up-left')])
            
            for col in range(self.end_point[1]+1, self.start_point[1]-1)
                call add(preview_text, [self.end_point[0], col, line_x_style])
            endfor

            for row in range(self.end_point[0]+1, self.start_point[0]-1)
                call add(preview_text, [row, self.start_point[1], line_y_style])
            endfor
        endif

        let self.pop_up.anchor = 'topleft'
        let self.pop_up.pos = copy(self.end_point)
    elseif self.direction.primary == s:direction.up && self.direction.secondary == s:direction.right
        if self.diagonal_enable
            let points = vimio#drawline#plan_diagonal_path(self.start_point, self.end_point, 'up-right')
            
            let start_char = (self.arrow.start.enable) ? g:vimio_config_arrow_chars_map.down[line_styles[points.start[2]]] : line_styles[points.start[2]]
            call add(preview_text, [self.start_point[0], self.start_point[1], start_char])

            let end_char = (self.arrow.end.enable) ? g:vimio_config_arrow_chars_map.right[line_styles[points.end[2]]] : line_styles[points.end[2]]
            call add(preview_text, [self.end_point[0], self.end_point[1], end_char])

            " 添加拐点
            let corner_key = (points.start[2] == '-' || points.start[2] == '|') ? 's' : 'd'

            if !empty(points.corner)
                call add(preview_text, [points.corner[0], points.corner[1], self.get_diagonal_corner_char('up-right', corner_key)])
            endif

            " 添加直线和斜线部分
            for point in points.points
                call add(preview_text, [point[0], point[1], line_styles[point[2]]])
            endfor
        else
            " corner.------->B(end)                           
            "       |                                         
            "       |                                         
            "       A (start)                                 
            if self.arrow.start.enable
                call add(preview_text, [self.start_point[0], self.start_point[1], g:vimio_config_arrow_chars_map.down[line_y_style]])
            else
                call add(preview_text, [self.start_point[0], self.start_point[1], line_y_style])
            endif
            if self.arrow.end.enable
                call add(preview_text, [self.end_point[0], self.end_point[1], g:vimio_config_arrow_chars_map.right[line_x_style]])
            else
                call add(preview_text, [self.end_point[0], self.end_point[1], line_x_style])
            endif
            
            call add(preview_text, [self.end_point[0], self.start_point[1], self.get_corner_char('up-right')])
            
            for col in range(self.start_point[1]+1, self.end_point[1]-1)
                call add(preview_text, [self.end_point[0], col, line_x_style])
            endfor

            for row in range(self.end_point[0]+1, self.start_point[0]-1)
                call add(preview_text, [row, self.start_point[1], line_y_style])
            endfor
        endif
        let self.pop_up.anchor = 'topright'
        let self.pop_up.pos = [self.end_point[0], self.start_point[1]]
    elseif self.direction.primary == s:direction.down && self.direction.secondary == s:direction.left
        if self.diagonal_enable
            let points = vimio#drawline#plan_diagonal_path(self.start_point, self.end_point, 'down-left')

            let start_char = (self.arrow.start.enable) ? g:vimio_config_arrow_chars_map.up[line_styles[points.start[2]]] : line_styles[points.start[2]]
            call add(preview_text, [self.start_point[0], self.start_point[1], start_char])

            let end_char = (self.arrow.end.enable) ? g:vimio_config_arrow_chars_map.left[line_styles[points.end[2]]] : line_styles[points.end[2]]
            call add(preview_text, [self.end_point[0], self.end_point[1], end_char])

            " 添加拐点
            let corner_key = (points.start[2] == '-' || points.start[2] == '|') ? 's' : 'd'
            if !empty(points.corner)
                call add(preview_text, [points.corner[0], points.corner[1], self.get_diagonal_corner_char('down-left', corner_key)])
            endif

            " 添加直线和斜线部分
            for point in points.points
                call add(preview_text, [point[0], point[1], line_styles[point[2]]])
            endfor
        else
            "             |(start)                            
            "             |                                   
            "             |                                   
            " (end)-------'(corner)                           
            if self.arrow.start.enable
                call add(preview_text, [self.start_point[0], self.start_point[1], g:vimio_config_arrow_chars_map.up[line_y_style]])
            else
                call add(preview_text, [self.start_point[0], self.start_point[1], line_y_style])
            endif
            if self.arrow.end.enable
                call add(preview_text, [self.end_point[0], self.end_point[1], g:vimio_config_arrow_chars_map.left[line_x_style]])
            else
                call add(preview_text, [self.end_point[0], self.end_point[1], line_x_style])
            endif
            
            call add(preview_text, [self.end_point[0], self.start_point[1], self.get_corner_char('down-left')])
            
            for col in range(self.end_point[1]+1, self.start_point[1]-1)
                call add(preview_text, [self.end_point[0], col, line_x_style])
            endfor

            for row in range(self.start_point[0]+1, self.end_point[0]-1)
                call add(preview_text, [row, self.start_point[1], line_y_style])
            endfor
        endif
        let self.pop_up.anchor = 'botleft'
        let self.pop_up.pos = [self.start_point[0], self.end_point[1]]
    elseif self.direction.primary == s:direction.down && self.direction.secondary == s:direction.right
        if self.diagonal_enable
            let points = vimio#drawline#plan_diagonal_path(self.start_point, self.end_point, 'down-right')
            
            let start_char = (self.arrow.start.enable) ? g:vimio_config_arrow_chars_map.up[line_styles[points.start[2]]] : line_styles[points.start[2]]
            call add(preview_text, [self.start_point[0], self.start_point[1], start_char])

            let end_char = (self.arrow.end.enable) ? g:vimio_config_arrow_chars_map.right[line_styles[points.end[2]]] : line_styles[points.end[2]]
            call add(preview_text, [self.end_point[0], self.end_point[1], end_char])

            " 添加拐点
            let corner_key = (points.start[2] == '-' || points.start[2] == '|') ? 's' : 'd'

            if !empty(points.corner)
                call add(preview_text, [points.corner[0], points.corner[1], self.get_diagonal_corner_char('down-right', corner_key)])
            endif

            " 添加直线和斜线部分
            for point in points.points
                call add(preview_text, [point[0], point[1], line_styles[point[2]]])
            endfor
        else
            "             |(start)                            
            "             |                                   
            "             |                                   
            "     (corner)'---------- (end)                   
            if self.arrow.start.enable
                call add(preview_text, [self.start_point[0], self.start_point[1], g:vimio_config_arrow_chars_map.up[line_y_style]])
            else
                call add(preview_text, [self.start_point[0], self.start_point[1], line_y_style])
            endif
            if self.arrow.end.enable
                call add(preview_text, [self.end_point[0], self.end_point[1], g:vimio_config_arrow_chars_map.right[line_x_style]])
            else
                call add(preview_text, [self.end_point[0], self.end_point[1], line_x_style])
            endif
            
            call add(preview_text, [self.end_point[0], self.start_point[1], self.get_corner_char('down-right')])
            
            for col in range(self.start_point[1]+1, self.end_point[1]-1)
                call add(preview_text, [self.end_point[0], col, line_x_style])
            endfor

            for row in range(self.start_point[0]+1, self.end_point[0]-1)
                call add(preview_text, [row, self.start_point[1], line_y_style])
            endfor
        endif
        let self.pop_up.anchor = 'botright'
        let self.pop_up.pos = copy(self.start_point)
    elseif self.direction.primary == s:direction.left && self.direction.secondary == s:direction.up
        if self.diagonal_enable
            let points = vimio#drawline#plan_diagonal_path(self.start_point, self.end_point, 'left-up')
            
            let start_char = (self.arrow.start.enable) ? g:vimio_config_arrow_chars_map.right[line_styles[points.start[2]]] : line_styles[points.start[2]]
            call add(preview_text, [self.start_point[0], self.start_point[1], start_char])

            let end_char = (self.arrow.end.enable) ? g:vimio_config_arrow_chars_map.up[line_styles[points.end[2]]] : line_styles[points.end[2]]
            call add(preview_text, [self.end_point[0], self.end_point[1], end_char])

            " 添加拐点
            let corner_key = (points.start[2] == '-' || points.start[2] == '|') ? 's' : 'd'

            if !empty(points.corner)
                call add(preview_text, [points.corner[0], points.corner[1], self.get_diagonal_corner_char('left-up', corner_key)])
            endif

            " 添加直线和斜线部分
            for point in points.points
                call add(preview_text, [point[0], point[1], line_styles[point[2]]])
            endfor
        else
            "    (end) |                                      
            "          |                                      
            "          |                                      
            "  (corner)'----------(start)                          
            if self.arrow.start.enable
                call add(preview_text, [self.start_point[0], self.start_point[1], g:vimio_config_arrow_chars_map.right[line_x_style]])
            else
                call add(preview_text, [self.start_point[0], self.start_point[1], line_x_style])
            endif
            if self.arrow.end.enable
                call add(preview_text, [self.end_point[0], self.end_point[1], g:vimio_config_arrow_chars_map.up[line_y_style]])
            else
                call add(preview_text, [self.end_point[0], self.end_point[1], line_y_style])
            endif
            
            call add(preview_text, [self.start_point[0], self.end_point[1], self.get_corner_char('left-up')])
            
            for col in range(self.end_point[1]+1, self.start_point[1]-1)
                call add(preview_text, [self.start_point[0], col, line_x_style])
            endfor

            for row in range(self.end_point[0]+1, self.start_point[0]-1)
                call add(preview_text, [row, self.end_point[1], line_y_style])
            endfor
        endif
        let self.pop_up.anchor = 'topleft'
        let self.pop_up.pos = copy(self.end_point)
    elseif self.direction.primary == s:direction.left && self.direction.secondary == s:direction.down
        if self.diagonal_enable
            let points = vimio#drawline#plan_diagonal_path(self.start_point, self.end_point, 'left-down')
            
            let start_char = (self.arrow.start.enable) ? g:vimio_config_arrow_chars_map.right[line_styles[points.start[2]]] : line_styles[points.start[2]]
            call add(preview_text, [self.start_point[0], self.start_point[1], start_char])

            let end_char = (self.arrow.end.enable) ? g:vimio_config_arrow_chars_map.down[line_styles[points.end[2]]] : line_styles[points.end[2]]
            call add(preview_text, [self.end_point[0], self.end_point[1], end_char])

            " 添加拐点
            let corner_key = (points.start[2] == '-' || points.start[2] == '|') ? 's' : 'd'

            if !empty(points.corner)
                call add(preview_text, [points.corner[0], points.corner[1], self.get_diagonal_corner_char('left-down', corner_key)])
            endif

            " 添加直线和斜线部分
            for point in points.points
                call add(preview_text, [point[0], point[1], line_styles[point[2]]])
            endfor
        else
            "  (corner).--------------                         
            "          |        (start)                        
            "          |                                       
            "          v(end)                                      
            if self.arrow.start.enable
                call add(preview_text, [self.start_point[0], self.start_point[1], g:vimio_config_arrow_chars_map.right[line_x_style]])
            else
                call add(preview_text, [self.start_point[0], self.start_point[1], line_x_style])
            endif
            if self.arrow.end.enable
                call add(preview_text, [self.end_point[0], self.end_point[1], g:vimio_config_arrow_chars_map.down[line_y_style]])
            else
                call add(preview_text, [self.end_point[0], self.end_point[1], line_y_style])
            endif
            
            call add(preview_text, [self.start_point[0], self.end_point[1], self.get_corner_char('left-down')])
            
            for col in range(self.end_point[1]+1, self.start_point[1]-1)
                call add(preview_text, [self.start_point[0], col, line_x_style])
            endfor

            for row in range(self.start_point[0]+1, self.end_point[0]-1)
                call add(preview_text, [row, self.end_point[1], line_y_style])
            endfor
        endif

        let self.pop_up.anchor = 'botleft'
        let self.pop_up.pos = [self.start_point[0], self.end_point[1]]
    elseif self.direction.primary == s:direction.right && self.direction.secondary == s:direction.up
        if self.diagonal_enable
            let points = vimio#drawline#plan_diagonal_path(self.start_point, self.end_point, 'right-up')

            let start_char = (self.arrow.start.enable) ? g:vimio_config_arrow_chars_map.left[line_styles[points.start[2]]] : line_styles[points.start[2]]
            call add(preview_text, [self.start_point[0], self.start_point[1], start_char])

            let end_char = (self.arrow.end.enable) ? g:vimio_config_arrow_chars_map.up[line_styles[points.end[2]]] : line_styles[points.end[2]]
            call add(preview_text, [self.end_point[0], self.end_point[1], end_char])

            " 添加拐点
            let corner_key = (points.start[2] == '-' || points.start[2] == '|') ? 's' : 'd'
            if !empty(points.corner)
                call add(preview_text, [points.corner[0], points.corner[1], self.get_diagonal_corner_char('right-up', corner_key)])
            endif

            " 添加直线和斜线部分
            for point in points.points
                call add(preview_text, [point[0], point[1], line_styles[point[2]]])
            endfor
        else
            "                ^(end)                            
            "                |                                 
            "  (start)       |                                 
            "   -------------'(corner)                             
            if self.arrow.start.enable
                call add(preview_text, [self.start_point[0], self.start_point[1], g:vimio_config_arrow_chars_map.left[line_x_style]])
            else
                call add(preview_text, [self.start_point[0], self.start_point[1], line_x_style])
            endif
            if self.arrow.end.enable
                call add(preview_text, [self.end_point[0], self.end_point[1], g:vimio_config_arrow_chars_map.up[line_y_style]])
            else
                call add(preview_text, [self.end_point[0], self.end_point[1], line_y_style])
            endif
            
            call add(preview_text, [self.start_point[0], self.end_point[1], self.get_corner_char('right-up')])
            
            for col in range(self.start_point[1]+1, self.end_point[1]-1)
                call add(preview_text, [self.start_point[0], col, line_x_style])
            endfor

            for row in range(self.end_point[0]+1, self.start_point[0]-1)
                call add(preview_text, [row, self.end_point[1], line_y_style])
            endfor
        endif

        let self.pop_up.anchor = 'topright'
        let self.pop_up.pos = [self.end_point[0], self.start_point[1]]
    elseif self.direction.primary == s:direction.right && self.direction.secondary == s:direction.down
        if self.diagonal_enable
            let points = vimio#drawline#plan_diagonal_path(self.start_point, self.end_point, 'right-down')
            
            let start_char = (self.arrow.start.enable) ? g:vimio_config_arrow_chars_map.left[line_styles[points.start[2]]] : line_styles[points.start[2]]
            call add(preview_text, [self.start_point[0], self.start_point[1], start_char])

            let end_char = (self.arrow.end.enable) ? g:vimio_config_arrow_chars_map.down[line_styles[points.end[2]]] : line_styles[points.end[2]]
            call add(preview_text, [self.end_point[0], self.end_point[1], end_char])

            " 添加拐点
            let corner_key = (points.start[2] == '-' || points.start[2] == '|') ? 's' : 'd'

            if !empty(points.corner)
                call add(preview_text, [points.corner[0], points.corner[1], self.get_diagonal_corner_char('right-down', corner_key)])
            endif

            " 添加直线和斜线部分
            for point in points.points
                call add(preview_text, [point[0], point[1], line_styles[point[2]]])
            endfor
        else
            "   ------------.(corner)                          
            "  (start)      |                                  
            "               |                                  
            "               v(end)                                 
            if self.arrow.start.enable
                call add(preview_text, [self.start_point[0], self.start_point[1], g:vimio_config_arrow_chars_map.left[line_x_style]])
            else
                call add(preview_text, [self.start_point[0], self.start_point[1], line_x_style])
            endif
            if self.arrow.end.enable
                call add(preview_text, [self.end_point[0], self.end_point[1], g:vimio_config_arrow_chars_map.down[line_y_style]])
            else
                call add(preview_text, [self.end_point[0], self.end_point[1], line_y_style])
            endif
            
            call add(preview_text, [self.start_point[0], self.end_point[1], self.get_corner_char('right-down')])
            
            for col in range(self.start_point[1]+1, self.end_point[1]-1)
                call add(preview_text, [self.start_point[0], col, line_x_style])
            endfor

            for row in range(self.start_point[0]+1, self.end_point[0]-1)
                call add(preview_text, [row, self.end_point[1], line_y_style])
            endfor
        endif
        let self.pop_up.anchor = 'botright'
        let self.pop_up.pos = copy(self.start_point)
    endif

    let self.pop_up.txt = vimio#utils#get_rect_txt_for_single_width_char(preview_text, self.cross.enable, self.pop_up.pos)
    call vimio#popup#update_block({ 'new_text': self.pop_up.txt, 'anchor': self.pop_up.anchor })
endfunction


function! vimio#drawline#draw() dict abort
    " 1. Record the endpoint
    call self.record_end_point()
    " 2. Determine whether the endpoint and the starting point are the same.
    if self.is_start_end_point_same()
        return
    endif
    " 3. Generate preview characters and open the preview.
    call self.update_preview()
endfunction

function! vimio#drawline#start_arrow_show_flip() dict abort
    let val = self.arrow.start.enable
    let self.arrow.start.enable = !val
    call self.update_preview()
endfunction

function! vimio#drawline#end_arrow_show_flip() dict abort
    let val = self.arrow.end.enable
    let self.arrow.end.enable = !val
    call self.update_preview()
endfunction

function! vimio#drawline#diagonal_flip() dict abort
    let val = self.diagonal_enable
    let self.diagonal_enable = !val
    call self.update_preview()
endfunction

function! vimio#drawline#cross_flip() dict abort
    let val = self.cross.enable
    let self.cross.enable = !val
    call self.update_preview()
endfunction

" End and insert character
function! vimio#drawline#end() dict abort
    call vimio#replace#paste_block_clip(0, { 
                \ 'new_text': self.pop_up.txt,
                \ 'pos_start': [self.pop_up.pos[0], self.pop_up.pos[1]]
                \ })
    " Close the pop-up window here
    call vimio#popup#close_block()

    let [cur_chars_array, index] = vimio#utils#get_line_cells(self.end_point[0], self.end_point[1])
    let jumpcol = len(join(cur_chars_array[0:index], ''))
    " Move the cursor position to the end point.
    call cursor(self.end_point[0], jumpcol)

    call self.reset()
endfunction

function! vimio#drawline#cancel() dict abort
    " Close the pop-up window here
    call vimio#popup#close_block()

    call self.reset()
endfunction

function! vimio#drawline#continue_draw() dict abort
    if get(self, 'in_draw_context', v:false)
        call self.end()
    endif
    call self.start()
endfunction

