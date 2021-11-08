--loads lovefs for a while
require('lib/internal/filesystem/lovefs')
fs = lovefs()

--filesystem
File = require('lib/internal/filesystem/file')

--lua
utf8 = rawrequire 'utf8'
bit = rawrequire 'bit'
jit = rawrequire 'jit'
vector = require 'lua/vector'
require 'lua/table'
require 'lua/math'
require 'lua/string'
require 'lua/coroutine'
require 'lua/thread'
require 'lua/channel'

-- local t = thread.run[[
	-- print 'e'
-- ]]

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
Sprite = require('graphics/sprite')

--classes and etc
Background = require("class/background")
Section = require("class/section")
Section.spawn(0, 0, 1600, 1200)
Camera = require("class/camera")

-- Camera.type = CAMTYPE.VERT1 --purely for testing purposes
NPC = require("class/npc")
Block = require("class/block")

NPC.spawn(1, 0,0)

local time = Engine.getTime()

function onGlobalLoad()
	time = Engine.getTime()
end

function onGlobalDraw()
	local currentTime = Engine.getTime()
	if time <= currentTime then
		time = currentTime
	end
	
	love.timer.sleep(time - currentTime)
	
	libManager.callEvent('onDraw')
	libManager.callEvent('onDrawEnd')
	
	for k,v in ipairs(Camera) do
		libManager.callEvent('onCameraDraw', v)
		libManager.callEvent('onHUDDraw', v)
	end
end

function onGlobalTick(dt)
	local fps = 1 / Engine.FPS
	time = time + fps
	
	libManager.callEvent('onTick', dt)
	libManager.callEvent('onTickEnd', dt)
	
	local s = 3
	
	if love.keyboard.isDown('right') then
		camera.x = camera.x + s
	elseif love.keyboard.isDown('left') then
		camera.x = camera.x - s
	end
	
	if love.keyboard.isDown('up') then
		camera.y = camera.y - s
	elseif love.keyboard.isDown('down') then
		camera.y = camera.y + s
	end
	
	for k,v in ipairs(Camera) do
		libManager.callEvent('onCameraUpdate', v)
	end
end

function love.resize(w, h)
	libManager.callEvent('onWindowResize', w, h)
end