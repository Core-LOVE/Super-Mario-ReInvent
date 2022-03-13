local Classic = {}

local function clamp(val,min,max)
	return math.max(math.min(val,max),min)
end

local function findRunningCollision(Loc1, Loc2) --Helps the player to walk over 1 unit cracks
    local tempFindRunningCollision = COLLISION_NONE;

    if(Loc1.y + Loc1.height - Loc1.speedY - 2.5 <= Loc2.y - Loc2.speedY) then
        tempFindRunningCollision = COLLISION_TOP;
    elseif(Loc1.x - Loc1.speedX >= Loc2.x + Loc2.width - Loc2.speedX) then
        tempFindRunningCollision = COLLISION_RIGHT;
    elseif(Loc1.x + Loc1.width - Loc1.speedX <= Loc2.x - Loc2.speedX) then
        tempFindRunningCollision = COLLISION_LEFT;
    elseif(Loc1.y - Loc1.speedY >= Loc2.y + Loc2.height - Loc2.speedY) then
        tempFindRunningCollision = COLLISION_BOTTOM;
    else
        tempFindRunningCollision = COLLISION_CENTER;
    end

    return tempFindRunningCollision;
end

local function findNPCcollision(Loc1, Loc2) -- Whats side the collision happened for NPCs
	local tempNPCFindCollision = COLLISION_NONE;

    if(Loc1.y + Loc1.height - Loc1.speedY <= Loc2.y - Loc2.speedY + 4) then
        tempNPCFindCollision = COLLISION_TOP;
    elseif(Loc1.x - Loc1.speedX >= Loc2.x + Loc2.width - Loc2.speedX) then
        tempNPCFindCollision = COLLISION_RIGHT;
    elseif(Loc1.x + Loc1.width - Loc1.speedX <= Loc2.x - Loc2.speedX) then
        tempNPCFindCollision = COLLISION_LEFT;
    elseif(Loc1.y - Loc1.speedY > Loc2.y + Loc2.height - Loc2.speedY - 0.1) then
        tempNPCFindCollision = COLLISION_BOTTOM;
    else
        tempNPCFindCollision = COLLISION_CENTER;
    end

    return tempNPCFindCollision;
end

local function npcHitNpc(v, npc)
	if not (v.x + v.width >= npc.x and
		v.x <= npc.x + npc.width and
		v.y + v.height >= npc.y and
		v.y <= npc.y + npc.height) then return end
		
	if NPC.config[npc.id].ignored then return end
	
	local hitspot = findNPCcollision(v, npc)
	
	if hitspot == 2 or hitspot == 4 then
		v.direction = -v.direction
		v.speedX = -v.speedX
		
		npc.direction = -npc.direction
		npc.speedX = -npc.speedX
	end
end
	
local function getSlopeEjectionPosition(v,solid,solidCfg,slopeDirection)
	local vSide     = (v.x    +(v.width    *0.5))-((v.width    *0.5)*slopeDirection)
	local solidSide = (solid.x+(solid.width*0.5))+((solid.width*0.5)*slopeDirection)

	local distance = (solidSide-vSide)*slopeDirection

	if solidCfg.floorslope ~= 0 then
		return (solid.y+solid.height) - (clamp(distance/solid.width,0,1) * solid.height) - v.height
	elseif solidCfg.ceilingslope ~= 0 then
		return solid.y + (clamp(distance/solid.width,0,1) * solid.height)
	end
end

