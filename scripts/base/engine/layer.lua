Layer = {}

local layers = {}

function Layer.create(name, objs)
	local v = objs or {}
	
	v.speedX = 0
	v.speedY = 0
	v.isHidden = false
	v.name = name
	
	layers[name] = v
	setmetatable(layrs[name], {__index = Layer})
	return v
end

function Layer.get(name)
	return layers[name]
end

function Layer:add(obj)
	self[#self + 1] = obj
end

function Layer:show(noSmoke)
	self.isHidden = false
end

function Layer:hide(noSmoke)
	self.isHidden = true
end

function Layer:toggle(noSmoke)
	if self.isHidden then
		self:show(noSmoke)
	else
		self:hide(noSmoke)
	end
end

function Layer:stop()
	self.speedX = 0
	self.speedY = 0
end

function Layer.internalUpdate()
	for k,v in pairs(layers) do
		
	end
end

Tags = Layer