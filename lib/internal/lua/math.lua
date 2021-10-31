function math.randomdec(...)
	return math.random(...) + math.random()
end

math.noise = love.math.noise

function math.clamp(a, b, c)
	-- MrDoubleA, please don't kill me, this is the most perfomant way to clamp ._.
	
	return (a < b and b < c and b) or (c < b and b < a and b) or (a < b and c < b and c) or (b < a and a < c and a) or c
end


function math.lerp(a,b,t) 
	return a + (b-a) * 0.5 * t 
end

function math.sign(n)
	return (n > 0 and 1) or (n == 0 and 0) or -1
end

function math.type(n)
	if type(n) ~= 'number' or n == nil then return end
	
	if n == math.floor(n) then
		return 'integer'
	else
		return 'float'
	end
end

function math.round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

function math.tointeger(x)
    num = tonumber(x)
    return num < 0 and math.ceil(num) or math.floor(num)
end

--TOTALLY DIDN'T TAKE IT FROM LOVE2D WIKI

-- Returns the distance between two points.
function math.dist(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end

-- Distance between two 3D points:
function math.dist3d(x1,y1,z1, x2,y2,z2) return ((x2-x1)^2+(y2-y1)^2+(z2-z1)^2)^0.5 end

-- Averages an arbitrary number of angles (in radians).
function math.averageAngles(...)
	local x,y = 0,0
	for i=1,select('#',...) do local a= select(i,...) x, y = x+math.cos(a), y+math.sin(a) end
	return math.atan2(y, x)
end

-- Returns the angle between two vectors assuming the same origin.
function math.angle(x1,y1, x2,y2) return math.atan2(y2-y1, x2-x1) end

-- Returns the closest multiple of 'size' (defaulting to 10).
function math.multiple(n, size) size = size or 10 return math.round(n/size)*size end

--TOTALLY DIDN'T TAKE IT FROMN SMBX2

--interpolates between 0 and 360, wrapping around the ends
function math.anglelerp(a,b,t)
	local v = (b - a) % 360;
	return a + (((2*v) % 360) - v)*t;
end

function math.invlerp(a,b,v)
	if(type(a) ~= type(b) or type(a) ~= type(v) or (type(a) == "table" and (a.__type ~= b.__type or a.__type ~= v.__type))) then
		error("Types must match when performing an inverse lerp.", 2)
	end
	local v1 = b-a;
	local v2 = v-a;
	if(type(v1) ~= "number") then
		
		--Color or Vector
		local t1 = 0
		local t2 = 0
		
		for k,v in ipairs(v1) do
			t1 = t1 + v
			t2 = t2 + v2[k]
		end
		
		v1 = t1
		v2 = t2
		
	end
	
	return (v2/v1);
end