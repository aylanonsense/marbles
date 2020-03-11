import "level/object/LevelObject"
import "physics/PhysCircle"
import "render/camera"
import "render/patterns"

class("Circle").extends("LevelObject")

function Circle:init(x, y, radius)
	Circle.super.init(self, LevelObject.Type.Circle)
	self.physCircle = self:addPhysicsObject(PhysCircle(x, y, radius))
	self.isVisible = true
	self.fillPattern = 'Grey'
end

function Circle:draw()
	if self.isVisible then
		local x, y = self:getPosition()
		x, y = camera.matrix:transformXY(x, y)
		local radius = self.physCircle.radius * camera.scale
		if self.fillPattern ~= 'Transparent' then
			-- Fill circle
			playdate.graphics.setPattern(patterns[self.fillPattern])
			playdate.graphics.fillCircleAtPoint(x, y, radius)
		end
		-- Draw outline
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.setLineWidth(1)
		playdate.graphics.drawCircleAtPoint(x, y, radius)
	end
end

function Circle:serialize()
	local data = Circle.super.serialize(self)
	data.radius = self.physCircle.radius
	if not self.physCircle.isEnabled then
		data.isSolid = false
	end
	if not self.isVisible then
		data.isVisible = false
	end
	if self.fillPattern ~= 'Grey' then
		data.fillPattern = self.fillPattern
	end
	return data
end

function Circle.deserialize(data)
	local circle = Circle(data.x, data.y, data.radius)
	if data.isSolid == false then
		circle.physCircle.isEnabled = false
	end
	if data.isVisible == false then
		circle.isVisible = false
	end
	if data.fillPattern then
		circle.fillPattern = data.fillPattern
	end
	return circle
end
