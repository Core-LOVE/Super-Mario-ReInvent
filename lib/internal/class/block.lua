local Block = {}
Block.__type = "Block"

do
	local luafiles = {}

	function Block.loadLua(id)
		local name = 'block/block-' .. id
		
		if not luafiles[id] and File.exists(name .. '.lua', File.requirePaths) then
			luafiles[id] = true
			
			--load lua file
			local g = table.copy(_G)
			g.BLOCK_ID = id
			
			setfenv(1, g)
			require(name)
			setfenv(1, _G)
		end
	end
end

do
	local config = require 'configuration'
	
	Block.config = config('block', {
		frames = 1,
		framespeed = 8,
		
		sizable = false,
		passthrough = false,
		pswitchable = false,
		lava = false,
		semisolid = false,
		floorslope = 0,
		ceilingslope = 0,
		bumpable = false,
		smashable = 0,
	})
end

Block.bumped = {}

function Block.spawn(id, x, y)
	local v = {}
	
	v.idx = #Block + 1
	v.id = id
	v.x = x
	v.y = y
	v.width = 32
	v.height = 32
	v.speedX = 0
	v.speedY = 0
	
	v.data = {}
	
	v.params = {
		opacity = 1,
		xOffset = 0,
		yOffset = 0,
	}
	
	Block.loadLua(v.id)
	
	local img = Graphics.sprites.block[v.id]
	
	if img then
		v.width = img:getWidth()
		v.height = img:getHeight() / Block.config[v.id].frames
	end
	
	setmetatable(v, {__index = Block})
	Block[#Block + 1] = v
	return v
end

function Block:render(args)
	local v = self
	local p = v.params
	local args = args or {}
	
	Graphics.draw{
		texture = Graphics.sprites.block[v.id],
		
		x = (v.x or args.x) + p.xOffset,
		y = (v.y or args.y) + p.yOffset,
		
		opacity = args.opacity or p.opacity,

		scene = (args.scene == nil and true) or args.scene,
		targetCamera = args.targetCamera or 0,
		priority = PRIORITY.BLOCK,
	}
end

function Block.onDrawInternal()
	for k,v in ipairs(Block) do
		v:render()
	end
end

function Block.onInit()
	registerFunction(Block, 'onDrawInternal')
end

do
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
end

function Block.setSettings(config)
	local id = config.id	
	local default = Block.config[id]
	
	local nt = table.copy(config)
	nt.id = nil
	
	Block.config[id] = table.deepmerge(default, nt)
end

registerBlockFunction = libManager.defineRegistering(Block, 'id', 'Block')
libManager.registerBlockEvent = registerBlockFunction

return Block