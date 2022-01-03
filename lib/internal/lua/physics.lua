local HC = require 'collision/HC/init'

physics = {}

physics.world = function(...)
	return HC(...)
end

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

	return self:unpack()
end

physics.polygon = function(x, y, tris)
	local p = HC.polygon(unpack(tris))
	local cx, cy = p:center()
	
	p:moveTo(x + cx, y + cy)
	
	return p
end

physics.slope = function(x, y, w, h)
	local x, y, w, h = x, y, w, h
	
	if w < 0 then
		x = x - w
	end
	
	if h < 0 then
		y = y - h
	end
	
	return physics.polygon(x, y, {
		w, 0, 
		0, h, 
		w, h
	})
end

physics.triangle = function(x, y, w, h)
	return physics.polygon(x, y, {
		w * 0.5, 0, 
		0, h, 
		w, h
	})
end