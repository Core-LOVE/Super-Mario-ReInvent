--loads lovefs for a while
require('lib/internal/filesystem/lovefs')
fs = lovefs()

--filesystem
File = require('lib/internal/filesystem/file')

--lua
utf8 = rawrequire 'utf8'
bit = rawrequire 'bit'
vector = require 'lua/vector'
require 'lua/table'
require 'lua/math'
require 'lua/string'

--important
libManager = require('internal/libManager')

--engine
require 'run'
Graphics = require('graphics/graphics')

--classes and etc
Camera = require("class/camera")
Camera.type = CAMTYPE.HORZ1 --purely for testing purposes
NPC = require("class/npc")
NPC.spawn(1, 0, 0)
NPC.spawn(1, 32, 0)
NPC.spawn(1, 64, 0)
NPC.spawn(1, 96, 0)
NPC.spawn(1, 128, 0)
NPC.spawn(1, 160, 0)

function onGlobalDraw()
	libManager.callEvent('onDraw')
	libManager.callEvent('onDrawEnd')
	
	for k,v in ipairs(Camera) do
		libManager.callEvent('onCameraDraw', v)
		libManager.callEvent('onHUDDraw', v)
	end
end

function onGlobalTick(dt)
	libManager.callEvent('onTick', dt)
	libManager.callEvent('onTickEnd', dt)
	
	for k,v in ipairs(Camera) do
		libManager.callEvent('onCameraUpdate', v)
	end
end