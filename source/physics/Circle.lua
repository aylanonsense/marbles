import "physics/PhysicsObject"
import "physics/Collision"

class("Circle").extends(PhysicsObject)

function Circle:init(x, y, radius)
	Circle.super.init(self, x, y)
	self.type = PhysicsObject.Type.Circle
	self.radius = radius
	self.drawFilled = false
end

function Circle:checkForCollision(other)
	if other.type == PhysicsObject.Type.Circle then
		-- Check to see if the circles are overlapping
		local dx, dy = other.position.x - self.position.x, other.position.y - self.position.y
		local squareDist = dx * dx + dy * dy
		if squareDist > 0 and squareDist < (self.radius + other.radius) ^ 2 then
			-- They are overlapping!
			local dist = math.sqrt(squareDist)
			return Collision(self, other, self.radius + other.radius - dist, dx / dist, dy / dist) -- TODO pool
		end
	end
end

function Circle:draw()
	if self.drawFilled then
		playdate.graphics.drawArc(self.position.x, self.position.y, 0, self.radius)
	else
		playdate.graphics.drawArc(self.position.x, self.position.y, self.radius)
	end
end
