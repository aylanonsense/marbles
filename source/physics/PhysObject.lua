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
	self.position = playdate.geometry.vector2D.new(x, y)
	self.velocity = playdate.geometry.vector2D.new(0, 0)
	self.acceleration = playdate.geometry.vector2D.new(0, 0)
	self.mass = 0 -- 0 means immovable (infinite mass)
	self.restitution = 1 -- i.e. bounciness (0 = no bounce, 1 = full bounce)
	self.isEnabled = true
	self.parent = nil
	self.maxSpeed = nil
end

function PhysObject:applyAcceleration(dt)
	self.velocity.x += 0.5 * self.acceleration.x * dt * dt
	self.velocity.y += 0.5 * self.acceleration.y * dt * dt
end

function PhysObject:applyVelocity(dt)
	self.position.x += self.velocity.x * dt
	self.position.y += self.velocity.y * dt
end

function PhysObject:enforceMaxSpeed()
	if self.maxSpeed then
		if self.velocity:magnitudeSquared() > self.maxSpeed * self.maxSpeed then
			self.velocity:normalize()
			self.velocity:scale(self.maxSpeed)
		end
	end
end

function PhysObject:draw()
	-- Draw an X at the object's position
	local x, y = camera.matrix:transformXY(self.position.x, self.position.y)
	playdate.graphics.drawLine(x - 5, y - 5, x + 5, y + 5)
	playdate.graphics.drawLine(x - 5, y + 5, x + 5, y - 5)
end

function PhysObject:isMovable()
	return self.mass > 0
end

function PhysObject:add()
	table.insert(physics.objects, self)
	return self
end

function PhysObject:remove()
	removeItem(physics.objects, self)
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

function PhysObject:serialize()
	return {
		type = self.type,
		x = self.position.x,
		y = self.position.y
	}
end
