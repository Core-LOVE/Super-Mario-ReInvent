local Sprite = {}

function Sprite:draw()
	return Graphics.draw(self)
end

function Sprite.new(v)
	local v = v or {}
	
	setmetatable(v, {__index = Sprite})
	return v
end

return Sprite