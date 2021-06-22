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

	function obj.new(arg)
		local fields = {}
		
		if t.fields then
			for k,v in pairs(t.fields) do
				fields[k] = v
			end
		end
	
		local v = fields
		
		for k,val in pairs(arg) do
			v[k] = val
		end
		
		setmetatable(v, {__index = obj})
		return v
	end
	
	setmetatable(obj, mt)
	return obj
end