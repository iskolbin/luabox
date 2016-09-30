local luabox = require('luabox')
local active = true

local x, y = 10, 10
local info  = '<none>'
local info2 = '<none>'
local info3 = '<none>'

local render = function()
    luabox.clear()
    luabox.print( 'Palette', 0, 0, luabox.grayf(1) + luabox.BOLD + luabox.UNDERLINE, luabox.grayf(0) )

    for r = 0, luabox.RGBCOLORMAX do
        for g = 0, luabox.RGBCOLORMAX do
            for b = 0, luabox.RGBCOLORMAX do
                local x = b + 6*g
                local y = r + 1
                luabox.print( ' ', x, y, 0, luabox.rgbf( r/luabox.RGBCOLORMAX, g/luabox.RGBCOLORMAX, b/luabox.RGBCOLORMAX ))
            end
        end
    end

    luabox.print( 'Grayscale', 0, luabox.RGBCOLORMAX+3, luabox.grayf(1) + luabox.BOLD + luabox.UNDERLINE, luabox.grayf(0) )
    for i = 0, luabox.GRAYMAX do
        luabox.print( ' ', i, luabox.RGBCOLORMAX+4, 0, luabox.grayf(i/luabox.GRAYMAX))
    end

    local ROW = luabox.RGBCOLORMAX+6
    luabox.print( 'Mix', 0, ROW, luabox.grayf(1) + luabox.BOLD + luabox.UNDERLINE, luabox.grayf(0) )

    for i = 0, 12*luabox.RGBCOLORMAX do
        local v = 0.1*i/luabox.RGBCOLORMAX
        luabox.print( ' ', i, ROW+1, 0, luabox.rgbf(v,0,0))
        luabox.print( ' ', i, ROW+2, 0, luabox.rgbf(0,v,0))
        luabox.print( ' ', i, ROW+3, 0, luabox.rgbf(0,0,v))
        luabox.print( ' ', i, ROW+4, 0, luabox.rgbf(0,v,v))
        luabox.print( ' ', i, ROW+5, 0, luabox.rgbf(v,0,v))
        luabox.print( ' ', i, ROW+6, 0, luabox.rgbf(v,v,0))
        luabox.print( ' ', i, ROW+7, 0, luabox.rgbf(v,v,v))
        luabox.print( ' ', i, ROW+8, 0, luabox.rgbf(0.5*v,v,v))
        luabox.print( ' ', i, ROW+9, 0, luabox.rgbf(v,0.5*v,v))
        luabox.print( ' ', i, ROW+10, 0, luabox.rgbf(v,v,0.5*v))
        luabox.print( ' ', i, ROW+11, 0, luabox.rgbf(0.5*v,0.5*v,v))
        luabox.print( ' ', i, ROW+12, 0, luabox.rgbf(v,0.5*v,0.5*v))
        luabox.print( ' ', i, ROW+13, 0, luabox.rgbf(0.5*v,v,0.5*v))
        luabox.print( ' ', i, ROW+14, 0, luabox.rgbf(0.5*v,0.5*v,0.5*v))
		end

    luabox.print( 'Event info', 0, luabox.RGBCOLORMAX+22, luabox.grayf(1) + luabox.BOLD + luabox.UNDERLINE, luabox.grayf(0) )
    luabox.print( info, 0, luabox.RGBCOLORMAX+23, luabox.grayf(1), luabox.grayf(0) )
    luabox.print( info2, 0, luabox.RGBCOLORMAX+24, luabox.grayf(1), luabox.grayf(0) )
    luabox.print( info3, 0, luabox.RGBCOLORMAX+25, luabox.grayf(1), luabox.grayf(0) )

    luabox.print( ('Screen size: %dx%d'):format( luabox.width(), luabox.height()), 0, luabox.RGBCOLORMAX+28, luabox.grayf(1), luabox.grayf(0) )

    luabox.print( 'Press <ESC> to exit', 0, luabox.RGBCOLORMAX+30, luabox.grayf(1) + luabox.REVERSE, luabox.grayf(0) )

    luabox.present()
end

local onkey = function( ch, key, mod )
    if key == luabox.ESC then
        active = false
    end

    info = ('Key event: ch=%q key=%d mod=%d'):format( ch, key, mod )
end

local onresize = function( w, h )
	info2 = 'Resize event: w=' .. w .. ' h=' .. h
end

local onmouse = function( x, y, key )
	local msg = ''
	if key == luabox.MOUSE_LEFT then msg = '<LEFT>'
	elseif key == luabox.MOUSE_RIGHT then msg = '<RIGHT>'
	elseif key == luabox.MOUSE_RELEASE then msg = '<RELEASE>'
	elseif key == luabox.MOUSE_WHEEL_UP then msg = '<WHEEL UP>'
	elseif key == luabox.MOUSE_WHEEL_DOWN then msg = '<WHEEL DOWN>'
	end

	local ch, fg, bg = luabox.getcell( x, y )

	info3 = 'Mouse event: x=' .. x .. ' y= ' .. y .. ' key=' .. msg .. ' ch=' .. ch .. ' fg=' .. fg .. ' bg=' .. bg
end

luabox.init( luabox.INPUT_ESC + luabox.INPUT_MOUSE, luabox.OUTPUT_256 )
luabox.setcallback( luabox.EVENT_KEY, onkey )
luabox.setcallback( luabox.EVENT_RESIZE, onresize )
luabox.setcallback( luabox.EVENT_MOUSE, onmouse )

while active do
    render()
    luabox.peek()
end

luabox.shutdown()
