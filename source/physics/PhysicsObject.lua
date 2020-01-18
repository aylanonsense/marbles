import "CoreLibs/object"
import "physics/physics"

class("PhysicsObject").extends()

function PhysicsObject:init(x, y)
	self.position = playdate.geometry.vector2D.new(x, y)
	self.velocity = playdate.geometry.vector2D.new(0, 0)
	self.acceleration = playdate.geometry.vector2D.new(0, 0)
	self.mass = 0 -- 0 means immovable (infinite mass)
	self.restitution = 1 -- i.e. bounciness (0 = no bounce, 1 = full bounce)
end

function PhysicsObject:update(dt)
	self:applyAcceleration(dt)
	self:applyVelocity(dt)
end

function PhysicsObject:applyAcceleration(dt)
	self.velocity.x += 0.5 * self.acceleration.x * dt * dt
	self.velocity.y += 0.5 * self.acceleration.y * dt * dt
end

function PhysicsObject:applyVelocity(dt)
	self.position.x += self.velocity.x * dt
	self.position.y += self.velocity.y * dt
end

function PhysicsObject:draw()
	-- Draw an X at the object's position
	local x, y = self.position.x, self.position.y
	playdate.graphics.drawLine(x - 5, y - 5, x + 5, y + 5)
	playdate.graphics.drawLine(x - 5, y + 5, x + 5, y - 5)
end

function PhysicsObject:isMovable()
	return self.mass > 0
end

function PhysicsObject:add()
	table.insert(physics.objects, self)
	return self
end

function PhysicsObject:checkForCollisionWithBall(ball) end
