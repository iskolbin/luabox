#define LUA_LIB
#include "lua.h"
#include "lauxlib.h"
#include <stdio.h>
#include <string.h>
#include <stddef.h>
#include <ctype.h>
#include <math.h>
#include <assert.h>

#include "termbox/termbox.h"

#if (LUA_VERSION_NUM<=501)
#define lua_len(L,i) (lua_pushnumber( (L), lua_objlen( (L), (i) )))
#define luaL_newlib(L,l) (lua_newtable(L), luaL_register(L,NULL,l))
#endif

#ifndef luaL_checkint
#define luaL_checkint luaL_checkinteger
#endif

#define LUABOX_WRAP     0
#define LUABOX_WRAP_RAW 1
#define LUABOX_TRUNC    2
#define LUABOX_REPEAT   3

#define LUABOX_RGBCOLORMAX 5
#define LUABOX_RGBMAX  ((LUABOX_RGBCOLORMAX+1)*(LUABOX_RGBCOLORMAX+1)*(LUABOX_RGBCOLORMAX+1)-1)
#define LUABOX_GRAYMAX 23


#ifdef _WIN32
__declspec (dllexport)
#endif
int luaopen_luabox( lua_State *L );

struct luabox_State {
	struct tb_event event;
	const char TB_EVENT_KEY_[1];
	const char TB_EVENT_RESIZE_[1];
	const char TB_EVENT_MOUSE_[1];
};

static int lua_tb_init( lua_State *L ) {
	int err = tb_init();
	struct luabox_State *lbstate;

	if ( err ) {
		lua_pushnil( L );
		lua_pushinteger( L, err );
		return 2;
	}

	if ( lua_gettop( L ) >= 1 ) {
		if ( lua_isnumber( L, 1 )) {
			uint16_t inputmode = (uint16_t) lua_tonumber( L, 1 );
			tb_select_input_mode( inputmode );
		}
	}

	if ( lua_gettop( L ) >= 2 ) {
		if ( lua_isnumber( L, 2 )) {
			uint16_t ouputmode = (uint16_t) lua_tonumber( L, 2 );
			tb_select_output_mode( ouputmode );
		}
	}

	lua_pushlightuserdata( L, L );
	lbstate = lua_newuserdata( L, sizeof *lbstate );
	lua_settable( L, LUA_REGISTRYINDEX );

	return 0;
}

static int lua_tb_shutdown( lua_State *L ) {
	tb_shutdown();

	return 0;
}

static int lua_tb_width( lua_State *L ) {
	lua_pushinteger( L, tb_width());

	return 1;
}

static int lua_tb_height( lua_State *L ) {
	lua_pushinteger( L, tb_height());

	return 1;
}

static int lua_tb_clear( lua_State *L ) {
	if ( lua_gettop( L ) >= 2) {
		uint16_t fg = luaL_checkint( L, 1 );
		uint16_t bg = luaL_checkint( L, 2 );

		tb_set_clear_attributes( fg, bg );
	}

	tb_clear();

	return 0;
}

static int lua_tb_present( lua_State *L ) {
	tb_present();

	return 0;
}

static int lua_tb_set_cursor( lua_State *L ) {
	int x = luaL_checkint( L, 1 );
	int y = luaL_checkint( L, 2 );

	tb_set_cursor( x, y );

	return 0;
}

static int luabox_setcell( lua_State *L ) {
	const char *chstr = luaL_checkstring( L, 1 );
	int x = luaL_checkint( L, 2 );
	int y = luaL_checkint( L, 3 );
	uint16_t fg;
	uint16_t bg;
	uint32_t ch;

	tb_utf8_char_to_unicode( &ch, chstr );

	fg = lua_isnumber( L, 4 ) ? lua_tonumber( L, 4 ) : TB_DEFAULT;
	bg = lua_isnumber( L, 5 ) ? lua_tonumber( L, 5 ) : TB_DEFAULT;

	tb_change_cell( x, y, ch, fg, bg );

	return 0;
}

