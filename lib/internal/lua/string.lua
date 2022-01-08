local stringsub = string.sub
local stringfind = string.find
local stringgsub = string.gsub
local random = math.random

do
	local upperCase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	local lowerCase = "abcdefghijklmnopqrstuvwxyz"
	local numbers = "0123456789"	
	local symbols = "!@#$%&()*+-,./" .. [[\]] .. ":;<=>?^[]{}"
	
	local allCase = upperCase .. lowerCase .. numbers .. symbols
	
	function string.randomchar(at)
		if type(at) == 'boolean' then
			local rand = random(#upperCase)
			
			return stringsub(upperCase, rand, rand)
		elseif type(at) == 'string' then
			local limit = stringfind(allCase, at)
			local rand = random(limit)
			
			return stringsub(allCase, rand, rand)
		elseif type(at) == 'table' then
			return table.irandom(at)
		else
			local rand = math.random(#allCase)
			
			return stringsub(allCase, rand, rand)
		end
	end
end

function string.random(len, t)
	local str = ""
	
	for k = 1, len do
		str = str .. string.randomchar(t)
	end
	
	return str
end

function string.explode(str, div)
    assert(type(str) == "string" and type(div) == "string", "invalid arguments")
    local o = {}
    while true do
        local pos1,pos2 = str:find(div)
        if not pos1 then
            o[#o+1] = str
            break
        end
        o[#o+1],str = str:sub(1,pos1-1),str:sub(pos2+1)
    end
    return o
end