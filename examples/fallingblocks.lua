local luabox = require('luabox')

luabox.init( luabox.INPUT_CURRENT, luabox.OUTPUT_256 )

local state = 'menu'
local dt = 0.5

local WHITE, BLACK = luabox.rgbf(1,1,1), luabox.rgbf(0,0,0) 

local states; states = {
	menu = {
		ingame = false,
		selected = 1,
	
		render = function( self )
			luabox.print( '  New game  ', 1, 1, WHITE, (self.selected == 1 and luabox.REVERSE) )
			luabox.print( '  Continue  ', 1, 2, self.ingame and WHITE or luabox.grayf(0.5), (self.selected == 2 and luabox.REVERSE) )
			luabox.print( '  About     ', 1, 3, WHITE, (self.selected == 3 and luabox.REVERSE) )
			luabox.print( '  Exit      ', 1, 4, WHITE, (self.selected == 4 and luabox.REVERSE) )
		end,
		
		update = function( self )
		end,
		
		resetgame = function( self )
			states.game.field = false
			states.game.figure = false
			states.game.score = 0
			states.game.level = 1
		end,
		
		onkey = function( self, ch, key, mode )
			if key == luabox.DOWN then
				self.selected = self.selected % 4 + 1
				if self.selected == 2 and not self.ingame then
					self.selected = 3
				end
				
			elseif key == luabox.UP then
				self.selected = (self.selected-2) % 4 + 1
				if self.selected == 2 and not self.ingame then
					self.selected = 1
				end
			
			elseif key == luabox.ENTER then
				if     self.selected == 1 then state = 'game'; self.ingame = true; self:resetgame()
				elseif self.selected == 2 then state = 'game'
				elseif self.selected == 3 then state = 'about'
				elseif self.selected == 4 then state = 'exit'
				end
			end
		end,
	},
	
	about = {
		render = function( self )
			luabox.print( 'About', 1, 1, WHITE + luabox.BOLD, BLACK )
			luabox.print( 'Falling blocks v 1.0', 1, 3, WHITE, BLACK )
			luabox.print( 'Made with luabox https://bitbucket.org/iskoluaboxin/luabox', 1, 4, WHITE, BLACK )
			luabox.print( 'by Ilya Kolbin iskolbin@gmail.com', 1, 5, WHITE, BLACK )
		end,
		
		update = function( self )
		end,
		
		onkey = function( self, ch, key, mode )
			state = 'menu'
		end,
	},
	
	game = {
		score = 0,
		field = false,
		level = 1,
		delay = 1,
		fastdelay = 0.1,
		timeout = 0,
		matchscore = 10,
		figure = {
			pos = {5, 0},
			color = 'r',
			prototype = 1,
			direction = 1,
		},
		levels = {
			{ delay = 0.9, score = 10, nextscore = 100 },
			{ delay = 0.8, score = 15, nextscore = 250 },
			{ delay = 0.75, score = 20, nextscore = 700 },
			{ delay = 0.7, score = 30, nextscore = 1500 },
			{ delay = 0.6, score = 50, nextscore = 2500 },
			{ delay = 0.5, score = 100, nextscore = 5000 },
			{ delay = 0.4, score = 250, nextscore = 10000 },
			{ delay = 0.3, score = 350, nextscore = 15000 },
			{ delay = 0.2, score = 500, nextscore = 25000 },
			{ delay = 0.1, score = 1000, nextscore = math.huge },
		},
		w = 10,
		h = 20,
		figcolors = {'r','g','b','p','c','y'},
		colors = {
			[' '] = luabox.rgbf( 0, 0, 0 ),
			['r'] = luabox.rgbf( 1, 0, 0 ),
			['g'] = luabox.rgbf( 0, 1, 0 ),
			['b'] = luabox.rgbf( 0, 0, 1 ),
			['y'] = luabox.rgbf( 1, 1, 0 ),
			['p'] = luabox.rgbf( 1, 0, 1 ),
			['c'] = luabox.rgbf( 0, 1, 1 ),
		},
		figures = {
			{ {{ 1,-1},{ 0,-1},{ 0, 0},{ 0, 1}}, {{ 1, 1},{ 1, 0},{ 0, 0},{-1, 0}}, {{-1, 1},{ 0, 1},{ 0, 0},{ 0,-1}}, {{-1,-1},{-1, 0},{ 0, 0},{ 1, 0}} },
			{ {{-1,-1},{ 0,-1},{ 0, 0},{ 0, 1}}, {{ 1,-1},{ 1, 0},{ 0, 0},{-1, 0}}, {{ 1, 1},{ 0, 1},{ 0, 0},{ 0,-1}}, {{-1, 1},{-1, 0},{ 0, 0},{ 1, 0}} },
			{ {{ 0, 0},{ 0, 1},{ 1, 0},{ 1, 1}} },
			{ {{ 0,-1},{ 0, 0},{ 0, 1},{ 0, 2}}, {{-1, 0},{ 0, 0},{ 1, 0},{ 2, 0}}},
			{ {{-1, 0},{ 0, 0},{ 1, 0},{ 0,-1}}, {{ 0,-1},{ 0, 0},{ 0, 1},{ 1, 0}}, {{ 1, 0},{ 0, 0},{-1, 0},{ 0, 1}}, {{ 0, 1},{ 0, 0},{ 0,-1},{-1, 0}} },
			{ {{-1, 1},{ 0, 1},{ 0, 0},{ 1, 0}}, {{ 0,-1},{ 0, 0},{ 1, 0},{ 1, 1}} },
			{ {{-1, 0},{ 0, 0},{ 0, 1},{ 1, 1}}, {{ 0, 1},{ 0, 0},{ 1, 0},{ 1,-1}} },
		},
		layout = {
			field = {1,3},
			score = {1,1},
			level = {1,2},
		},
		
		render = function( self )
			local SCORE_POS = self.layout.score
			
			luabox.print( 'Score', SCORE_POS[1], SCORE_POS[2], WHITE + luabox.BOLD )
			luabox.print( self.score, SCORE_POS[1] + 7, SCORE_POS[2], WHITE )
		
			local LEVEL_POS = self.layout.level
		
			luabox.print( 'Level', LEVEL_POS[1], LEVEL_POS[2], WHITE + luabox.BOLD )
			luabox.print( self.level, LEVEL_POS[1] + 7, LEVEL_POS[2], WHITE )
		
			local FIELD_POS = self.layout.field
			
			for x = 1, self.w do
				for y = 1, self.h do
					local c = self.field[x][y]
					luabox.print( ' ', FIELD_POS[1] + x, FIELD_POS[2] + y, WHITE, self.colors[c] )
				end
			end
			
			local pos0 = self.figure.pos
			local c = self.colors[self.figure.color]
			local f = self.figure
			local p = self.figures[f.prototype]
			for _, pos in ipairs( p[f.direction] ) do
				luabox.print( ' ', FIELD_POS[1] + pos[1] + pos0[1], FIELD_POS[2] + pos[2] + pos0[2], WHITE, c )
			end
		end,
		
		isfree = function( self, x, y )
			if x > self.w or y > self.h or x < 1 then
				return false
			elseif y < 1 then
				return true
			elseif self.field[x][y] == ' ' then
				return true
			else
				return false
			end
		end,
		
		intersect = function( self, x, y, points )
			for _, pos in pairs( points ) do
				if not self:isfree( pos[1] + x, pos[2] + y ) then
					return true
				end
			end
			return false
		end,
		
		moveleft = function( self )
			local f = self.figure
			local p = self.figures[f.prototype]
			if not self:intersect( f.pos[1] - 1, f.pos[2], p[f.direction] ) then
				f.pos[1] = f.pos[1] - 1
			end
		end,
		
		moveright = function( self )
			local f = self.figure
			local p = self.figures[f.prototype]
			if not self:intersect( f.pos[1] + 1, f.pos[2], p[f.direction] ) then
				f.pos[1] = f.pos[1] + 1
			end
		end,
		
		rotatecw = function( self )
			local f = self.figure
			local p = self.figures[f.prototype]
			local nextdir = f.direction % #p + 1
			if not self:intersect( f.pos[1], f.pos[2], p[nextdir] ) then
				f.direction = nextdir
			end
		end,
		
		rotateccw = function( self )
			local f = self.figure
			local p = self.figures[f.prototype]
			local nextdir = (f.direction-2) % #p + 1
			if not self:intersect( f.pos[1], f.pos[2], p[nextdir] ) then
				f.direction = nextdir
			end
		end,
		
		update = function( self )
			if not self.field then
				self:newfield()
			end
			
			if not self.figure then
				self:newfigure()
			end
			
			if os.clock() >= self.timeout then
				self.timeout = os.clock() + self.delay
				self:update2()
			end
		end,

		update2 = function( self )
			local f = self.figure
			local p = self.figures[f.prototype]
			self.delay = self.levels[self.level].delay
			if self:intersect( f.pos[1], f.pos[2]+1, p[f.direction] ) then
				local c = self.figure.color
				local pos0 = self.figure.pos
				for _, pos in ipairs( p[f.direction] ) do
					local x, y = pos[1] + pos0[1], pos[2] + pos0[2]
					self.field[x][y] = c
				
					if y < 1 then
						state = 'gameover'
						return
					end
				end
				local matches = self:findmatches()
				self:removematches( matches )
				self.score = self.score + #matches * self.matchscore
				self:promote()
				self:newfigure()
			else
				f.pos[2] = f.pos[2] + 1
			end
		end,
		
		promote = function( self )
			if self.score >= self.levels[self.level].nextscore then
				self.level = self.level + 1
			end
		end,
		
		findmatches = function( self )
			local matches = {}
			for y = self.h, 1, -1 do
				local match = true
				for x = 1, self.w do
					if self.field[x][y] == ' ' then
						match = false
						break
					end
				end
				if match then
					matches[#matches+1] = y
				end
			end
			
			return matches
		end,
		
		removematches = function( self, matches )
			for dy, y0 in ipairs( matches ) do
				for y = y0+dy-1, 1, -1 do
					for x = 1, self.w do
						self.field[x][y+1] = self.field[x][y]
						self.field[x][y] = ' '
					end
				end
			end
		end,
		
		newfield = function( self )
			self.field = {}
			for x = 1, self.w do
				self.field[x] = {}
				for y = 1, self.h do
					self.field[x][y] = ' '
				end
			end
		end,
		
		newfigure = function( self )
			local p = math.random( #self.figures )


			self.figure = {
				pos = {5, 0},
				color = self.figcolors[math.random(#self.figcolors)],
				prototype = p,
				direction = math.random( #self.figures[p] ),
			}
		end,

		onkey = function( self, ch, key, mode )
			if key == luabox.LEFT then
				self:moveleft()
			elseif key == luabox.RIGHT then
				self:moveright()
			elseif key == luabox.UP then
				self:rotatecw()
			elseif key == luabox.DOWN then
				self.delay = self.fastdelay
			elseif key == luabox.ESC then
				state = 'menu'
			end
		end,
	},
	
	gameover = {
		render = function( self )
			luabox.print( 'A looser are you lol', 1, 2, WHITE )
			luabox.print( 'Score', 1, 5, WHITE + luabox.BOLD )
			luabox.print( states.game.score, 1 + 7, 5, WHITE )
		end,
		
		update = function( self )
			states.menu.ingame = false
		end,
	
		onkey = function( self, ch, key, mode )
			state = 'menu'
		end,
	}
}

luabox.setcallback( luabox.EVENT_KEY, function( ch, key, mode ) 
	states[state]:onkey( ch, key, mode ) 
end )


while state ~= 'exit' do
	states[state]:update()
	
	luabox.clear()
	states[state]:render()
	luabox.present()
	
	luabox.peek( 1/60 )
end

luabox.shutdown()
