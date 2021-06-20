rawPrint = print
print = function(...)
	if debug then
		return rawPrint(...)
	end
end