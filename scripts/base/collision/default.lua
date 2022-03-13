local Classic = {}

local function clamp(val,min,max)
	return math.max(math.min(val,max),min)
end
	
local function lazySlopes(v, vType, solid, floorslope, ceilingslope, side)
	local slopeDirection = (floorslope ~= 0 and floorslope) or -ceilingslope
	
	if slopeDirection == -1 then
		if side ~= COLLISION_SIDE_LEFT and side ~= COLLISION_SIDE_TOP then
			return
		end
	else
		if side ~= COLLISION_SIDE_RIGHT and side ~= COLLISION_SIDE_TOP then
			return
		end
	end
	
	-- print(slopeDirection, side)
	
    local vSide     = (v.x    +(v.width    *0.5))-((v.width    *0.5)*slopeDirection)
	local solidSide = (solid.x+(solid.width*0.5))+((solid.width*0.5)*slopeDirection)

    local distance = (solidSide-vSide)*slopeDirection
	
	local y = (solid.y+solid.height) - (clamp(distance/solid.width,0,1) * solid.height) - v.height
	
	v.y = y
	v.speedY = 0
	v.collidesBlockBottom = true
	
	return true
end

local function hitSolid(v, solid)
	if not Collision.isColliding(solid, v) then return end
	
	local vType = v.__type
	local sType = solid.__type
	
	local side = Collision.getSide(solid, v,3.5)

	local cfg = Block.config[solid.id]

	local floorslope = cfg.floorslope
	local ceilingslope = cfg.ceilingslope
	
	if floorslope ~= 0 or ceilingslope ~= 0 then
		local stop = lazySlopes(v, vType, solid, floorslope, ceilingslope, side)
		
		if stop then
			return
		end
	end
	
	-- Effects
	if side == COLLISION_SIDE_LEFT or side == COLLISION_SIDE_RIGHT then
		local continue = true
		
		for _, otherSolid in ipairs(Block) do
			if otherSolid ~= solid and Collision.isColliding(v, otherSolid) then
				continue = false
				break
			end
		end
		
		if continue then
			if vType == "NPC" then
				v.speedX = -v.speedX
				v.direction = -v.direction
			else
				v.speedX = 0
			end
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
	
	-- Ejection
	if side == COLLISION_SIDE_TOP then
		-- if slopeEjectionPosition == nil then
			v.y = solid.y-v.height
		-- else
			-- v.y = slopeEjectionPosition
			-- v.collidingSlope = solid
		-- end

		v.collidesBlockBottom = true
	elseif side == COLLISION_SIDE_RIGHT then
		v.x = solid.x+solid.width
		v.collidesBlockLeft = true
	elseif side == COLLISION_SIDE_BOTTOM then
		-- if slopeEjectionPosition == nil then
			v.y = solid.y+solid.height
		-- else
			-- v.y = slopeEjectionPosition
			-- v.collidingSlope = solid
		-- end

		v.collidesBlockTop = true
	elseif side == COLLISION_SIDE_LEFT then
		v.x = solid.x-v.width
		v.collidesBlockRight = true
	end	
end

local function hitNPC(v, solid)
	if not Collision.isColliding(solid, v) then return end
	
	local vType = v.__type
	local sType = solid.__type
	
	local side = Collision.getSide(solid, v,3.5)

	local vCfg = NPC.config[v.id]
	
	if vCfg.turnAroundNPC then
		if side == COLLISION_SIDE_LEFT or side == COLLISION_SIDE_RIGHT then
			v.speedX = -v.speedX
			v.direction = -v.direction
			solid.speedX = -v.speedX
			solid.direction = -v.direction	
		end
	end
end

function Classic.onUpdate(v)
	-- Reset collision fields
	-- for i=1,#v.collidingSolids do
		-- v.collidingSolids[i] = nil
		-- v.collidingSolidsSides[i] = nil
	-- end

	v.collidingSlope = nil

	v.collidesBlockBottom = false
	v.collidesBlockLeft = false
	v.collidesBlockRight = false
	v.collidesBlockTop = false
	
	v.x = v.x + (v.speedX * Engine.speed)
	v.y = v.y + (v.speedY * Engine.speed)

	if v.__type == "NPC" and NPC.config[v.id].noblockcollision then return end
	
	-- Interact with blocks
	for k,b in ipairs(Block) do
		hitSolid(v, b)
	end

	if v.__type ~= "NPC" then return end
	
	for k,b in ipairs(NPC) do
		if b ~= v then
			hitSolid(v, b)
		end
	end
	-- for _,npc in NPC.iterateIntersecting(v.x,v.y,v.x+v.width,v.y+v.height) do
		-- hitSolid(v, npc)
	-- end
end

return Classic