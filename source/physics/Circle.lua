import "CoreLibs/graphics"
import "physics/PhysicsObject"

class("Circle").extends(PhysicsObject)

function Circle:init(x, y, radius)
	Circle.super.init(self, x, y)
	self.type = PhysicsObject.Type.Circle
	self.radius = radius
end

function Circle:draw()
	playdate.graphics.drawCircleAtPoint(self.position, self.radius)
end
