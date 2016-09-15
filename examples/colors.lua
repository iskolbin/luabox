local Luabox = require('luabox')
local active = true

local x, y = 10, 10
local info  = '<none>'
local info2 = '<none>'
local info3 = '<none>'

local render = function()
    Luabox.clear()
    Luabox.print( 'Palette', 0, 0, Luabox.grayf(1) + Luabox.BOLD + Luabox.UNDERLINE, Luabox.grayf(0) )

    for r = 0, Luabox.RGBCOLORMAX do
        for g = 0, Luabox.RGBCOLORMAX do
            for b = 0, Luabox.RGBCOLORMAX do
                local x = b + 6*g
                local y = r + 1
                Luabox.print( ' ', x, y, 0, Luabox.rgbf( r/Luabox.RGBCOLORMAX, g/Luabox.RGBCOLORMAX, b/Luabox.RGBCOLORMAX ))
            end
        end
    end

    Luabox.print( 'Grayscale', 0, Luabox.RGBCOLORMAX+3, Luabox.grayf(1) + Luabox.BOLD + Luabox.UNDERLINE, Luabox.grayf(0) )
    for i = 0, Luabox.GRAYMAX do
        Luabox.print( ' ', i, Luabox.RGBCOLORMAX+4, 0, Luabox.grayf(i/Luabox.GRAYMAX))
    end

    local ROW = Luabox.RGBCOLORMAX+6
    Luabox.print( 'Mix', 0, ROW, Luabox.grayf(1) + Luabox.BOLD + Luabox.UNDERLINE, Luabox.grayf(0) )

    for i = 0, 12*Luabox.RGBCOLORMAX do
        local v = 0.1*i/Luabox.RGBCOLORMAX
        Luabox.print( ' ', i, ROW+1, 0, Luabox.rgbf(v,0,0))
        Luabox.print( ' ', i, ROW+2, 0, Luabox.rgbf(0,v,0))
        Luabox.print( ' ', i, ROW+3, 0, Luabox.rgbf(0,0,v))
        Luabox.print( ' ', i, ROW+4, 0, Luabox.rgbf(0,v,v))
        Luabox.print( ' ', i, ROW+5, 0, Luabox.rgbf(v,0,v))
        Luabox.print( ' ', i, ROW+6, 0, Luabox.rgbf(v,v,0))
        Luabox.print( ' ', i, ROW+7, 0, Luabox.rgbf(v,v,v))
        Luabox.print( ' ', i, ROW+8, 0, Luabox.rgbf(0.5*v,v,v))
        Luabox.print( ' ', i, ROW+9, 0, Luabox.rgbf(v,0.5*v,v))
        Luabox.print( ' ', i, ROW+10, 0, Luabox.rgbf(v,v,0.5*v))
        Luabox.print( ' ', i, ROW+11, 0, Luabox.rgbf(0.5*v,0.5*v,v))
        Luabox.print( ' ', i, ROW+12, 0, Luabox.rgbf(v,0.5*v,0.5*v))
        Luabox.print( ' ', i, ROW+13, 0, Luabox.rgbf(0.5*v,v,0.5*v))
        Luabox.print( ' ', i, ROW+14, 0, Luabox.rgbf(0.5*v,0.5*v,0.5*v))
		end

    Luabox.print( 'Event info', 0, Luabox.RGBCOLORMAX+22, Luabox.grayf(1) + Luabox.BOLD + Luabox.UNDERLINE, Luabox.grayf(0) )
    Luabox.print( info, 0, Luabox.RGBCOLORMAX+23, Luabox.grayf(1), Luabox.grayf(0) )
    Luabox.print( info2, 0, Luabox.RGBCOLORMAX+24, Luabox.grayf(1), Luabox.grayf(0) )
    Luabox.print( info3, 0, Luabox.RGBCOLORMAX+25, Luabox.grayf(1), Luabox.grayf(0) )

    Luabox.print( ('Screen size: %dx%d'):format( Luabox.width(), Luabox.height()), 0, Luabox.RGBCOLORMAX+28, Luabox.grayf(1), Luabox.grayf(0) )

    Luabox.print( 'Press <ESC> to exit', 0, Luabox.RGBCOLORMAX+30, Luabox.grayf(1) + Luabox.REVERSE, Luabox.grayf(0) )

    Luabox.present()
end

local onkey = function( ch, key, mod )
    if key == Luabox.ESC then
        active = false
    end

    info = ('Key event: ch=%q key=%d mod=%d'):format( ch, key, mod )
end

local onresize = function( w, h )
	info2 = 'Resize event: w=' .. w .. ' h=' .. h
end

local onmouse = function( x, y, key )
	local msg = ''
	if key == Luabox.MOUSE_LEFT then msg = '<LEFT>'
	elseif key == Luabox.MOUSE_RIGHT then msg = '<RIGHT>'
	elseif key == Luabox.MOUSE_RELEASE then msg = '<RELEASE>'
	elseif key == Luabox.MOUSE_WHEEL_UP then msg = '<WHEEL UP>'
	elseif key == Luabox.MOUSE_WHEEL_DOWN then msg = '<WHEEL DOWN>'
	end

	local ch, fg, bg = Luabox.getcell( x, y )

	info3 = 'Mouse event: x=' .. x .. ' y= ' .. y .. ' key=' .. msg .. ' ch=' .. ch .. ' fg=' .. fg .. ' bg=' .. bg
end

Luabox.init( Luabox.INPUT_ESC + Luabox.INPUT_MOUSE, Luabox.OUTPUT_256 )
Luabox.setcallback( Luabox.EVENT_KEY, onkey )
Luabox.setcallback( Luabox.EVENT_RESIZE, onresize )
Luabox.setcallback( Luabox.EVENT_MOUSE, onmouse )

while active do
    render()
    Luabox.peek()
end

Luabox.shutdown()
