
function! Vimio__DefineSmartDrawShapesanimal(indexes, index)
    let cat =<< EOF
   /\_/\ 
  ( o.o )
   > ^ <
EOF
    let dog =<< EOF
  _=,_
o_/6 /#\
\__ |##/
='|--\
  /   #'-.
  \#|_   _'-. /
   |/ \_( # |" 
  C/ ,--___/
EOF

let g:vimio_config_shapes = {'set_index': a:index, 'value': [
    \ {
    \ 'index': a:indexes[0],
    \ 'step': [1, 1],
    \ 'value': [ cat, dog ]
    \ }
    \ ],
    \ }
endfunction