static int luabox_print( lua_State *L ) {
	const char *chstr = luaL_checkstring( L, 1 );
	int x = luaL_checkint( L, 2 );
	int y = luaL_checkint( L, 3 );
	uint16_t fg;
	uint16_t bg;
	int w;
	int h;
	int xfrom = x;
	int len;
	int lensaved;
	const char *chstrfrom = chstr;
	int mode;
	int CR = 0;
	int NL = 0;
	int wrapped = 0;

	lua_len( L, 1 );
	len = lensaved = (int) lua_tonumber( L, -1 );
	lua_pop( L, 1 );

	fg = lua_isnumber( L, 4 ) ? lua_tonumber( L, 4 ) : TB_DEFAULT;
	bg = lua_isnumber( L, 5 ) ? lua_tonumber( L, 5 ) : TB_DEFAULT;
	w = lua_isnumber( L, 6 ) ? lua_tonumber( L, 6 ) : tb_width();
	h = lua_isnumber( L, 7 ) ? lua_tonumber( L, 7 ) : tb_height();
	mode = lua_isnumber( L, 8 ) ? lua_tonumber( L, 8 ) : LUABOX_WRAP;

	w = w + xfrom;
	h = h + y;

	while ( len > 0 ) {
		uint32_t ch;
		int chlen = tb_utf8_char_to_unicode( &ch, chstr );

		if ( ch == '\n' && CR ) {
			CR = 0;
		} else if ( ch == '\r' || ch == '\n' ) {
			NL = 1;
		} else {
			tb_change_cell( x, y, ch, fg, bg );
			if ( x >= w-1 ) {
				NL = 1;
				wrapped = 1;
			} else {
				if ( wrapped && mode == LUABOX_WRAP && ( ch == ' ' || ch == '\t' ) && x == xfrom ) {
				} else {
					x++;
					wrapped = 0;
				}
			}
		}
		len -= chlen;
		chstr += chlen;

		if ( NL ) {
			NL = 0;
			if ( mode == LUABOX_TRUNC || y >= h-1 ) {
				break;
			} else {
				if ( ch == '\r' ) CR = 1;
				y++;
				x = xfrom;
			}
		}

		if ( len <= 0 && mode == LUABOX_REPEAT ) {
			chstr = chstrfrom;
			len = lensaved;
		}
	}

	return 0;
}

static int luabox_fill( lua_State *L ) {
	const char *chstr = luaL_checkstring( L, 1 );
	int x0 = luaL_checkint( L, 2 );
	int y0 = luaL_checkint( L, 3 );
	int w = luaL_checkint( L, 4 );
	int h = luaL_checkint( L, 5 );
	uint16_t fg = lua_isnumber( L, 6 ) ? lua_tonumber( L, 6 ) : TB_DEFAULT;
	uint16_t bg = lua_isnumber( L, 7 ) ? lua_tonumber( L, 7 ) : TB_DEFAULT;
	int x, y;
	uint32_t ch;
	
	tb_utf8_char_to_unicode( &ch, chstr );
			
	for ( x = x0; x < x0 + w; x++ ) {
		for ( y = y0; y < y0 + h; y++ ) {
			tb_change_cell( x, y, ch, fg, bg );
		}
	}

	return 0;
}

static int lua_tb_select_input_mode( lua_State *L ) {
	int mode = luaL_checkint( L, 1 );
	lua_pushnumber( L, tb_select_input_mode( mode ));
	return 1;
}

static int lua_tb_select_output_mode( lua_State *L ) {
	int mode = luaL_checkint( L, 1 );
	lua_pushnumber( L, tb_select_output_mode( mode ));
	return 1;
}

#ifndef CELL
#define CELL(buf, x, y) (buf)->cells[(y) * (buf)->width + (x)]
#endif

static int luabox_getcell( lua_State *L ) {
	uint16_t x = luaL_checknumber( L, 1 );
 	uint16_t y = luaL_checknumber( L, 2 );
	if ( x >= 0 && x < tb_width() && y >= 0 && y < tb_height()) {
		struct tb_cell *cell = (tb_cell_buffer() + y * tb_width() + x);
		lua_pushnumber( L, cell->ch );
		lua_pushnumber( L, cell->fg );
		lua_pushnumber( L, cell->bg );
		return 3;
	} else {
		luaL_error( L, "coordinates out of bounds" );
		return 0;
	}
}

