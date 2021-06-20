table.unpack = unpack

function table.pack(...)
	local t = {...}
	t.n = #t
	return t
end

function table.move(a1, f, e, t, a2)
	a2 = a2 or a1
	t = t + e

	for i = e, f, -1 do
		t = t - 1
		a2[t] = a1[i]
	end

	return a2
end