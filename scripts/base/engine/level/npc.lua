local npc = {}

npc.fields = function()
	return {
		id = 0,
		
		x = 0,
		y = 0,
		width = 32,
		height = 32,
		speedX = 0,
		speedY = 0,
		
		sceneCoords = true,
		priority = RENDER_PRIORITY.NPC,
		camera = 0,
		
		spawnDirection = 0,
		direction = 0,

		dontMove = false,
		friendly = false,
		
		spawnAi1 = 0,
		spawnAi2 = 0,
		ai1 = 0,
		ai2 = 0,
		ai3 = 0,
		ai4 = 0,
		ai5 = 0,
		
		section = 0,
		
		data = {},
	}
end

function npc:render(arg)
	local v = self or {}
	local arg = arg or {}
	
	arg.id = arg.id or v.id
	arg.x = arg.x or v.x
	arg.y = arg.y or v.y
	arg.sceneCoords = arg.sceneCoords or v.sceneCoords
	arg.priority = arg.priority or v.priority or RENDER_PRIORITY.NPC
	arg.camera = arg.camera or v.camera
	
	if not Game.isColliding(arg.x, arg.y, 32, 32) then return end
	
	Graphics.draw{
		image = Graphics.sprites.npc[arg.id].img,
		x = arg.x,
		y = arg.y,
		isSceneCoordinates = arg.sceneCoords,
		camera = arg.camera,
	}
end

function npc.spawn(id, x, y, section)
	local v = npc.new{
		id = id,
		
		x = x,
		y = y,
		
		section = section,
	}
	v.idx = #npc + 1
	
	npc[#npc + 1] = v
	return v
end

function npc.internalDraw()
	for k,v in ipairs(npc) do
		v:render()
	end
end

_G.NPC = Objectify(npc)