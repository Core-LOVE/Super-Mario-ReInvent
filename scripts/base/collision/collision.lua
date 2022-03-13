local Collision = {}
Collision.system = 'classic'

local systems = {}

function Collision.isColliding(a,b)
   if ((b.x >= a.x + a.width) or
	   (b.x + b.width <= a.x) or
	   (b.y >= a.y + a.height) or
	   (b.y + b.height <= a.y)) then
		  return false 
   else return true
	   end
end

COLLISION_SIDE_NONE    = 0
COLLISION_SIDE_TOP     = 1
COLLISION_SIDE_RIGHT   = 2
COLLISION_SIDE_BOTTOM  = 3
COLLISION_SIDE_LEFT    = 4
COLLISION_SIDE_UNKNOWN = 5
COLLISION_SIDE_CENTER = COLLISION_SIDE_UNKNOWN

COLLISION_NONE    = 0
COLLISION_TOP     = 1
COLLISION_RIGHT   = 2
COLLISION_BOTTOM  = 3
COLLISION_LEFT    = 4
COLLISION_UNKNOWN = 5
COLLISION_CENTER = COLLISION_SIDE_UNKNOWN

function Collision.getSide(Loc1, Loc2, leniencyForTop)
    leniencyForTop = leniencyForTop or 0
    
	local right = (Loc1.x + Loc1.width) - Loc2.x - Loc2.speedX
	local left = (Loc2.x + Loc2.width) - Loc1.x - Loc1.speedX
	local bottom = (Loc1.y + Loc1.height) - Loc2.y - Loc2.speedY
	local top = (Loc2.y + Loc2.height) - Loc1.y - Loc1.speedY
	
	if right < left and right < top and right < bottom then
		return COLLISION_SIDE_RIGHT
	elseif left < top and left < bottom then
		return COLLISION_SIDE_LEFT
	elseif top < bottom then
		return COLLISION_SIDE_TOP
	else
		return COLLISION_SIDE_BOTTOM
	end
end

function Collision.addSystem(name, sys)
	local sys = (sys or name)
	
	if type(sys) == 'string' then
		sys = require('collision/' .. sys)
	end
	
	systems[name] = sys
end

function Collision.getSystem(name)
	return systems[name or Collision.system]
end

function Collision.update(v)
	systems[Collision.system].onUpdate(v)
end

Collision.addSystem('classic')
return Collision