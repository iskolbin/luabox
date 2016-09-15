local Luabox = require'luabox'

Luabox.init( Luabox.INPUT_CURRENT, Luabox.OUTPUT_256 )

for i = 0, 0x7 do
	Luabox.print( ' ', i+1, 1, 0, i )
end

for i = 0x08, 0x0f do
	Luabox.print( ' ', i-0x08+1, 3, 0, i )
end

for i = 0x10, 0xe7 do
	local x = (i - 0x10) % 36
	local y = math.floor((i - 0x10) / 36)
	Luabox.print( ' ', x+1, y + 5, 0, i )
end

for i = 0xe8, 0xff do
	Luabox.print( ' ', i-0xe8+1, 12, 0, i )
end

local active = true

Luabox.setcallback( Luabox.EVENT_KEY, function()
	active = false
end )

Luabox.present()
while active do
	Luabox.peek()
end

Luabox.shutdown()
