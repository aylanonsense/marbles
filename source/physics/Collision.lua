import "CoreLibs/object"

class("Collision").extends()

function Collision:init(objectA, objectB, penetration, normalX, normalY)
	self.objectA = objectA
	self.objectB = objectB
	self.penetration = penetration
	self.normal = playdate.geometry.vector2D.new(normalX, normalY)
end

function Collision:handle()
	-- Figure out how much each object should be affected by the collision
	local proportionA
	if self.objectA.isStatic and not self.objectB.isStatic then
		proportionA = 0.0
	elseif not self.objectA.isStatic and self.objectB.isStatic then
		proportionA = 1.0
	else
		proportionA = 0.5
	end
	local proportionB = 1.0 - proportionA

	-- Separate the objects
	self.objectA.position.x -= self.penetration * proportionA * self.normal.x
	self.objectA.position.y -= self.penetration * proportionA * self.normal.y
	self.objectB.position.x += self.penetration * proportionB * self.normal.x
	self.objectB.position.y += self.penetration * proportionB * self.normal.y

	-- Update their velocities
	-- TODO
end
