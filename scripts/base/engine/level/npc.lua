local npc = {}

npc.config = Configuration.create('npc', {
	width = 32,
	height = 32,
	
	gfxwidth = 32,
	gfxheight = 32,
	gfxoffsetx = 0,
	gfxoffsety = 0,
	
	frames = 0,
	framespeed = 8,
	framestyle = 0,
	
	priority = nil,
	foreground = false,
	
	speed = 1,
})

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
		
		animationFrame = 0,
		animationTimer = 0,
		
		spawnDirection = 0,
		direction = 0,

		dontMove = false,
		friendly = false,
		
		holdingPlayer = 0,
		projectile = 0,
		
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
	local config = NPC.config[arg.id]

	arg.x = arg.x or v.x
	arg.y = arg.y or v.y
	arg.sceneCoords = arg.sceneCoords or v.sceneCoords
	arg.priority = arg.priority or (config.priority) or (config.foreground and -15) or RENDER_PRIORITY.NPC
	arg.camera = arg.camera or v.camera
	
	if not Game.isColliding(arg.x, arg.y, v.width, v.height) then return end

	local x = arg.x + (v.width * 0.5) - (config.gfxwidth * 0.5) + config.gfxoffsetx
	local y = arg.y + v.height - config.gfxheight + config.gfxoffsety
		
	Graphics.draw{
		image = Graphics.sprites.npc[arg.id].img,
		x = x,
		y = y,
		
		sourceY = v.animationFrame * config.gfxheight,
		sourceWidth = config.gfxwidth,
		sourceHeight = config.gfxheight,

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
	
	local config = NPC.config[id]
	v.width = config.width
	v.height = config.height
	
	npc[#npc + 1] = v
	return v
end

do
	local frame = function(v)
		local config = npc.config[v.id]
		
		if(config.frames > 0) then
			v.animationTimer = v.animationTimer + 1
			if(config.framestyle == 2 and (v.projectile ~= 0 or v.holdingPlayer > 0)) then
				v.animationTimer = v.animationTimer + 1
			end
			if(v.animationTimer >= config.framespeed) then
				if(config.framestyle == 0) then
					v.animationFrame = v.animationFrame + 1 * v.direction
				else
					v.animationFrame = v.animationFrame + 1
				end
				v.animationTimer = 0
			end
			if(config.framestyle == 0) then
				if(v.animationFrame >= config.frames) then
					v.animationFrame = 0
				end
				if(v.animationFrame < 0) then
					v.animationFrame = config.frames - 1
				end
			elseif(config.framestyle == 1) then
				if(v.direction == -1) then
					if(v.animationFrame >= config.frames) then
						v.animationFrame = 0
					end
					if(v.animationFrame < 0) then
						v.animationFrame = config.frames
					end
				else
					if(v.animationFrame >= config.frames * 2) then
						v.animationFrame = config.frames
					end
					if(v.animationFrame < config.frames) then
						v.animationFrame = config.frames
					end
				end
			elseif(config.framestyle == 2) then
				if(v.holdingPlayer == 0 and v.projectile == 0) then
					if(v.direction == -1) then
						if(v.animationFrame >= config.frames) then
							v.animationFrame = 0
						end
						if(v.animationFrame < 0) then
							v.animationFrame = config.frames - 1
						end
					else
						if(v.animationFrame >= config.frames * 2) then
							v.animationFrame = config.frames
						end
						if(v.animationFrame < config.frames) then
							v.animationFrame = config.frames * 2 - 1
						end
					end
				else
					if(v.direction == -1) then
						if(v.animationFrame >= config.frames * 3) then
							v.animationFrame = config.frames * 2
						end
						if(v.animationFrame < config.frames * 2) then
							v.animationFrame = config.frames * 3 - 1
						end
					else
						if(v.animationFrame >= config.frames * 4) then
							v.animationFrame = config.frames * 3
						end
						if(v.animationFrame < config.frames * 3) then
							v.animationFrame = config.frames * 4 - 1
						end
					end
				end
			end
		end
	end
	
	function npc.update()
		for k = 1, #npc do
			if npc[k] then
				frame(npc[k])
			end
		end
	end
end

function npc.internalDraw()
	for k,v in ipairs(npc) do
		v:render()
	end
end

_G.NPC = Objectify(npc)