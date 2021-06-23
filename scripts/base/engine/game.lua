Game = {}

Game.FPS = 65
Game.speed = Game.FPS / 60
Game.isColliding = function(a,b)
   if ((b.x >= a.x + a.width) or
	   (b.x + b.width <= a.x) or
	   (b.y >= a.y + a.height) or
	   (b.y + b.height <= a.y)) then
		  return false 
   else return true
	   end
end