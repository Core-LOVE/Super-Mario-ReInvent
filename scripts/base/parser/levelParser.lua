local levelParser = {}

local tonumber = tonumber

levelParser.format = {}

do
	local types = {}

	types['HEAD'] = function(settings)

	end

	types['SECTION'] = function(settings)
		local x = settings.L
		local y = settings.T
		
		local w = (settings.R - x)
		local h = (settings.B - y)
		
		print(w, h)
		local v = Section.new(x, y, w, h)
	end

	types['STARTPOINT'] = function(settings)
		local v = Player.spawn(1, settings.X, settings.Y)
		
		v.direction = settings.D
	end
	
	types['BLOCK'] = function(settings)
		local v = Block.spawn(settings.ID, settings.X, settings.Y)
		
		v.width = settings.W
		v.height = settings.H
	end

	types['NPC'] = function(settings)
		local v = NPC.spawn(settings.ID, settings.X, settings.Y)
		v.direction = settings.D
		v.dontMove = settings.NM or false
	end
	
	types['BGO'] = function(settings)
		local v = BGO.spawn(settings.ID, settings.X, settings.Y)
	end
	
	levelParser.format['lvlx'] = function(fileName)
		local type

		for line in File.rawLines(fileName) do
			local canParse = true
			
			if type == nil then
				type = line
				canParse = false
			else
				if line:match('END') then
					type = nil
				end
			end
			
			if not (type == nil or types[type] == nil) and canParse then	
				local settings = {}
				
				for key, val in line:gmatch("(%w+):([^%;]+)") do
					local val = val
					
					local tonum = tonumber(val)
					if (tonum ~= nil) then
						val = tonum
					end
					
					settings[key] = val
				end
				
				types[type](settings)
			end
		end
	end
end

function levelParser.parse(fileName)
	local format = File.getExtension(fileName)
	
	levelParser.format[format](fileName)
end

return levelParser