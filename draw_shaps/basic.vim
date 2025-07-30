function! Vimio__GenerateLeftRightTriangle(index)
    " .   .    .   
    " |\  |\   |\  
    " '-' | \  | \ 
    "     '--' |  \
    "          '---'
    let triangle = []
    call add(triangle, '.')
    for j in range(0, a:index)
        call add(triangle, '|' . repeat(' ', j) . '\')
    endfor
    call add(triangle, "'" . repeat('-', a:index+1) . "'")
    
    return triangle
endfunction

" :TODO: There are 3 types of triangles
"              . 
"        .    /| 
"   .   /|   / | 
"  /|  / |  /  | 
" '-' '--' '---' 
" .-.  .--. .---.
"  \|   \ |  \  |
"   '    \|   \ |
"         '    \|
"               '
"  .-. .--. .---.
"  |/  | /  |  / 
"  '   |/   | /  
"      '    |/   
"           '    


" :TODO: Let's implement it when we are free. This graphic is a bit troublesome.
function! Vimio__GenerateSixPointedStar(index)
    "  __/\__       /\                /\         
    "  \    /  ____/  \____          /  \        
    "  /_  _\  \          /   ______/    \______ 
    "    \/     \        /    \                / 
    "           /        \     \              /  
    "          /___    ___\     \            /   
    "              \  /         /            \   
    "               \/         /              \  
    "                         /_____      _____\ 
    "                               \    /       
    "                                \  /        
    "                                 \/         
    let six_pointed_star = []
    let range = a:index
endfunction


" https://waylonwalker.com/drawing-ascii-boxes/
function! Vimio__GenerateUpTriangle(index)
    "   .      .       .
    "  / \    / \     / \
    " '---'  /   \   /   \
    "       '-----' /     \
    "              '-------'
    let i = a:index + 1

    let triangle = []
    call add(triangle, repeat(' ', i+1) . '.' . repeat(' ', i+1))
    for j in range(1, i)
        call add(triangle, repeat(' ', i-j+1) . '/' . repeat(' ', j*2-1) . '\')
    endfor
    call add(triangle, "'" . repeat('-', 2*i+1) . "'")

    return triangle
endfunction


function! Vimio__GenerateDownTriangle(index)
    " .---. .-----. .-------.
    "  \ /   \   /   \     / 
    "   '     \ /     \   /  
    "          '       \ /   
    "                   '    
    let i = a:index + 1

    let width = i * 2 + 1
    let triangle = []
    call add(triangle, '.' . repeat('-', width) . '.')
    for j in range(1, i)
        call add(triangle, repeat(' ', j) . '\' . repeat(' ', width - 2 * j) . '/')
    endfor
    call add(triangle, repeat(' ', i + 1) . "'")

    return triangle
endfunction

function! Vimio__GenerateHexagon(index)
    "    ____
    "   / __ \
    "  / /  \ \
    "  \ \__/ /
    "   \____/
    let i = a:index + 1

    let hexagon = []
    " top
    call add(hexagon, repeat(' ', i) . repeat('_', i*2))
    " upper part
    for j in range(1, i)
        call add(hexagon, repeat(' ', i-j) . '/' . repeat(' ', i*2+(j-1)*2) . '\')
    endfor
    " lower part
    for j in range(1, i-1)
        call add(hexagon, repeat(' ', j-1) . '\' . repeat(' ', i*2+(i-j)*2) . '/')
    endfor
    " bottom edge
    call add(hexagon, repeat(' ', i-1) . '\' . repeat('_', i*2) . '/')

    return hexagon
endfunction

function! Vimio__GenerateProcessRight(row_index, col_index)
    " __   _____  
    " \ \  \    \ 
    "  ) )  )    )
    " /_/  /____/ 
    " __________   
    " \         \  
    "  \         \ 
    "   )         )
    "  /         / 
    " /_________/  
    let i = a:row_index
    let j = a:col_index

    let process_right = []
    " Draw the upper part
    call add(process_right, repeat('_', j))
    " Draw the upper part
    for k in range(1, i)
        call add(process_right, repeat(' ', k-1) . '\' . repeat(' ', j-1) . '\')
    endfor
    " Draw the middle part
    call add(process_right, repeat(' ', i) . ')' . repeat(' ', j-1) . ')')
    " Draw the lower part
    for k in range(1, i-1)
        call add(process_right, repeat(' ', i-k) . '/' . repeat(' ', j-1) . '/')
    endfor
    " Draw the bottom
    call add(process_right, '/' . repeat('_', j-1) . '/')

    return process_right
endfunction

function! Vimio__GenerateProcessLeft(row_index, col_index)
    "   __   ___
    "  / /  /  /
    " ( (  (  ( 
    "  \_\  \__\
    "    ___
    "   /  /
    "  /  /
    " (  (
    "  \  \
    "   \__\
    let i = a:row_index
    let j = a:col_index

    let process_left = []
    " up
    call add(process_left, repeat(' ', i+1) . repeat('_', j))
    " up half
    for k in range(1, i)
        call add(process_left, repeat(' ', i-k+1) . '/' . repeat(' ', j-1) . '/')
    endfor
    " middle
    call add(process_left, '(' . repeat(' ', j-1) . '(')
    " down half
    for k in range(1, i-1)
        call add(process_left, repeat(' ', k) . '\' . repeat(' ', j-1) . '\')
    endfor
    " down
    call add(process_left, repeat(' ', i) . '\' . repeat('_', j-1) . '\')

    return process_left
endfunction

function! Vimio__GenerateIfBox(row_index, col_index)
    "
    "    .-.    .--.
    "   (   )  (    )
    "    '-'    '--'
    "  .-.       .--.  
    " /   \     /    \     
    "(     )   (      )                
    " \   /     \    / 
    "  '-'       '--'  
    let i = a:row_index + 1
    let j = a:col_index + 1

    let if_box = []
    " up
    call add(if_box, repeat(' ', i) . '.' . repeat('-', j) . '.')
    " up half
    for k in range(1, i-1)
        call add(if_box, repeat(' ', i-k). '/' . repeat(' ', j+k*2) . '\')
    endfor
    " middle
    call add(if_box, '(' . repeat(' ', 2*i+j) . ')')
    " down half
    for k in range(1, i-1)
        call add(if_box, repeat(' ', k) . '\' . repeat(' ', j+(i-k)*2) . '/')
    endfor
    " down
    call add(if_box, repeat(' ', i) . "'" . repeat('-', j) . "'")

    return if_box
endfunction

function! Vimio__GenerateRhombus(radius)
    " 3 row 5 col
    "    .'. 
    "   :   :
    "    '.' 
    " 5 row 9 col
    "     .'.  
    "   .'   '. 
    "  :       :
    "   '.   .'
    "     '.'   
    " 7 row 13 col
    "      .'.      
    "    .'   '.    
    "  .'       '.  
    " :           : 
    "  '.       .'  
    "    '.   .'    
    "      '.'      
    " 9 row 17 col
    "       .'.       
    "     .'   '.     
    "   .'       '.   
    " .'           '. 
    ":               :
    " '.           .' 
    "   '.       .'   
    "     '.   .'     
    "       '.'       
    " max_col = 2 * max_row - 1
    let i = a:radius + 1
    let rhombus = []

    " top
    call add(rhombus, repeat(' ', i*2-1) . ".'.")
    " up half
    for j in range(1, i-1)
        call add(rhombus, repeat(' ', (i-j)*2-1) . ".'" . repeat(' ', j*4-1) . "'.")
    endfor
    " middle
    call add(rhombus, ':' . repeat(' ', 4*i-1) . ':')
    " down half
    for j in range(1, i-1)
        call add(rhombus, repeat(' ', 2*j-1) . "'." . repeat(' ', (i-j)*4-1) . ".'")
    endfor
    " bottom
    call add(rhombus, repeat(' ', i*2-1) . "'.'")

    return rhombus
endfunction

function! Vimio__GenerateProcessUp(row_index, col_index)
    let l:process_up1 =<< EOF
  /\
 /  \
| /\ |
|/  \|
'    '
EOF
    let l:process_up2 =<< EOF
  /\
 /  \
|    |
| /\ |
|/  \|
'    '
EOF
    let l:process_up3 =<< EOF
  /\
 /  \
|    |
|    |
| /\ |
|/  \|
'    '
EOF
    let l:process_up4 =<< EOF
  /\
 /  \
|    |
|    |
|    |
| /\ |
|/  \|
'    '
EOF
    let l:process_up5 =<< EOF
  /\
 /  \
|    |
|    |
|    |
|    |
| /\ |
|/  \|
'    '
EOF
    let l:process_up6 =<< EOF
  /\
 /  \
|    |
|    |
|    |
|    |
|    |
| /\ |
|/  \|
'    '
EOF
    let l:process_up7 =<< EOF
  /\
 /  \
|    |
|    |
|    |
|    |
|    |
|    |
| /\ |
|/  \|
'    '
EOF
    let l:process_up8 =<< EOF
  /\
 /  \
|    |
|    |
|    |
|    |
|    |
|    |
|    |
| /\ |
|/  \|
'    '
EOF
    let l:process_up9 =<< EOF
  /\
 /  \
|    |
|    |
|    |
|    |
|    |
|    |
|    |
|    |
| /\ |
|/  \|
'    '
EOF
    let l:process_up10 =<< EOF
  /\
 /  \
|    |
|    |
|    |
|    |
|    |
|    |
|    |
|    |
|    |
| /\ |
|/  \|
'    '
EOF

    let l:process_up_1_1 =<< EOF
   .
  / \
 / . \
| / \ |
|/   \|
'     '
EOF
    let l:process_up_1_2 =<< EOF
   .
  / \
 /   \
|  .  |
| / \ |
|/   \|
'     '
EOF
    let l:process_up_1_3 =<< EOF
   .
  / \
 /   \
|     |
|  .  |
| / \ |
|/   \|
'     '
EOF
    let l:process_up_1_4 =<< EOF
   .
  / \
 /   \
|     |
|     |
|  .  |
| / \ |
|/   \|
'     '
EOF
    let l:process_up_1_5 =<< EOF
   .
  / \
 /   \
|     |
|     |
|     |
|  .  |
| / \ |
|/   \|
'     '
EOF
    let l:process_up_1_6 =<< EOF
   .
  / \
 /   \
|     |
|     |
|     |
|     |
|  .  |
| / \ |
|/   \|
'     '
EOF
    let l:process_up_1_7 =<< EOF
   .
  / \
 /   \
|     |
|     |
|     |
|     |
|     |
|  .  |
| / \ |
|/   \|
'     '
EOF
    let l:process_up_1_8 =<< EOF
   .
  / \
 /   \
|     |
|     |
|     |
|     |
|     |
|     |
|  .  |
| / \ |
|/   \|
'     '
EOF
    let l:process_up_1_9 =<< EOF
   .
  / \
 /   \
|     |
|     |
|     |
|     |
|     |
|     |
|     |
|  .  |
| / \ |
|/   \|
'     '
EOF
    let l:process_up_1_10 =<< EOF
   .
  / \
 /   \
|     |
|     |
|     |
|     |
|     |
|     |
|     |
|     |
|  .  |
| / \ |
|/   \|
'     '
EOF
    let l:process_ups = [
               \ [ l:process_up1, l:process_up_1_1 ],
               \ [ l:process_up2, l:process_up_1_2 ],
               \ [ l:process_up3, l:process_up_1_3 ],
               \ [ l:process_up4, l:process_up_1_4 ],
               \ [ l:process_up5, l:process_up_1_5 ],
               \ [ l:process_up6, l:process_up_1_6 ],
               \ [ l:process_up7, l:process_up_1_7 ],
               \ [ l:process_up8, l:process_up_1_8 ],
               \ [ l:process_up9, l:process_up_1_9 ],
               \ [ l:process_up10, l:process_up_1_10 ],
               \ ]
    return l:process_ups[a:row_index-1][a:col_index]
endfunction

function! Vimio__GenerateProcessDown(row_index, col_index) abort
    let l:process_down1 =<< EOF
.    .
|\  /|
| \/ |
 \  /
  \/
EOF

    let l:process_down2 =<< EOF
.    .
|\  /|
| \/ |
|    |
 \  /
  \/
EOF
    let l:process_down3 =<< EOF
.    .
|\  /|
| \/ |
|    |
|    |
 \  /
  \/
EOF
    let l:process_down4 =<< EOF
.    .
|\  /|
| \/ |
|    |
|    |
|    |
 \  /
  \/
EOF
    let l:process_down5 =<< EOF
.    .
|\  /|
| \/ |
|    |
|    |
|    |
|    |
 \  /
  \/
EOF
    let l:process_down6 =<< EOF
.    .
|\  /|
| \/ |
|    |
|    |
|    |
|    |
|    |
 \  /
  \/
EOF
    let l:process_down7 =<< EOF
.    .
|\  /|
| \/ |
|    |
|    |
|    |
|    |
|    |
|    |
 \  /
  \/
EOF
    let l:process_down8 =<< EOF
.    .
|\  /|
| \/ |
|    |
|    |
|    |
|    |
|    |
|    |
|    |
 \  /
  \/
EOF
    let l:process_down9 =<< EOF
.    .
|\  /|
| \/ |
|    |
|    |
|    |
|    |
|    |
|    |
|    |
|    |
 \  /
  \/
EOF
    let l:process_down10 =<< EOF
.    .
|\  /|
| \/ |
|    |
|    |
|    |
|    |
|    |
|    |
|    |
|    |
|    |
 \  /
  \/
EOF
    let l:process_down_1_1 =<< EOF
.     .  
|\   /|  
| \ / |  
 \ ' /   
  \ /    
   '
EOF
    let l:process_down_1_2 =<< EOF
.     .  
|\   /|  
| \ / |  
|  '  |  
 \   /   
  \ /  
   '   
EOF
    let l:process_down_1_3 =<< EOF
.     .  
|\   /|  
| \ / |  
|  '  |  
|     |  
 \   / 
  \ /  
   '   
EOF
    let l:process_down_1_4 =<< EOF
.     .  
|\   /|  
| \ / |  
|  '  |  
|     |  
|     |  
 \   / 
  \ /  
   '   
EOF
    let l:process_down_1_5 =<< EOF
.     .  
|\   /|  
| \ / |  
|  '  |  
|     |  
|     |  
|     |  
 \   / 
  \ /  
   '   
EOF
    let l:process_down_1_6 =<< EOF
.     .  
|\   /|  
| \ / |  
|  '  |  
|     |  
|     |  
|     |  
|     |  
 \   / 
  \ /  
   '   
EOF
    let l:process_down_1_7 =<< EOF
.     .  
|\   /|  
| \ / |  
|  '  |  
|     |  
|     |  
|     |  
|     |  
|     |  
 \   / 
  \ /  
   '   
EOF
    let l:process_down_1_8 =<< EOF
.     .  
|\   /|  
| \ / |  
|  '  |  
|     |  
|     |  
|     |  
|     |  
|     |  
|     |  
 \   / 
  \ /  
   '   
EOF
    let l:process_down_1_9 =<< EOF
.     .  
|\   /|  
| \ / |  
|  '  |  
|     |  
|     |  
|     |  
|     |  
|     |  
|     |  
|     |  
 \   / 
  \ /  
   '   
EOF
    let l:process_down_1_10 =<< EOF
.     .  
|\   /|  
| \ / |  
|  '  |  
|     |  
|     |  
|     |  
|     |  
|     |  
|     |  
|     |  
|     |  
 \   / 
  \ /  
   '   
EOF
    let process_downs = [
                \   [ l:process_down1, l:process_down_1_1 ],
                \   [ l:process_down2, l:process_down_1_2 ],
                \   [ l:process_down3, l:process_down_1_3 ],
                \   [ l:process_down4, l:process_down_1_4 ],
                \   [ l:process_down5, l:process_down_1_5 ],
                \   [ l:process_down6, l:process_down_1_6 ],
                \   [ l:process_down7, l:process_down_1_7 ],
                \   [ l:process_down8, l:process_down_1_8 ],
                \   [ l:process_down9, l:process_down_1_9 ],
                \   [ l:process_down10, l:process_down_1_10 ],
                \   [],
                \ ]
    return process_downs[a:row_index-1][a:col_index]
endfunction


function! Vimio__DefineSmartDrawShapesBasic(indexes, index)
    let l:circle_3x3 =<< EOF
 _
( )
 '
EOF

    let l:circle_3x5 =<< EOF
 .-.
(   )
 '-'
EOF

    let l:circle_3x7 =<< EOF
 .---.
(     )
 '---'
EOF
    let l:circle_7x9 =<< EOF
  .---.
 /     \
:       :
|       |
:       :
 \     /
  '---'
EOF
    let l:circle_7x15 =<< EOF
    _.---._
 .''       ''.
:             :
|             |
:             :
 '..       ..'
    '-...-'
EOF
    let l:circle_9x11 =<< EOF
   .---.
  /     \
 /       \
:         :
|         |
:         :
 \       /
  \     /
   '---'
EOF
    let l:circle_9x15 =<< EOF
    _.---._
  .'       '.
 /           \
:             :
|             |
:             :
 \           /
  '.       .'
    '-...-'
EOF

    let l:circle_9x17 =<< EOF
     _.---._
  .''       ''.
 /             \
:               :
|               |
:               :
 \             /
  '..       ..'
     '-...-'
EOF
    let l:circle_11x21 =<< EOF
      _..---.._
   .''         ''.
  /               \
 /                 \
:                   :
|                   |
:                   :
 \                 /
  \               /
   '..         ..'
      '--...--'
EOF

    let l:circle_11x25 =<< EOF
       _...---..._
    .''           ''.
  .'                 '.
 /                     \
:                       :
|                       |
:                       :
 \                     /
  '.                 .'
    '..           ..'
       '---...---'
EOF
    let l:circle_13x25 =<< EOF
        _..---.._
     .''         ''.
   .'               '.
  /                   \
 /                     \
:                       :
|                       |
:                       :
 \                     /
  \                   /
   '.               .'
     '..         ..'
        '--...--'
EOF
    let l:fill_box_1 =<< EOF
╭─────────────────────╮
│ ███████████████████ │
│ ███████████████████ │
│ ███████████████████ │
│ ███████████████████ │
│ ███████████████████ │
│ ███████████████████ │
│ ███████████████████ │
│ ███████████████████ │
╰─────────────────────╯
EOF

    let l:snapshot =<< EOF
  0   1   2   3   4   5    6   7
 .-..---. .  .'.  __ __    __  /\  
(   )\ / / \:   :/  \\ \  / / /  \ 
 '-'  ' '---''.' \__/ ) )( ( | /\ |
                     /_/  \_\|/  \|
                             '    '
  8      9    10  11  12 13  14
.    .  .-.  ╭───┐.    ●  █  ◥
|\  /| /   \ │ █ │|\ 
| \/ |(     )└───┘'-'
 \  /  \   / 
  \/    '-'  
EOF


    let l:snapshot_bullet_points =<< EOF
0 1 2 3 4 5 6 7 8 9 10 11
✓ ✔ ✗ ✘ ☐ ☑ ☒ □ ■ ○ ●  ∨
EOF

    let l:snapshot_square_symbol =<< EOF
0  1  2  3  4  5  6  7  8  9  10 11 12 13 14 15
▀  ▁  ▂  ▃  ▄  ▅  ▆  ▇  █  ▉  ▊  ▋  ▌  ▍  ▎  ▏ 

16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31
▐  ░  ▒  ▓  ▔  ▕  ▖  ▗  ▘  ▙  ▚  ▛  ▜  ▝  ▞  ▟
EOF

    let l:snapshot_marks =<< EOF
0 1 2 3 4 5 6 7
▫ ◖ ◗ ▪ ◤ ◥ ◢ ◣
EOF


let g:vimio_state_shapes_sub_funcs = [
    \ 'Vimio__GenerateLeftRightTriangle',
    \ 'Vimio__GenerateSixPointedStar',
    \ 'Vimio__GenerateUpTriangle',
    \ 'Vimio__GenerateDownTriangle',
    \ 'Vimio__GenerateHexagon',
    \ 'Vimio__GenerateProcessRight',
    \ 'Vimio__GenerateProcessLeft',
    \ 'Vimio__GenerateIfBox',
    \ 'Vimio__GenerateRhombus',
    \ 'Vimio__GenerateProcessUp',
    \ 'Vimio__GenerateProcessDown',
    \ ]

let vimio_config_shapes = {'set_index': a:index, 'stencil_set_name': 'basic', 'snapshot': join(l:snapshot, "\n"), 'value': 
    \ [
    \ {
    \ 'index': a:indexes[0],
    \ 'step': [1, 1],
    \ 'name': 'ellipse',
    \ 'value': [ l:circle_3x3   , l:circle_3x5   , l:circle_3x7   ,
    \            l:circle_7x9   , l:circle_7x15  ,
    \            l:circle_9x11  , l:circle_9x15  , l:circle_9x17  ,
    \            l:circle_11x21 , l:circle_11x25 , l:circle_13x25
    \ ]
    \ },
    \ {
    \ 'index': a:indexes[1],
    \ 'step': [1, 1],
    \ 'name': 'down_triangle',
    \ 'value': 'Vimio__GenerateDownTriangle'
    \ },
    \ {
    \ 'index': a:indexes[2],
    \ 'step': [1, 1],
    \ 'name': 'up_triangle',
    \ 'value': 'Vimio__GenerateUpTriangle'
    \ },
    \ {
    \ 'index': a:indexes[3],
    \ 'step': [1, 1],
    \ 'name': 'rhombus',
    \ 'value': 'Vimio__GenerateRhombus'
    \ },
    \ {
    \ 'index': a:indexes[4],
    \ 'step': [1, 1],
    \ 'name': 'hexagon',
    \ 'value': 'Vimio__GenerateHexagon'
    \ },
    \ {
    \ 'index': a:indexes[5],
    \ 'step': [1, 30],
    \ 'name': 'process_right',
    \ 'value': 'Vimio__GenerateProcessRight'
    \ },
    \ {
    \ 'index': a:indexes[6],
    \ 'step': [1, 30],
    \ 'name': 'process_left',
    \ 'value': 'Vimio__GenerateProcessLeft'
    \ },
    \ {
    \ 'index': a:indexes[7],
    \ 'step': [1, 2],
    \ 'name': 'process_up',
    \ 'value': 'Vimio__GenerateProcessUp'
    \ },
    \ {
    \ 'index': a:indexes[8],
    \ 'step': [1, 2],
    \ 'name': 'process_down',
    \ 'value': 'Vimio__GenerateProcessDown'
    \ },
    \ {
    \ 'index': a:indexes[9],
    \ 'step': [1, 30],
    \ 'name': 'ifbox',
    \ 'value': 'Vimio__GenerateIfBox'
    \ },
    \ {
    \ 'index': a:indexes[10],
    \ 'step': [1, 1],
    \ 'name': 'fill_box',
    \ 'value':  [l:fill_box_1]
    \ },
    \ {
    \ 'index': a:indexes[11],
    \ 'step': [1, 1],
    \ 'name': 'left_right_triangle',
    \ 'value': 'Vimio__GenerateLeftRightTriangle'
    \ },
    \ {
    \ 'index': a:indexes[12],
    \ 'step': [1, 1],
    \ 'name': 'bullet_points',
    \ 'value': [ ['✓'], ['✔'], ['✗'], ['✘'], ['☐'], ['☑'], ['☒'], ['□'], ['■'], ['○'], ['●'], ['∨'] ],
    \ 'snapshot': join(l:snapshot_bullet_points, "\n"),
    \ },
    \ {
    \ 'index': a:indexes[13],
    \ 'step': [1, 1],
    \ 'name': 'square_symbol',
    \ 'value': [ ['▀'], ['▁'], ['▂'], ['▃'], ['▄'], ['▅'], ['▆'], ['▇'], ['█'], ['▉'], ['▊'], ['▋'], ['▌'], ['▍'], ['▎'], ['▏'],
    \            ['▐'], ['░'], ['▒'], ['▓'], ['▔'], ['▕'], ['▖'], ['▗'], ['▘'], ['▙'], ['▚'], ['▛'], ['▜'], ['▝'], ['▞'], ['▟'] ],
    \ 'snapshot': join(l:snapshot_square_symbol, "\n"),
    \ },
    \ {
    \ 'index': a:indexes[14],
    \ 'step': [1, 1],
    \ 'name': 'marks',
    \ 'value': [ ['▫'], ['◖'], ['◗'], ['▪'], ['◤'], ['◥'], ['◢'], ['◣'] ],
    \ 'snapshot': join(l:snapshot_marks, "\n"),
    \ },
    \ ],
    \ }
    
    return vimio_config_shapes
endfunction

