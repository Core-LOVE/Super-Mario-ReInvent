function math.clamp(a, b, c)
	-- MrDoubleA, please don't kill me, this is the most perfomant way to clamp ._.
	
	return (a < b and b < c and b) or (c < b and b < a and b) or (a < b and c < b and c) or (b < a and a < c and a) or c
end

function math.round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

function math.tointeger(x)
	return math.floor(x)
end

function math.type(x)
	if type(x) == 'number' then
		if math.floor(x) == x then
			print 'integer'
		else
			print 'float'
		end
	end
end

function math.ult(m, n)
	return (m < n)
end

math.maxinteger = 2147483647
math.mininteger = -math.maxinteger