Game = {}

Game.FPS = 65
Game.speed = Game.FPS / 60
Game.isColliding = function(x,y,width,height)
	for _,cam in ipairs(Camera) do
		if not cam.isHidden and x < cam.x+cam.width and x+width > cam.x and y < cam.y+cam.height and y+height > cam.y then
			return true
		end
	end

	return false
end

Game.score = 0
Game.coins = 0
Game.lives = 3

Game.width = 800
Game.height = 600
Game.widescreen = true
Game.speedrun = {time = 0, enabled = false}

Game.isPaused = false


Game.isMenu = true
Game.logo = 1
do
	local Options = require 'options'

	local menu = Options.new()
	menu:add{name = '1 Player Game'}
	menu:add{name = '2 Player Game'}
	menu:add{name = 'Battle Game'}
	menu:add{name = 'Modifications', disabled = true}
	
	menu:add{name = 'Options', onPress = function()
		menu = Options.new(menu)
		menu:add{name = 'Player 1 Controls'}
		menu:add{name = 'Player 2 Controls'}
		menu:add{name = 'Fullscreen Mode'}
		menu:add{name = 'View Credits'}
		menu:add{name = 'Change Logo'}
	end}

	menu:add{name = 'Exit'}
	
	menu.cursor = 4
	
	Game.drawMenu = function()
		if not Game.isMenu then return end
		
		local logo_img = Graphics.sprites.ui['Logo' .. Game.logo].img
		local curtain_img = Graphics.sprites.ui['MenuGFX1'].img
		curtain_img:setWrap('repeat', 'clampzero')
		
		local x = Game.width - logo_img:getWidth()
		
		Graphics.draw{
			image = curtain_img,
			x = 0,
			
			sourceWidth = Game.width,
			sourceHeight = curtain_img.height,
			
			priority = RENDER_PRIORITY.HUD,
		}
		
		Graphics.draw{
			image = logo_img,
			x = x / 2, 
			y = curtain_img:getHeight() + 16,
			
			priority = RENDER_PRIORITY.HUD,
		}
		
		Graphics.draw{
			image = Graphics.sprites.ui['MCursor0'].img,
			x = (Game.width / 2) - 124,
			y = 340 + 30 * menu.cursor
		}
		
		for k,v in ipairs(menu) do
			local o = 1
			if v.disabled then
				o = 0.75
			end
			
			Text.print(v.name, (Game.width / 2) - 100, 340 + 30 * (k - 1), 3, o)
		end
	end
end