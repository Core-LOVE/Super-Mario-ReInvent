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

local function collideCheck(v, solid)
	local cfg = Block.config[solid.id]
	
	print(checkSide(v, solid))
	
	if cfg.floorslope ~= 0 or cfg.ceilingslope ~= 0 then
		return slopeCollide(v, solid)
	end
	
	local side = checkSide(v, solid)
	
	-- Effects
	if side == COLLISION_SIDE_LEFT or side == COLLISION_SIDE_RIGHT then
		if vType == "NPC" then
			v.turnAround = true
		else
			v.speedX = 0
		end
	elseif side == COLLISION_SIDE_TOP or side == COLLISION_SIDE_BOTTOM then
		-- if solidData.collidingSlope == 0 then
			v.speedY = 0
		-- else
			-- v.speedY = 1
		-- end

		if vType == "Player" then
			v.jumpForce = 0
		end
	end

	if side == COLLISION_SIDE_BOTTOM and vType == "Player" then
		-- SFX.play(3)
	end


	-- Ejection
	if side == COLLISION_SIDE_BOTTOM then
		if slopeEjectionPosition == nil then
			v.y = solid.y-v.height
		else
			v.y = slopeEjectionPosition
			v.collidingSlope = solid
		end

		v.collidesBlockBottom = true
	elseif side == COLLISION_SIDE_RIGHT then
		v.x = solid.x+solid.width
		v.collidesBlockLeft = true
	elseif side == COLLISION_SIDE_BOTTOM then
		if slopeEjectionPosition == nil then
			v.y = solid.y+solid.height
		else
			v.y = slopeEjectionPosition
			v.collidingSlope = solid
		end

		v.collidesBlockTop = true
	elseif side == COLLISION_SIDE_LEFT then
		v.x = solid.x-v.width
		v.collidesBlockRight = true
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

    obj.x = obj.x + (obj.speedX)
	obj.y = obj.y + (obj.speedY)

	for _,block in Block.iterateIntersecting(obj.x, obj.y, obj.x + obj.width, obj.y + obj.height) do
		if not Block.config[block.id].passthrough then
			collideCheck(obj, block)
		end
	end
end

return sus