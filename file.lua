local File = {
	_NAME = "File",
	_VERSION = 1.0,
	_DESCRIPTION = "A library for handling absolute filepaths :)",
	
	_LICENSE = 'MIT license',
}

local love = love

local lfs
local lfs_isFused
local lfs_getSource
local lfs_getSourceBaseDirectory
local lfs_createDirectory
local lfs_getSaveDirectory
local lfs_getRequirePath
local lfs_newFileData
local lfs_remove
local lfs_newFile

local lg
local lg_newImage
local lg_newFont
local lg_newVideo

local li
local li_newImageData

local la
local la_newSource

local ls
local ls_newSoundData

local io = io
local string = string
local package = package
local assert = assert
local pcall = pcall
local load = load or loadstring
assert(io ~= nil, "Can't use File class without Lua's I/O module!")

local ioOpen = io.open
local ioLines = io.lines

local gmatch = string.gmatch
local match = string.match
local gsub = string.gsub

local packagePath = package.path
local packageLoaded = package.loaded

if love then -- if you love2d
	lfs = love.filesystem
	lg = love.graphics
	la = love.audio
	ls = love.sound
	li = love.image
	
	if lfs then
		lfs_newFile = lfs.newFile
		lfs_isFused = lfs.isFused
		lfs_getSource = lfs.getSource
		lfs_getSourceBaseDirectory = lfs.getSourceBaseDirectory
		lfs_createDirectory = lfs.createDirectory
		lfs_getSaveDirectory = lfs.getSaveDirectory
		lfs_getRequirePath = lfs.getRequirePath
		lfs_newFileData = lfs.newFileData
		lfs_remove = lfs.remove
	end
	
	if lg then
		lg_newImageData = lg.newImageData
		lg_newImage = lg.newImage
		lg_newFont = lg.newFont
		lg_newVideo = lg.newVideo
	end
	
	if li then
		li_newImageData = li.newImageData
	end
	
	if la then
		la_newSource = la.newSource
	end
	
	if ls then
		ls_newSoundData = ls.newSoundData
	end
end

do -- As default search path it will use love2d project default folder... if you're using love2d of course
	local gamePath

	if lfs then
		if lfs_isFused() then
			gamePath = lfs_getSourceBaseDirectory()
		else
			gamePath = (lfs_getSource() .. '/')
		end
	end
	
	File.path = {gamePath}
end

function File.resolve(name, mode) -- it will search through File.path table and return found path (if it was found of course he he)
	local mode = mode or 'r'
	
	do
		local file = ioOpen(name, mode)
		
		if file then
			file:close()
			
			return name
		end
	end
	
	local path = File.path
	
	for key = 1, #path do
		local searchPath = (path[key] .. name)
		local found = ioOpen(searchPath, mode)
		
		if found ~= nil then
			found:close()
			
			return searchPath
		end
	end
end
File.find = File.resolve

function File.open(name, mode) -- basically this works as normal io.open, except it also can search in File.path table
	assert(name ~= nil, "Specify file's name you want to find!")
	local ok, chunk = pcall(ioOpen, name, mode or 'r')
	
	if (ok and chunk ~= nil) then return chunk end
	
	local foundPath = File.resolve(name)
	
	if foundPath == nil then
		return
	end
	
	return ioOpen(foundPath, mode)
end

function File.rawOpen(name, mode) -- opens, but does not search...
	assert(name ~= nil, "Specify file's name you want to find!")
	
	return ioOpen(foundPath, mode)
end

function File.read(name, m) -- if you just want to read content
	local m = (m or "*all")
	
	local file = File.open(name)
	local content = file:read(m)
	
	file:close()
	return content
end

function File.write(name, ...) -- if you just want to write
	local file = File.open(name)
	file:write(...)
	file:close()
end


function File.lines(name)
	assert(name ~= nil, "Specify file's name you want to find!")
	local ok, chunk = pcall(ioLines, name, mode or 'r')
	
	if (ok and chunk ~= nil) then return ioLines(name) end
	
	local foundPath = File.resolve(name)
	
	if foundPath == nil then
		return
	end
	
	return ioLines(foundPath)	
end

function File.rawLines(name)
	assert(name ~= nil, "Specify file's name you want to find!")
	
	return ioLines(name)
end

function File.copy(path, dest) -- method taken from lovefs lol
	local inp = ioOpen(path, "rb")
	local out = ioOpen(dest, "wb")
	
	local data = inp:read("*all")
	
	out:write(data)
	
	out:close()
	inp:close()
end

function File.getName(file)
	return match(file, "[^/]*$")
end

function File.getNameExtension(fileName)
	return match(fileName, "([^/]-([^.]+))$")
end

function File.getExtension(fileName)
	return match(fileName, "[^.]+$")
end

function File.loadFile(path)
	local content = File.read(path)

	-- this error handling MUST BE improved
	local status, message = pcall(function()
		assert(load(content))
	end)
	
	if not status then
		assert(nil, File.getName(path) .. ': ' .. message)
	end
	
	return load(content)
end

function File.doFile(path)
	local file = File.loadFile(path)
	
	return file()
end

function File.require(path) -- yeah..... also it supports package.path (or love.filesystem.getRequirePath)
	local packagePath = (lfs and lfs_getRequirePath()) or packagePath
	
	if not packageLoaded[path] then
		local realPath
		
		for searchPath in gmatch(gsub(packagePath, '?', path), "[^%;]+") do
			realPath = File.resolve(searchPath)
			
			if realPath then break end
		end
		
		local lib = File.doFile(realPath)
		
		packageLoaded[path] = lib
	end
	
	return packageLoaded[path]
end

if love == nil then return File end

--	LOVE2D ONLY --
local gifnew = require("gifload") -- for loading gif files

local function loadGif(path)
	local gifFile = ioOpen(path, 'rb')
	
	if not gifFile then
		return nil
	end
	
	local gif = gifnew()

	repeat
		local s = gifFile:read(65536)
		
		if s == nil or s == "" then
			break
		end

		gif:update(s)
	until false

	gifFile:close()

	return gif:done()
end

local function define(f, imageRelated, imageData)
	local File = File
	local copy = File.copy
	local f = f
	
	return function(path, ...)
		local foundPath = File.resolve(path, 'rb')

		if imageRelated then
			if File.getExtension(foundPath, 'rb') == 'gif' then
				local file = loadGif(foundPath)
				local imgData = file:frame(0)
				
				if imageData then
					return imgData
				end
				
				return lg_newImage(imgData)
			end
		end
		
		-- lfs_createDirectory('lovefs_temp')
		copy(foundPath, lfs_getSaveDirectory() ..'/temp.f')
		-- lfs_remove('lovefs_temp')
		return f('temp.f', ...)
	end
end

File.newImage = define(lg_newImage, true)
File.newImageData = define(li_newImageData, true, true)
File.newSource = define(la_newSource)
File.newSoundData = define(ls_newSoundData)
File.newFont = define(lg_newFont)
File.newVideo = define(lg_newVideo)
File.newFileData = define(lfs_newFileData)

return File