local npc = {}

local function callSpecialEvent(v,eventName)
	npcManager.callSpecialEvent(v,eventName)
end

local scripts = {}

local function requireScript(k) 
	if not scripts[k] then
		NPC_ID = k
		
		local script = require('npc-' .. k, true)
		
		if not script then
			script = require('npc/npc-' .. k, true)
		end
		
		scripts[k] = true
		NPC_ID = nil
		
		return
	end
end

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
	disablerender = false,
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
		priority = RENDER_PRIORITY.npc,
		camera = 0,
		
		animationFrame = 0,
		animationTimer = 0,
		disableRender = false,
		
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
	local config = npc.config[arg.id]

	arg.x = arg.x or v.x
	arg.y = arg.y or v.y
	arg.sceneCoords = arg.sceneCoords or v.sceneCoords
	arg.priority = arg.priority or (config.priority) or (config.foreground and -15) or RENDER_PRIORITY.npc
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
	
	local config = npc.config[id]
	v.width = config.width
	v.height = config.height
	
	requireScript(id)
	
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
		
		callSpecialEvent(v,"onAnimateNPC")
	end
	
	function npc.update()
		for k = 1, #npc do
			if npc[k] then
				frame(npc[k])
				
				callSpecialEvent(v,"onActiveNPC")
			end
		end
	end
end

function npc.internalDraw()
	for k,v in ipairs(npc) do
		if not npc.config[v.id].disablerender and not v.disableRender then
			v:render()
		end
	end
end


do
	function npc.count()
		return #npc
	end

	function npc.get(idFilter)
		local ret = {}

		local idFilterType = type(idFilter)
		local idMap
		if idFilter == "table" then
			idMap = {}

			for _,id in ipairs(idFilter) do
				idMap[id] = true
			end
		end


		for _,v in ipairs(npc) do
			if idFilter == nil or idFilter == -1 or idFilter == v.id or (idMap ~= nil and idMap[v.id]) then
				ret[#ret + 1] = v
			end
		end

		return ret
	end

	function npc.getIntersecting(x1,y1,x2,y2)
		local ret = {}

		for _,v in ipairs(npc) do
			if v.x <= x2 and v.y <= y2 and v.x+v.width >= x1 and v.y+v.height >= y1 then
				ret[#ret + 1] = v
			end
		end

		return ret
	end


	-- Based on the lunalua implementation

	local function iterate(args,i)
		while (i <= args[1]) do
			local v = npc[i]

			local idFilter = args[2]
			local idMap = args[3]

			if idFilter == nil or idFilter == -1 or idFilter == v.id or (idMap ~= nil and idMap[v.id]) then
				return i+1,v
			end

			i = i + 1
		end
	end

	function npc.iterate(idFilter)
		local args = {#npc,idFilter}

		if type(idFilter) == "table" then
			args[3] = {}

			for _,id in ipairs(idFilter) do
				args[3][id] = true
			end
		end

		return iterate, args, 1
	end

	local function iterateIntersecting(args,i)
		while (i <= args[1]) do
			local v = npc[i]

			if v.x <= args[4] and v.y <= args[5] and v.x+v.width >= args[2] and v.y+v.height >= args[3] then
				return i+1,v
			end

			i = i + 1
		end
	end

	function npc.iterateIntersecting(x1,y1,x2,y2)
		local args = {#npc,x1,y1,x2,y2}

		return iterateIntersecting, args, 1
	end
end

_G.NPC = Objectify(npc)