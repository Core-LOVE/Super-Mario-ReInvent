local Collision = {}
Collision.system = 'default'

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
	
	for _,block in ipairs(Block) do
		sys(obj, block)
	end
end

do
	Collision.registerSystem('default', function(obj, block)
		local blockBox
		
		blockBox = physics.slope(block.x, block.y, block.width, block.height)
		-- blockBox = physics.rect(block.x, block.y, block.width, block.height)
		Graphics.polygon{physics.unpack(blockBox)}
		
		local objBox = physics.rectangle(obj.x, obj.y, obj.width, obj.height)
		Graphics.polygon{physics.unpack(objBox)}
		
		local col, dx, dy = objBox:collidesWith(blockBox)
		
		if col then
			objBox:move(-dx * 0.5, -dy * 0.5)	
			obj.x = obj.x + dx * 0.5
			obj.y = obj.y + dy * 0.5
			
			if dy ~= 0 then
				obj.speedY = 0
			end
			
			if dx ~= 0 then
				if obj.__type == "NPC" then
					obj.direction = -obj.direction
					obj.speedX = -obj.speedX
				else
					obj.speedX = 0
				end
			end
		end
		
		physics.remove(blockBox)
		physics.remove(objBox)
		blockBox = nil
		objBox = nil
		collectgarbage()
	end)
end

return Collision