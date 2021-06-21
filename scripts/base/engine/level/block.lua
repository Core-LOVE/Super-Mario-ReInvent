local block = {}

block.fields = {
	id = 0,
	
	x = 0,
	y = 0,
	width = 32,
	height = 32,
}

function block.spawn(id, x, y)
	local v = block.new{
		id = id,
		x = x,
		y = y,
	}
	v.idx = #block + 1
	
	block[v.idx] = v
end

function block:render(arg)
	local v = self
	local arg = arg or {}
	
	arg.id = arg.id or v.id
	arg.x = arg.x or v.x
	arg.y = arg.y or v.y
	
	Graphics.basicDraw(
		Graphics.sprites.block[arg.id].img,
		arg.x, arg.y
	)
end

function block.internalDraw()
	for k = 1, #block do
		local v = block[k]
		
		if v then
			v:render()
		end
	end
end

_G.Block = Objectify(block)