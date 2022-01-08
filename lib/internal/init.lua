--loads lovefs for a while
require('lib/internal/filesystem/lovefs')
fs = lovefs()

--filesystem
File = require('lib/internal/filesystem/file')

--lua additions
vector = require 'lua/vector'
require 'lua/thread'
require 'lua/channel'
require 'lua/physics'

--lua
utf8 = rawrequire 'utf8'
bit = rawrequire 'bit'
jit = rawrequire 'jit'
require 'lua/table'
require 'lua/math'
require 'lua/string'
require 'lua/coroutine'

--parser
ini = require 'parser/ini'
txt = require 'parser/txt'

--important
libManager = require('internal/libManager')

--loadscreen stuff
loadscreen = require 'loadscreen'

--engine
require 'run'
Engine = require('engine')
Defines = require('defines')
Graphics = require('graphics/graphics')
Sprite = require('graphics/sprite')
Collision = require('collision/collision')
-- Collision.setSystem("classic")

--classes and etc
Background = require("class/background")
Section = require("class/section")
Section.spawn(0, 0, 1600, 1200)
Player = require("class/player")
Camera = require("class/camera")

-- Camera.type = CAMTYPE.VERT1 --purely for testing purposes
NPC = require("class/npc")
Block = require("class/block")

-- NPC.spawn(1, 208,0)

for x = 0, 512, 32 do
	print(x)
	
	Block.spawn(1, x, 512)
end

Block.spawn(305, 512 + 32, 512 - 32)
Block.spawn(305, 512 + 64, 512 - 64)

Player.spawn(0, 0)

function onGlobalLoad()
	libManager.callEvent('onLoad')
	libManager.callEvent('onStart')
end

function onGlobalDraw()
	libManager.callEvent('onDraw')
	
	for k,v in ipairs(Camera) do
		libManager.callEvent('onCameraDraw', v)
		libManager.callEvent('onHUDDraw', v)
	end
	
	libManager.callEvent('onDrawInternal')
	libManager.callEvent('onDrawEnd')
end
 
function onGlobalTick(dt)
	deltaTime = (dt * Engine.FPSCap) * Engine.speed 

	libManager.callEvent('onInputUpdateInternal')
	libManager.callEvent('onInputUpdate')
	
	libManager.callEvent('onTick')
	libManager.callEvent('onTickInternal')
	libManager.callEvent('onTickEnd')
	
	for k,v in ipairs(Camera) do
		libManager.callEvent('onCameraUpdate', v)
	end
	
	return true
end

function love.resize(w, h)
	libManager.callEvent('onWindowResize', w, h)
end