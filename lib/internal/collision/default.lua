local default = {}

local function onCollide(v, obj, block)
	local dx = v.x
	local dy = v.y
	
	obj.x = obj.x + dx
	obj.y = obj.y + dy
	
	-- collidesBlockBottom and etc...
	if dy < 0 then
		obj.collidesBlockBottom = true
	elseif dy > 0 then
		obj.collidesBlockTop = true
	end
	
	if dx < 0 then
		obj.collidesBlockRight = true
	elseif dx > 0 then
		obj.collidesBlockLeft = true
	end
	
	-- "effects"
	if obj.collidesBlockBottom then
		obj.speedY = 0
	end
	
	if obj.collidesBlockLeft or obj.collidesBlockRight then
		if obj.__type == "NPC" then
			obj.speedX = -obj.speedX
			obj.direction = -obj.direction
		else
			obj.speedX = 0
		end
	end
end

local function collideCheck(obj, block)
	local blockBox
	local objBox

	local blockCfg = Block.config[block.id]
	
	if blockCfg.floorslope ~= 0 or blockCfg.ceilingslope ~= 0 then
		local w, h = 1, 1
		
		if blockCfg.floorslope > 0 then
			w = -1
		end
		
		if blockCfg.ceilingslope > 0 then
			h = -1
		end
		
		blockBox = physics.slope(block.x, block.y, block.width * w, block.height * h)
	else
		blockBox = physics.rect(block.x, block.y, block.width, block.height)
	end
	
	--debug stuff
	local debugging = (Collision and Collision.debug)
	
	if debugging then
		local t = {physics.unpack(blockBox)}
		t.color = {0, 0, 0, 1}
		t.priority = 4
		
		Graphics.polygon(t)
	end
	--]]
	
	local objBox = physics.rectangle(obj.x, obj.y, obj.width, obj.height)
	
	--debug stuff
	-- if debugging then
		-- local t = {physics.unpack(objBox)}
		-- t.color = {0.5, 0.5, 0.5, 1}
		-- t.priority = 5
		
		-- Graphics.polygon(t)
	-- end
	--]]
	
	local col, dx, dy = objBox:collidesWith(blockBox)
	
	local collides, dx, dy = objBox:collidesWith(blockBox)
	
	if collides then
		onCollide(vector(dx, dy), obj, block)
	end
	
	physics.remove(blockBox)
	physics.remove(objBox)
		
	blockBox = nil
	objBox = nil
end

default.update = function(obj)
	if obj.__type == "NPC" then
		if obj.noblockcollision or NPC.config[obj.id].noblockcollision then return end
	else
		if obj.noblockcollision then return end
	end
	
    obj.collidesBlockBottom = false
	obj.collidesBlockLeft = false
	obj.collidesBlockRight = false
    obj.collidesBlockTop = false
		
	local dt = deltaTime

    obj.x = obj.x + (obj.speedX * dt)
	obj.y = obj.y + (obj.speedY * dt)

	for _,block in Block.iterateIntersecting(obj.x, obj.y, obj.x + obj.width, obj.y + obj.height) do
		if not Block.config[block.id].passthrough then
			collideCheck(obj, block)
		end
	end
	
	collectgarbage()
end

return default