#define LUABOX_CALL(event) \
	case event: \
lua_pushlightuserdata( L, (void *) &lbstate->event ## _ ); \
lua_gettable( L, LUA_REGISTRYINDEX ); \
if ( lua_isfunction( L, -1 )) {

#define LUABOX_RETURN(event,inV,outV) \
	if ( lua_pcall( L, (inV), (outV), 0) != 0 ) { \
		luaL_error( L, "error calling '%s': %s", # event, lua_tostring( L, -1 )); \
	} \
} \
return 0; \

static int lua_tb_peek_event( lua_State *L ) {
	int event_type = 0;
	struct luabox_State *lbstate;
	struct tb_event *event_struct;

	lua_pushlightuserdata( L, L );
	lua_gettable( L, LUA_REGISTRYINDEX );
	lbstate = lua_touserdata( L, -1 );
	event_struct = &lbstate->event;
	if ( lua_isnumber( L, 1 ) ) {
		event_type = tb_peek_event( event_struct, (int) lua_tonumber( L, 1 ));
	} else {
		event_type = tb_poll_event( event_struct );
	}

	switch ( event_type ) {
		LUABOX_CALL( TB_EVENT_KEY )
		if ( event_struct->ch ) {
			char buffer[8] = {0};
			tb_utf8_unicode_to_char( buffer, event_struct->ch );
			lua_pushstring( L, buffer );
			lua_pushnumber( L, event_struct->ch );
		} else {
			lua_pushstring( L, "" );
			lua_pushnumber( L, event_struct->key );
		}
		lua_pushnumber( L, event_struct->mod );
		LUABOX_RETURN( TB_EVENT_KEY, 3, 0 )

		LUABOX_CALL( TB_EVENT_RESIZE )
		lua_pushnumber( L, event_struct->w );
		lua_pushnumber( L, event_struct->h );
		LUABOX_RETURN( TB_EVENT_RESIZE, 2, 0 )

		LUABOX_CALL( TB_EVENT_MOUSE )
		lua_pushnumber( L, event_struct->x );
		lua_pushnumber( L, event_struct->y );
		lua_pushnumber( L, event_struct->key );
		LUABOX_RETURN( TB_EVENT_MOUSE, 3, 0 )
	}

	return 0;
}

#undef LUABOX_CALL
#undef LUABOX_RETURN

#define LUABOX_CALLBACK(event) \
	case event: { \
								lua_pushlightuserdata( L, (void *) &lbstate->event ## _ ); \
								lua_pushvalue( L, 2 ); \
								lua_settable( L, LUA_REGISTRYINDEX ); \
								break; \
							}

static int luabox_set_callback( lua_State *L ) {
	int event_type;
	struct luabox_State *lbstate;

	lua_pushlightuserdata( L, L );
	lua_gettable( L, LUA_REGISTRYINDEX );
	lbstate = lua_touserdata( L, -1 );

	event_type = luaL_checkint( L, 1 );
	if ( lua_isfunction( L, 2 )) {
		switch ( event_type ) {
			LUABOX_CALLBACK( TB_EVENT_KEY );
			LUABOX_CALLBACK( TB_EVENT_RESIZE );
			LUABOX_CALLBACK( TB_EVENT_MOUSE );
		}
	}

	return 0;
}


#undef LUABOX_CALLBACK

static int luabox_gray_internal( lua_State *L, lua_Number mul ) {
	lua_Number gr, offset = 0;
	switch ( tb_select_output_mode( TB_OUTPUT_CURRENT )) {
		case TB_OUTPUT_NORMAL: 
			luaL_error( L, "wrong output mode for grayscale colors: NORMAL" );
			return 0;
		case TB_OUTPUT_216: 
			luaL_error( L, "wrong output mode for grayscale colors: 216" );
			return 0;
		case TB_OUTPUT_256:
			offset = 0xe8;
		case TB_OUTPUT_GRAYSCALE:
			gr = mul * luaL_checknumber( L, -1 );
			lua_pushnumber( L, gr + offset );
			return 1;
		default:
			luaL_error( L, "wrong output mode for grayscale colors: UNKNOWN" );
			return 0;
	}
}

static int luabox_gray( lua_State *L ) {
	return luabox_gray_internal( L, 1 );
}

static int luabox_grayf( lua_State *L ) {
	return luabox_gray_internal( L, LUABOX_GRAYMAX );
}

static int luabox_rgb_internal( lua_State *L, uint16_t mul ) {
	uint16_t r, g, b, offset = 0;
	switch ( tb_select_output_mode( TB_OUTPUT_CURRENT )) {
		case TB_OUTPUT_NORMAL: 
			luaL_error( L, "wrong output mode for RGB colors: NORMAL" );
			return 0;
		case TB_OUTPUT_GRAYSCALE: 
			luaL_error( L, "wrong output mode for RGB colors: GRAYSCALE" );
			return 0;
		case TB_OUTPUT_256:
			offset = 0x10;
		case TB_OUTPUT_216: 
			r = mul*luaL_checknumber( L, 1 ); r *= (LUABOX_RGBCOLORMAX+1) * (LUABOX_RGBCOLORMAX+1);
			g = mul*luaL_checknumber( L, 2 ); g *= (LUABOX_RGBCOLORMAX+1);
			b = mul*luaL_checknumber( L, 3 );
			lua_pushnumber( L, (r + g + b) + offset );
			return 1;
		default:
			luaL_error( L, "wrong output mode for RGB colors: UNKNOWN" );
			return 0;
	}
}

static int luabox_rgb( lua_State *L ) {
	return luabox_rgb_internal( L, 1 );
}

static int luabox_rgbf( lua_State *L ) {
	return luabox_rgb_internal( L, LUABOX_RGBCOLORMAX );
}


#define LUABOX_CONST(k,v) \
	lua_pushnumber( L, (v) ); \
lua_setfield( L, -2, (k) )

static void lua_luabox_const( lua_State *L ) {
	LUABOX_CONST( "F1", TB_KEY_F1 );
	LUABOX_CONST( "F2", TB_KEY_F2 );
	LUABOX_CONST( "F3", TB_KEY_F3 );
	LUABOX_CONST( "F4", TB_KEY_F4 );
	LUABOX_CONST( "F5", TB_KEY_F5 );
	LUABOX_CONST( "F6", TB_KEY_F6 );
	LUABOX_CONST( "F7", TB_KEY_F7 );
	LUABOX_CONST( "F8", TB_KEY_F8 );
	LUABOX_CONST( "F9", TB_KEY_F9 );
	LUABOX_CONST( "F10", TB_KEY_F10 );
	LUABOX_CONST( "F11", TB_KEY_F11 );
	LUABOX_CONST( "F12", TB_KEY_F12 );

	LUABOX_CONST( "INSERT", TB_KEY_INSERT );
	LUABOX_CONST( "DELETE", TB_KEY_DELETE );

	LUABOX_CONST( "HOME", TB_KEY_HOME );
	LUABOX_CONST( "END", TB_KEY_END );
	LUABOX_CONST( "PGUP", TB_KEY_PGUP );
	LUABOX_CONST( "PGDN", TB_KEY_PGDN );

	LUABOX_CONST( "UP", TB_KEY_ARROW_UP );
	LUABOX_CONST( "DOWN", TB_KEY_ARROW_DOWN );
	LUABOX_CONST( "LEFT", TB_KEY_ARROW_LEFT );
	LUABOX_CONST( "RIGHT", TB_KEY_ARROW_RIGHT );

	LUABOX_CONST( "BACKSPACE", TB_KEY_BACKSPACE );
	LUABOX_CONST( "BACKSPACE2", TB_KEY_BACKSPACE2 );
	LUABOX_CONST( "ENTER", TB_KEY_ENTER );
	LUABOX_CONST( "ESC", TB_KEY_ESC );
	LUABOX_CONST( "SPACE", TB_KEY_SPACE );

	LUABOX_CONST( "MOUSE_LEFT", TB_KEY_MOUSE_LEFT );
	LUABOX_CONST( "MOUSE_RIGHT", TB_KEY_MOUSE_RIGHT );
	LUABOX_CONST( "MOUSE_MIDDLE", TB_KEY_MOUSE_MIDDLE );
	LUABOX_CONST( "MOUSE_RELEASE", TB_KEY_MOUSE_RELEASE );
	LUABOX_CONST( "MOUSE_WHEEL_UP", TB_KEY_MOUSE_WHEEL_UP );
	LUABOX_CONST( "MOUSE_WHEEL_DOWN", TB_KEY_MOUSE_WHEEL_DOWN );

	LUABOX_CONST( "INPUT_CURRENT", TB_INPUT_CURRENT );
	LUABOX_CONST( "INPUT_ESC", TB_INPUT_ESC );
	LUABOX_CONST( "INPUT_ALT", TB_INPUT_ALT );
	LUABOX_CONST( "INPUT_MOUSE", TB_INPUT_MOUSE );

	LUABOX_CONST( "OUTPUT_CURRENT", TB_OUTPUT_CURRENT );
	LUABOX_CONST( "OUTPUT_NORMAL", TB_OUTPUT_NORMAL );
	LUABOX_CONST( "OUTPUT_256", TB_OUTPUT_256 );
	LUABOX_CONST( "OUTPUT_216", TB_OUTPUT_216 );
	LUABOX_CONST( "OUTPUT_GRAYSCALE", TB_OUTPUT_GRAYSCALE );

	LUABOX_CONST( "EVENT_NONE", 0 );
	LUABOX_CONST( "EVENT_KEY", TB_EVENT_KEY );
	LUABOX_CONST( "EVENT_RESIZE", TB_EVENT_RESIZE );
	LUABOX_CONST( "EVENT_MOUSE", TB_EVENT_MOUSE );

	LUABOX_CONST( "DEFAULT", TB_DEFAULT);
	LUABOX_CONST( "BLACK", TB_BLACK );
	LUABOX_CONST( "RED", TB_RED);
	LUABOX_CONST( "GREEN", TB_GREEN );
	LUABOX_CONST( "YELLOW", TB_YELLOW );
	LUABOX_CONST( "BLUE", TB_BLUE );
	LUABOX_CONST( "MAGENTA", TB_MAGENTA );
	LUABOX_CONST( "CYAN", TB_CYAN );
	LUABOX_CONST( "WHITE", TB_WHITE );

	LUABOX_CONST( "BOLD", TB_BOLD );
	LUABOX_CONST( "UNDERLINE", TB_UNDERLINE );
	LUABOX_CONST( "REVERSE", TB_REVERSE );

	LUABOX_CONST( "WRAP", LUABOX_WRAP );
	LUABOX_CONST( "WRAP_RAW", LUABOX_WRAP_RAW );
	LUABOX_CONST( "REPEAT", LUABOX_REPEAT );
	LUABOX_CONST( "TRUNC", LUABOX_TRUNC );

	LUABOX_CONST( "RGBMAX", LUABOX_RGBMAX );
	LUABOX_CONST( "RGBCOLORMAX", LUABOX_RGBCOLORMAX );
	LUABOX_CONST( "GRAYMAX", LUABOX_GRAYMAX );
}

#undef LUABOX_CONST

static const luaL_Reg luaboxlib[] = {
	{"init", lua_tb_init},
	{"shutdown", lua_tb_shutdown},
	{"present", lua_tb_present},
	{"width", lua_tb_width},
	{"height", lua_tb_height},
	{"clear", lua_tb_clear},
	{"setcell", luabox_setcell},
	{"getcell", luabox_getcell},
	{"setinput", lua_tb_select_input_mode},
	{"setoutput", lua_tb_select_output_mode},
	{"peek", lua_tb_peek_event},
	{"setcursor", lua_tb_set_cursor},
	{"setcallback", luabox_set_callback},
	{"print", luabox_print},
	{"fill", luabox_fill},
	{"rgb", luabox_rgb},
	{"gray", luabox_gray},
	{"rgbf", luabox_rgbf},
	{"grayf", luabox_grayf},
	{NULL, NULL},
};

#ifdef _WIN32
__declspec (dllexport)
#endif
int luaopen_luabox( lua_State *L ) {
	luaL_newlib( L, luaboxlib );
	lua_luabox_const( L );
	return 1;
}
