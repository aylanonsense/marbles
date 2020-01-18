import "CoreLibs/graphics"
import "physics/PhysicsObject"
import "physics/Collision"

class("Arc").extends(PhysicsObject)

-- Facing constants
Arc.Outwards = 1
Arc.Inwards = 2
Arc.DoubleSided = 3

function Arc:init(x, y, radius, startAngle, endAngle)
	Arc.super.init(self, x, y)
	self.radius = radius
	self.facing = Arc.Outwards
	self.ignoreReverseSideCollisions = false
	-- Angles are in degrees, with 0 at the top and 90 at the right
	self.startAngle = startAngle
	self.endAngle = endAngle
end

function Arc:draw()
	playdate.graphics.drawArc(self.position.x, self.position.y, self.radius, self.radius, self.startAngle, self.endAngle)
end

function Arc:checkForCollisionWithBall(ball)
	-- Check to see if the ball is touching (or inside) the arc
	local dx, dy = ball.position.x - self.position.x, ball.position.y - self.position.y
	local squareDist = dx * dx + dy * dy
	local maxDist = ball.radius + self.radius
	if squareDist < maxDist * maxDist then
		-- The ball is touching (or inside) the arc!
		local angle = atan2(dy, dx)
		local isOnArc
		if self.startAngle > self.endAngle then
			isOnArc = self.startAngle <= angle or angle <= self.endAngle
		else
			isOnArc = self.startAngle <= angle and angle <= self.endAngle
		end
		if isOnArc then
			local dist = math.sqrt(squareDist)
			if self.facing == Arc.Outwards then
				if not self.ignoreReverseSideCollisions or dist > (self.radius - ball.radius) then
					-- Bounce off the outside of the arc
					return Collision.pool:withdraw(self, ball, self.radius + ball.radius - dist, dx / dist, dy / dist)
				end
			elseif self.facing == Arc.Inwards then
				if dist > (self.radius - ball.radius) and (not self.ignoreReverseSideCollisions or dist <= self.radius) then
					-- Bounce off the inside of the arc
					return Collision.pool:withdraw(self, ball, dist - (self.radius - ball.radius), -dx / dist, -dy / dist)
				end
			elseif self.facing == Arc.DoubleSided then
				if dist >= self.radius then
					-- Bounce off the outside of the arc
					return Collision.pool:withdraw(self, ball, self.radius + ball.radius - dist, dx / dist, dy / dist)
				else
					-- Bounce off the inside of the arc
					return Collision.pool:withdraw(self, ball, dist - (self.radius - ball.radius), -dx / dist, -dy / dist)
				end
			end
		end
	end
end
