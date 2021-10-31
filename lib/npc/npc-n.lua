local npc = {}
local id = NPC_ID

NPC.setSettings{
	id = id,
	
	frames = 1,
	framespeed = 6,
	
	noharm = true,
}

NPC.setHarmTypes(id,
	{
		HARM_TYPE_LAVA
	},
	{
		[HARM_TYPE_LAVA] = 10
	},
)

function npc.onTickEndNPC(v)
	if v.collidesBlockBottom then
		v.speedY = -6
	end
end

function npc.onInit()
	registerNPCFunction(id, npc, 'onTickEndNPC')
end

return npc