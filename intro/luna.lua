--------------------------------------------------
-- Level code
-- Created 19:34 2022-2-28
--------------------------------------------------

-- Run code on level start
function onStart()

end

-- Run code every frame (~1/65 second)
-- (code will be executed before game logic will be processed)
function onTick()
	for k,v in ipairs(NPC.get(1)) do
		Text.print(v.speedX, 10, 10)
	end
end

-- Run code when internal event of the SMBX Engine has been triggered
-- eventName - name of triggered event
function onEvent(eventName)
    --Your code here
end

