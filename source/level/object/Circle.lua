import "level/object/LevelObject"
import "physics/PhysCircle"
import "render/camera"
import "render/patterns"

class("Circle").extends("LevelObject")

function Circle:init(x, y, radius)
	Circle.super.init(self, LevelObject.Type.Circle)
	self.physCircle = self:addPhysicsObject(PhysCircle(x, y, radius))
end

function Circle:draw()
	local x, y = self:getPosition()
	x, y = camera.matrix:transformXY(x, y)
	local radius = self.physCircle.radius * camera.scale
	-- Fill circle
  playdate.graphics.setPattern(patterns.Checkerboard)
  playdate.graphics.fillCircleAtPoint(x, y, radius)
  -- Draw outline
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.setLineWidth(1)
	playdate.graphics.drawCircleAtPoint(x, y, radius)
end

function Circle:serialize()
	local data = Circle.super.serialize(self)
	data.radius = self.physCircle.radius
	return data
end

function Circle.deserialize(data)
	return Circle(data.x, data.y, data.radius)
end
