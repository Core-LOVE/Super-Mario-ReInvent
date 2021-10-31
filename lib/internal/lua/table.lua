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
	local t2 = table.deepCopy(t2)
	local nt = table.deepCopy(t1)
	
	for k,v in pairs(t2) do
		nt[k] = v
	end
	
	local mt1 = getmetatable(nt)
	local mt2 = getmetatable(t2)
	
	setmetatable(nt, table.merge(mt1, mt2))
	return nt
end

function table.ideepmerge(t1, t2)
	local t2 = table.deepCopy(t2)
	local nt = table.deepCopy(t1)
	
	for k,v in ipairs(t2) do
		nt[k] = v
	end
	
	local mt1 = getmetatable(nt)
	local mt2 = getmetatable(t2)
	
	setmetatable(nt, table.merge(mt1, mt2))
	return nt
end

--I TOTALLY DIDN'T TAKE IT FROM SMBX2............................
function table.ifindlast(t, val)
	for i = #t,1,-1 do
		if(t[i] == val) then
			return i;
		end
	end
	return nil;
end

function table.findlast(t, val)
	local lst = nil;
	for k,v in pairs(t) do
		if(v == val) then
			lst = k;
		end
	end
	return lst;
end

function table.ifind(t, val)
	for k,v in ipairs(t) do
		if(v == val) then
			return k;
		end
	end
	return nil;
end

function table.find(t, val)
	for k,v in pairs(t) do
		if(v == val) then
			return k;
		end
	end
	return nil;
end

function table.ifindall(t, val)
	local rt = {};
	for k,v in ipairs(t) do
		if(v == val) then
			table.insert(rt,k);
		end
	end
	return rt;
end

function table.findall(t, val)
	local rt = {};
	for k,v in pairs(t) do
		if(v == val) then
			table.insert(rt,k);
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
	
function table.ishuffle(t)
	for i=#t,2,-1 do 
		local j = rng.randomInt(1,i)
		t[i], t[j] = t[j], t[i]
	end
	return t
end

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
		table.insert(t2,k);
	end
	return t2;
end

function table.join(...)
	local ts = {...};
	local t = {};
	local ct = #ts;
	for i=ct,1,-1 do
		for k,v in pairs(ts[i]) do
			t[k] = v;
		end
	end
	return t;
end

function table.append(...)
	local ts = {...}
	local t = {};
	for _,t1 in ipairs(ts) do
		for _,v in ipairs(t1) do
			table.insert(t,v);
		end
	end
	return t;
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

function table.flatten(t)
	local t2 = {};
	for _,v in ipairs(t) do
		if(pcall(ipairs(v))) then
			for _,v2 in ipairs(v) do
				table.insert(t2, v2);
			end
		else
			table.insert(t2, v);
		end
	end
	return t2;
end
--TOTALLY

function table.get(t, k)
	return t[k]
end

function table.irandom(t, l, r)
	return t[math.random(l or 1, r or #t)]
end

function table.random(t, l, r)
	local choice
    local n = 0
	
    for i, o in pairs(t) do
        n = n + 1
        if math.random() < (1/n) then
            choice = o      
        end
    end
	
	if not choice then
		choice = table.randomn(t, l, r)
	end
	
    return choice 
end