local block = {}

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
	
	block[v.idx] = v
	return v
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
	
	if not Game.isColliding(arg.x, arg.y, 32, 32) then return end

	Graphics.basicDraw(
		Graphics.sprites.block[arg.id].img,
		arg.x, arg.y,
		arg.priority,
		arg.opacity,
		arg.sceneCoords
	)
end

function block.internalDraw()
	for k,v in ipairs(block) do
		v:render()
	end
end

_G.Block = Objectify(block)