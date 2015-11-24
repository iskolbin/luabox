local lb = require('luabox')
local active = true

local x, y = 10, 10
local info  = '<none>'
local info2 = '<none>'

local render = function()
    lb.clear()
    lb.print( 'Palette', 0, 0, lb.gray(1) + lb.BOLD + lb.UNDERLINE, lb.gray(0) )

    for i = 0, lb.RGBCOLORMAX do
        for j = 0, lb.RGBCOLORMAX do
            for k = 0, lb.RGBCOLORMAX do
                local x = i + 6*k
                local y = j + 1
                lb.print( ' ', x, y, 0, lb.rgb( i/lb.RGBCOLORMAX, j/lb.RGBCOLORMAX, k/lb.RGBCOLORMAX ))
            end
        end
    end

    lb.print( 'Grayscale', 0, lb.RGBCOLORMAX+3, lb.gray(1) + lb.BOLD + lb.UNDERLINE, lb.gray(0) )
    for i = 0, lb.GRAYMAX do
        lb.print( ' ', i, lb.RGBCOLORMAX+4, 0, lb.gray(i/lb.GRAYMAX))
    end

    local ROW = lb.RGBCOLORMAX+6
    lb.print( 'Mix', 0, ROW, lb.gray(1) + lb.BOLD + lb.UNDERLINE, lb.gray(0) )

    for i = 0, 10*lb.RGBCOLORMAX do
        local v = 0.1*i/lb.RGBCOLORMAX
        lb.print( ' ', i, ROW+1, 0, lb.rgb(v,0,0))
        lb.print( ' ', i, ROW+2, 0, lb.rgb(0,v,0))
        lb.print( ' ', i, ROW+3, 0, lb.rgb(0,0,v))
        lb.print( ' ', i, ROW+4, 0, lb.rgb(0,v,v))
        lb.print( ' ', i, ROW+5, 0, lb.rgb(v,0,v))
        lb.print( ' ', i, ROW+6, 0, lb.rgb(v,v,0))
        lb.print( ' ', i, ROW+7, 0, lb.rgb(v,v,v))
        lb.print( ' ', i, ROW+8, 0, lb.rgb(0.5*v,v,v))
        lb.print( ' ', i, ROW+9, 0, lb.rgb(v,0.5*v,v))
        lb.print( ' ', i, ROW+10, 0, lb.rgb(v,v,0.5*v))
        lb.print( ' ', i, ROW+11, 0, lb.rgb(0.5*v,0.5*v,v))
        lb.print( ' ', i, ROW+12, 0, lb.rgb(v,0.5*v,0.5*v))
        lb.print( ' ', i, ROW+13, 0, lb.rgb(0.5*v,v,0.5*v))
        lb.print( ' ', i, ROW+14, 0, lb.rgb(0.5*v,0.5*v,0.5*v))
    end

    lb.print( 'Event info', 0, lb.RGBCOLORMAX+22, lb.gray(1) + lb.BOLD + lb.UNDERLINE, lb.gray(0) )
    lb.print( info, 0, lb.RGBCOLORMAX+23, lb.gray(1), lb.gray(0) )
    lb.print( info2, 0, lb.RGBCOLORMAX+24, lb.gray(1), lb.gray(0) )
    
    lb.print( ('Screen size: %dx%d'):format( lb.width(), lb.height()), 0, lb.RGBCOLORMAX+28, lb.gray(1), lb.gray(0) )

    lb.print( 'Press <ESC> to exit', 0, lb.RGBCOLORMAX+30, lb.gray(1) + lb.REVERSE, lb.gray(0) )

    lb.present()
end

local onkey = function( ch, key, mod )
    if key == lb.ESC then
        active = false
    end

    info = ('Key event: ch=%q key=%d mod=%d'):format( ch, key, mod )
end

local onresize = function( w, h )
	info2 = 'Resize event: w=' .. w .. ' h=' .. h
end


lb.init( lb.INPUT_CURRENT, lb.OUTPUT_256 )
lb.setcallback( lb.EVENT_KEY, onkey )
lb.setcallback( lb.EVENT_RESIZE, onresize )

while active do
    render()
    lb.peek()
end

lb.shutdown()
