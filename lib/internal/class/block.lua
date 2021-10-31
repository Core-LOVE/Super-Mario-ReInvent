local Block = {}

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

function Block.spawn(id, x, y)
	local v = {}
	
	v.idx = #Block + 1
	v.id = id
	v.x = x
	v.y = y
	
	v.data = {}
	
	v.params = {
		opacity = 1,
		xOffset = 0,
		yOffset = 0,
	}
	
	Block.loadLua(v.id)
	
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
	}
end

function Block.onDraw()
	for k,v in ipairs(Block) do
		v:render()
	end
end

function Block.onInit()
	registerFunction(Block, 'onDraw')
end

registerBlockFunction = libManager.defineRegistering(Block, 'id', 'Block')
libManager.registerBlockEvent = registerBlockFunction

return Block