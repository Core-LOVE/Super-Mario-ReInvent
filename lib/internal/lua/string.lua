do
	local upperCase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	local lowerCase = "abcdefghijklmnopqrstuvwxyz"
	local numbers = "0123456789"	
	local symbols = "!@#$%&()*+-,./" .. [[\]] .. ":;<=>?^[]{}"
	
	local allCase = upperCase .. lowerCase .. numbers .. symbols
	
	function string.randomchar(at)
		if type(at) == 'boolean' then
			local rand = math.random(#upperCase)
			
			return string.sub(upperCase, rand, rand)
		elseif type(at) == 'string' then
			local limit = string.find(allCase, at)
			local rand = math.random(limit)
			
			return string.sub(allCase, rand, rand)
		elseif type(at) == 'table' then
			return table.irandom(at)
		else
			local rand = math.random(#allCase)
			
			return string.sub(allCase, rand, rand)
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

--TOTALLY DIDN'T TAKE IT FROM SMBX2
local string_byte = string.byte
local string_sub = string.sub
local string_gsub = string.gsub
local table_insert = table.insert
	
--Trim trailing and leading whitespace
function string.trim(s)
	return string_gsub(s, "^%s*(.-)%s*$", "%1")
end

--Split a string on a pattern into a table of strings
function string.split(s, p, exclude, plain)
	if  exclude == nil  then  exclude = false; end;
	if  plain == nil  then  plain = true; end;

	local t = {};
	local i = 0;
   
	if(#s <= 1) then
		return {s};
	end
   
	while true do
		local ls,le = s:find(p, i, plain);	--find next split pattern
		if (ls ~= nil) then
			table_insert(t, string_sub(s, i,le-1));
			i = ls+1;
			if  exclude  then
				i = le+1;
			end
		else
			table_insert(t, string_sub(s, i));
			break;
		end
	end
	
	return t;
end

--Compare two strings
function string.compare(left, right)
	if left == right then
		return 0
	else
		local i = 1
		while true do
			local a = string_byte(left, i)
			local b = string_byte(right, i)
			if b == nil then --left is longer than right
				return 1
			elseif a == nil then --right is longer than left
				return -1
			elseif a > b then --left is lexically greater than right
				return 1
			elseif b > a then --right is lexically greater than left
				return -1
			end
			i = i + 1
		end
	end
end