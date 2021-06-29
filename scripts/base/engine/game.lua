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
Game.widescreen = false
Game.speedrun = {time = 0, enabled = false}

Game.isPaused = false


Game.isMenu = false
Game.drawMenu = function()
	if not Game.isMenu then return end
	
end