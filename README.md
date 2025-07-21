# Vimio

Vimio is a lightweight Vim plugin for drawing text-based diagrams—such as flowcharts, architecture sketches, and layout mockups—using only ASCII and Unicode characters, directly in your editor.

```
                __     __  _               _ 
                \ \   / / (_)  _ __ ___   (_)   ___  
                 \ \ / /  | | | '_ ` _ \  | |  / _ \ 
                  \ V /   | | | | | | | | | | | (_) |       
                   \_/    |_| |_| |_| |_| |_|  \___/        
```

Inspired by [Asciio](https://github.com/nkh/P5-App-Asciio) by Nadim Khemir.

With this plugin, you can draw:


```txt
╔════════════════════════════════════════════════════════╗  SGMI(GE) ┌───────┐
║   MAIN BOARD                       ┌────────┐RGMII     ║  ┌───────>│sw6    │
║              SGMII┌──────┐  MDI    │(0)     │    ┌───┐ ║  │   ┌───>│0x01   │
║   ┌────────┐  ┌──>│sw1   │<───────>│P0   RG2│<──>│sw4│<╫──┘   │    └───────┘
║   │GE0/ETH2│<─┘   └──────┘         │     (5)│    │   │ ║      │
║   │  BMC   │      ┌──────┐  MDI    │(1).---.│    └───┘ ║      │    ┌───────┐
║   │GE1/ETH3│<────>│sw2   │<───────>│P1 |sw3|│          ║      ├───>│sw7    │
║   └────────┘      └──────┘         │   '---'│RGMII     ║      │    │0x02   │
║                   ┌──────┐  MDI    │(2)     │    ┌───┐ ║      │    └───────┘
║   ┌──────────┐    │    P0│<───────>│P2   RG1│<──>│sw5│ ║      │
║   │CPU0      │<──>│NIC   │  MDI    │(3)  (4)│    │   │ ║      │    ┌───────┐
║   └──────────┘    │    P1│<───────>│P3      │    └───┘ ║      ├───>│sw8    │
║             PCIEX2└──────┘         └────────┘      ^   ║      │    │0x03   │
╚════════════════════════════════════════════════════╪═══╝      │    └───────┘
                                             SGMI(GE)│          │
                                                     v          │    ┌───────┐
                 ┌─────────────────────────────┐  .-----.       ├───>│sw9    │
                 │                             │  |     |       │    │0x01   │
                 │                             │  |other|       │    └───────┘
                 │                             │  |     |       │    ┌───────┐
                 │     .---------.             │  '-----'    ┌──┼───>│sw10   │
                 │     |   BMC   |             │<────────SGM─┼──┼────│0x02   │
                 │     '---------'             │             │  │    └───────┘
                 │                             │             │  │  ┌─────────┐
                 │                             │             │  └─>│Analog   │
                 │    OTHER MAIN BOARD         │             └────>│Switch   │
                 └─────────────────────────────┘                   └─────────┘
```

---

## Features

- Virtual text mode: draw anywhere, even beyond line ends  
- Line tools: horizontal, vertical, diagonal, with smart joins and automatic cross-point characters  
- Box-drawing: instant rectangles, adaptive corners, auto arrows  
- Erasers: cleanly remove characters, including wide glyphs  
- Clipboard: copy/cut/paste shapes or characters with precision  
- Shape templates: ASCII art, banners, LEDs, and user-defined sets  
- Live preview: floating overlay follows your cursor  
- Highlight marking: select irregular shapes for fine-grained edits  
- CJK support: draw with Chinese, Japanese, and Korean characters  

---

## Installation

### Requirements

- Vim 8.2+ compiled with:
  - `+popupwin` (for popup window support)
  - `+mouse` (for mouse interaction, optional)
  - `+clipboard` (for system clipboard integration)

- Clipboard support on Linux:
  - Install a GUI-enabled Vim build such as `vim-gtk3`:
    ```bash
    sudo apt install vim-gtk3
    ```

- A GUI version of Vim is recommended (e.g. gVim)  
  ⚠️ **Neovim is not supported**, as Vimio relies on Vim 8's `popup_*()` API, which Neovim does not implement. Maybe adapted in the future.  
  ⚠️ **Terminal Vim is partially supported** — many features work, including popup windows (with transparency in some terminals), but key mappings may conflict with terminal shortcuts, and rendering could vary depending on terminal emulator. Full support and refinement are planned in future versions.

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'qindapao/vimio'
```

### Manual (packages)

```sh
mkdir -p ~/.vim/pack/vimio/start
cp -r /path/to/vimio ~/.vim/pack/vimio/start
```

Then reload Vim or run:

```vim
:packloadall
```

### Config

To disable default mappings:

```vim
let g:vimio_enable_default_mappings = 0
```

Then check `plugin/vimio.vim` for all default mappings and redefine them in your `.vimrc` as you like.


To define your own set of shape templates:

```vim
let g:vimio_custom_shapes_dir = expand('~/.vim/vimio_custom_shapes')
let g:vimio_user_shapes_define_graph_functions = [
      \ ['Vimio__DefineSmartDrawShapesanimal', [0], 0, 'my_animal1.vim'],
      \ ['Vimio__DefineSmartDrawShapesanimal', [0], 0, 'my_animal2.vim'],
      \ ]
```

Then place your custom template files in the directory you specified (g:vimio_custom_shapes_dir).

⚠️ Important: Please avoid using the following file names in your custom templates, as they are reserved by the plugin and may cause conflicts:

basic.vim  
figlet.vim  
led.vim  
animal.vim  

Use unique names like my_animal.vim, custom_led.vim, etc., to ensure compatibility.


---

## Quick Start

Enter virtual text mode:

```vim
<Leader>vea
```

Draw a box:

```vim
M-l / M-j / M-h / M-k   " draw lines in four directions
```

Switch line style:

```vim
sl   " cycle line types (ASCII, Unicode, bold, etc.)
```

Paste a shape:

```vim
C-M-Space   " paste shape from clipboard
```

Preview before pasting:

```vim
C-j/k/h/l   " move cursor and show floating preview
```

---

## Examples

Draw a rectangle in seconds:

```
.--------.
|        |
|        |
'--------'
```

Switch to Unicode box-drawing:

```
┌────────┐
│        │
│        │
└────────┘
```

Insert a cat from the shape library:

```
 /\_/\  
( o.o ) 
 > ^ <  
```

---

## Defining Your Own Shapes

Create a file like `draw_shaps/animal.vim` and define your ASCII art.  
Register it in `autoload/vimio/shapes.vim`. See `vimio.txt` section 13 for details.

---

## Project History

Vimio draws its inspiration from and pays homage to [Asciio](https://github.com/nkh/P5-App-Asciio), Nadim Khemir’s object-oriented ASCII/Unicode diagramming suite in Perl 5 that has been evolving for over twenty years.

While Vimio doesn’t aim to replicate Asciio’s full feature set, it brings a focused, minimal approach to diagramming directly within Vim. I collaborated with Nadim on Asciio’s later development and drew heavily from its design philosophy when building Vimio.

---

## Known Limitations

- Currently tested primarily in GUI Vim (e.g. gVim).  
- Terminal Vim support is experimental and may have rendering issues.  
- TAB characters are not supported in drawing mode.
- do not surport Neovim, Maybe adapted in the future.

---

## License

MIT License © 2025 qindapao

---

## Credits

Inspired by [Asciio](https://github.com/nkh/P5-App-Asciio) by Nadim Khemir.

