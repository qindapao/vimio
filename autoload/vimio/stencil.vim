" autoload/vimio/shapes.vim
" ----------------
" Graphical template system control module.
" Used to switch graphic sets, graphic indexes, load template files, and call 
" graphic generation functions.
"
" Contents:
" - vimio#stencil#switch_lev1_index(direction)
" - vimio#stencil#switch_lev2_index(direction)
" - vimio#stencil#update_lev2_info()
" - vimio#stencil#load_and_use_custom_drawset_funcs(func_name,indexes,index,file_name)
" - vimio#stencil#switch_define_graph_set(is_show)
" - vimio#stencil#get_default_graph_functions()
" - vimio#stencil#get_all_graph_functions()
" - vimio#stencil#cleanup_shape_subfuncs()

let s:vimio_stencil_graph_set_popup = v:null
let s:vimio_stencil_key_buffer = ''



function! vimio#stencil#popup_filter(winid, key) abort
    if a:key !~# '^\d$'
        " Non-numeric keys are handled by other processes.
        let s:vimio_stencil_key_buffer = ''
        return 0
    endif

    let s:vimio_stencil_key_buffer .= a:key

    if strlen(s:vimio_stencil_key_buffer) == 3
        " execute opration
        if stridx(s:vimio_stencil_key_buffer, '1') == 0
            let lev1_num = str2nr(strpart(s:vimio_stencil_key_buffer, 1))
            if lev1_num < len(g:vimio_config_shapes['value'])
                let g:vimio_config_shapes['set_index'] = lev1_num
            endif
        elseif stridx(s:vimio_stencil_key_buffer, '2') == 0
            let lev2_num = str2nr(strpart(s:vimio_stencil_key_buffer, 1))
            if type(g:vimio_config_shapes['value'][g:vimio_config_shapes['set_index']]['index']) != type([])
                if lev2_num < len(g:vimio_config_shapes['value'][g:vimio_config_shapes['set_index']]['value'])
                    let g:vimio_config_shapes['value'][g:vimio_config_shapes['set_index']]['index'] = lev2_num
                endif
            endif
        endif

        call vimio#stencil#update_lev2_info()
        call vimio#popup#update_cross_block()
        " Update the text in the template pop-up window.
        let lines_str = vimio#stencil#show_graph_set_text()
        call g:vimio_popup_all_popups[a:winid].update({
                    \ 'new_text': lines_str,
                    \ })

        let s:vimio_stencil_key_buffer = ''
    endif

    " Indicates that the key event has been processed.
    return 1
endfunction


function! vimio#stencil#show_graph_set_text()
    let set_index = g:vimio_config_shapes['set_index']
    let shapes_lev1s = g:vimio_config_shapes['value']
    let shape_set = shapes_lev1s[set_index]
    let stencil_name = g:vimio_config_shapes['stencil_set_name']
    let snapshot = get(g:vimio_config_shapes, 'snapshot', '')
    let sub_snapshot = get(shape_set, 'snapshot', '')
    let step = shape_set['step'][g:vimio_state_switch_lev2_step_index]
    let step1 = shape_set['step'][1]
    let lev2_index = shape_set['index']
    if type(lev2_index) == type([])
        let all_cnt = lev2_index[0]
        let now_cnt = lev2_index[1]
        let now_row = now_cnt / step1
        let now_col = now_cnt % step1
        let all_row = all_cnt / step1

        let step_str = 'step: ' . step . '(' . now_row . '/' . all_row . ',' . now_col . '/' . step1 . ') '
    else
        let step_str = 'step: ' . step . '(' . lev2_index . '/' . len(shape_set['value']) . ') '
    endif

    let lines = [
                \ 'stencil set name: ' . stencil_name . ' ',
                \ 'stencil index: ' . set_index . '/' . len(shapes_lev1s) . ' ',
                \ 'snapshot: ' . "\n" . snapshot ,
                \ 'stencil sub set name: ' . shape_set['name'] . ' ',
                \ 'sub snapshot: ' . "\n" . sub_snapshot ,
                \ step_str,
                \ ]
    return join(lines, "\n")
endfunction


function! vimio#stencil#show_graph_set_info()
    let lines_str = vimio#stencil#show_graph_set_text()
    let popup_def = { 
                \ 'new_text': lines_str, 
                \ 'anchor': 'botright',
                \ 'filter': function('vimio#stencil#popup_filter')
                \ }
    if type(s:vimio_stencil_graph_set_popup) == type({})
        call s:vimio_stencil_graph_set_popup.update(popup_def)
    else
        let s:vimio_stencil_graph_set_popup = vimio#popup#new(popup_def)
    endif
endfunction


