Text = {}

Text.print = function(str, x, y, typ, opacity)
	local str = str or ""
	str = tostring(str)
	
	local x = x or 0
	local y = y or 0
	local typ = typ or 3
	local opacity = opacity or 1
	
	local B = 0
	local C = 0
	
	if typ == 3 then
		local img = Graphics.sprites.ui['Font2_2'].img
		local str = str:upper()
		
		for cs = 1, #str do
			local c = string.sub(str, cs, cs)
			c = c:byte()
			
            if(c >= 33 and c <= 126) then
                C = (c - 33) * 32
				
				Graphics.draw{
					image = img, 
					x = x + B, 
					y = y, 
					sourceX = 2, 
					sourceY = C, 
					sourceWidth = 18, 
					sourceHeight = 16, 
					priority = RENDER_PRIORITY.TEXT,
					opacity = opacity,
				}
				
                B = B + 18
                if(c == 'M') then
                    B = B + 2
				end
            else
                B = B + 16
            end
		end
	elseif typ == 0 then
		for cs = 1, #str do
			local c = string.sub(str, cs, cs)
			local img = Graphics.sprites.ui['Font1_' .. c].img
				
			Graphics.draw{
				image = img, 
				x = x + B, 
				y = y, 
				priority = RENDER_PRIORITY.TEXT,
			}
			
			B = B + 18			
		end
	elseif typ == 5 then
		local img = Graphics.sprites.ui['Font2_5'].img
		local str = str:upper()
		
		for cs = 1, #str do
			local c = string.sub(str, cs, cs)
			c = c:byte()
			
            if(c >= 33 and c <= 126) then
                C = (c - 33) * 32
				
				Graphics.draw{
					image = img, 
					x = x + B, 
					y = y, 
					sourceX = 2, 
					sourceY = C, 
					sourceWidth = 18, 
					sourceHeight = 16, 
					priority = RENDER_PRIORITY.TEXT,
				}
                B = B + 18
                if(c == 'M') then
                    B = B + 2
				end
            else
                B = B + 16
            end
		end
	end
end