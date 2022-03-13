local Player = {}
Player.__type = "Player"
-- PlayerSettings = require 'class/playersettings'

Player.controls = {}

Player.controls[1] = {
	jump = 'z',
	altJump = 'a',
	
	run = 'x',
	altRun = 's',
	
	left = 'left',
	right = 'right',
	up = 'up',
	down = 'down',
}

function Player.spawn(character, x, y)
	local v = {}
	
	v.idx = (#Player + 1)
	
	v.data = {}
	
	v.keys = {
		jump = false,
		altJump = false,
		
		run = false,
		altRun = false,
		
		left = false,
		right = false,
		up = false,
		down = false,
	}
	
	v.powerup = 1
	v.character = character
	
	v.ai1 = 0
	v.ai2 = 0
	v.ai3 = 0
	v.ai4 = 0 
	v.ai5 = 0
	
	v.x = x
	v.y = y
	v.speedX = 0
	v.speedY = 0
	v.width = 32
	v.height = 32
	v.direction = 1
	
	v.section = 1
	
	v.frame = 0
	
	v.jumpForce = 0
	v.isSpinjumping = false
	
	setmetatable(v, {__index = Player})
	Player[#Player + 1] = v
	return v
end

function Player:isPressing(key)
	return self.keys[key]
end

function Player:translate(dx, dy)
	self.x = self.x + dx
	self.y = self.y + dy
end


do
	local list = {
		[1] = 'mario',
	}
	
	function Player:getCharacterName()
		return list[self.character]
	end
end

function Player:getSettings()
	return PlayerSettings.get(self.character, self.powerup)
end	

do
	local function pfrX(plrFrame)
		local A
		A = plrFrame
		A = A - 50
		
		while(A > 100) do
			A = A - 100
		end
		
		if(A > 90) then
			A = 9
		elseif(A > 90) then
			A = 9
		elseif(A > 80) then
			A = 8
		elseif(A > 70) then
			A = 7
		elseif(A > 60) then
			A = 6
		elseif(A > 50) then
			A = 5
		elseif(A > 40) then
			A = 4
		elseif(A > 30) then
			A = 3
		elseif(A > 20) then
			A = 2
		elseif(A > 10) then
			A = 1
		else
			A = 0
		end
		
		return A * 100
	end

	local function pfrY(plrFrame)
		local A
		A = plrFrame
		A = A - 50
		
		while(A > 100) do
			A = A - 100
		end
		
		A = A - 1
		while(A > 9) do
			A = A - 10
		end
		
		return A * 100
	end

	function Player.render(v, args, c)
		Graphics.drawRect{
			x = v.x,
			y = v.y,
			width = v.width,
			height = v.height,
			
			sceneCoords = true,
		}
		
		-- local name = v:getCharacterName()
		-- local img = Graphics.sprites[name][v.powerup]
		
		-- if not img then return end
		
		-- local settings = v:getSettings()
		
		-- local tx, ty = pfrX(100 + v.frame * v.direction), pfrY(100 + v.frame * v.direction)
		
		-- local ntx, nty = tx / 100, ty / 100
		
		-- local ox = settings:getSpriteOffsetX(ntx, nty)
		-- local oy = settings:getSpriteOffsetY(ntx, nty)
		
		-- Graphics.draw{
			-- texture = img,
			
			-- x = v.x + ox,
			-- y = v.y + oy,
			
			-- sourceX = tx,
			-- sourceY = ty,
			-- sourceWidth = 100,
			-- sourceHeight = 100,
			
			-- sceneCoords = true
		-- }
	end
end

local function clamp(n, low, high) return math.min(math.max(n, low), high) end

function Player.onPhysics(v)
	-- WALKING
	
	local speedModifier = 1

	local walkSpeed = Defines.player_walkspeed*speedModifier
	local runSpeed = Defines.player_runspeed*speedModifier

	local walkDirection = (v.keys.left and -1) or (v.keys.right and 1) or 0
	-- print(v.keys.left)
	
	if walkDirection ~= 0 then
		local speedingUpForWalk = (v.speedX*walkDirection < walkSpeed)

		if v.keys.run or speedingUpForWalk then
			if speedingUpForWalk then
				v.speedX = v.speedX + Defines.player_walkingAcceleration*speedModifier*walkDirection
			elseif v.speedX*walkDirection < runSpeed then
				v.speedX = v.speedX + Defines.player_runningAcceleration*speedModifier*walkDirection
			end

			if v.speedX*walkDirection < 0 then
				v.speedX = v.speedX + Defines.player_turningAcceleration*walkDirection
			end
		else
			v.speedX = v.speedX - Defines.player_runToWalkDeceleration*walkDirection
		end
	elseif v.collidesBlockBottom then
		if v.isSpinjumping then v.isSpinjumping = false end
		
		if v.speedX > 0 then
			v.speedX = math.max(0,v.speedX - Defines.player_deceleration*speedModifier)
		elseif v.speedX < 0 then
			v.speedX = math.min(0,v.speedX + Defines.player_deceleration*speedModifier)
		end
	end
	
	-- JUMPING
	
	if v.keys.jump or v.keys.altJump then
		if v.slidingSlope then v.slidingSlope = nil end
		
		if (v.keys.jump == KEY_PRESSED or v.keys.altJump == KEY_PRESSED) and v.collidesBlockBottom then
			v.jumpForce = Defines.jumpheight
			if v.keys.altJump then
				v.jumpForce = Defines.spinjumpheight
				v.direction = -v.direction
				
				v.isSpinjumping = true
				-- SFX.play(33)	
			else
				v.isSpinjumping = false
				-- SFX.play(1)
			end
		end

		if v.jumpForce > 0 then
			v.speedY = Defines.player_jumpspeed-math.abs(v.speedX*0.2)
		end
	end
	
	if not v.keys.jump and not v.keys.altJump then
		v.jumpForce = 0
	elseif v.jumpForce > 0 then
		v.jumpForce = math.max(0,v.jumpForce - 1)
	end
	
	for k,n in NPC.iterateIntersecting(v.x - 1, v.y - v.height - 1, v.x + v.width + 1, v.y + v.height + 1) do
		if not n.friendly then
			if n.despawnTimer > 0 then
				local config = NPC.config[n.id]

				-- Hit from top
				if Collision.getSide(n,v) == COLLISION_SIDE_TOP then
					local harmType
					if v.isSpinjumping and (config.damageMap[HARM_TYPE_SPINJUMP] ~= nil or config.spinjumpsafe) then
						harmType = HARM_TYPE_SPINJUMP
					elseif (v.isSpinjumping or not config.jumphurt) and config.damageMap[HARM_TYPE_JUMP] ~= nil then
						harmType = HARM_TYPE_JUMP
					end

					if harmType ~= nil then
						n:harm(harmType, nil, v)

						Effect.spawn(75, v.x + v.width / 2 - 16, v.y + v.height / 2 - 16)
						
						if harmType == HARM_TYPE_SPINJUMP and not config.jumphurt then
							-- SFX.play(36)
							Effect.spawn(76, n.x + n.width / 2, n.y + n.height / 2)
							v.y = n.y - n.height - 1
							v.speedY = -5.69
						else
							-- SFX.play(2)
							v.y = n.y - n.height - 1
							v.jumpForce = Defines.jumpheight_bounce + n.speedY
							v.speedY = Defines.player_jumpspeed - math.abs(v.speedX*0.2)	
						end
					end
				else
					-- v:harm()
				end
				
				-- Grabbing
				-- if (v.holdingNPC == nil and v.keys.run and n.grabbingPlayer == nil) and v.y > n.y and (config.grabside or config.isshell) then
					-- local sfx = 23
					-- if config.isshell then
						-- sfx = nil
					-- end

					-- n:grab(v, sfx)
				-- end
			end	
		end
	end
	
	v.speedY = math.min(v.speedY + Defines.player_grav, Defines.gravity)
	
	local section = Section(v.section)
	
	if v.x < section.x then
		v.speedX = 0
		v.x = section.x
	elseif v.x + v.width >= section.x + section.width then
		v.speedX = 0
		v.x = (section.x + section.width) - v.width
	end
	
	Collision.update(v)
end

function Player.onDrawInternal()
	for k = 1, #Player do
		Player[k]:render()
	end
end

function Player.onTickInternal()
	for k = 1, #Player do
		Player[k]:onPhysics()
	end
end

local function controls(p)
	local keys = (Player.controls[p.idx] or Player.controls[1])
	
	for key in pairs(p.keys) do
		p.keys[key] = Keys.get(keys[key]) or false
	end
end

function Player.onInputUpdateInternal()
	for k = 1, #Player do
		controls(Player[k])
	end
end

function Player.onInit()
	registerEvent(Player, 'onInputUpdateInternal')
	registerEvent(Player, 'onDrawInternal')
	registerEvent(Player, 'onTickInternal')
end

setmetatable(Player, {__call = function(self, idx)
	return self[idx]
end})

return Player