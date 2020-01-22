import "CoreLibs/object"
import "physics/physics"

class("PhysObject").extends()

function PhysObject:init(x, y)
	PhysObject.super.init(self)
	self.position = playdate.geometry.vector2D.new(x, y)
	self.velocity = playdate.geometry.vector2D.new(0, 0)
	self.acceleration = playdate.geometry.vector2D.new(0, 0)
	self.mass = 0 -- 0 means immovable (infinite mass)
	self.restitution = 1 -- i.e. bounciness (0 = no bounce, 1 = full bounce)
	self.isEnabled = true
end

function PhysObject:update(dt)
	self:applyAcceleration(dt)
	self:applyVelocity(dt)
end

function PhysObject:applyAcceleration(dt)
	self.velocity.x += 0.5 * self.acceleration.x * dt * dt
	self.velocity.y += 0.5 * self.acceleration.y * dt * dt
end

function PhysObject:applyVelocity(dt)
	self.position.x += self.velocity.x * dt
	self.position.y += self.velocity.y * dt
end

function PhysObject:draw()
	-- Draw an X at the object's position
	local x, y = self.position.x, self.position.y
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

function PhysObject:checkForCollisionWithBall(ball) end
