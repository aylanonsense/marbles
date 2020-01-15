import "CoreLibs/object"

class("Collision").extends()

function Collision:init(objectA, objectB, penetration, normalX, normalY)
	self.objectA = objectA
	self.objectB = objectB
	self.penetration = penetration
	self.normal = playdate.geometry.vector2D.new(normalX, normalY)
end

function Collision:handle()
	local a, b = self.objectA, self.objectB
	local aPos, bPos = a.position, b.position
	local aVel, bVel = a.velocity, b.velocity

	-- Separate the objects
	local proportionA
	if not a:isMovable() and not b:isMovable() then
		proportionA = 0.5
	elseif not a:isMovable() then
		proportionA = 0.0
	elseif not b:isMovable() then
		proportionA = 1.0
	else
		proportionA = b.mass / (a.mass + b.mass)
	end
	local proportionB = 1.0 - proportionA
	aPos.x -= self.penetration * proportionA * self.normal.x
	aPos.y -= self.penetration * proportionA * self.normal.y
	bPos.x += self.penetration * proportionB * self.normal.x
	bPos.y += self.penetration * proportionB * self.normal.y

	-- Update their velocities
	local relativeVelocity = playdate.geometry.vector2D.new(bVel.x - aVel.x, bVel.y - aVel.y)
	local velocityAlongNormal = relativeVelocity:dotProduct(self.normal)
	if velocityAlongNormal <= 0 then
		local e = math.min(a.restitution, b.restitution)
		local aInverseMass = (a.mass > 0) and (1 / a.mass) or 0
		local bInverseMass = (b.mass > 0) and (1 / b.mass) or 0
		local j = -(1 + e) * velocityAlongNormal / (aInverseMass + bInverseMass)
	  local impulse = playdate.geometry.vector2D.new(j * self.normal.x, j * self.normal.y)
	  aVel.x -= aInverseMass * impulse.x
	  aVel.y -= aInverseMass * impulse.y
	  bVel.x += bInverseMass * impulse.x
	  bVel.y += bInverseMass * impulse.y
	end
end
