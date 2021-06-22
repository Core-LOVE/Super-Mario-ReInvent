local bgo = {}

bgo.fields = {
	id = 0,
	
	x = 0,
	y = 0,
	width = 32,
	height = 32,
}

function bgo.spawn(id, x, y)
	local v = bgo.new{
		id = id,
		
		x = x,
		y = y,
	}
	
	bgo[#bgo + 1] = v
	return v
end

function bgo:render(arg)
	local v = self or {}
	local arg = arg or {}
	
	arg.id = arg.id or v.id
	arg.x = arg.x or v.x
	arg.y = arg.y or v.y
	arg.priority = arg.priority or RENDER_PRIORITY.BGO
	arg.opacity = arg.opacity or 1
	arg.sceneCoords = arg.sceneCoords or true
	
	Graphics.basicDraw(
		Graphics.sprites.background[arg.id].img,
		arg.x, arg.y,
		arg.priority,
		arg.opacity,
		arg.sceneCoords
	)
end	

_G.BGO = bgo