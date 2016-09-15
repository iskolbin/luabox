local Luabox = require('luabox')

Luabox.init( Luabox.INPUT_CURRENT, Luabox.OUTPUT_256 )

local REPL = {
	active = true,
	buffer = {},
	bufferpos = 1,
	current = '',
	pos = 0,
	about = _VERSION .. '\nmade with luabox (https://bitbucket.org/iskolbin/luabox)\nby Ilya Kolbin (iskolbin@gmail.com)',
	output = '',
	outputsep = ' ',
	output_error = false,
	recursiveTableString = '<tbl_%d>',

	title = 'Lua REPL v 1.0.0',
	newline = '> ',
	oldExit = os.exit,

	tostr = function( self, item, tbls )
		if type( item ) == 'string' then 
			return ('%q'):format( item )
		elseif type( item ) == 'table' then
			if tbls[item] then
				return tbls[item]
			end

			tbls.n = (tbls.n or 0) + 1
			tbls[item] = self.recursiveTableString:format( tbls.n )
			local acc = {}
			for i = 1, #item do
				acc[#acc+1] = self:tostr( item[i], tbls )
			end
			local kvacc = {}
			for k, v in pairs( item ) do
				if not acc[k] then
					kvacc[#kvacc+1] = '['..self:tostr(k, tbls)..'] = ' .. self:tostr(v,tbls)
				end
			end
			return '{' .. table.concat( acc, ',' ) .. (#kvacc > 0 and (',' .. table.concat( kvacc, ',' )) or '') .. '}'
		else
			return tostring( item )
		end
	end,

	renderTitle = function( self )
		Luabox.print( self.title, 1, 1, Luabox.grayf( 1 ) + Luabox.BOLD + Luabox.UNDERLINE, Luabox.grayf( 0 ))
	end,

	renderCurrent = function( self )
		local current = self.current
		Luabox.print( self.newline .. current, 1, 3, Luabox.grayf(1) + Luabox.BOLD, Luabox.grayf(0))
		local csymb = current:sub(self.pos+1,self.pos+1)
		Luabox.print( csymb == '' and ' ' or csymb, 3+self.pos, 3, Luabox.rgbf(0,0,0)+Luabox.BOLD, Luabox.rgbf(1,1,1))
	end,

	renderOutput = function( self )
		if self.output_error then
			Luabox.print( self.output, 3, 5, Luabox.rgbf(1,0,0), Luabox.grayf(0))
		else
			Luabox.print( self.output, 3, 5, Luabox.rgbf(0,1,0), Luabox.grayf(0))
		end
	end,

	render = function( self )
		local pos, current, output = self.pos, self.current, self.output
		Luabox.clear()
		self:renderTitle()
		self:renderCurrent()
		self:renderOutput()
		Luabox.present()
	end,
	
	backspace = function( self ) 
		if self.pos > 0 and #self.current > 0 then
			self.current = self.current:sub(1,self.pos-1) .. self.current:sub(self.pos+1)
			self.pos = self.pos - 1
		end
	end,

	execute = function( self )
		local result, err = loadstring(  self.current:sub(1,1) == '=' and ('return ' .. self.current:sub(2)) or self.current )
		if err then
			self.output_error = true
			self.output = err
		else
			self.output_error = false
			local out = {pcall( result )}
			self.output_error = not out[1]
			local toprint = {}
			for i = 2, #out do
				toprint[i-1] = self:tostr( out[i],{} )
			end
			self.output = tostring( table.concat(toprint,self.outputsep) or '<none>' )
		end
		self.buffer[#self.buffer+1] = self.current
		self.current = ''
		self.pos = 0 
		self.bufferpos = #self.buffer+1
	end,

	addch = function( self, ch )	
		local pos = self.pos
		self.current = self.current:sub(1,pos) .. ch .. self.current:sub(pos+1)
		self.pos = pos + #ch
	end,

	move = function( self, dx )
		if self.pos+dx-1 < #self.current and self.pos+dx >= 0 then
			self.pos = self.pos + dx
		end
	end,

	onresize = function( self, w, h )
	end,

	scanbuffer = function( self, dy )
		if self.buffer[self.bufferpos+dy] then
			self.bufferpos = self.bufferpos + dy
			self.current = self.buffer[self.bufferpos]
		else
			self.bufferpos = #self.buffer+1
			self.current = ''
		end
	end,

	onkey = function( self, ch, key, mod )
		if key == Luabox.BACKSPACE2 then
			self:backspace()
		elseif key == Luabox.ENTER then
			self:execute()
		elseif key == Luabox.SPACE then
			self:addch( ' ' )
		elseif key == Luabox.LEFT then
			self:move( -1 )
		elseif key == Luabox.RIGHT then
			self:move( 1 )
		elseif key == Luabox.UP then
			self:scanbuffer( -1 )
		elseif key == Luabox.DOWN then
			self:scanbuffer( 1 )
		else
			self:addch( ch )
		end
	end,
}

os.exit = function(...) REPL.active = false end

Luabox.setcallback( Luabox.EVENT_KEY, function(...) REPL:onkey(...) end )
Luabox.setcallback( Luabox.EVENT_RESIZE, function(...) REPL:onresize(...) end )

REPL.output = REPL.about
_G.REPL = REPL

while REPL.active do
	REPL:render()
	Luabox.peek()
end

Luabox.shutdown()
