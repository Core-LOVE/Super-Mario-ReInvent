local Player = {}
Player.__type = "Player"

--keyboard stuff (based on smbx2) (thanks to mrdoublea!!!)
KEYS_UP = false
KEYS_RELEASED = nil
KEYS_DOWN = true
KEYS_PRESSED = 1

local keysMT = {
	__index = (function(self,key)
		local last = self._last[key]
		local now = self._now[key]

		if not last and not now then
			return KEYS_UP
		elseif last and not now then
			return KEYS_RELEASED
		elseif not last and now then
			return KEYS_PRESSED
		else
			return KEYS_DOWN
		end
	end),
	__newindex = (function(self,key,value)
		self._now[key] = (not not value)
	end),
}

function newControls()
	local keys = {}

	keys._last = {}
	keys._now = {}

	setmetatable(keys,keysMT)

	return keys
end


local inputs = {"up","right","down","left","jump","run","altJump","altRun","pause","dropItem"}

-- TODO: replace this entirely
local inputConfig = {
	up = "up",
	right = "right",
	down = "down",
	left = "left",
	jump = "z",
	run = "x",
	altJump = "a",
	altRun = "s",
	pause = "escape",
	dropItem = "rshift",
}
	
function Player.spawn(x, y)
	local v = {}
	
	v.idx = #Player + 1
	v.isValid = true
	
	v.character = 1
	v.x = x
	v.y = y
	v.width = 32
	v.height = 32
	v.speedX = 0
	v.speedY = 0
	v.direction = 1
	
	v.nogravity = false
	
	v.isSpinjumping = false
	v.jumpForce = 0
	v.sliding = false
	
	v.slope = 0
	
	v.keys = newControls()
	v.rawKeys = newControls()
	
	setmetatable(v, {__index = Player})
	Player[#Player + 1] = v
	return v
end

local function updateKeys(keys,inputConfig)
	for _,name in ipairs(inputs) do
		keys._last[name] = keys._now[name]
		keys._now[name] = love.keyboard.isDown(inputConfig[name])
	end
end

function Player:onControl()
	updateKeys(self.rawKeys,inputConfig)
	updateKeys(self.keys,inputConfig)
end

function Player:onPhysics(dt)
	local v = self

	-- Direction stuff
	if v.keys.left then
		v.direction = -1
	elseif v.keys.right then
		v.direction = 1
	end
	
	-- Walking/running
	local walkDirection = (v.keys.left and -1) or (v.keys.right and 1) or 0

	local speedModifier = 1

	local walkSpeed = Defines.player_walkspeed*speedModifier
	local runSpeed = Defines.player_runspeed*speedModifier

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
	
	-- Jumping
	if v.keys.jump or v.keys.altJump then
		if v.sliding then v.sliding = false end
		
		if (v.keys.jump == KEYS_PRESSED or v.keys.altJump == KEYS_PRESSED) and v.collidesBlockBottom then
			v.y = v.y - 1
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
	
	-- gravity and etc
	if not v.nogravity then
		v.speedY = math.min(v.speedY + (v.gravity or Defines.player_grav), v.maxgravity or Defines.gravity)
	end
	
	Collision.update(v)
end

function Player:render(args)
	local v = self
	local args = args or {}
	
	Graphics.box{
		width = v.width,
		height = v.height,
		x = v.x,
		y = v.y,
		
		scene = (args.scene == nil and true) or args.scene,
	}
end

function Player.onDrawInternal()
	for k,v in ipairs(Player) do
		v:render()
	end
end

function Player.onInputUpdateInternal()
	for k,v in ipairs(Player) do
		v:onControl()
	end
end

function Player.onTickInternal()
	local dt = deltaTime
	
	for k,v in ipairs(Player) do
		v:onPhysics(dt)
	end
end

function Player.onInit()
	registerFunction(Player, 'onDrawInternal')
	registerFunction(Player, 'onTickInternal')
	registerFunction(Player, 'onInputUpdateInternal')
end

return Player