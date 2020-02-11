import "CoreLibs/object"

class("Collision").extends()

function Collision:init(objectA, objectB, overlap, normalX, normalY)
	self.objectA = objectA
	self.objectB = objectB
	self.overlap = overlap
	self.normal = playdate.geometry.vector2D.new(normalX, normalY)
end

function Collision:reset(objectA, objectB, overlap, normalX, normalY)
	self.objectA = objectA
	self.objectB = objectB
	self.overlap = overlap
	self.normal.x, self.normal.y = normalX, normalY
end

function Collision:handle()
	self:separateObjects()
	self:updateVelocities()
end

function Collision:separateObjects()
	local a, b = self.objectA, self.objectB
	local aPos, bPos = a.position, b.position
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
	aPos.x -= self.overlap * proportionA * self.normal.x
	aPos.y -= self.overlap * proportionA * self.normal.y
	bPos.x += self.overlap * (1 - proportionA) * self.normal.x
	bPos.y += self.overlap * (1 - proportionA) * self.normal.y
end

function Collision:updateVelocities()
	local a, b = self.objectA, self.objectB
	local aVel, bVel = a.velocity, b.velocity
	-- Update the objects' velocities
	local relativeVelX, relativeVelY = bVel.x - aVel.x, bVel.y - aVel.y
	local velocityAlongNormal = relativeVelX * self.normal.x + relativeVelY * self.normal.y
	if velocityAlongNormal <= 0 then
		local e = math.min(a.restitution, b.restitution)
		local aInverseMass = (a.mass > 0) and (1 / a.mass) or 0
		local bInverseMass = (b.mass > 0) and (1 / b.mass) or 0
		local j = -(1 + e) * velocityAlongNormal / (aInverseMass + bInverseMass)
		aVel.x -= j * self.normal.x * aInverseMass
		aVel.y -= j * self.normal.y * aInverseMass
		bVel.x += j * self.normal.x * bInverseMass
		bVel.y += j * self.normal.y * bInverseMass
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
