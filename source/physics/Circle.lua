import "CoreLibs/graphics"
import "physics/PhysicsObject"
import "physics/Collision"

class("Circle").extends(PhysicsObject)

function Circle:init(x, y, radius)
	Circle.super.init(self, x, y)
	self.radius = radius
end

function Circle:draw()
	playdate.graphics.drawCircleAtPoint(self.position, self.radius)
end

function Circle:checkForCollisionWithBall(ball)
	-- Check to see if they are overlapping
	local dx, dy = ball.position.x - self.position.x, ball.position.y - self.position.y
	local squareDist = dx * dx + dy * dy
	local minDist, maxDist = 0, self.radius + ball.radius
	if minDist * minDist < squareDist and squareDist < maxDist * maxDist then
		-- They are overlapping!
		local dist = math.sqrt(squareDist)
		return Collision(self, ball, self.radius + ball.radius - dist, dx / dist, dy / dist) -- TODO pool
	end
end