function! vimio#stencil#switch_lev1_index(direction)
    if a:direction == 1
        let g:vimio_config_shapes['set_index'] = (g:vimio_config_shapes['set_index']+1) % len(g:vimio_config_shapes['value'])
    else
        let g:vimio_config_shapes['set_index'] = (g:vimio_config_shapes['set_index']-1 + len(g:vimio_config_shapes['value'])) % len(g:vimio_config_shapes['value'])
    endif

    call vimio#stencil#update_lev2_info()
    call vimio#popup#update_cross_block()
    call vimio#stencil#show_graph_set_info()
endfunction

function! vimio#stencil#switch_lev2_index(direction)
    if !exists('g:vimio_config_shapes')
       call vimio#stencil#switch_define_graph_set(0)
    endif

    let step = g:vimio_config_shapes['value'][g:vimio_config_shapes['set_index']]['step'][g:vimio_state_switch_lev2_step_index] * a:direction

    " If index is an array, the limit value is the first element of the array, otherwise it is the number of elements in value
    if type(g:vimio_config_shapes['value'][g:vimio_config_shapes['set_index']]['index']) == type([])
        let size_count = g:vimio_config_shapes['value'][g:vimio_config_shapes['set_index']]['index'][0]
        if a:direction == 1
            let g:vimio_config_shapes['value'][g:vimio_config_shapes['set_index']]['index'][1] = (g:vimio_config_shapes['value'][g:vimio_config_shapes['set_index']]['index'][1]+step) % size_count
        elseif a:direction == -1
            let g:vimio_config_shapes['value'][g:vimio_config_shapes['set_index']]['index'][1] = (g:vimio_config_shapes['value'][g:vimio_config_shapes['set_index']]['index'][1]+step+size_count) % size_count

        endif
    else
        let size_count = len(g:vimio_config_shapes['value'][g:vimio_config_shapes['set_index']]['value'])
        if a:direction == 1
            let g:vimio_config_shapes['value'][g:vimio_config_shapes['set_index']]['index'] = (g:vimio_config_shapes['value'][g:vimio_config_shapes['set_index']]['index']+step) % size_count
        elseif a:direction == -1
            let g:vimio_config_shapes['value'][g:vimio_config_shapes['set_index']]['index'] = (g:vimio_config_shapes['value'][g:vimio_config_shapes['set_index']]['index']+step+size_count) % size_count
        endif
    endif

    call vimio#stencil#update_lev2_info()
    call vimio#popup#update_cross_block()
    call vimio#stencil#show_graph_set_info()
endfunction

function! vimio#stencil#switch_sub_step() abort
    let g:vimio_state_switch_lev2_step_index = !g:vimio_state_switch_lev2_step_index
    call vimio#stencil#switch_lev2_index(0)
endfunction

function! vimio#stencil#get_default_graph_functions() abort
  return [
        \ ['Vimio__DefineSmartDrawShapesBasic', [0, [60, 0], [60, 0], [60, 0], [60, 0], [600, 0], [600, 0], [20, 0], [20, 0], [600, 0], 0, [40, 0], 0, 0, 0], 0, 'basic.vim'],
        \ ['Vimio__DefineSmartDrawShapesFiglet', [0, 0, 0, 0, 0, 0], 0, 'figlet.vim'],
        \ ['Vimio__DefineSmartDrawShapesLed', [0], 0, 'led.vim'],
        \ ['Vimio__DefineSmartDrawShapesanimal', [0], 0, 'animal.vim'],
        \ ]
endfunction

function! vimio#stencil#get_all_graph_functions() abort
  let default = vimio#stencil#get_default_graph_functions()
  let user = get(g:, 'vimio_user_shapes_define_graph_functions', [])
  return default + user
endfunction


" 'index': Function Set Index
" '[0, 0, 0]': Index of subcategories within each major category of functions
" 0: Index of lev1 categories of functions
" :TODO: The array in the back can be completely decoupled from the specific definition file, and the number of 
"       elements in the array should be automatically created based on the content in the file.
" This is not set to -1 because there are many basic graphic groups, 
" and we are worried about the startup speed, so it is set to the last group.
let g:vimio_shapes_define_graph_functions = {
    \ 'index': 1,
    \ 'value': vimio#stencil#get_all_graph_functions()
    \ }