local function lazySlopes(v, solid, blockCfg)
	local hitspot = findNPCcollision(v, solid)
	local blockCfg = Block.config[solid.id]
	
	local floorslope = blockCfg.floorslope
	local ceilingslope = blockCfg.ceilingslope
	
	local slopeDirection = (floorslope ~= 0 and floorslope) or ceilingslope
	local slopeEjectionPos = getSlopeEjectionPosition(v, solid, blockCfg, slopeDirection)
	
	if floorslope ~= 0 then
		if hitspot == COLLISION_BOTTOM then
			return
		end
		
		if (floorslope == -1 and hitspot == COLLISION_RIGHT) or (floorslope == 1 and hitspot == COLLISION_LEFT) then
			return
		end
		
		v.collidesBlockBottom = true
	else
		if hitspot == COLLISION_TOP then
			return
		end
		
		if (ceilingslope == 1 and hitspot == COLLISION_RIGHT) or (ceilingslope == -1 and hitspot == COLLISION_LEFT) then
			return
		end
		
		v.collidesBlockTop = true
	end
	
	v.y = slopeEjectionPos
	v.speedY = 0
	
	return true
end

local function hitBlock(v, solid)
	-- if(NPC[A].Location.x + NPC[A].Location.width >= Block[B].Location.x)
	-- {
	-- if(NPC[A].Location.x <= Block[B].Location.x + Block[B].Location.width)
	-- {
		-- if(NPC[A].Location.y + NPC[A].Location.height >= Block[B].Location.y)
		-- {
			-- if(NPC[A].Location.y <= Block[B].Location.y + Block[B].Location.height)
			-- {
	if not (v.x + v.width >= solid.x and
		v.x <= solid.x + solid.width and
		v.y + v.height >= solid.y and
		v.y <= solid.y + solid.height) then return end
		
	local blockCfg = Block.config[solid.id]
	local vType = v.__type
	
	if blockCfg.floorslope ~= 0 or blockCfg.ceilingslope ~= 0 then
		local breakRoutine = lazySlopes(v, solid)
	
		if breakRoutine then
			return
		end
	end
	
	local hitspot
	
	if vType == "Player" then
		hitspot = findRunningCollision(v, solid)
	else
		hitspot = findNPCcollision(v, solid)
	end
	
	if hitspot == 1 then -- bottom
		v.y = solid.y - v.height
		v.collidesBlockBottom = true
	elseif hitspot == 2 then
		v.x = solid.x + solid.width
		v.collidesBlockLeft = true
	elseif hitspot == 3 then
		v.y = solid.y + solid.height
		v.collidesBlockTop = true
	elseif hitspot == 4 then
		v.x = solid.x - v.width
		v.collidesBlockRight = true
	end
	
	-- effects
	
	if hitspot == 1 then
		v.speedY = 0
	elseif hitspot == 2 or hitspot == 4 then
		if vType == "NPC" then
			v.direction = -v.direction
			v.speedX = -v.speedX
		else
			v.speedX = 0
		end
	elseif hitspot == 3 then
	
	end
end

-- local function playerHitNPC(v, npc)
	-- if not (v.x + v.width >= npc.x and
		-- v.x <= npc.x + npc.width and
		-- v.y + v.height >= npc.y and
		-- v.y <= npc.y + npc.height) then return end
		
	-- local hitspot = Collision.getSide(v, npc)
	
	-- if hitspot == COLLISION_BOTTOM and v.y < npc.y and v.speedY >= 0 then
		-- Effect.spawn(75, npc)
		
		-- npc:kill()
		
		-- v.y = npc.y - v.height
		-- v.jumpForce = Defines.jumpheight_bounce
		-- v.speedY = -6
	-- end
-- end

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

	if (v.__type == "NPC" and NPC.config[v.id].noblockcollision) or v.noblockcollision then return end
	
	local blockList = Block.get()
	
	table.sort(blockList, function(a, b)
		return (a.x > b.x)
	end)
	
	for k,solid in ipairs(blockList) do
		hitBlock(v, solid)
	end
	
	if v.__type == "NPC" then
		local cfg = NPC.config[v.id]
		
		if not cfg.turnaround or cfg.ignoring then return end
		
		for k, n in ipairs(NPC) do
			if n ~= v then
				npcHitNpc(v, n)
			end
		end
	end
end

return Classic