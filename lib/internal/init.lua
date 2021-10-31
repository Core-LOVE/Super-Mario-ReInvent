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
Camera.type = CAMTYPE.HORZ1

--window
-- Window = require 'lib/internal/window'

function onGlobalDraw()
	libManager.callEvent('onDraw')
end

function onGlobalTick(dt)
	libManager.callEvent('onTick', dt)
end