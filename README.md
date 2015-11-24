# README #

## Quick summary ##

Highlevel Lua bindings to termbox library (see https://github.com/nsf/termbox).  

## Setup ##

```sh
luarocks install luabox
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
* INPUT_CURRENT
* INPUT_ESC
* INPUT_ALT

#### Output modes ####
* OUTPUT_CURRENT
* OUTPUT_NORMAL
* OUTPUT_256
* OUTPUT_RGB216
* OUTPUT_GRAY24

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
* EVENT_KEY -- callback( ch, key, mod )
* EVENT_RESIZE -- callback( width, height )

#### Predefined keys ####
* F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12
* INSERT, DELETE
* HOME, END, PGUP, PGDN
* UP, LEFT, DOWN, RIGHT
* BACKSPACE, ENTER, SPACE
* ESC

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

* rgb( r, g, b ) -- for output mode OUTPUT_256
* gray( gr ) -- for output mode OUTPUT_256
* rgb216( r, g, b ) -- for output mode OUTPUT_RGB216
* gray24( gr ) -- for output mode OUTPUT_GRAY24

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
