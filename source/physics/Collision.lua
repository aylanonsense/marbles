import "CoreLibs/object"

class("Collision").extends()

function Collision:init(objectA, objectB, overlap, normalX, normalY)
	self.objectA = objectA
	self.objectB = objectB
	self.overlap = overlap
	self.normal = playdate.geometry.vector2D.new(normalX, normalY)
end

function Collision:handle()
	local a, b = self.objectA, self.objectB
	local aPos, bPos, aVel, bVel = a.position, b.position, a.velocity, b.velocity
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
	-- Update the objects' velocities
	local relativeVelocity = playdate.geometry.vector2D.new(bVel.x - aVel.x, bVel.y - aVel.y) -- TODO pool
	local velocityAlongNormal = relativeVelocity:dotProduct(self.normal)
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
