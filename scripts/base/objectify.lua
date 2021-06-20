local mt = {}

function mt.__call(self, id, id2)
	if not id2 then
		return self[id]
	else
		local ret = {}
		
		for i = id, id2 do
			ret[#ret + 1] = self[i]
		end
		
		return ret
	end
end

_G.Objectify = function(t)
	local obj = t or {}
	local fileds = {}
	
	for k,v in pairs(t.fields) do
		fields[k] = v
	end
	
	function obj.new(arg)
		local v = t.fields
		
		for k,val in pairs(arg) do
			v[k] = val
		end
		
		return v
	end
	
	setmetatable(obj, mt)
	return obj
end