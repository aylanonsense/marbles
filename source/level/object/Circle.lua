import "level/object/LevelObject"
import "physics/PhysCircle"
import "render/camera"
import "render/patterns"

class("Circle").extends("LevelObject")

function Circle:init(x, y, radius)
	Circle.super.init(self, LevelObject.Type.Circle)
	self.physObj = PhysCircle(x, y, radius):add()
end

function Circle:draw()
	local x, y = self:getPosition()
	x, y = camera.matrix:transformXY(x, y)
	local radius = self.physObj.radius * camera.scale
	-- Fill circle
  playdate.graphics.setPattern(patterns.Checkerboard)
  playdate.graphics.fillCircleAtPoint(x, y, radius)
  -- Draw outline
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.setLineWidth(1)
	playdate.graphics.drawCircleAtPoint(x, y, radius)
end

function Circle:getPosition()
	return self.physObj.position.x, self.physObj.position.y
end

function Circle:setPosition(x, y)
	self.physObj.position.x, self.physObj.position.y = x, y
end

function Circle:serialize()
	local data = Circle.super.serialize(self)
	data.radius = self.physObj.radius
	return data
end

function Circle.deserialize(data)
	return Circle(data.x, data.y, data.radius)
end
