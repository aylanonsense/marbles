import "CoreLibs/object"
import "CoreLibs/graphics"
import "physics/PhysObject"
import "physics/Collision"
import "render/camera"

class("PhysPoint").extends(PhysObject)

function PhysPoint:init(x, y)
	PhysPoint.super.init(self, PhysObject.Type.PhysPoint, x, y)
end

function PhysPoint:draw()
	local x, y = camera.matrix:transformXY(self.position.x, self.position.y)
	playdate.graphics.fillCircleAtPoint(x, y, 2)
end

function PhysPoint:checkForCollisionWithBall(ball)
	-- Check to see if they are overlapping
	local dx, dy = ball.position.x - self.position.x, ball.position.y - self.position.y
	local squareDist = dx * dx + dy * dy
	local minDist, maxDist = 0, ball.radius
	if minDist * minDist < squareDist and squareDist < maxDist * maxDist then
		-- They are overlapping!
		local dist = math.sqrt(squareDist)
		return Collision.pool:withdraw(self, ball, ball.radius - dist, dx / dist, dy / dist)
	end
end

function PhysPoint.deserialize(data)
	return PhysPoint(data.x, data.y)
end
