import "CoreLibs/graphics"
import "physics/PhysicsObject"

class("Arc").extends(PhysicsObject)

function Arc:init(x, y, radius, startAngle, endAngle)
	Arc.super.init(self, x, y)
	self.type = PhysicsObject.Type.Arc
	self.radius = radius
	-- Angles are in degrees, with 0 at the top and 90 at the right
	self.startAngle = startAngle
	self.endAngle = endAngle
end

function Arc:draw()
	playdate.graphics.drawPixel(self.position.x, self.position.y)
	playdate.graphics.drawArc(self.position.x, self.position.y, self.radius, self.radius, self.startAngle, self.endAngle)
end
