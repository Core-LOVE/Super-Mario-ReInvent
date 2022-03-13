local npc = {}
local id = NPC_ID

NPC.setHarmTypes(id, 
	{
		[HARM_TYPE_JUMP] = true,
	}
)

local function animation(v)
	if v.collidesBlockBottom then    
		if(v.frameTimer >= 8) then
			v.frameTimer = 0
			v.frame = v.frame + 1
			if(v.frame >= 2) then
				v.frame = 0
			end
		end
	else
		if(v.frameTimer >= 4) then
			v.frameTimer = 0
			if(v.frame == 0) then
				v.frame = 2
			elseif(v.frame == 1) then
				v.frame = 3
			elseif(v.frame == 2) then
				v.frame = 1
			elseif(v.frame == 3) then
				v.frame = 0
			end
		end
	end
end

function npc.onNPCInit(v, data)
	if v.id ~= id then return end
	
	data.timer = 0
end

function npc.onNPCKill(e, v, r)
	if v.id ~= id then return end
	
	local n = NPC.spawn(2, v.x, v.y)
	n.dontMove = v.dontMove
end

function npc.onTickInternalNPC(v)
	local data = v.data
	animation(v)
	
	if not v.collidesBlockBottom then return end

	if data.timer <= 30 then
		data.timer = data.timer + 1
	elseif data.timer == 31 or data.timer == 32 or data.timer == 33 then
		data.timer = data.timer + 1
		v.speedY = -4
	elseif data.timer == 34 then
		v.speedY = -7
		data.timer = 0
	end	
end

function npc.onInit()
	registerEvent(npc, 'onNPCKill')
	registerEvent(npc, 'onNPCInit')
	registerNPCEvent(id, npc, 'onTickInternalNPC')
end

return npc