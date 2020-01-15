import "physics/PhysicsObject"

class("Circle").extends(PhysicsObject)

function Circle:init(x, y, radius)
	Circle.super.init(self, x, y)
	self.radius = radius
end

function Circle:draw()
	playdate.graphics.drawArc(self.position.x, self.position.y, self.radius)
end
