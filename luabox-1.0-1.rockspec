package = 'LuaBox'
version = '1.0-1'
source = {
	url = 'git://github.com/iskolbin/luabox'
	tag = '1.0',
}
description = {
	summary = 'Highlevel Lua bindings to termbox library',
	detailed = [[]],
	homepage = 'https://github.com/iskolbin/luabox',
	license = 'MIT/X11',
}
dependencies = {
	'lua >= 5.1'
}
build = {
	type = 'builtin',
	modules = {
		luabox = {
			sources = {'src/luabox.c'}
		},
		termbox = {
			sources = {
				'src/termbox/termbox.c', 
				'src/termbox/utf8.c', 
				'src/termbox/bytebuffer.inl', 
				'src/termbox/input.inl',
				'src/termbox/term.inl',
				'src/termbox/termbox.h',
			},
		}
	}
}