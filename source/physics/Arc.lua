import "CoreLibs/graphics"
import "physics/PhysicsObject"
import "physics/Collision"

class("Arc").extends(PhysicsObject)

function Arc:init(x, y, radius, startAngle, endAngle)
	Arc.super.init(self, x, y)
	self.radius = radius
	-- Angles are in degrees, with 0 at the top and 90 at the right
	self.startAngle = startAngle
	self.endAngle = endAngle
end

function Arc:draw()
	playdate.graphics.drawArc(self.position.x, self.position.y, self.radius, self.radius, self.startAngle, self.endAngle)
end

function Arc:checkForCollisionWithBall(ball)
	-- Check to see if they are overlapping
	local dx, dy = ball.position.x - self.position.x, ball.position.y - self.position.y
	local squareDist = dx * dx + dy * dy
	-- TODO minDist should change based on whether the arc is inverted
	local minDist = (self.radius > ball.radius) and (self.radius - ball.radius) or 0
	local maxDist = ball.radius + self.radius
	if minDist * minDist < squareDist and squareDist < maxDist * maxDist then
		-- They are overlapping! Figure out if it's on the solid part of the arc though
		local angle = atan2(dy, dx)
		local isOnArc
		if self.startAngle > self.endAngle then
			isOnArc = self.startAngle <= angle or angle <= self.endAngle
		else
			isOnArc = self.startAngle <= angle and angle <= self.endAngle
		end
		if isOnArc then
			local dist = math.sqrt(squareDist)
			local overlap = dist - (self.radius - ball.radius)
			return Collision(self, ball, overlap, -dx / dist, -dy / dist) -- TODO pool
		end
	end
end
