import "CoreLibs/object"
import "physics/physics"
import "utility/table"

class("PhysObject").extends()

PhysObject.Type = {
	PhysArc = "PhysArc",
	PhysBall = "PhysBall",
	PhysCircle = "PhysCircle",
	PhysLine = "PhysLine",
	PhysPoint = "PhysPoint"
}

function PhysObject:init(type, x, y)
	PhysObject.super.init(self)
	self.type = type
	self.x = x
	self.y = y
	self.velX = 0
	self.velY = 0
	self.prevVelX = 0
	self.prevVelY = 0
	self.accX = 0
	self.accY = 0
	self.mass = 0 -- 0 means immovable (infinite mass)
	self.restitution = 0.25 -- i.e. bounciness (0 = no bounce, 1 = full bounce)
	self.isEnabled = true
	self.parent = nil
	self.maxSpeed = nil
	self.isStatic = true
end

function PhysObject:applyAcceleration(dt)
	self.prevVelX = self.velX
	self.prevVelY = self.velY
	self.velX += 0.5 * self.accX * dt * (1 / 20)
	self.velY += 0.5 * self.accY * dt * (1 / 20)
end

function PhysObject:applyVelocity(dt)
	self.x += (self.velX + self.prevVelX) / 2 * dt
	self.y += (self.velY + self.prevVelY) / 2 * dt
end

function PhysObject:enforceMaxSpeed()
	if self.maxSpeed then
		local speedSquared = self.velX * self.velX + self.velY * self.velY
		if speedSquared > self.maxSpeed * self.maxSpeed then
			local speed = math.sqrt(speedSquared)
			self.velX *= self.maxSpeed / speed
			self.velY *= self.maxSpeed / speed
		end
	end
end

function PhysObject:draw()
	-- Draw an X
	local x, y = camera.matrix:transformXY(self.x, self.y)
	playdate.graphics.drawLine(x - 5, y - 5, x + 5, y + 5)
	playdate.graphics.drawLine(x - 5, y + 5, x + 5, y - 5)
end

function PhysObject:isMovable()
	return self.mass > 0
end

function PhysObject:add()
	if self.isStatic then
		physics:addStaticObject(self)
	else
		physics:addDynamicObject(self)
	end
	return self
end

function PhysObject:remove()
	if self.isStatic then
		physics:removeStaticObject(self)
	else
		physics:removeDynamicObject(self)
	end
	return self
end

function PhysObject:getParent()
	return self.parent
end

function PhysObject:setParent(parent)
	self.parent = parent
	return self
end

function PhysObject:checkForCollisionWithBall(ball) end

function PhysObject:calculateSectors()
	return {}
end

function PhysObject:serialize()
	return {
		type = self.type,
		x = self.x,
		y = self.y,
		sectors = self:calculateSectors()
	}
end
