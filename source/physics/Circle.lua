import "CoreLibs/graphics"
import "physics/PhysicsObject"
import "physics/Collision"

class("Circle").extends(PhysicsObject)

-- Facing constants
Circle.Outwards = 1
Circle.Inwards = 2
Circle.DoubleSided = 3

function Circle:init(x, y, radius)
	Circle.super.init(self, x, y)
	self.radius = radius
	self.facing = Circle.Outwards
	self.ignoreReverseSideCollisions = false
end

function Circle:draw()
	playdate.graphics.drawCircleAtPoint(self.position, self.radius)
end

function Circle:checkForCollisionWithBall(ball)
	-- Check to see if the ball is touching (or inside) the circle
	local dx, dy = ball.position.x - self.position.x, ball.position.y - self.position.y
	local squareDist = dx * dx + dy * dy
	local maxDist = self.radius + ball.radius
	if squareDist < maxDist * maxDist then
		-- The ball is touching (or inside) the circle!
		local dist = math.sqrt(squareDist)
		if self.facing == Circle.Outwards then
			if not self.ignoreReverseSideCollisions or dist > (self.radius - ball.radius) then
				-- Bounce off the outside of the circle
				return Collision.pool:withdraw(self, ball, self.radius + ball.radius - dist, dx / dist, dy / dist)
			end
		elseif self.facing == Circle.Inwards then
			if dist > (self.radius - ball.radius) and (not self.ignoreReverseSideCollisions or dist <= self.radius) then
				-- Bounce off the inside of the circle
				return Collision.pool:withdraw(self, ball, dist - (self.radius - ball.radius), -dx / dist, -dy / dist)
			end
		elseif self.facing == Circle.DoubleSided then
			if dist >= self.radius then
				-- Bounce off the outside of the circle
				return Collision.pool:withdraw(self, ball, self.radius + ball.radius - dist, dx / dist, dy / dist)
			else
				-- Bounce off the inside of the circle
				return Collision.pool:withdraw(self, ball, dist - (self.radius - ball.radius), -dx / dist, -dy / dist)
			end
		end
	end
end
