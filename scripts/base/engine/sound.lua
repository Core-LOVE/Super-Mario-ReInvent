local sound = {}

local cache = {sfx = {}, audio = {}}
local sfx_ini = nil

function sound.rawLoad(name, typ)
	return love.audio.newSource(name, typ or 'static')
end

function sound.load(name, typ)
	if not cache[name] then
		cache[name] = function()
			love.audio.newSource(name, typ or 'static')
		end
	end
	
	return cache[name]
end

function sound.loadAudio(name, typ)

end

function sound.play(name, typ)
	if type(name) == 'number' then
		local sfx = cache.sfx[name]()
		sfx:play()
	else
		local sfx = sound.load(name, typ)
		sfx:play()
	end
end

setmetatable(cache.sfx, {
	__index = function(self, key)
		if type(key) == 'number' then
			sfx_ini = sfx_ini or ini.load('config/sounds.ini')
			local sfx = 'sound/' .. sfx_ini['sound-' .. tostring(key)].file
			
			rawset(self, key, function()
				return sound.rawLoad(sfx)
			end)
			return rawget(self, key)
		end
	end
})

_G.Sound = sound