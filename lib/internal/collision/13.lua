local sus = {}

local function check(Loc1, Loc2) --simple collision check
    if(Loc1.y + Loc1.height >= Loc2.y) then
        if(Loc1.y <= Loc2.y + Loc2.height) then
            if(Loc1.x <= Loc2.x + Loc2.width) then
                if(Loc1.x + Loc1.width >= Loc2.x) then
                    return true
                end
            end
        end
    end
	
	return false
end

COLLISION_SIDE_NONE    = 0
COLLISION_SIDE_TOP     = 1
COLLISION_SIDE_RIGHT   = 2
COLLISION_SIDE_BOTTOM  = 3
COLLISION_SIDE_LEFT    = 4
COLLISION_SIDE_UNKNOWN = 5

local function checkSide(Loc1, Loc2, leniencyForTop)
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

local function slopeCollide(obj, block)

end

local function collideCheck(obj, block)
	local cfg = Block.config[block.id]
	
	if not check(obj, block) then return end
	
	if cfg.floorslope ~= 0 or cfg.ceilingslope ~= 0 then
		return slopeCollide(obj, block)
	end
	
	local side = checkSide(obj, block)
	
	-- collides stuff
	if side == COLLISION_SIDE_BOTTOM then
		obj.y = block.y - obj.height
		obj.collidesBlockBottom = true
	elseif side == COLLISION_SIDE_TOP then
		obj.y = block.y + block.height
		obj.collidesBlockTop = true
	elseif side == COLLISION_SIDE_LEFT then
		obj.x = block.x + block.width
		obj.collidesBlockLeft = true
	elseif side == COLLISION_SIDE_RIGHT then
		obj.x = block.x + block.width
		obj.collidesBlockRight = true
	end
	
	if side ~= 3 then
		print(side)
	end
	
	--effects...
	if obj.collidesBlockBottom then
		obj.speedY = 0
	end
	
	if obj.collidesBlockTop then
		obj.speedY = 0
	end
end

sus.update = function(obj)
	if obj.__type == "NPC" then
		if obj.noblockcollision or NPC.config[obj.id].noblockcollision then return end
	else
		if obj.noblockcollision then return end
	end
	
    obj.collidesBlockBottom = false
	obj.collidesBlockLeft = false
	obj.collidesBlockRight = false
    obj.collidesBlockTop = false
		
	local dt = 1

    obj.x = obj.x + (obj.speedX * dt)
	obj.y = obj.y + (obj.speedY * dt)

	for _,block in Block.iterateIntersecting(obj.x, obj.y, obj.x + obj.width, obj.y + obj.height) do
		if not Block.config[block.id].passthrough then
			collideCheck(obj, block)
		end
	end
end

return sus