local block = {}

local function callSpecialEvent(v,eventName)
	blockManager.callSpecialEvent(v,eventName)
end

local scripts = {}

local function requireScript(k) 
	if not scripts[k] then
		BLOCK_ID = k
		
		local script = require('block-' .. k, true)
		
		if not script then
			script = require('block/block-' .. k, true)
		end
		
		scripts[k] = true
		BLOCK_ID = nil
		
		return
	end
end

local blockFrame = {}
local blockFrameTimer = {}

block.config = Configuration.create('block', {
	width = 32,
	height = 32,
	
	sizable = false,
	connecting = false,
	playerpassthrough = false,
	npcpassthrough = false,
	passthrough = false,
	floorslope = 0,
	ceilingslope = 0,
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
	frames = 1,
	framespeed = 8,
	foreground = false,
})

local frame = {}
local frametimer = {}

block.fields = function()
	return {
		id = 0,
		
		x = 0,
		y = 0,
		width = 32,
		height = 32,
		
		contentID = 0,
		hiddenUntilHit = false,
		slippery = false,
	}
end

function block.spawn(id, x, y)
	local v = block.new{
		id = id,
		x = x,
		y = y,
	}
	v.idx = #block + 1
	
	requireScript(id)
	block[v.idx] = v
	return v
end

local function drawBlock(arg)
	Graphics.draw{
		image = Graphics.sprites.block[arg.id].img,
		x = arg.x, 
		y = arg.y,
		priority = arg.priority,
		opacity = arg.opacity,
		isSceneCoordinates = arg.sceneCoords,
		
		sourceY = blockFrame[arg.id] * arg.height,
		sourceWidth = arg.width,
		sourceHeight = arg.height,
	}
end

local function drawSizable(arg)
	local img = Graphics.sprites.block[arg.id].img
	
	if arg.width ~= img:getWidth() or arg.height ~= img:getHeight() then
		
	else
		drawBlock(arg)
	end
end

function block:render(arg)
	local v = self or {}
	local arg = arg or {}
	
	arg.id = arg.id or v.id
	arg.x = arg.x or v.x
	arg.y = arg.y or v.y
	arg.priority = arg.priority or RENDER_PRIORITY.BLOCK
	arg.opacity = arg.opacity or 1
	arg.sceneCoords = arg.sceneCoords or true
	arg.width = arg.width or v.width
	arg.height = arg.height or v.height
	
	if not Game.isColliding(arg.x, arg.y, arg.width, arg.height) then return end

	local config = block.config[arg.id]
	
	blockFrame[arg.id] = blockFrame[arg.id] or 0
	blockFrameTimer[arg.id] = blockFrameTimer[arg.id] or 0
	
	blockFrameTimer[arg.id] = blockFrameTimer[arg.id] + 1
	if blockFrameTimer[arg.id] >= config.framespeed then
		blockFrame[arg.id] = (blockFrame[arg.id] + 1) % config.frames
		blockFrameTimer[arg.id] = 0
	end
	
	if not block.config[arg.id].sizable then
		drawBlock(arg)
	else
		drawSizable(arg)
	end
end

function block.internalDraw()
	for k,v in ipairs(block) do
		v:render()
	end
end

_G.Block = Objectify(block)