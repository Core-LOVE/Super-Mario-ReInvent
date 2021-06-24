local hud = {}

hud.itembox = {
	x = 0, 
	y = 0,
	priority = RENDER_PRIORITY.HUD,

	image = Graphics.sprites.ui['Container0'].img,
	visible = true
}
hud.livecount = {
	x = 0,
	y = 0,
	priority = RENDER_PRIORITY.HUD,
	
	image = Graphics.sprites.ui['Interface3'].img,
	visible = true,
	
	value = function()
		return Game.lives
	end
}
hud.coincount = {
	x = 0,
	y = 0,
	priority = RENDER_PRIORITY.HUD,
	
	image = Graphics.sprites.ui['Interface2'].img,
	visible = true,
	
	value = function()
		return Game.coins
	end
}
hud.scorecount = {
	x = 0,
	y = 0,
	priority = RENDER_PRIORITY.HUD,
	
	visible = true,
	
	value = function()
		return Game.score
	end
}

local function count(i, x, y)
	Graphics.draw{
		image = Graphics.sprites.ui['Interface1'].img,
		x = x,
		y = y,
	}
	
	Text.print(i, x + 22, y, 0)
end

local function draw_liveCount()
	local i = hud.livecount
	
	if not i.visible then return end
	
	local t = {
		x = i.x,
		y = i.x,
		priority = i.priority,
		
		image = i.image
	}
	local x = 166
	
	t.x = t.x + (camera.width / 2) - x
	t.y = t.y + 26
	
	Graphics.draw(t)
	count(tostring(i.value()), t.x + (t.image.width * 2) + 8, t.y + 1)
end

local function draw_coinCount()
	local i = hud.coincount
	
	if not i.visible then return end
	
	local t = {
		x = i.x,
		y = i.x,
		priority = i.priority,
		
		image = i.image
	}
	local x = 88
	
	t.x = t.x + (camera.width / 2) + x
	t.y = t.y + 26
	
	Graphics.draw(t)
	
	Graphics.draw{
		image = Graphics.sprites.ui['Interface1'].img,
		x = t.x + t.image.width + 8,
		y = t.y + 1,
	}
	
	local str = "0"
	local x = (#str - 1) * 18
	Text.print(tostring(i.value()), t.x + 64 - x, t.y + 1, 0)
end

local function draw_scoreCount()
	local i = hud.scorecount
	
	if not i.visible then return end
	
	local t = {
		x = i.x,
		y = i.x,
		priority = i.priority,
	}
	
	local x = 88
	
	t.x = t.x + (camera.width / 2) + x
	t.y = t.y + 47
	
	local str = tostring(i.value())
	local x = (#str - 1) * 18
	Text.print(str, t.x + 64 - x, t.y + 1, 0)
end

local function draw_itemBox()
	local i = hud.itembox
	
	if not i.visible then return end
	
	local t = {
		x = i.x,
		y = i.x,
		priority = i.priority,
		
		image = i.image
	}
	local x = 400 - 372
	
	t.x = t.x + (camera.width / 2) - x
	t.y = t.y + 16
	
	Graphics.draw(t)
end

local x = {
	[1] = camera.width / 2 - 1,
	[2] = 0
}

local y = {
	[1] = camera.height / 2 - 1,
	[2] = 0
}

local function draw_camLines()
	if Camera.type == 1 then
		for i = 1, #x do
			Graphics.rect{
				x = x[i],
				y = 0,
				width = 1,
				height = camera.height,
				color = Color.black,
			}
		end
	elseif Camera.type == 2 then
		for i = 1, #y do
			Graphics.rect{
				x = 0,
				y = y[i],
				width = camera.width,
				height = 1,
				color = Color.black,
			}
		end
	end
end

function hud.internalDraw()
	draw_itemBox()
	draw_liveCount()
	draw_coinCount()
	draw_scoreCount()
	
	draw_camLines()
end

_G.LevelHUD = hud