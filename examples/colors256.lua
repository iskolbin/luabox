local luabox = require'luabox'

luabox.init( luabox.INPUT_CURRENT, luabox.OUTPUT_256 )

for i = 0, 0x7 do
	luabox.print( ' ', i+1, 1, 0, i )
end

for i = 0x08, 0x0f do
	luabox.print( ' ', i-0x08+1, 3, 0, i )
end

for i = 0x10, 0xe7 do
	local x = (i - 0x10) % 36
	local y = math.floor((i - 0x10) / 36)
	luabox.print( ' ', x+1, y + 5, 0, i )
end

for i = 0xe8, 0xff do
	luabox.print( ' ', i-0xe8+1, 12, 0, i )
end

local active = true

luabox.setcallback( luabox.EVENT_KEY, function()
	active = false
end )

luabox.present()
while active do
	luabox.peek()
end

luabox.shutdown()