" If lev2_index is an array [300, 124],Prove that the current graph is dynamically
"    generated by a function, and the array elements cannot be directly accessed, 
"    but the function needs to be called.
" The first value is the limit of the function that generates the graph, and 
"   the second value is the current index.
" The logic of function parameters
" If step is 1, then the function only needs one parameter.
"            2, So the function needs two parameters (width and height).
function! vimio#stencil#update_lev2_info()
    " Update the contents of clip register
    let lev2_index = g:vimio_config_shapes['value'][g:vimio_config_shapes['set_index']]['index']
    let step_arr = g:vimio_config_shapes['value'][g:vimio_config_shapes['set_index']]['step']
    if type(lev2_index) == type([])
        let func_name = g:vimio_config_shapes['value'][g:vimio_config_shapes['set_index']]['value']

        if step_arr[1] == 1
            let func_param = lev2_index[1]
            let @+ = join(call(func_name, [func_param]), "\n")
        else
            let func_param_row = lev2_index[1] / step_arr[1] + 1
            let func_param_col = lev2_index[1] % step_arr[1]
            let @+ = join(call(func_name, [func_param_row, func_param_col]), "\n")
        endif
    else
        let @+ = join(g:vimio_config_shapes['value'][g:vimio_config_shapes['set_index']]['value'][lev2_index], "\n")
    endif
endfunction


function! vimio#stencil#cleanup_shape_subfuncs() abort
    if exists('g:vimio_state_shapes_sub_funcs') && !empty(g:vimio_state_shapes_sub_funcs)
        for fname in g:vimio_state_shapes_sub_funcs
            " exists('g:var')     Check if global variable g:var exists
            " exists(':Cmd')      Check if Ex command :Cmd exists
            " exists('*Func')     Check if function Func() exists
            " exists('#Group')    Check if autocommand group Group exists
            " exists('##Event')   Check if event (e.g. BufEnter) exists
            if type(fname) == type('') && exists('*' . fname)
                execute 'delfunction!' fname
            endif
        endfor
        let g:vimio_state_shapes_sub_funcs = []
    endif
endfunction


function! vimio#stencil#load_and_use_custom_drawset_funcs(func_name, indexes, index, file_name)
    " First clear all sub-functions in the previous template to release memory
    call vimio#stencil#cleanup_shape_subfuncs()

    " Get the plugin root directory (prefer vimio, fallback to $VIM if not found)
    let plugin_root = vimio#utils#get_plugin_root()
    let plugin_path = plugin_root . '/draw_shaps/' . a:file_name
    let user_dir = get(g:, 'vimio_custom_shapes_dir', '')
    let user_path = user_dir !=# '' ? user_dir . '/' . a:file_name : ''

    if user_path !=# '' && filereadable(user_path)
        let file_path = user_path
    elseif filereadable(plugin_path)
        let file_path = plugin_path
    else
        echohl ErrorMsg
        echom 'vimio: Cannot find draw shape file: ' . a:file_name
        echohl None
        return
    endif

    execute 'source' fnameescape(file_path)

    " Call function
    let result = call(a:func_name, [a:indexes, a:index])

    " Delete function definition after global variables are loaded
    " The purpose of deleting the function here is to save memory (because the 
    " local variables in the function initialization may contain a large number
    " of strings).
    execute 'delfunction!' a:func_name
endfunction

function! vimio#stencil#switch_define_graph_set(is_show)
    " " Record start time
    " let l:start_time = reltime()

    " First, record the index of all lev2.
    if exists('g:vimio_config_shapes')
        let old_index = g:vimio_shapes_define_graph_functions['index']
        for i in range(len(g:vimio_shapes_define_graph_functions['value'][old_index][1]))
            let g:vimio_shapes_define_graph_functions['value'][old_index][1][i] = copy(g:vimio_config_shapes['value'][i]['index'])
        endfor
        
        " Record the index of the lev1 category
        let g:vimio_shapes_define_graph_functions['value'][old_index][2] = g:vimio_config_shapes['set_index']
    endif

    let g:vimio_shapes_define_graph_functions['index'] = (g:vimio_shapes_define_graph_functions['index']+1) % len(g:vimio_shapes_define_graph_functions['value'])
    let index_value = g:vimio_shapes_define_graph_functions['index']

    call vimio#stencil#load_and_use_custom_drawset_funcs(g:vimio_shapes_define_graph_functions['value'][index_value][0], g:vimio_shapes_define_graph_functions['value'][index_value][1], g:vimio_shapes_define_graph_functions['value'][index_value][2], g:vimio_shapes_define_graph_functions['value'][index_value][3])

    call vimio#stencil#update_lev2_info()
    if a:is_show
        call vimio#popup#update_cross_block()
        call vimio#stencil#show_graph_set_info()
    endif

    " " Record end time
    " let l:end_time = reltime()

    " " Calculate execution time
    " let l:elapsed_time = reltimestr(reltime(l:start_time, l:end_time))

    " " Output execution time
    " echo "Execution time: " . l:elapsed_time
endfunction

