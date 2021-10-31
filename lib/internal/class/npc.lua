local NPC = {}

do
	local luafiles = {}

	function NPC.loadLua(id)
		local name = 'npc/npc-' .. id
		
		if not luafiles[id] and File.exists(name .. '.lua', File.requirePaths) then
			luafiles[id] = true
			
			--load lua file
			local g = table.copy(_G)
			g.NPC_ID = id
			
			setfenv(1, g)
			require(name)
			setfenv(1, _G)
		end
	end
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

function NPC.spawn(id, x, y, sect_num, respawn, centred)
	local v = {}
	
	v.isValid = true
	v.idx = #NPC + 1
	v.id = id
	v.x = x
	v.y = y
	v.section = sect_num or 1
	v.respawn = respawn or false
	
	v.spawnId = v.id
	v.spawnX = v.x
	v.spawnY = v.y
	
	v.frame = 0
	v.frameTimer = 0
	
	v.data = {}
	
	v.params = {
		opacity = 1,
		xOffset = 0,
		yOffset = 0,
	}
	
	NPC.loadLua(v.id)
	
	setmetatable(v, {__index = NPC})
	NPC[#NPC + 1] = v
	return v
end

function NPC:render(args)
	local v = self
	local p = v.params
	local args = args or {}
	
	Graphics.draw{
		texture = Graphics.sprites.npc[v.id],
		
		x = (v.x or args.x) + p.xOffset,
		y = (v.y or args.y) + p.yOffset,
		
		opacity = args.opacity or p.opacity,

		scene = (args.scene == nil and true) or args.scene,
		targetCamera = args.targetCamera or 0,
	}
end

function NPC:onPhysics()
	local v = self
end

function NPC.onDraw()
	for k,v in ipairs(NPC) do
		v:render()
	end
end

function NPC.onTick()
	for k,v in ipairs(NPC) do
		v:onPhysics()
	end
end

function NPC.onInit()
	registerFunction(NPC, 'onTick')
	registerFunction(NPC, 'onDraw')
end

registerNPCFunction = libManager.defineRegistering(NPC, 'id', 'NPC')
libManager.registerNPCEvent = registerNPCFunction

setmetatable(NPC, {__call = function(self, key)
	return NPC[key]
end})

return NPC