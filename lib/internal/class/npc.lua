local NPC = {}
NPC.__type = "NPC"

do
	local luafiles = {}

	function NPC.loadLua(id)
		local name = 'npc/npc-' .. id
		
		if not luafiles[id] and File.exists(name .. '.lua', File.requirePaths) then
			luafiles[id] = true
			
			--load lua file
			NPC_ID = id
			
			require(name)
			
			NPC_ID = nil
		end
	end
end

do
	local config = require 'configuration'
	NPC.config = config('npc', {
		width = 32,
		height = 32,
		gfxwidth = 32,
		gfxheight = 32,
		
		frames = 0,
		framespeed = 8,
		
		jumphurt = true,
	})
end

local function returnToSpawnPosition(v)
	-- callSpecialEvent(v,"onDeinitNPC")

	if v.spawnId <= 0 then
		v:kill(HARM_TYPE_VANISH)
		return
	end

	v.x = v.spawnX
	v.y = v.spawnY
	v.width = v.spawnWidth
	v.height = v.spawnHeight
	v.speedX = v.spawnSpeedX
	v.speedY = v.spawnSpeedY
	v.direction = v.spawnDirection
	v.id = v.spawnId
end

function NPC.setSettings(config)
	local id = config.id	
	local default = NPC.config[id]
	
	local nt = table.copy(config)
	nt.id = nil
	
	NPC.config[id] = table.deepmerge(default, nt)
end

function NPC.spawn(id, x, y, sect_num, respawn, centred)
	local v = {}

	v.isValid = true
	v.idx = #NPC + 1
	v.id = id
	
	local cfg = NPC.config[v.id]
	
	v.x = x
	v.y = y
	v.width = cfg.width
	v.height = cfg.height
	v.speedX = 0
	v.speedY = 0
	v.direction = 1
	
	v.section = sect_num or 1
	v.respawn = respawn or false
	
	v.spawnId = v.id
	v.spawnX = v.x
	v.spawnY = v.y
	
	v.frame = 0
	v.frameTimer = 0
	
	v.data = {settings = {}}
	
	v.params = {
		opacity = 1,
		xOffset = 0,
		yOffset = 0,
	}
	
	NPC.loadLua(v.id)
	setmetatable(v, {__index = NPC})
	
	do
		local event = {cancelled = false}
	
		libManager.callEvent('onNPCSpawn', event, v)
	
		if not event.cancelled then
			NPC[#NPC + 1] = v
		end
	end
	
	return v
end

function NPC:render(args)
	local v = self
	local p = v.params
	local args = args or {}
	
	local id = args.id or v.id
	local cfg = NPC.config[id]
	
	local texture = args.texture or Graphics.sprites.npc[id]
	
	Graphics.draw{
		texture = texture,
		
		x = (args.x or v.x) + p.xOffset,
		y = (args.y or v.y) + p.yOffset,
		
		sourceWidth = cfg.gfxwidth,
		sourceHeight = cfg.gfxheight,
		sourceY = cfg.gfxheight * v.frame,
		
		opacity = args.opacity or cfg.opacity or p.opacity,

		scene = (args.scene == nil and true) or args.scene,
		targetCamera = args.targetCamera or 0,
	}
	
	-- Graphics.rect{
		-- x = v.x,
		-- y = v.y,
		-- width = v.width,
		-- height = v.height,
		
		-- scene = true,
	-- }
end

local min = math.min

local function animation(v, dt)
	local config = NPC.config[v.id]

	if(config.frames > 0) then
		v.frameTimer = v.frameTimer + dt
		if(config.framestyle == 2 and (v.projectile ~= 0 or v.holdingPlayer > 0)) then
			v.frameTimer = v.frameTimer + dt
		end
		if(v.frameTimer >= config.framespeed) then
			if(config.framestyle == 0) then
				v.frame = v.frame + 1 * v.direction
			else
				v.frame = v.frame + 1
			end
			v.frameTimer = 0
		end
		if(config.framestyle == 0) then
			if(v.frame >= config.frames) then
				v.frame = 0
			end
			if(v.frame < 0) then
				v.frame = config.frames - 1
			end
		elseif(config.framestyle == 1) then
			if(v.direction == -1) then
				if(v.frame >= config.frames) then
					v.frame = 0
				end
				if(v.frame < 0) then
					v.frame = config.frames
				end
			else
				if(v.frame >= config.frames * 2) then
					v.frame = config.frames
				end
				if(v.frame < config.frames) then
					v.frame = config.frames
				end
			end
		elseif(config.framestyle == 2) then
			if(v.holdingPlayer == 0 and v.projectile == 0) then
				if(v.direction == -1) then
					if(v.frame >= config.frames) then
						v.frame = 0
					end
					if(v.frame < 0) then
						v.frame = config.frames - 1
					end
				else
					if(v.frame >= config.frames * 2) then
						v.frame = config.frames
					end
					if(v.frame < config.frames) then
						v.frame = config.frames * 2 - 1
					end
				end
			else
				if(v.direction == -1) then
					if(v.frame >= config.frames * 3) then
						v.frame = config.frames * 2
					end
					if(v.frame < config.frames * 2) then
						v.frame = config.frames * 3 - 1
					end
				else
					if(v.frame >= config.frames * 4) then
						v.frame = config.frames * 3
					end
					if(v.frame < config.frames * 3) then
						v.frame = config.frames * 4 - 1
					end
				end
			end
		end
	end
end

function NPC:onPhysics(dt)
	local v = self
	local cfg = NPC.config[v.id]
	
	if not cfg.nogravity then
		v.speedY = min(v.speedY + (v.gravity or cfg.gravity or Defines.npc_grav), v.maxSpeedY or cfg.maxSpeedY or Defines.gravity)
	end
	
	v.speedX = 1 * v.direction
	
	Collision.update(v)
end

function NPC.onDrawInternal()
	for k,v in ipairs(NPC) do
		v:render()
	end
end

function NPC.onTickInternal()
	local dt = deltaTime
	
	for k,v in ipairs(NPC) do
		animation(v, dt)
		v:onPhysics(dt)
	end
end

function NPC.onInit()
	registerFunction(NPC, 'onTickInternal')
	registerFunction(NPC, 'onDrawInternal')
end

registerNPCFunction = libManager.defineRegistering(NPC, 'id', 'NPC')
libManager.registerNPCEvent = registerNPCFunction

setmetatable(NPC, {__call = function(self, key)
	return NPC[key]
end})

return NPC