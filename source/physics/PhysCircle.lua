import "CoreLibs/object"
import "CoreLibs/graphics"
import "physics/PhysObject"
import "physics/Collision"
import "render/camera"

class("PhysCircle").extends(PhysObject)

PhysCircle.Facing = {
	Outwards = 1,
	Inwards = 2,
	DoubleSided = 3
}

function PhysCircle:init(x, y, radius)
	PhysCircle.super.init(self, PhysObject.Type.PhysCircle, x, y)
	self.radius = radius
	self.facing = PhysCircle.Facing.Outwards
	self.ignoreReverseSideCollisions = false
end

function PhysCircle:draw()
	local x, y = camera.matrix:transformXY(self.position.x, self.position.y)
	playdate.graphics.drawCircleAtPoint(x, y, self.radius)
end

function PhysCircle:checkForCollisionWithBall(ball)
	-- Check to see if the ball is touching (or inside) the circle
	local dx, dy = ball.position.x - self.position.x, ball.position.y - self.position.y
	local squareDist = dx * dx + dy * dy
	local maxDist = self.radius + ball.radius
	if squareDist < maxDist * maxDist then
		-- The ball is touching (or inside) the circle!
		local dist = math.sqrt(squareDist)
		if self.facing == PhysCircle.Facing.Outwards then
			if not self.ignoreReverseSideCollisions or dist > (self.radius - ball.radius) then
				-- Bounce off the outside of the circle
				return Collision.pool:withdraw(self, ball, self.radius + ball.radius - dist, dx / dist, dy / dist)
			end
		elseif self.facing == PhysCircle.Facing.Inwards then
			if dist > (self.radius - ball.radius) and (not self.ignoreReverseSideCollisions or dist <= self.radius) then
				-- Bounce off the inside of the circle
				return Collision.pool:withdraw(self, ball, dist - (self.radius - ball.radius), -dx / dist, -dy / dist)
			end
		elseif self.facing == PhysCircle.Facing.DoubleSided then
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

function PhysCircle:serialize()
	local data = PhysCircle.super.serialize(self)
	data.radius = self.radius
	if self.facing ~= PhysCircle.Facing.Outwards then
		data.facing = self.facing
	end
	return data
end

function PhysCircle.deserialize(data)
	local circle = PhysCircle(data.x1, data.y1, data.x2, data.y2)
	if data.facing then
		circle.facing = data.facing
	end
	return circle
end
