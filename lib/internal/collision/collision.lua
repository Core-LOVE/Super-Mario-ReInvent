local Collision = {}
Collision.system = 'default'
Collision.debug = true

local cls = {}

function Collision.registerSystem(name, f)
	cls[name] = f
end

function Collision.getSystem(name)
	if not name then
		return cls[Collision.system]
	else
		return cls[name]
	end
end

function Collision.setSystem(n)
	Collision.system = n
end

function Collision.update(obj)
	local sys = Collision.getSystem()
	
	if sys and sys.update then
		sys.update(obj)
	end
end

Collision.registerSystem('default', require('collision/default'))
Collision.registerSystem('classic', require('collision/13'))

return Collision