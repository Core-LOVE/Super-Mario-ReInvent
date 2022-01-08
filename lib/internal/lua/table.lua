function table.copy(t)
	local nt = {}
	
	for k,v in pairs(t) do
		nt[k] = v
	end
	
	return nt
end

function table.icopy(t)
	local nt = {}
	
	for k,v in ipairs(t) do
		nt[k] = v
	end
	
	return nt
end

table.clone = table.copy
table.iclone = table.icopy

function table.deepcopy(t)
	local nt = { }
	
	for k,v in pairs(t) do nt[k] = v end
	
	setmetatable(nt, getmetatable(t))
	return nt
end

function table.ideepcopy(t)
	local nt = { }
	
	for k,v in ipairs(t) do nt[k] = v end
	
	setmetatable(nt, getmetatable(t))
	return nt
end

table.deepclone = table.deepcopy
table.ideepclone = table.ideepcopy

function table.merge(t1, t2)
	local t2 = table.copy(t2)
	local nt = table.copy(t1)
	
	for k,v in pairs(t2) do
		nt[k] = v
	end
	
	return nt
end

function table.imerge(t1, t2)
	local t2 = table.copy(t2)
	local nt = table.copy(t1)
	
	for k,v in ipairs(t2) do
		nt[k] = v
	end
	
	return nt
end

function table.deepmerge(t1, t2)
	local t2 = table.deepcopy(t2)
	local nt = table.deepcopy(t1)
	
	for k,v in pairs(t2) do
		nt[k] = v
	end
	
	local mt1 = getmetatable(nt) or {}
	local mt2 = getmetatable(t2) or {}
	
	setmetatable(nt, table.merge(mt1, mt2))
	return nt
end

function table.ideepmerge(t1, t2)
	local t2 = table.deepcopy(t2)
	local nt = table.deepcopy(t1)
	
	for k,v in ipairs(t2) do
		nt[k] = v
	end
	
	local mt1 = getmetatable(nt) or {}
	local mt2 = getmetatable(t2) or {}
	
	setmetatable(nt, table.merge(mt1, mt2))
	return nt
end

function table.find(t, val)
	for k,v in pairs(t) do
		if(v == val) then
			return k;
		end
	end
	return nil;
end

function table.ifind(t, val)
	for k,v in ipairs(t) do
		if(v == val) then
			return k;
		end
	end
	return nil;
end

local tableinsert = table.insert

function table.findall(t, val)
	local rt = {};
	for k,v in pairs(t) do
		if(v == val) then
			tableinsert(rt,k);
		end
	end
	return rt;
end

function table.ifindall(t, val)
	local rt = {};
	for k,v in ipairs(t) do
		if(v == val) then
			tableinsert(rt,k);
		end
	end
	return rt;
end

function table.icontains(t, val)
	return table.ifind(t, val) ~= nil;
end

function table.contains(t, val)
	return table.find(t, val) ~= nil;
end

local random = math.random
	
function table.map(t)
	local t2 = {};
	for _,v in ipairs(t) do
		t2[v] = true;
	end
	return t2;
end

function table.unmap(t)
	local t2 = {};
	for k,_ in pairs(t) do
		tableinsert(t2,k);
	end
	return t2;
end

function table.reverse(t)
	local len = 0
	for k,_ in ipairs(t) do
		len = k
	end
	local rt = {}
	for i = 1, len do
		rt[len - i + 1] = t[i]
	end
	return rt
end

function table.irandom(t, l, r)
	return t[random(l or 1, r or #t)]
end

function table.random(t, l, r)
	local choice
    local n = 0
	
    for i, o in pairs(t) do
        n = n + 1
        if random() < (1/n) then
            choice = o      
        end
    end
	
	if not choice then
		choice = table.randomn(t, l, r)
	end
	
    return choice 
end

function table.get(t, arg2)
	local ret = {}
		
	if type(arg2) == 'function' then
		for k,v in pairs(t) do
			if arg2(v) then
				ret[#ret + 1] = v
			end
		end
	elseif type(arg2) == 'table' then
		for k,v in pairs(t) do
			local condition = false
			
			for k2,v2 in pairs(arg2) do
				if v[k2] == v2 then
					condition = true
				else
					condition = false
				end
			end
			
			if condition then
				ret[#ret + 1] = v
			end
		end
	else
		for k,v in pairs(t) do
			ret[#ret + 1] = v
		end
	end
	
	return ret
end

function table.iget(t, arg2)
	local ret = {}
		
	if type(arg2) == 'function' then
		for k,v in ipairs(t) do
			if arg2(v) then
				ret[#ret + 1] = v
			end
		end
	elseif type(arg2) == 'table' then
		for k,v in ipairs(t) do
			local condition = false
			
			for k2,v2 in pairs(arg2) do
				if v[k2] == v2 then
					condition = true
				else
					condition = false
				end
			end
			
			if condition then
				ret[#ret + 1] = v
			end
		end
	else
		for k,v in ipairs(t) do
			ret[#ret + 1] = v
		end
	end
	
	return ret
end

-- local function iterate(t, args, i)
	-- while (i <= args[1]) do
		-- local v = t[i]
	-- end
-- end

-- function table.iterate(t, arg2)

-- end