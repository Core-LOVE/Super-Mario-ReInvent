local NPC = {}
NPC.__type = "NPC"

local configuration = require 'config'
NPC.config = configuration.new('npc', {
	width = 32,
	height = 32,
	gfxwidth = 32,
	gfxheight = 32,
	gfxoffsetx = 0,
	gfxoffsety = 0,
	
	frames = 0,
	framespeed = 8,
	
	speed = 1,

	turnaround = true,
	ignored = false,
	ignoring = false,
	
	damageMap = {},
	effectMap = {},
})

local script = require 'script'

function NPC.spawn(id, x, y)
	local v = {}
	script.load('npc', id, 'NPC_ID')
	
	v.idx = (#NPC + 1)
	v.isValid = true
	
	v.data = {}
	v.params = {}
	
	v.id = id
	v.x = x
	v.y = y
	v.width = 32
	v.height = 32
	v.speedX = 0
	v.speedY = 0
	v.dontMove = false
	v.direction = 1
	
	v.frame = 0
	v.frameTimer = 0
	
	v.despawnTimer = 180

	v.collidingSolids = {}
	v.collidesBlockBottom = false
	v.collidesBlockTop = false
	v.collidesBlockLeft = false
	v.collidesBlockRight = false
	v.collidingSlope = nil
	
	v.isHidden = false
	
	v.projectile = 0
	v.holdingPlayer = 0
	
	v.health = 0
	v.immuneTimer = 0
	v.killed = 0
	
	local event = {cancelled = false}
	libManager.callEvent('onNPCSpawn', event, v)
	
	if event.cancelled then
		return
	end
	
	setmetatable(v, {__index = NPC})
	NPC[#NPC + 1] = v
	
	libManager.callEvent('onPostNPCSpawn', v)
	libManager.callEvent('onNPCInit', v, v.data)			
	
	return v
end

function NPC.setHarmTypes(id, death, effect)
	local death = death or {}
	
	for k,v in ipairs(death) do
		if type(v) == 'boolean' then
			if v then
				death[k] = 1
			else
				death[k] = nil
			end
		end
	end
	
	NPC.config[id].damageMap = death or {}
	NPC.config[id].effectMap = effect or {}
end

function NPC.setSettings(config)
	for k,v in pairs(config) do
		if k ~= 'id' then
			NPC.config[config.id][k] = v
		end
	end
end

do
	local function iterate(args,i)
		while (i <= args[1]) do
			local v = NPC[i]

			local idFilter = args[2]
			local idMap = args[3]

			if idFilter == nil or idFilter == -1 or idFilter == v.id or (idMap ~= nil and idMap[v.id]) then
				return i+1,v
			end

			i = i + 1
		end
	end

	function NPC.iterate(idFilter)
		local args = {#NPC,idFilter}

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
			local v = NPC[i]

			if v.x < args[4] and v.y < args[5] and v.x+v.width > args[2] and v.y+v.height > args[3] then
				return i+1,v
			end

			i = i + 1
		end
	end

	function NPC.iterateIntersecting(x1,y1,x2,y2)
		local args = {#NPC,x1,y1,x2,y2}

		return iterateIntersecting, args, 1
	end
end

-- NPC harming / killing
local updateRemovalQueue

do
	HARM_TYPE_JUMP = 1
	HARM_TYPE_FROMBELOW = 2
	HARM_TYPE_NPC = 3
	HARM_TYPE_PROJECTILE_USED = 4
	HARM_TYPE_LAVA = 5
	HARM_TYPE_HELD = 6
	HARM_TYPE_TAIL = 7
	HARM_TYPE_SPINJUMP = 8
	HARM_TYPE_VANISH = 9
	HARM_TYPE_SWORD = 10

	HARM_TYPE_OFFSCREEN = HARM_TYPE_VANISH

	-- function NPC:forceHarm(harmType, damageMultiplier, culprit)
		-- harmType = harmType or HARM_TYPE_NPC
		-- damageMultiplier = damageMultiplier or 1
		
		-- local config = NPC.config[self.id]
		
		-- local eventObj = {cancelled = false}

		-- libManager.callEvent("onNPCHarm", eventObj, self, harmType, culprit, damageMultiplier)
		-- if eventObj.cancelled then
			-- return
		-- end
		-- libManager.callEvent("onPostNPCHarm", self, harmType, culprit, damageMultiplier)


		-- local damage = config.damageMap[harmType] or 1

		-- self.health = self.health - damage

		-- if self.health <= 0 then
			-- self:kill(harmType)
		-- end
	-- end
	
	function NPC:harm(harmType, damageMultiplier, culprit)
		harmType = harmType or HARM_TYPE_NPC
		damageMultiplier = damageMultiplier or 1


		local config = NPC.config[self.id]

		if config.damageMap[harmType] == nil or damageMultiplier == 0 then
			return
		end


		-- Call the onNPCHarm event and see if it's been cancelled
		local eventObj = {cancelled = false}

		libManager.callEvent("onNPCHarm", eventObj, self, harmType, culprit, damageMultiplier)
		if eventObj.cancelled then
			return
		end
		libManager.callEvent("onPostNPCHarm", self, harmType, culprit, damageMultiplier)


		local damage = config.damageMap[harmType]

		self.health = self.health - damage

		if self.health <= 0 then
			self:kill(harmType)
		end
	end


	local npcRemovalQueue = {}

	function NPC:kill(harmType)
		if self.killed == 0 then
			table.insert(npcRemovalQueue,self)
		end

		self.killed = harmType or HARM_TYPE_JUMP
	end


	local function npcKillInternal(self,queuePos)
		-- Call the onNPCKill event and see if it's been cancelled
		local eventObj = {cancelled = false}

		libManager.callEvent("onNPCKill", eventObj, self, self.killed)
		if eventObj.cancelled then
			return
		end
		libManager.callEvent("onPostNPCKill", self, self.killed)


		local config = NPC.config[self.id]

		local effect = config.effectMap[self.killed]

		if type(effect) == "number" then
			Effect.spawn(effect,self)
		end


		-- Manual table remove, to update idx fields
		local npcCount = #NPC

		for i = self.idx+1, npcCount do
			local npcHere = NPC[i]

			npcHere.idx = npcHere.idx - 1
			NPC[i-1] = npcHere
		end

		NPC[npcCount] = nil


		self.isValid = false
		self.idx = -1


		table.remove(npcRemovalQueue,queuePos)
	end

	updateRemovalQueue = function()
		for i = #npcRemovalQueue, 1, -1 do
			local npc = npcRemovalQueue[i]

			if npc.isValid then
				npcKillInternal(npcRemovalQueue[i],i)
			end
		end
	end
end

function NPC.onPhysics(v)
	local cfg = NPC.config[v.id]
	
	v.speedY = math.min(v.speedY + Defines.npc_grav, Defines.gravity)
	
	if cfg.originalSpeed then
		v.speedX = cfg.originalSpeed
	end
	
	if v.dontMove then
		v.speedX = 0
	end
	
	v.speedX = (v.speedX * cfg.speed) * v.direction

	Collision.update(v)
end

function NPC.onAnimation(v, dt)
	local cfg = NPC.config[v.id]
	
	local frames  = cfg.frames
	local framespeed = cfg.framespeed
	local framestyle = cfg.framestyle
	
	if(frames > 0) then
		v.frameTimer = v.frameTimer + dt
		if(framestyle == 2 and (v.projectile ~= 0 or v.holdingPlayer > 0)) then
			v.frameTimer = v.frameTimer + dt
		end
		if(v.frameTimer >= framespeed) then
			if(framestyle == 0) then
				v.frame = v.frame + 1 * v.direction
			else
				v.frame = v.frame + 1
			end
			v.frameTimer = 0
		end
		if(framestyle == 0) then
			if(v.frame >= frames) then
				v.frame = 0
			end
			if(v.frame < 0) then
				v.frame = frames - 1
			end
		elseif(framestyle == 1) then
			if(v.direction == -1) then
				if(v.frame >= frames) then
					v.frame = 0
				end
				if(v.frame < 0) then
					v.frame = frames
				end
			else
				if(v.frame >= frames * 2) then
					v.frame = frames
				end
				if(v.frame < frames) then
					v.frame = frames
				end
			end
		elseif(framestyle == 2) then
			if(v.holdingPlayer == 0 and v.projectile == 0) then
				if(v.direction == -1) then
					if(v.frame >= frames) then
						v.frame = 0
					end
					if(v.frame < 0) then
						v.frame = frames - 1
					end
				else
					if(v.frame >= frames * 2) then
						v.frame = frames
					end
					if(v.frame < frames) then
						v.frame = frames * 2 - 1
					end
				end
			else
				if(v.direction == -1) then
					if(v.frame >= frames * 3) then
						v.frame = frames * 2
					end
					if(v.frame < frames * 2) then
						v.frame = frames * 3 - 1
					end
				else
					if(v.frame >= frames * 4) then
						v.frame = frames * 3
					end
					if(v.frame < frames * 3) then
						v.frame = frames * 4 - 1
					end
				end
			end
		end
	end
end

function NPC.render(v, args)
	if v.isHidden then return end
	
	local c = (c or camera)
	
	if not isColliding(v, c) then return end
	
	local id = v.id
	local texture = Graphics.sprites.npc[id]
	
	if not texture then return end
	
	local p = v.params
	local args = args or {}
	local cfg = NPC.config[id]
	
	local priority = p.priority or (cfg.priority) or (cfg.foreground and RENDER_PRIORITY.FOREGROUND_NPC) or RENDER_PRIORITY.NPC
	
	local dy = (cfg.gfxheight - cfg.height)
	local dx = (cfg.gfxwidth - cfg.width) * 0.5
	
	Graphics.draw{
		texture = texture,
		
		x = ((args.x or v.x) + (p.xOffset or 0)) - dx,
		y = ((args.y or v.y) + (p.yOffset or 0)) - dy,
		
		sourceWidth = cfg.gfxwidth,
		sourceHeight = cfg.gfxheight,
		sourceY = cfg.gfxheight * v.frame,
		
		opacity = args.opacity or cfg.opacity or p.opacity or 1,

		priority = priority,
		scene = (args.scene == nil and true) or args.scene,
		targetCamera = args.targetCamera or 0,
	}
end

function NPC.onDrawInternal()
	for k = 1, #NPC do
		NPC[k]:render()
	end
end

function NPC.onTickInternal()
	updateRemovalQueue()

	for k = 1, #NPC do
		NPC[k]:onAnimation(Engine.speed)
		NPC[k]:onPhysics()
	end
end

function NPC.onInit()
	registerEvent(NPC, 'onDrawInternal')
	registerEvent(NPC, 'onTickInternal')
end

setmetatable(NPC, {__call = function(self, idx)
	return self[idx]
end})

libManager.registerNPCEvent = libManager.registerCustomEvent(NPC, 'NPC')
registerNPCEvent = libManager.registerNPCEvent

return NPC