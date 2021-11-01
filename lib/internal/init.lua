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

--parser
ini = require 'parser/ini'
txt = require 'parser/txt'

--important
libManager = require('internal/libManager')

--engine
require 'run'
Engine = require('engine')
Defines = require('defines')
Graphics = require('graphics/graphics')

--classes and etc
Camera = require("class/camera")
--Camera.type = CAMTYPE.HORZ1 --purely for testing purposes
NPC = require("class/npc")
Block = require("class/block")

local v = NPC.spawn(1, 0, 0)

Block.spawn(1, 0, 96)

function onGlobalDraw()
	libManager.callEvent('onDraw')
	libManager.callEvent('onDrawEnd')
	
	for k,v in ipairs(Camera) do
		libManager.callEvent('onCameraDraw', v)
		libManager.callEvent('onHUDDraw', v)
	end
end

function onGlobalTick(dt)
	local fps = 1 / Engine.FPS
	Engine.buffer = Engine.buffer + dt
	
	if Engine.buffer > fps then
		Engine.buffer = Engine.buffer - fps
	else
		return
	end
	
	libManager.callEvent('onTick', dt)
	libManager.callEvent('onTickEnd', dt)
	
	for k,v in ipairs(Camera) do
		libManager.callEvent('onCameraUpdate', v)
	end
end