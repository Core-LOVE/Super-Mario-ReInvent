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


Game.isMenu = false
Game.logo = 4
do
	local Options = require 'game/options'

	local menu = Options.new()
	menu.maxDelay = 10
	
	menu:add{name = '1 Player Game', onPress = function()
		Level.unload()
	end}
	menu:add{name = '2 Player Game'}
	menu:add{name = 'Battle Game'}
	menu:add{name = 'Modifications', disabled = true}
	
	menu:add{name = 'Options', onBack = function()
		menu.parent = nil
	end,
	
	onPress = function()
		menu = Options.new(menu)
		menu.maxDelay = 10
		
		menu:add{name = 'Player 1 Controls', onPress = function()
			menu = Options.new(menu)
			menu.maxDelay = 10
			
			for k,v in pairs(Keys.player[1]) do
				local name = string.format('%s.........%s', k, v)
				print(name)
				local key = menu:add{name = k .. '....' .. v}
				
				key.onPress = function()
					menu.locked = (not menu.locked)
					
					if menu.locked then
						key.name = k .. '....'
						
						Keys.pressed.key = nil
						Keys.pressed.delay = menu.maxDelay
						
						menu.onUpdate = function()
							if Keys.pressed.key then
								key.name = k .. '....' .. Keys.pressed.key
								Keys.player[1][k] = Keys.pressed.key
								
								Sound.play(14)
								menu.locked = false
								menu.onUpdate = nil
								menu.delay = menu.maxDelay
								
								return
							end
						end
					end
				end
			end
			menu.type = 'controls'
		end}
		
		menu:add{name = 'Player 2 Controls'}
		menu:add{name = 'Fullscreen Mode'}
		menu:add{name = 'View Credits'}
		menu:add{name = 'Change Logo', onPress = function()
			Game.logo = (Game.logo + 1) % 5
		end}
	end}

	menu:add{name = 'Exit'}
	
	Game.drawMenu = function()
		if not Game.isMenu then return end
		
		local logo_img = Graphics.sprites.ui['Logo' .. Game.logo + 1].img
		local curtain_img = Graphics.sprites.ui['MenuGFX1'].img
		curtain_img:setWrap('repeat', 'clampzero')
		
		local x = Game.width - logo_img:getWidth()
		
		Graphics.draw{
			image = curtain_img,
			x = 0,
			
			sourceWidth = Game.width,
			sourceHeight = curtain_img:getHeight(),
			
			priority = RENDER_PRIORITY.HUD,
		}
		
		Graphics.draw{
			image = logo_img,
			x = x / 2, 
			y = curtain_img:getHeight() + 16 + logo_img:getHeight() / 8,
			
			priority = RENDER_PRIORITY.HUD,
		}
		
		-- options
		
		local y = 340
		if menu.type == 'controls' then
			y = 240
		end
		
		menu:assign(Keys.isDown('up'), Keys.isDown('down'), Keys.isDown('jump'), Keys.isDown('run'))
		menu:update()
		menu:draw(Game.width / 2 - 100, y)
	end
end