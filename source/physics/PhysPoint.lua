import "CoreLibs/object"
import "CoreLibs/graphics"
import "physics/physics"
import "physics/PhysObject"
import "physics/Collision"
import "render/camera"

class("PhysPoint").extends(PhysObject)

function PhysPoint:init(x, y)
	PhysPoint.super.init(self, PhysObject.Type.PhysPoint, x, y)
end

function PhysPoint:draw()
	local x, y = camera.matrix:transformXY(self.x, self.y)
	playdate.graphics.fillCircleAtPoint(x, y, 2)
end

function PhysPoint:checkForCollisionWithBall(ball)
	-- Check to see if they are overlapping
	local dx, dy = ball.x - self.x, ball.y - self.y
	local squareDist = dx * dx + dy * dy
	local minDist, maxDist = 0, ball.radius
	if minDist * minDist < squareDist and squareDist < maxDist * maxDist then
		-- They are overlapping!
		local dist = math.sqrt(squareDist)
		return Collision.pool:withdraw(self, ball, ball.radius - dist, dx / dist, dy / dist)
	end
end

function PhysPoint:calculateSectors()
	local sectorMinX = math.floor((self.x - physics.SECTOR_OVERLAP) / physics.SECTOR_SIZE)
	local sectorMaxX = math.floor(self.x / physics.SECTOR_SIZE)
	local sectorMinY = math.floor((self.y - physics.SECTOR_OVERLAP) / physics.SECTOR_SIZE)
	local sectorMaxY = math.floor(self.y / physics.SECTOR_SIZE)
	local sectors = {}
	for x = sectorMinX, sectorMaxX do
		for y = sectorMinY, sectorMaxY do
			table.insert(sectors, x)
			table.insert(sectors, y)
		end
	end
	return sectors
end

function PhysPoint.deserialize(data)
	local point = PhysPoint(data.x, data.y)
	if data.sectors then
		point.sectors = data.sectors
	end
	return point
end
