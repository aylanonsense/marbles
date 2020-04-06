import "level/object/LevelObject"
import "physics/PhysCircle"
import "render/camera"
import "render/patterns"

class("Circle").extends("LevelObject")

function Circle:init(x, y, radius, moveX, moveY)
	Circle.super.init(self, LevelObject.Type.Circle)
	self.moveX = moveX or 0
	self.moveY = moveY or 0
	if self.moveX ~= 0 or self.moveY ~= 0 then
		local dist = math.sqrt(self.moveX * self.moveX + self.moveY * self.moveY)
		self.moveState = 'still'
		self.moveTimer = 0
		self.moveVelX = 50 * self.moveX / dist
		self.moveVelY = 50 * self.moveY / dist
		self.moveDuration = dist / 50
	end
	local circle = PhysCircle(x, y, radius)
	if self.moveX ~= 0 or self.moveY ~= 0 then
		circle.isStatic = false
	end
	self.physCircle = self:addPhysicsObject(circle)
	self.isVisible = true
	self.fillPattern = 'Grey'
end

function Circle:update()
	if self.moveX ~= 0 or self.moveY ~= 0 then
		-- Change platform movement
		self.moveTimer = self.moveTimer + time.dt
		if self.moveState == 'still' and self.moveTimer >= 1.0 then
			self.moveState = 'moving'
			self.moveTimer = 0
			self:setVelocity(self.moveVelX, self.moveVelY)
		elseif self.moveState == 'moving' and self.moveTimer >= self.moveDuration then
			self.moveState = 'still-reverse'
			self.moveTimer = 0
			self:setVelocity(0, 0)
		elseif self.moveState == 'still-reverse' and self.moveTimer >= 1.0 then
			self.moveState = 'moving-reverse'
			self.moveTimer = 0
			self:setVelocity(-self.moveVelX, -self.moveVelY)
		elseif self.moveState == 'moving-reverse' and self.moveTimer >= self.moveDuration then
			self.moveState = 'still'
			self.moveTimer = 0
			self:setVelocity(0, 0)
		end
	end
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
	if self.moveX ~= 0 then
		data.moveX = self.moveX
	end
	if self.moveY ~= 0 then
		data.moveY = self.moveY
	end
	if not self.physCircle.isEnabled then
		data.isSolid = false
	end
	if not self.isVisible then
		data.isVisible = false
	end
	if self.fillPattern ~= 'Grey' then
		data.fillPattern = self.fillPattern
	end
	if self.layer ~= 0 then
		data.layer = self.layer
	end
	return data
end

function Circle.deserialize(data)
	local circle = Circle(data.x, data.y, data.radius, data.moveX or 0, data.moveY or 0)
	if data.isSolid == false then
		circle.physCircle.isEnabled = false
	end
	if data.isVisible == false then
		circle.isVisible = false
	end
	if data.fillPattern then
		circle.fillPattern = data.fillPattern
	end
	if data.layer then
		circle.layer = data.layer
	end
	return circle
end
