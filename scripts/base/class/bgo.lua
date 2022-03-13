local BGO = {}

local BGOFrame = {}
local BGOFrameTimer = {}

local configuration = require 'config'
BGO.config = configuration.new('background', {
	width = 32,
	height = 32,
	
	frames = 1,
	framespeed = 8,
	climbable = false,
	npcclimbable = false,
	foreground = false,
	priority = nil,
	water = false,
	stoponfreeze = false,
	dooreffect = 0,
})

function BGO.spawn(id, x, y)
	local v = {}
	
	local cfg = BGO.config[id]
	
	BGOFrame[id] = BGOFrame[id] or 0
	BGOFrameTimer[id] = BGOFrameTimer[id] or 0
	
	v.id = id
	v.x = x
	v.y = y
	v.width = cfg.width
	v.height = cfg.height
	
	setmetatable(v, {__index = BGO})
	BGO[#BGO + 1] = v
	return v
end

function isColliding(a,b)
   return not (((b.x >= a.x + a.width) or
	   (b.x + b.width <= a.x) or
	   (b.y >= a.y + a.height) or
	   (b.y + b.height <= a.y)))
end

function BGO:render(args, c)
	local v = self or {}
	local arg = args or {}
	
	if v.isHidden then return end
	
	local c = (c or camera)
	
	if not isColliding(v, c) then return end
	
	arg.id = arg.id or v.id
	local id = args.id

	local img = Graphics.sprites.background[id]
	
	if not img then return end
	
	local config = BGO.config[id]
	
	arg.x = arg.x or v.x
	arg.y = arg.y or v.y
	
	arg.priority = arg.priority or (config.priority) or (config.foreground and RENDER_PRIORITY.FOREGROUND_BGO) or RENDER_PRIORITY.BGO

	arg.opacity = arg.opacity or 1
	arg.sceneCoords = arg.sceneCoords or true

	Graphics.draw{
		image = img,
		
		x = arg.x, 
		y = arg.y,
		
		sourceY = v.height * BGOFrame[id],
		sourceHeight = v.height,	
		sourceWidth = v.width,
		
		-- priority = arg.priority,
		-- opacity = arg.opacity,
		sceneCoords = arg.sceneCoords
	}
end

function BGO.onDrawInternal(c)
	for k = 1, #BGO do
		BGO.render(BGO[k], {}, c)
	end
end

function BGO.onTickInternal()
	for id,val in pairs(BGOFrameTimer) do
		local cfg = BGO.config[id]

		if cfg.frames ~= 0 then
			BGOFrameTimer[id] = BGOFrameTimer[id] + Engine.speed
			
			if BGOFrameTimer[id] >= cfg.framespeed then
				BGOFrame[id] = BGOFrame[id] + 1
				
				if BGOFrame[id] >= cfg.frames then
					BGOFrame[id] = 0
				end
				
				BGOFrameTimer[id] = 0
			end
		end
	end
end

function BGO.onInit()
	registerEvent(BGO, 'onTickInternal')
	registerEvent(BGO, 'onDrawInternal')
end

return BGO