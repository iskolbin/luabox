# README #

## Quick summary ##

Highlevel Lua bindings to termbox library (see https://github.com/nsf/termbox).  

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
* init( [inputmode, outputmode] )
* shutdown()

### Setting input and/or output modes
* setinput( mode )
* setoutput( mode )

#### Input modes ####
* INPUT\_CURRENT
* INPUT\_ESC
* INPUT\_ALT

#### Output modes ####
* OUTPUT\_CURRENT
* OUTPUT\_NORMAL
* OUTPUT\_256
* OUTPUT\_RGB216
* OUTPUT\_GRAY24

### Peeking and processing an event ###

* peek( [timeout] ) -- timeout is infinite by default
* setcallback( event, callback )

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
* EVENT\_KEY -- callback( ch, key, mod )
* EVENT\_RESIZE -- callback( width, height )
* EVENT\_MOUSE -- callback( x, y, key )

#### Predefined keys ####
* F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12
* INSERT, DELETE
* HOME, END, PGUP, PGDN
* UP, LEFT, DOWN, RIGHT
* BACKSPACE, ENTER, SPACE
* ESC

#### Mouse keys ####
* MOUSE\_LEFT
* MOUSE\_RIGHT
* MOUSE\_MIDDLE
* MOUSE\_RELEASE
* MOUSE\_WHEEL\_UP
* MOUSE\_WHEEL\_DOWN

### Changing content ###
* clear( [textcolor, bgcolor] )
* print( str, x, y, [textcolor, bgcolor, width, height, mode] )
* setcell( ch, x, y, [textcolor, bgcolor] )

#### Text color modifiers ####

* BOLD -- text bold
* UNDERLINE - text underline
* REVERSE -- reverse color

To use them simply add to color i.e.

```lua
local boldText = lb.gray( 1 ) + lb.BOLD 
```

#### Printing modes ####
* WRAP
* TRUNC
* REPEAT


### Rendering ###
* present()

### Moving cursor ###
* setcursor( x, y )

### Color conversions ###

Functions assume that 0 <= color <= 1.

* rgb( r, g, b ) -- for output mode OUTPUT\_256
* gray( gr ) -- for output mode OUTPUT\_256
* rgb216( r, g, b ) -- for output mode OUTPUT\_RGB216
* gray24( gr ) -- for output mode OUTPUT\_GRAY24

#### Color constants ####
* RGBMAX -- RGB colors count - 1
* RGBCOLORMAX -- RGB color range max resolution
* GRAYMAX -- grayscale color range max resolution

### Example usage ###

See examples folder

####color.lua####
Testing script showing colored text

####fallingblocks.lua####
Falling blocks game

####lufm.lua####
Primitive file manager

####repl.lua####
REPL for Lua

####corerl.lua####
Clone of small rogulike game, see http://www.locklessinc.com/articles/512byte\_roguelike/
