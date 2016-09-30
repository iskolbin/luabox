local luabox = require('luabox')
local ok, lfs = pcall( require, 'lfs' )

assert( ok, 'Lua file system is not installed; try\nluarocks install lfs' )

luabox.init( luabox.INPUT_CURRENT, luabox.OUTPUT_256 )

local lufm = {
	active = true,
	
	rgbf = {
		path = {1,1,0},
		folder = {0,0,1},
		executable = {0,1,0},
		common = {1,1,1},
		link = {0,1,1},
	},

	grayf = {},

	getcolor = function( self, key )
		local rgbf = self.rgbf[key]
		if rgbf then
			return luabox.rgbf( rgbf[1], rgbf[2], rgbf[3] )
		else
			local grayf = self.grayf[key]
			if grayf then
				return luabox.grayf( grayf )
			else
				return luabox.grayf( 0 )
			end
		end
	end,

	files = {},
	filteredfiles = {},
	pos = 1,
	pagepos = 1,

	chdir = function( self, dir )
		lfs.chdir( dir )
		self.pos = 1
		self.pagepos = 1
		self.files = {}
		for f in lfs.dir(lfs.currentdir()) do
			self.files[#self.files+1] = {name = f, attr = lfs.symlinkattributes(f)}
		end
		self:sort()
		self:filter()
	end,

	sorting = {
		name = function( b, a ) 
			return a.name < b.name 
		end,
		type = function( b, a )
			if a.name == '.' then return false
			elseif b.name == '.' then return true
			elseif a.name == '..' then return false
			elseif b.name == '..' then return true
			elseif a.attr.mode ~= b.attr.mode and a.attr.mode == 'directory' then return false
			elseif a.attr.mode ~= b.attr.mode and b.attr.mode == 'directory' then return true
			elseif a.attr.mode == b.attr.mode and b.attr.mode == 'directory' then return a.name < b.name
			elseif a.attr.mode ~= b.attr.mode then return a.attr.mode < b.attr.mode
			else
				local ta, tb = a.name:match('%.([%w_$]+)$'), b.name:match('%.([%w_$]+)$')
				if ta and tb then return ta < tb
				elseif not ta and tb then return true
				elseif not tb and ta then return false
				else return a.name < b.name
				end
			end
		end,
	},

	sort = function( self, mode )
		table.sort( self.files, self.sorting[mode] or self.sorting.type )
	end,
	
	filter = function( self )
		self.filteredfiles = {}
		for i = 1, #self.files do
			local f = self.files[i]
			local filtered = true
			for _, v in pairs( self.activefilters ) do
				local filter = self.filter[v]
				if filter and not filter( f ) then 
					filtered = false
					break
				end
			end
			
			if filtered then
				self.filteredfiles[#self.filteredfiles+1] = f
			end
		end
	end,

	filtering = {
		hidden = function( f )
			return f == '..' or f:sub(1,1) ~= '.'
		end,
	},

	activefilters = {},

	render = function( self )
    luabox.clear()
		luabox.print( lfs.currentdir(), 0, 0, self:getcolor'path', luabox.grayf(0))
   	local i = 0
		for i = 1, math.min( self.pagepos+#self.files-1, luabox.height()) do
			local f = self.files[i+self.pagepos-1]
			local rgbf = f.attr.mode == 'directory' and self:getcolor'folder' or 
				f.attr.permissions:match('x') and self:getcolor'executable' or
				f.attr.mode == 'link' and self:getcolor'link' or
				self:getcolor'common'
			
			if i+self.pagepos-1 == self.pos then
				luabox.print( f.name, 1, i, luabox.grayf(0), rgbf )
			else	
				luabox.print( f.name, 1, i, rgbf, luabox.grayf(0))
			end
		end
		luabox.present()
	end,
	
	exit = function( self )
		self.active = false
	end,

	setpos = function( self, pos )
		self.pos = pos
		while self.pos-self.pagepos >= luabox.height() do self.pagepos = self.pagepos + 1 end
		while self.pos-self.pagepos < 0 do self.pagepos = self.pagepos - 1 end
	end,

	exec = function( self )
		if self.filteredfiles[self.pos].attr.mode == 'directory' then
			self:chdir( self.filteredfiles[self.pos].name )
		end
	end,

	onkey = function( self, ch, key, mod )
		if key == luabox.ESC then self:exit()
    elseif key == luabox.DOWN and self.pos < #self.filteredfiles then self:setpos( self.pos + 1 )
    elseif key == luabox.UP and self.pos > 1 then self:setpos( self.pos - 1 )
		elseif key == luabox.ENTER then self:exec()
		end
	end,
	
	onresize = function( self, w, h )
	end,
}


luabox.setcallback( luabox.EVENT_KEY, function(ch,key,mod) lufm:onkey(ch,key,mod) end )
luabox.setcallback( luabox.EVENT_RESIZE, function(w,h) lufm:onresize(w,h) end )

lufm:chdir(lfs.currentdir())
while lufm.active do
	lufm:render()
	luabox.peek()
end

luabox.shutdown()
