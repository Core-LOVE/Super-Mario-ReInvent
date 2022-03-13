local npc = {}
local id = NPC_ID

local stompId = 6
local thrownId = 7

NPC.setHarmTypes(id, 
	{
		[HARM_TYPE_JUMP] = true,
	},
	{
		[HARM_TYPE_JUMP] = stompId,
	}
)

return npc