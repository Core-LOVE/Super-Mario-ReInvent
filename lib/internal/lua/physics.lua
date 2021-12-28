local HC = require 'collision/HC/init'

physics = {}

physics.registerShape = HC.register

physics.point = HC.point

physics.box = HC.rectangle
physics.rectangle = physics.box
physics.rect = physics.box

physics.circle = HC.circle

physics.remove = HC.remove

physics.neighbors = HC.neighbors
physics.shapesAt = HC.shapesAt
physics.collisions = HC.collisions

physics.unpack = function(self)
	local self = self._polygon
	local v = {}
	
	for i = 1,#self.vertices do
		v[2*i-1] = self.vertices[i].x
		v[2*i]   = self.vertices[i].y
	end
	
	return unpack(v)
end

physics.polygon = function(x, y, tris)
	local p = HC.polygon(unpack(tris))
	local cx, cy = p:center()
	
	p:moveTo(x + cx, y + cy)
	
	return p
end

physics.slope = function(x, y, w, h)
	return physics.polygon(x, y, {
	w, 0, 
	0, h, 
	w,h
	})
end

physics.triangle = function(x1, y1, x2, y2, x3, y3)

end