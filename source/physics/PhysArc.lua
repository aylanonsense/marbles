import "CoreLibs/object"
import "physics/physics"
import "physics/PhysObject"
import "physics/Collision"
import "utility/math"
import "render/camera"

class("PhysArc").extends(PhysObject)

PhysArc.Facing = {
	Outwards = 1,
	Inwards = 2,
	DoubleSided = 3
}

function PhysArc:init(x, y, radius, startAngle, endAngle)
	PhysArc.super.init(self, PhysObject.Type.PhysArc, x, y)
	self.radius = radius
	self.facing = PhysArc.Facing.Outwards
	self.ignoreReverseSideCollisions = false
	-- Angles are in degrees, with 0 at the top and 90 at the right
	self.startAngle = startAngle
	self.endAngle = endAngle
end

function PhysArc:draw()
	local x, y = camera.matrix:transformXY(self.x, self.y)
	playdate.graphics.drawArc(x, y, self.radius, self.radius, self.startAngle - camera.rotation, self.endAngle - camera.rotation)
end

function PhysArc:checkForCollisionWithBall(ball)
	-- Check to see if the ball is touching (or inside) the arc
	local dx, dy = ball.x - self.x, ball.y - self.y
	local squareDist = dx * dx + dy * dy
	local maxDist = ball.radius + self.radius
	if squareDist < maxDist * maxDist then
		-- The ball is touching (or inside) the arc!
		local angle = trigAngleToDrawableAngle(math.atan2(dy, dx))
		local isOnArc
		if self.startAngle > self.endAngle then
			isOnArc = self.startAngle <= angle or angle <= self.endAngle
		else
			isOnArc = self.startAngle <= angle and angle <= self.endAngle
		end
		if isOnArc then
			local dist = math.sqrt(squareDist)
			if self.facing == PhysArc.Facing.Outwards then
				if not self.ignoreReverseSideCollisions or dist > (self.radius - ball.radius) then
					-- Bounce off the outside of the arc
					return Collision.pool:withdraw(self, ball, self.radius + ball.radius - dist, dx / dist, dy / dist)
				end
			elseif self.facing == PhysArc.Facing.Inwards then
				if dist > (self.radius - ball.radius) and (not self.ignoreReverseSideCollisions or dist <= self.radius) then
					-- Bounce off the inside of the arc
					return Collision.pool:withdraw(self, ball, dist - (self.radius - ball.radius), -dx / dist, -dy / dist)
				end
			elseif self.facing == PhysArc.Facing.DoubleSided then
				if dist >= self.radius then
					-- Bounce off the outside of the arc
					return Collision.pool:withdraw(self, ball, self.radius + ball.radius - dist, dx / dist, dy / dist)
				else
					-- Bounce off the inside of the arc
					return Collision.pool:withdraw(self, ball, dist - (self.radius - ball.radius), -dx / dist, -dy / dist)
				end
			end
		end
	end
end

function PhysArc:calculateSectors()
	local sectorMinX = math.floor((self.x - self.radius - physics.SECTOR_OVERLAP) / physics.SECTOR_SIZE)
	local sectorMaxX = math.floor((self.x + self.radius) / physics.SECTOR_SIZE)
	local sectorMinY = math.floor((self.y - self.radius - physics.SECTOR_OVERLAP) / physics.SECTOR_SIZE)
	local sectorMaxY = math.floor((self.y + self.radius) / physics.SECTOR_SIZE)
	local sectors = {}
	for x = sectorMinX, sectorMaxX do
		for y = sectorMinY, sectorMaxY do
			table.insert(sectors, x)
			table.insert(sectors, y)
		end
	end
	return sectors
end

function PhysArc:serialize()
	local data = PhysArc.super.serialize(self)
	data.radius = self.radius
	data.startAngle = self.startAngle
	data.endAngle = self.endAngle
	if self.facing ~= PhysArc.Facing.Outwards then
		data.facing = self.facing
	end
	return data
end

function PhysArc.deserialize(data)
	local arc = PhysArc(data.x, data.y, data.radius, data.startAngle, data.endAngle)
	if data.facing then
		arc.facing = data.facing
	end
	if data.sectors then
		arc.sectors = data.sectors
	end
	return arc
end
