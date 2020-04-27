import "CoreLibs/object"

class("Collision").extends()

function Collision:init(objectA, objectB, overlap, normalX, normalY)
	self:reset(objectA, objectB, overlap, normalX, normalY)
end

function Collision:reset(objectA, objectB, overlap, normalX, normalY)
	self.objectA = objectA
	self.objectB = objectB
	self.overlap = overlap
	self.normalX = normalX
	self.normalY = normalY
	self.tag = nil
	-- Calculate impulse
	local a, b = self.objectA, self.objectB
	local relativeVelX, relativeVelY = b.velX - a.velX, b.velY - a.velY
	local velocityAlongNormal = relativeVelX * self.normalX + relativeVelY * self.normalY
	if velocityAlongNormal <= 0 then
		local e = math.min(a.restitution, b.restitution)
		local aInverseMass = (a.mass > 0) and (1 / a.mass) or 0
		local bInverseMass = (b.mass > 0) and (1 / b.mass) or 0
		self.impulse = -(1 + e) * velocityAlongNormal / (aInverseMass + bInverseMass)
	else
		self.impulse = 0
	end
end

function Collision:handle()
	self:separateObjects()
	self:updateVelocities()
end

function Collision:separateObjects()
	local a, b = self.objectA, self.objectB
	-- Separate the objects
	local proportionA
	if not a:isMovable() and not b:isMovable() then
		proportionA = 0.5
	elseif not a:isMovable() then
		proportionA = 0
	elseif not b:isMovable() then
		proportionA = 1
	else
		proportionA = b.mass / (a.mass + b.mass)
	end
	a.x -= self.overlap * proportionA * self.normalX
	a.y -= self.overlap * proportionA * self.normalY
	b.x += self.overlap * (1 - proportionA) * self.normalX
	b.y += self.overlap * (1 - proportionA) * self.normalY
end

function Collision:updateVelocities()
	local a, b = self.objectA, self.objectB
	if self.impluse ~= 0 then
		local aInverseMass = (a.mass > 0) and (1 / a.mass) or 0
		local bInverseMass = (b.mass > 0) and (1 / b.mass) or 0
		a.velX -= self.impulse * self.normalX * aInverseMass
		a.velY -= self.impulse * self.normalY * aInverseMass
		b.velX += self.impulse * self.normalX * bInverseMass
		b.velY += self.impulse * self.normalY * bInverseMass
	end
end

function Collision:discard()
	Collision.pool:deposit(self)
end

-- Create a pool of collision objects to limit the amount of objects we create
Collision.pool = {
	collisions = {}
}
function Collision.pool:withdraw(...)
	if #self.collisions <= 0 then
		return Collision(...)
	else
		local collision = table.remove(self.collisions)
		collision:reset(...)
		return collision
	end
end
function Collision.pool:deposit(collision)
	table.insert(self.collisions, collision)
end
