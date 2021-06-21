local cam = {}

cam.fields = {
	x = 0,
	y = 0,
	renderX = 0,
	renderY = 0,
	width = 400,
	height = 600,
	
	isHidden = false,
}

function cam.spawn(rx,ry)
	local v = Camera.new{
		renderX = rx,
		renderY = ry,
	}
	v.idx = #cam + 1
	v.canvas = love.graphics.newCanvas(v.width, v.height)
	
	cam[v.idx] = v
	return v
end

_G.Camera = Objectify(cam)
camera = Camera.spawn(0, 0)
camera2 = Camera.spawn(400, 0)