local options = {}

function options.new(parent)
	local v = {}
	
	v.cursor = 0
	v.parent = parent
	
	setmetatable(v, {__index = options})
	return v
end

function options:add(option)
	-- option must be an table!!
	option.disabled = option.disabled or false
	
	self[#self + 1] = option
end

function options:moveUp()
	local c = self[self.cursor - 1]
	
	if c then
		if c.disabled then
			self.cursor = self.cursor - 1
		end
	end
	
	self.cursor = self.cursor - 1
	if self.cursor < 0 then
		self.cursor = #self
	end
end

function options:moveDown()
	local c = self[self.cursor + 1]
	
	if c then
		if c.disabled then
			self.cursor = self.cursor + 1
		end
	end
	
	self.cursor = self.cursor + 1 
	self.cursor = self.cursor % #self
end

function options:press()
	local v = self[self.cursor + 1]
	
	if type(v.onPress) == 'function' then
		v.onPress()
	end
end

function options:back()
	local v = self[self.cursor]
	
	if v.parent then
		if type(v.onBack) == 'function' then
			v.onBack()
		end
		
		v = v.parent
	end
end

return options