# Luabox #

## Quick summary ##

Highlevel Lua bindings to [**termbox** library](https://github.com/nsf/termbox). Input and output sections of this readme is just little edited version from original sources, see src/termbox/termbox.h lines 233 and 259.  

## Setup ##
Building with luarocks from root folder:
```sh
luarocks make
```

To use library in your code you should:

```lua
local lb = require('luabox')
```

## API ##

### Init and finalize ###
* `init( [inputmode, outputmode] )`
* `shutdown()`

### Input ###

* `setinput( mode )`

Luabox has two input modes:
1. Esc input mode.
   When ESC sequence is in the buffer and it doesn't match any known
   ESC sequence => ESC means `KEY_ESC`.
2. Alt input mode.
   When ESC sequence is in the buffer and it doesn't match any known
   sequence => ESC enables `MOD_ALT` modifier for the next keyboard event.

You can also apply `INPUT_MOUSE` via addition operation to either of the
modes (e.g. `INPUT_ESC + INPUT_MOUSE`). If none of the main two modes
were set, but the mouse mode was, `INPUT**\_ESC` mode is used. If for some
reason you've decided to use (`INPUT_ESC + INPUT_ALT`) combination, it
will behave as if only `INPUT_ESC` was selected.

If `mode` is `INPUT_CURRENT`, it returns the current input mode.
Default luabox input mode is `INPUT_ESC`.

* `INPUT_CURRENT`
* `INPUT_ESC`
* `INPUT_ALT`
* `INPUT_MOUSE`

### Output ###

* `setoutput( mode )`

Luabox has three output options:
1. `OUTPUT_NORMAL`     => [1..8]
   This mode provides 8 different colors:
     `BLACK, RED, GREEN, YELLOW, BLUE, MAGENTA, CYAN, WHITE`

2. `OUTPUT_256`        => [0..256]
   In this mode you can leverage the 256 terminal mode:
   0x00 - 0x07: the 8 colors as in `TB_OUTPUT_NORMAL`
   0x08 - 0x0f: `TB_*` + `TB_BOLD`
   0x10 - 0xe7: 216 different colors
   0xe8 - 0xff: 24 different shades of grey

2. `OUTPUT_216`        => [0..216]
   This mode supports the 3rd range of the 256 mode only.
   But you don't need to provide an offset.

3. `OUTPUT_GRAYSCALE`  => [0..23]
   This mode supports the 4th range of the 256 mode only.
   But you dont need to provide an offset

If `mode` is `OUTPUT_CURRENT`, it returns the current output mode.
Default termbox output mode is `OUTPUT_NORMAL`.

* `OUTPUT_CURRENT`
* `OUTPUT_NORMAL`
* `OUTPUT_256`
* `OUTPUT_216`
* `OUTPUT_GRAYSCALE`

### Peeking and processing an event ###

* `peek( [timeout] )` - timeout is infinite by default.
* `setcallback( event, callback )` -- see events/callback list below.

Example usage

```lua
local onkey = function( ch, key, mode )
  if key == lb.ESC then
    lb.shutdown()
    os.exit()
  end
end

lb.setcallback( lb.EVENT_KEY, onkey )

while true do
  lb.peek()
end
```

#### Events ####
* `EVENT_KEY` - callback( ch, key, mod ).
* `EVENT_RESIZE` - callback( width, height ).
* `EVENT_MOUSE` - callback( x, y, key ).

#### Predefined keys ####
* `F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12`
* `INSERT, DELETE`
* `HOME, END, PGUP, PGDN`
* `UP, LEFT, DOWN, RIGHT`
* `BACKSPACE, ENTER, SPACE`
* `ESC`

#### Mouse keys ####
* `MOUSE_LEFT`
* `MOUSE_RIGHT`
* `MOUSE_MIDDLE`
* `MOUSE_RELEASE`
* `MOUSE_WHEEL_UP`
* `MOUSE_WHEEL_DOWN`

### Changing content ###
* `clear( [textcolor, bgcolor] )`
* `setcell( ch, x, y, [textcolor, bgcolor] )`

### Get cell content ###
* `getcell( x, y )` - returns tuple of char-code, text color and bg color of cell.

#### Text color modifiers ####

* `BOLD` - text bold.
* `UNDERLINE` - text underline.
* `REVERSE` - reverse color.

To use them simply add to color i.e.

```lua
local boldText = lb.gray( 1 ) + lb.BOLD 
```

### Highlevel functions ###

* `fill( ch, x, y, w, h, [textcolor, bgcolor] )`
* `print( str, x, y, [textcolor, bgcolor, width, height, mode] )`

Where mode is one of:

* `WRAP` (default)
* `WRAP_RAW`
* `TRUNC`
* `REPEAT`

### Rendering ###
* `present()`

### Moving cursor ###
* `setcursor( x, y )`

### Colors ###
* `rgb( r, g, b )` - for output mode `OUTPUT_256` and `OUTPUT_216`, values are integers in interval [0-5].
* `gray( gr )` - for output mode `OUTPUT_256` and `OUTPUT_GRAYSCALE`, values are intergers in interval [0-23].
* `rgbf( r, g, b )` - for output mode `OUTPUT_256` and `OUTPUT_216`, values are floats in interval [0-1].
* `grayf( gr )` - for output mode `OUTPUT_256` and `OUTPUT_GRAYSCALE`, values are floats in interval [0-1].

#### Color constants ####
* `RGBMAX` - RGB colors count - 1.
* `RGBCOLORMAX` - RGB color range max resolution.
* `GRAYMAX` -- grayscale color range max resolution.

### Example usage ###
See examples folder:

####color.lua####
Testing script showing colored text.

####fallingblocks.lua####
Falling blocks game.

####lufm.lua####
Primitive file manager.

####repl.lua####
REPL for Lua.

####corerl.lua####
Clone of small rogulike game, [details](http://www.locklessinc.com/articles/512byte\_roguelike/).
