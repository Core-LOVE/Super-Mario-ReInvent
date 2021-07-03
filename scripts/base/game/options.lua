local options = {}

function options.new(parent)
	local v = {}
	
	v.cursor = 0
	v.parent = parent
	v.delay = 0
	v.maxDelay = 8
	v.locked = false
	
	if parent then
		v.delay = v.maxDelay
	end
	
	setmetatable(v, {__index = options})
	return v
end

function options:add(option)
	-- option must be an table!!
	option.disabled = option.disabled or false
	
	self[#self + 1] = option
	return option
end

function options:moveUp()
	if self.delay > 0 or self.locked then return end
	
	Sound.play(26)
	
	self.cursor = self.cursor - 1
	if self.cursor < 0 then
		self.cursor = #self - 1
	end
	
	self.delay = self.maxDelay
end

function options:moveDown()
	if self.delay > 0 or self.locked then return end
	
	Sound.play(26)
	
	self.cursor = (self.cursor + 1) % #self 
	
	self.delay = self.maxDelay
end

function options:assign(keyUp, keyDown, keyPress, keyBack)
	if keyUp then
		self:moveUp()
	end
	
	if keyDown then
		self:moveDown()
	end
	
	if keyPress then
		self:press()
	end
	
	if keyBack then
		self:back()
	end
end

function options:press()
	if self.delay > 0 or self.locked then return end
	
	Sound.play(14)
	
	local v = self[self.cursor + 1]
	
	if type(v.onPress) == 'function' then
		v.onPress()
	end
	
	self.delay = self.maxDelay
end

function options:update()
	if self.delay > 0 then
		self.delay = self.delay - 1
	end
	
	if type(self.onUpdate) == 'function' then
		self.onUpdate()
	end
end

function options:back()
	if self.delay > 0 or self.locked then return end
	
	if self.parent then
		Sound.play(26)
		
		if type(self.onBack) == 'function' then
			self.onBack()
		end
		
		for k,_ in pairs(self) do
			if k ~= 'parent' then
				self[k] = nil
			end
		end
		
		for k,v in pairs(self.parent) do
			self[k] = v
		end
		
		self.delay = self.maxDelay
		return
	end
end

function options:draw(x, y)
	local cursor_o = 1
	if self.locked then
		cursor_o = 0.75
	end
		
	Graphics.draw{
		image = Graphics.sprites.ui['MCursor0'].img,
		x = x - 24,
		y = y + 30 * self.cursor,
		opacity = cursor_o,
		priority = RENDER_PRIORITY.HUD,
	}
	
	for k,v in ipairs(self) do
		local o = 1
		if v.disabled then
			o = 0.75
		end

		Text.print(v.name, x, y + 30 * (k - 1), 3, RENDER_PRIORITY.HUD + 1, o)
	end
end

return options