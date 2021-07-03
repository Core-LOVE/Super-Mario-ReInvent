local keys = {}
-- Some stuff should be reworked later!! ._.

keys.player = {}

keys.player[1] = {
	left = 'left',
	right = 'right',
	down = 'down',
	up = 'up',

	jump = 'z',
	altJump = 'a',
	run = 'x',
	altRun = 's',
	
	pause = "escape",
	dropItem = "rshift",
}

keys.player[2] = {
	
}

keys.pressed = {key = '', scancode = '', isrepeat = false, delay = 0}

function keys.isDown(key, plr)
	local plr = plr or 1
	
	if plr == 1 then
		return love.keyboard.isDown(keys.player[plr][key])
	else
		local n = love.joystick.getJoystickCount()
		
		if n > 0 then
			local j = love.joystick.getJoysticks()[1]
			
			return j:isGamepadDown(keys.player[plr][key])
		end
	end
end

_G.Keys = keys