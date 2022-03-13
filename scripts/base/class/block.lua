local Block = {}
Block.__type = "Block"

local BlockFrame = {}
local BlockFrameTimer = {}

local configuration = require 'config'

Block.config = configuration.new('block', {
	sizable = false,
	connecting = false,
	playerpassthrough = false,
	npcpassthrough = false,
	passthrough = false,
	floorslope = 0,
	ceilingslope = 0,
	width = 32,
	height = 32,
	semisolid = false,
	lava = false,
	bumpable = false,
	smashable = false,
	destroyeffect = 1,
	explodable = false,
	hammer = false,
	noicebrick = false,
	bounceside = false,
	diggable = false,
	frames = 0,
	framespeed = 8,
	foreground = false,
})

function Block.spawn(id, x, y)
	local v = {}
	
	v.idx = (#Block + 1)
	v.id = id
	
	local cfg = Block.config[v.id]
	BlockFrame[v.id] = BlockFrame[v.id] or 0
	BlockFrameTimer[v.id] = BlockFrameTimer[v.id] or 0
	
	v.x = x
	v.y = y
	v.width = cfg.width
	v.height = cfg.height
	v.speedX = 0
	v.speedY = 0
	
	v.isHidden = false
	
	setmetatable(v, {__index = Block})
	Block[#Block + 1] = v
	return v
end

function isColliding(a,b)
   return not (((b.x >= a.x + a.width) or
	   (b.x + b.width <= a.x) or
	   (b.y >= a.y + a.height) or
	   (b.y + b.height <= a.y)))
end
	
function Block.getFrame(id)
	return BlockFrame[id]
end

function Block.setFrame(id, n)
	BlockFrame[id] = n
end

function Block.render(v, c)
	if v.isHidden then return end
	
	local c = (c or camera)
	
	if not isColliding(v, c) then return end
	
	local id = v.id
	local img = Graphics.sprites.block[id]
	
	if img then
		local cfg = Block.config[id]
		local priority = (cfg.sizable and RENDER_PRIORITY.SIZEABLE) or (cfg.foreground and RENDER_PRIORITY.FOREGROUND_BLOCK) or RENDER_PRIORITY.BLOCK
		
		Graphics.draw{
			texture = img,
			
			x = v.x,
			y = v.y,
			
			sourceY = cfg.height * BlockFrame[id],
			sourceHeight = v.height,
			sourceWidth = v.width,
			
			priority = priority,
			
			sceneCoords = true,
			targetCamera = c.idx,
		}
	end
end

local function iterate(args,i)
	while (i <= args[1]) do
		local v = Block[i]

		local idFilter = args[2]
		local idMap = args[3]

		if idFilter == nil or idFilter == -1 or idFilter == v.id or (idMap ~= nil and idMap[v.id]) then
			return i+1,v
		end

		i = i + 1
	end
end

function Block.iterate(idFilter)
	local args = {#Block,idFilter}

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
		local v = Block[i]

		if v.x < args[4] and v.y < args[5] and v.x+v.width > args[2] and v.y+v.height > args[3] then
			return i+1,v
		end

		i = i + 1
	end
end

function Block.iterateIntersecting(x1,y1,x2,y2)
	local args = {#Block,x1,y1,x2,y2}

	return iterateIntersecting, args, 1
end
	
function Block.get(idFilter)
	local ret = {}
	
	if (idFilter == nil) then
		for idx = 1, #Block do
			ret[#ret+1] = Block[idx]
		end
	elseif (type(idFilter) == "number") then
		for idx = 1, #Block do
			local b = Block[idx]
			
			if b.id == idFilter then
				ret[#ret+1] = b
			end
		end
	elseif (type(idFilter) == "table") then
		local lookup = {}
		
		for _,id in ipairs(idFilter) do
			lookup[id] = true
		end
		
		for idx = 1, #Block do
			local b = Block[idx]
				
			if lookup[b.id] then
				ret[#ret+1] = b
			end
		end
	else
		error("Invalid parameters to get")
	end
	
	return ret
end

function Block.onDrawInternal()
	for k = 1, #Block do
		Block[k]:render(c)
	end
end

function Block.onTickInternal()
	for id,val in pairs(BlockFrameTimer) do
		local cfg = Block.config[id]

		if cfg.frames ~= 0 then
			BlockFrameTimer[id] = BlockFrameTimer[id] + Engine.speed
			
			if BlockFrameTimer[id] >= cfg.framespeed then
				BlockFrame[id] = BlockFrame[id] + 1
				
				if BlockFrame[id] >= cfg.frames then
					BlockFrame[id] = 0
				end
				
				BlockFrameTimer[id] = 0
			end
		end
	end
end

function Block.onInit()
	registerEvent(Block, 'onTickInternal')
	registerEvent(Block, 'onDrawInternal')
end

setmetatable(Block, {__call = function(self, idx)
	return self[idx]
end})

return Block