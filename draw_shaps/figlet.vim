function! Vimio__DefineSmartDrawShapesFiglet(indexes, index)
    let standard_a =<< EOF
   __ _
  / _` |
 | (_| |
  \__,_|
EOF
    let standard_b =<< EOF
  _
 | |__
 | '_ \
 | |_) |
 |_.__/
EOF
    let standard_c =<< EOF
   ___
  / __|
 | (__
  \___|
EOF
    let standard_d =<< EOF
      _
   __| |
  / _` |
 | (_| |
  \__,_|
EOF
    let standard_e =<< EOF
   ___
  / _ \
 |  __/
  \___|
EOF
    let standard_f =<< EOF
   __
  / _|
 | |_
 |  _|
 |_|
EOF
    let standard_g =<< EOF
   __ _
  / _` |
 | (_| |
  \__, |
  |___/
EOF
    let standard_h =<< EOF
  _
 | |__
 | '_ \
 | | | |
 |_| |_|
EOF
    let standard_i =<< EOF
  _
 (_)
 | |
 | |
 |_|
EOF
    let standard_j =<< EOF
    _
   (_)
   | |
   | |
  _/ |
 |__/
EOF
    let standard_k =<< EOF
  _
 | | __
 | |/ /
 |   <
 |_|\_\
EOF
    let standard_l =<< EOF
  _
 | |
 | |
 | |
 |_|
EOF
    let standard_m =<< EOF
  _ __ ___
 | '_ ` _ \
 | | | | | |
 |_| |_| |_|
EOF
    let standard_n =<< EOF
  _ __
 | '_ \
 | | | |
 |_| |_|
EOF
    let standard_o =<< EOF
   ___
  / _ \
 | (_) |
  \___/
EOF
    let standard_p =<< EOF
  _ __
 | '_ \
 | |_) |
 | .__/
 |_|
EOF
    let standard_q =<< EOF
   __ _
  / _` |
 | (_| |
  \__, |
     |_|
EOF
    let standard_r =<< EOF
  _ __
 | '__|
 | |
 |_|
EOF
    let standard_s =<< EOF
  ___
 / __|
 \__ \
 |___/
EOF
    let standard_t =<< EOF
  _
 | |_
 | __|
 | |_
  \__|
EOF
    let standard_u =<< EOF
  _   _
 | | | |
 | |_| |
  \__,_|
EOF
    let standard_v =<< EOF
 __   __
 \ \ / /
  \ V /
   \_/
EOF
    let standard_w =<< EOF
 __      __
 \ \ /\ / /
  \ V  V /
   \_/\_/
EOF
    let standard_x =<< EOF
 __  __
 \ \/ /
  >  <
 /_/\_\
EOF
    let standard_y =<< EOF
  _   _
 | | | |
 | |_| |
  \__, |
  |___/
EOF
    let standard_z =<< EOF
  ____
 |_  /
  / /
 /___|
EOF
    let standard_A =<< EOF
     _
    / \
   / _ \
  / ___ \
 /_/   \_\
EOF
    let standard_B =<< EOF
  ____
 | __ )
 |  _ \
 | |_) |
 |____/
EOF
    let standard_C =<< EOF
   ____
  / ___|
 | |
 | |___
  \____|
EOF
    let standard_D =<< EOF
  ____
 |  _ \
 | | | |
 | |_| |
 |____/
EOF
    let standard_E =<< EOF
  _____
 | ____|
 |  _|
 | |___
 |_____|
EOF
    let standard_F =<< EOF
  _____
 |  ___|
 | |_
 |  _|
 |_|
EOF
    let standard_G =<< EOF
   ____
  / ___|
 | |  _
 | |_| |
  \____|
EOF
    let standard_H =<< EOF
  _   _
 | | | |
 | |_| |
 |  _  |
 |_| |_|
EOF
    let standard_I =<< EOF
  ___
 |_ _|
  | |
  | |
 |___|
EOF
    let standard_J =<< EOF
      _
     | |
  _  | |
 | |_| |
  \___/
EOF
    let standard_K =<< EOF
  _  __
 | |/ /
 | ' /
 | . \
 |_|\_\
EOF
    let standard_L =<< EOF
  _
 | |
 | |
 | |___
 |_____|
EOF
    let standard_M =<< EOF
  __  __
 |  \/  |
 | |\/| |
 | |  | |
 |_|  |_|
EOF
    let standard_N =<< EOF
  _   _
 | \ | |
 |  \| |
 | |\  |
 |_| \_|
EOF
    let standard_O =<< EOF
   ___
  / _ \
 | | | |
 | |_| |
  \___/
EOF
    let standard_P =<< EOF
  ____
 |  _ \
 | |_) |
 |  __/
 |_|
EOF
    let standard_Q =<< EOF
   ___
  / _ \
 | | | |
 | |_| |
  \__\_\
EOF
    let standard_R =<< EOF
  ____
 |  _ \
 | |_) |
 |  _ <
 |_| \_\
EOF
    let standard_S =<< EOF
  ____
 / ___|
 \___ \
  ___) |
 |____/
EOF
    let standard_T =<< EOF
  _____
 |_   _|
   | |
   | |
   |_|
EOF
    let standard_U =<< EOF
  _   _
 | | | |
 | | | |
 | |_| |
  \___/
EOF
    let standard_V =<< EOF
 __     __
 \ \   / /
  \ \ / /
   \ V /
    \_/
EOF
    let standard_W =<< EOF
 __        __
 \ \      / /
  \ \ /\ / /
   \ V  V /
    \_/\_/
EOF
    let standard_X =<< EOF
 __  __
 \ \/ /
  \  /
  /  \
 /_/\_\
EOF
    let standard_Y =<< EOF
 __   __
 \ \ / /
  \ V /
   | |
   |_|
EOF
    let standard_Z =<< EOF
  _____
 |__  /
   / /
  / /_
 /____|
EOF
    let standard_1 =<< EOF
  _
 / |
 | |
 | |
 |_|
EOF
    let standard_2 =<< EOF
  ____
 |___ \
   __) |
  / __/
 |_____|
EOF
    let standard_3 =<< EOF
  _____
 |___ /
   |_ \
  ___) |
 |____/
EOF
    let standard_4 =<< EOF
  _  _
 | || |
 | || |_
 |__   _|
    |_|
EOF
    let standard_5 =<< EOF
  ____
 | ___|
 |___ \
  ___) |
 |____/
EOF
    let standard_6 =<< EOF
   __
  / /_
 | '_ \
 | (_) |
  \___/
EOF
    let standard_7 =<< EOF
  _____
 |___  |
    / /
   / /
  /_/
EOF
    let standard_8 =<< EOF
   ___
  ( _ )
  / _ \
 | (_) |
  \___/
EOF
    let standard_9 =<< EOF
   ___
  / _ \
 | (_) |
  \__, |
    /_/
EOF
    let standard_0 =<< EOF
   ___
  / _ \
 | | | |
 | |_| |
  \___/
EOF
    let standard_mark1 =<< EOF
  _
 ( )
 |/
EOF
    let standard_mark2 =<< EOF
  _
 ( )
  \|
EOF
    let standard_mark3 =<< EOF
  _ _
 ( | )
  V V
EOF
    let standard_mark4 =<< EOF
    ____
   / __ \
  / / _` |
 | | (_| |
  \ \__,_|
   \____/
EOF
    let standard_mark5 =<< EOF
    _  _
  _| || |_
 |_  ..  _|
 |_      _|
   |_||_|
EOF
    let standard_mark6 =<< EOF
   _
  | |
 / __)
 \__ \
 (   /
  |_|
EOF
    let standard_mark7 =<< EOF
  _  __
 (_)/ /
   / /
  / /_
 /_/(_)
EOF
    let standard_mark8 =<< EOF
  /\
 |/\|
EOF
    let standard_mark9 =<< EOF
   ___
  ( _ )
  / _ \/\
 | (_>  <
  \___/\/
EOF
    let standard_mark10 =<< EOF
 __/\__
 \    /
 /_  _\
   \/
EOF
    let standard_mark11 =<< EOF
   __
  / /
 | |
 | |
 | |
  \_\
EOF
    let standard_mark12 =<< EOF
 __
 \ \
  | |
  | |
  | |
 /_/
EOF
    let standard_mark13 =<< EOF
  _
 (_)
EOF
    let standard_mark14 =<< EOF
  _
 | |
 | |
 |_|
 (_)
EOF
    let standard_mark15 =<< EOF
    _
  _| |_
 |_   _|
   |_|
EOF
    let standard_mark16 =<< EOF
  _
 (_)
  _
 (_)
EOF
    let standard_mark17 =<< EOF
  _
 (_)
  _
 ( )
 |/
EOF
    let standard_mark18 =<< EOF
  _____
 |_____|
EOF
    let standard_mark19 =<< EOF
 __
 \ \
  \ \
  / /
 /_/
EOF
    let standard_mark20 =<< EOF
   __
  / /
 / /
 \ \
  \_\
EOF
    let standard_mark21 =<< EOF
  _
 | |
 | |
 | |
 | |
 |_|
EOF
    let standard_mark22 =<< EOF
 __
 \ \
  \ \
   \ \
    \_\
EOF
    let standard_mark23 =<< EOF
     __
    / /
   / /
  / /
 /_/
EOF
    let standard_mark24 =<< EOF
  ___
 |__ \
   / /
  |_|
  (_)
EOF
    let standard_mark25 =<< EOF
   __
  / /
 | |
< <
 | |
  \_\
EOF
    let standard_mark26 =<< EOF
__
\ \
 | |
  > >
 | |
/_/
EOF
    let standard_mark27 =<< EOF
 __
| _|
| |
| |
| |
|__|
EOF
    let standard_mark28 =<< EOF
 __
|_ |
 | |
 | |
 | |
|__|
EOF
    let italic_a =<< EOF
  ____ _
 / __ `/
/ /_/ /
\__,_/
EOF
    let italic_b =<< EOF
    __
   / /_
  / __ \
 / /_/ /
/_.___/
EOF
    let italic_c =<< EOF
  _____
 / ___/
/ /__
\___/
EOF
    let italic_d =<< EOF
       __
  ____/ /
 / __  /
/ /_/ /
\__,_/
EOF
    let italic_e =<< EOF
  ___
 / _ \
/  __/
\___/
EOF
    let italic_f =<< EOF
    ____
   / __/
  / /_
 / __/
/_/
EOF
    let italic_g =<< EOF
   ____ _
  / __ `/
 / /_/ /
 \__, /
/____/
EOF
    let italic_h =<< EOF
    __
   / /_
  / __ \
 / / / /
/_/ /_/
EOF
    let italic_i =<< EOF
    _
   (_)
  / /
 / /
/_/
EOF
    let italic_j =<< EOF
       _
      (_)
     / /
    / /
 __/ /
/___/
EOF
    let italic_k =<< EOF
    __
   / /__
  / //_/
 / ,<
/_/|_|
EOF
    let italic_l =<< EOF
    __
   / /
  / /
 / /
/_/
EOF
    let italic_m =<< EOF
   ____ ___
  / __ `__ \
 / / / / / /
/_/ /_/ /_/
EOF
    let italic_n =<< EOF
   ____
  / __ \
 / / / /
/_/ /_/
EOF
    let italic_o =<< EOF
  ____
 / __ \
/ /_/ /
\____/
EOF
    let italic_p =<< EOF
    ____
   / __ \
  / /_/ /
 / .___/
/_/
EOF
    let italic_q =<< EOF
  ____ _
 / __ `/
/ /_/ /
\__, /
  /_/
EOF
    let italic_r =<< EOF
   _____
  / ___/
 / /
/_/
EOF
    let italic_s =<< EOF
   _____
  / ___/
 (__  )
/____/
EOF
    let italic_t =<< EOF
   __
  / /_
 / __/
/ /_
\__/
EOF
    let italic_u =<< EOF
  __  __
 / / / /
/ /_/ /
\__,_/
EOF
    let italic_v =<< EOF
 _   __
| | / /
| |/ /
|___/
EOF
    let italic_w =<< EOF
 _      __
| | /| / /
| |/ |/ /
|__/|__/
EOF
    let italic_x =<< EOF
   _  __
  | |/_/
 _>  <
/_/|_|
EOF
    let italic_y =<< EOF
   __  __
  / / / /
 / /_/ /
 \__, /
/____/
EOF
    let italic_z =<< EOF
 ____
/_  /
 / /_
/___/
EOF
    let italic_A =<< EOF
    ___
   /   |
  / /| |
 / ___ |
/_/  |_|
EOF
    let italic_B =<< EOF
    ____
   / __ )
  / __  |
 / /_/ /
/_____/
EOF
    let italic_C =<< EOF
   ______
  / ____/
 / /
/ /___
\____/
EOF
    let italic_D =<< EOF
    ____
   / __ \
  / / / /
 / /_/ /
/_____/
EOF
    let italic_E =<< EOF
    ______
   / ____/
  / __/
 / /___
/_____/
EOF
    let italic_F =<< EOF
    ______
   / ____/
  / /_
 / __/
/_/
EOF
    let italic_G =<< EOF
   ______
  / ____/
 / / __
/ /_/ /
\____/
EOF
    let italic_H =<< EOF
    __  __
   / / / /
  / /_/ /
 / __  /
/_/ /_/
EOF
    let italic_I =<< EOF
    ____
   /  _/
   / /
 _/ /
/___/
EOF
    let italic_J =<< EOF
       __
      / /
 __  / /
/ /_/ /
\____/
EOF
    let italic_K =<< EOF
    __ __
   / //_/
  / ,<
 / /| |
/_/ |_|
EOF
    let italic_L =<< EOF
    __
   / /
  / /
 / /___
/_____/
EOF
    let italic_M =<< EOF
    __  ___
   /  |/  /
  / /|_/ /
 / /  / /
/_/  /_/
EOF
    let italic_N =<< EOF
    _   __
   / | / /
  /  |/ /
 / /|  /
/_/ |_/
EOF
    let italic_O =<< EOF
   ____
  / __ \
 / / / /
/ /_/ /
\____/
EOF
    let italic_P =<< EOF
    ____
   / __ \
  / /_/ /
 / ____/
/_/
EOF
    let italic_Q =<< EOF
   ____
  / __ \
 / / / /
/ /_/ /
\___\_\
EOF
    let italic_R =<< EOF
    ____
   / __ \
  / /_/ /
 / _, _/
/_/ |_|
EOF
    let italic_S =<< EOF
   _____
  / ___/
  \__ \
 ___/ /
/____/
EOF
    let italic_T =<< EOF
  ______
 /_  __/
  / /
 / /
/_/
EOF
    let italic_U =<< EOF
   __  __
  / / / /
 / / / /
/ /_/ /
\____/
EOF
    let italic_V =<< EOF
 _    __
| |  / /
| | / /
| |/ /
|___/
EOF
    let italic_W =<< EOF
 _       __
| |     / /
| | /| / /
| |/ |/ /
|__/|__/
EOF
    let italic_X =<< EOF
   _  __
  | |/ /
  |   /
 /   |
/_/|_|
EOF
    let italic_Y =<< EOF
__  __
\ \/ /
 \  /
 / /
/_/
EOF
    let italic_Z =<< EOF
 _____
/__  /
  / /
 / /__
/____/
EOF
    let italic_1 =<< EOF
   ___
  <  /
  / /
 / /
/_/
EOF
    let italic_2 =<< EOF
   ___
  |__ \
  __/ /
 / __/
/____/
EOF
    let italic_3 =<< EOF
   _____
  |__  /
   /_ <
 ___/ /
/____/
EOF
    let italic_4 =<< EOF
   __ __
  / // /
 / // /_
/__  __/
  /_/
EOF
    let italic_5 =<< EOF
    ______
   / ____/
  /___ \
 ____/ /
/_____/
EOF
    let italic_6 =<< EOF
   _____
  / ___/
 / __ \
/ /_/ /
\____/
EOF
    let italic_7 =<< EOF
 _____
/__  /
  / /
 / /
/_/
EOF
    let italic_8 =<< EOF
   ____
  ( __ )
 / __  |
/ /_/ /
\____/
EOF
    let italic_9 =<< EOF
   ____
  / __ \
 / /_/ /
 \__, /
/____/
EOF
    let italic_0 =<< EOF
   ____
  / __ \
 / / / /
/ /_/ /
\____/
EOF
    let italic_mark1 =<< EOF
  /\//
 //\/
EOF
    let italic_mark2 =<< EOF
  _
 ( )
  V
EOF
    let italic_mark3 =<< EOF
    __
   / /
  / /
 /_/
(_)
EOF
    let italic_mark4 =<< EOF
   ______
  / ____ \
 / / __ `/
/ / /_/ /
\ \__,_/
 \____/
EOF
    let italic_mark5 =<< EOF
     __ __
  __/ // /_
 /_  _  __/
/_  _  __/
 /_//_/
EOF
    let italic_mark6 =<< EOF
     __
   _/ /
  / __/
 (_  )
/  _/
/_/
EOF
    let italic_mark7 =<< EOF
   _   __
  (_)_/_/
   _/_/
 _/_/_
/_/ (_)
EOF
    let italic_mark8 =<< EOF
  //|
 |/||
EOF
    let italic_mark9 =<< EOF
   ___
  ( _ )
 / __ \/|
/ /_/  <
\____/\/
EOF
    let italic_mark10 =<< EOF
  __/|_
 |    /
/_ __|
 |/
EOF
    let italic_mark11 =<< EOF
     __
   _/_/
  / /
 / /
/ /
|_|
EOF
    let italic_mark12 =<< EOF
     _
    | |
    / /
   / /
 _/_/
/_/
EOF
    let italic_mark13 =<< EOF
 ______
/_____/
EOF
    let italic_mark14 =<< EOF
    __
 __/ /_
/_  __/
 /_/
EOF
    let italic_mark15 =<< EOF
  _____
 /____/
/____/
EOF
    let italic_mark16 =<< EOF
     __
   _/_/
 _/_/
< <
/ /
\_\
EOF
    let italic_mark17 =<< EOF
     _
    | |
    / /
   _>_>
 _/_/
/_/
EOF
    let italic_mark18 =<< EOF
     ___
    / _/
   / /
  / /
 / /
/__/
EOF
    let italic_mark19 =<< EOF
     ___
    /  /
    / /
   / /
 _/ /
/__/
EOF
    let italic_mark20 =<< EOF
     __
    / /
   / /
  / /
 / /
/_/
EOF
    let italic_mark21 =<< EOF
__
\ \
 \ \
  \ \
   \_\
EOF
    let italic_mark22 =<< EOF
   _
  (_)
 _
(_)
EOF
    let italic_mark23 =<< EOF
   _
  (_)
 _
( )
|/
EOF
    let italic_mark24 =<< EOF
 _ _
( | )
|/|/
EOF
    let italic_mark25 =<< EOF
  _
 ( )
 |/
EOF
    let italic_mark26 =<< EOF
  __
 / /
/ /
\ \
 \_\
EOF
    let italic_mark27 =<< EOF
__
\ \
 \ \
 / /
/_/
EOF
    let italic_mark28 =<< EOF



 _
( )
|/
EOF
    let italic_mark29 =<< EOF
 _
(_)
EOF
    let italic_mark30 =<< EOF
  ___
 /__ \
  / _/
 /_/
(_)
EOF
    let italic_mark31 =<< EOF
       __
     _/_/
   _/_/
 _/_/
/_/
EOF
    let italic_mark32 =<< EOF



 _
(_)

EOF
    let italic_mark33 =<< EOF
     __
    / /
   / / 
  / /  
 / /   
/_/    
EOF








" In fact, you can also use the second index to switch categories in the 
" subcategory, so you can quickly switch with the mouse
" So some templates are equivalent to having four layers
" 1.Function class
" 2.Category
" 3.Small category line
" 4.Columns per row of subclasses
let g:vimio_config_shapes = {'set_index': a:index, 'value': [
    \ {
    \ 'index': a:indexes[0],
    \ 'step': [1, 5],
    \ 'value': [ standard_a, standard_b, standard_c, standard_d, standard_e,
    \            standard_f, standard_g, standard_h, standard_i, standard_j,
    \            standard_k, standard_l, standard_m, standard_n, standard_o,
    \            standard_p, standard_q, standard_r, standard_s, standard_t,
    \            standard_u, standard_v, standard_w, standard_x, standard_y,
    \            standard_z, standard_mark1, standard_mark2, standard_mark3, standard_mark4 ]
    \ },
    \ {
    \ 'index': a:indexes[1],
    \ 'step': [1, 5],
    \ 'value': [ standard_A, standard_B, standard_C, standard_D, standard_E,
    \            standard_F, standard_G, standard_H, standard_I, standard_J,
    \            standard_K, standard_L, standard_M, standard_N, standard_O,
    \            standard_P, standard_Q, standard_R, standard_S, standard_T,
    \            standard_U, standard_V, standard_W, standard_X, standard_Y,
    \            standard_Z, standard_mark5, standard_mark6, standard_mark7, standard_mark8 ]
    \ },
    \ {
    \ 'index': a:indexes[2],
    \ 'step': [1, 5],
    \ 'value': [ standard_1, standard_2, standard_3, standard_4, standard_5,
    \            standard_6, standard_7, standard_8, standard_9, standard_0,
    \            standard_mark9, standard_mark10, standard_mark11, standard_mark12, standard_mark13,
    \            standard_mark14, standard_mark15, standard_mark16, standard_mark17, standard_mark18,
    \            standard_mark19, standard_mark20, standard_mark21, standard_mark22, standard_mark23,
    \            standard_mark24, standard_mark25, standard_mark26, standard_mark27, standard_mark28,
    \ ]
    \ },
    \ {
    \ 'index': a:indexes[3],
    \ 'step': [1, 5],
    \ 'value': [ italic_a, italic_b, italic_c, italic_d, italic_e,
    \            italic_f, italic_g, italic_h, italic_i, italic_j,
    \            italic_k, italic_l, italic_m, italic_n, italic_o,
    \            italic_p, italic_q, italic_r, italic_s, italic_t,
    \            italic_u, italic_v, italic_w, italic_x, italic_y,
    \            italic_z, italic_mark1, italic_mark2, italic_mark3, italic_mark4 ]
    \ },
    \ {
    \ 'index': a:indexes[4],
    \ 'step': [1, 5],
    \ 'value': [ italic_A, italic_B, italic_C, italic_D, italic_E,
    \            italic_F, italic_G, italic_H, italic_I, italic_J,
    \            italic_K, italic_L, italic_M, italic_N, italic_O,
    \            italic_P, italic_Q, italic_R, italic_S, italic_T,
    \            italic_U, italic_V, italic_W, italic_X, italic_Y,
    \            italic_Z, italic_mark5, italic_mark6, italic_mark7, italic_mark8 ]
    \ },
    \ {
    \ 'index': a:indexes[5],
    \ 'step': [1, 5],
    \ 'value': [ italic_1, italic_2, italic_3, italic_4, italic_5,
    \            italic_6, italic_7, italic_8, italic_9, italic_0,
    \            italic_mark9, italic_mark10, italic_mark11, italic_mark12, italic_mark13,
    \            italic_mark14, italic_mark15, italic_mark16, italic_mark17, italic_mark18,
    \            italic_mark19, italic_mark20, italic_mark21, italic_mark22, italic_mark23,
    \            italic_mark24, italic_mark25, italic_mark26, italic_mark27, italic_mark28,
    \            italic_mark29, italic_mark30, italic_mark31, italic_mark32, italic_mark33,
    \ ]
    \ }
    \ ],
    \ }
endfunction

