local plr = {}
local config = require 'level/player_config'

CHARACTERS = {
	'mario',
	'luigi',
}

plr.fields = function()
	return {
		character = 1,
		powerup = 1,
		
		x = 0,
		y = 0,
		width = 32,
		height = 32,
		speedX = 0,
		speedY = 0,
		direction = 1,
		
		frame = 1,
		
		section = 0,
	}
end

local function pfrX(plrFrame)
	local A
	A = plrFrame
	A = A - 50
	
	while(A > 100) do
		A = A - 100
	end
	
	if(A > 90) then
		A = 9
	elseif(A > 90) then
		A = 9
	elseif(A > 80) then
		A = 8
	elseif(A > 70) then
		A = 7
	elseif(A > 60) then
		A = 6
	elseif(A > 50) then
		A = 5
	elseif(A > 40) then
		A = 4
	elseif(A > 30) then
		A = 3
	elseif(A > 20) then
		A = 2
	elseif(A > 10) then
		A = 1
	else
		A = 0
	end
	
	return A * 100
end

local function pfrY(plrFrame)
	local A
	A = plrFrame
	A = A - 50
	
	while(A > 100) do
		A = A - 100
	end
	
	A = A - 1
	while(A > 9) do
		A = A - 10
	end
	
	return A * 100
end

function plr:render(arg)
	local v = self or {}
	local arg = arg or {}
	
	arg.powerup = arg.powerup or v.powerup
	arg.character = arg.character or v.character
	arg.x = arg.x or v.x
	arg.y = arg.y or v.y
	arg.direction = arg.direction or v.direction
	arg.priority = arg.priority or RENDER_PRIORITY.PLAYER
	arg.opacity = arg.opacity or 1
	arg.sceneCoords = arg.sceneCoords or true
	arg.frame = arg.frame or v.frame
	
	local fx = config[CHARACTERS[arg.character]]['FrameX'][(arg.powerup * 100) + (arg.frame * arg.direction)]
	local fy = config[CHARACTERS[arg.character]]['FrameY'][(arg.powerup * 100) + (arg.frame * arg.direction)]
	
	Graphics.draw{
		image = Graphics.sprites[CHARACTERS[arg.character]][arg.powerup].img,
		x = arg.x + fx,
		y = arg.y + fy,
		isSceneCoordinates = arg.sceneCoords,
		sourceX = pfrX(100 + v.frame * v.direction),
		sourceY = pfrY(100 + v.frame * v.direction),
		sourceWidth = 100,
		sourceHeight = 100,
	}
end

function plr.spawn(char, x, y)
	local v = plr.new{
		character = char,
		
		x = x,
		y = y,
	}
	
	plr[#plr + 1] = v
	return v
end

function plr.internalDraw()
	for k,v in ipairs(plr) do
		v:render()
	end
end

_G.Player = Objectify(plr)