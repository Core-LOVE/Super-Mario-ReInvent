local random = math.random
local floor = math.floor
local atan2 = math.atan2
local ceil = math.ceil
local cos = math.cos
local sin = math.sin

function math.randomdec(...)
	return random(...) + random()
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
	
	if n == floor(n) then
		return 'integer'
	else
		return 'float'
	end
end

function math.round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return floor(num * mult + 0.5) / mult
end

function math.tointeger(x)
    num = tonumber(x)
    return num < 0 and ceil(num) or floor(num)
end

--TOTALLY DIDN'T TAKE IT FROM LOVE2D WIKI

-- Returns the distance between two points.
function math.dist(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end

-- Distance between two 3D points:
function math.dist3d(x1,y1,z1, x2,y2,z2) return ((x2-x1)^2+(y2-y1)^2+(z2-z1)^2)^0.5 end

-- Averages an arbitrary number of angles (in radians).
function math.averageAngles(...)
	local x,y = 0,0
	for i=1,select('#',...) do local a= select(i,...) x, y = x+cos(a), y+sin(a) end
	return atan2(y, x)
end

-- Returns the angle between two vectors assuming the same origin.
function math.angle(x1,y1, x2,y2) return atan2(y2-y1, x2-x1) end

-- Returns the closest multiple of 'size' (defaulting to 10).
function math.multiple(n, size) size = size or 10 return math.round(n/size)*size end