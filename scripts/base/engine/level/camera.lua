local cam = {}

cam.fields = {
	x = 0,
	y = 0,
	renderX = 0,
	renderY = 0,
	width = 800,
	height = 600,
	
	isHidden = false,
}

function cam.spawn(x,y)
	local v = Camera.new{
		x = x,
		y = y,
	}
	v.canvas = love.graphics.newCanvas(v.width, v.height)
	
	table.insert(cam, v)
	return v
end

_G.Camera = Objectify(cam)
camera = Camera.spawn(0, 0)
camera2 = Camera.spawn(400, 0)