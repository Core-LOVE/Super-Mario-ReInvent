local Collision = {}
Collision.system = 'default'

local HC = require 'collision/HC/init'

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
	local floor = math.floor
	local abs = math.abs
	
	local function toCoords(p)
	  local t = {}
	  local j = 1
	  for i = 1, #p do
		local v = p[i]
		t[j], t[j + 1] = v.x, v.y
		j = j + 2
	  end
	  return t
	end
	
	slopes = {floor = {}, celling = {}}

	slopes.floor.left = function(vx, vy, vw, vh)
		return toCoords{
			{x = vx + vw, y = vy + vh},
			{x = vx, y = vy + vh},
			{x = vx + vw, y = vy},
		}
	end
	
	Collision.registerSystem('default', function(obj, block)
		local blockBox = HC.rectangle(block.x, block.y, block.width, block.height)
		-- local blockBox
		
		-- local vside = 'floor'
		-- local hside = 'left'
		-- local slope = slopes[vside][hside](block.x, block.y, block.width, block.height)
		
		-- Graphics.polygon(slope)
		
		-- blockBox = HC.polygon(obj.x, unpack(slope))
		
		local objBox = HC.rectangle(obj.x, obj.y, obj.width, obj.height)
		
		local col, dx, dy = objBox:collidesWith(blockBox)
		
		if col then
			obj.x = obj.x + dx
			obj.y = obj.y + dy
			
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
		
		HC.remove(blockBox)
		HC.remove(objBox)
		collectgarbage()
	end)
end

return Collision