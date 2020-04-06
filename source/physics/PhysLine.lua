import "CoreLibs/object"
import "physics/physics"
import "physics/PhysObject"
import "physics/Collision"
import "render/camera"

class("PhysLine").extends(PhysObject)

PhysLine.Facing = {
	TopOnly = 1,
	DoubleSided = 2
}

function PhysLine:init(x1, y1, x2, y2)
	PhysLine.super.init(self, PhysObject.Type.PhysLine, x1, y1)
	local dx, dy = x2 - x1, y2 - y1
	self.segment = { x = dx, y = dy }
	self.facing = PhysLine.Facing.TopOnly
	self.ignoreReverseSideCollisions = false
	-- Cache some information about the line that's useful for physics calculations
	local vector = playdate.geometry.vector2D.new(dx, dy)
	self.segmentNormalized = vector:normalized()
	self.normal = self.segmentNormalized:leftNormal()
	self.length = vector:magnitude()
end

function PhysLine:draw()
	local segment, normal, length = self.segment, self.normal, self.length
	local x1, y1 = camera.matrix:transformXY(self.x, self.y)
	local x2, y2 = camera.matrix:transformXY(self.x + segment.x, self.y + segment.y)
	-- Draw the line
	playdate.graphics.drawLine(x1, y1, x2, y2)
	-- Draw a hash mark on the back side of the line
	if self.facing == PhysLine.Facing.TopOnly then
		local xMid, yMid = (self.x + self.x + segment.x) / 2, (self.y + self.y + segment.y) / 2
		local x3, y3 = camera.matrix:transformXY(xMid, yMid)
		local x4, y4 = camera.matrix:transformXY(xMid - 7 * self.normal.x, yMid - 7 * self.normal.y)
		playdate.graphics.drawLine(x3, y3, x4, y4)
	end
end

function PhysLine:checkForCollisionWithBall(ball)
	-- Check if the ball is above/below the line
	local dx, dy = ball.x - self.x, ball.y - self.y
	local dot = dx * self.segmentNormalized.x + dy * self.segmentNormalized.dy
	if 0 <= dot and dot <= self.length then
		-- The ball is either above or below the line!
		local contactX, contactY = self.x + self.segmentNormalized.x * dot, self.y + self.segmentNormalized.y * dot
		local squareDist = (ball.x - contactX) ^ 2 + (ball.y - contactY) ^ 2
		if squareDist < ball.radius * ball.radius then
			-- The ball is overlapping the line!
			local dot2 = (ball.x - contactX) * self.normal.x + (ball.y - contactY) * self.normal.y
			local dist = math.sqrt(squareDist)
			if dot2 < 0 then
				-- The ball is overlapping the line from below
				if self.facing == PhysLine.Facing.DoubleSided then
					-- Bounce off the underside
					local overlap = ball.radius - dist
					return Collision.pool:withdraw(self, ball, overlap, -self.normal.x, -self.normal.y)
				elseif not self.ignoreReverseSideCollisions then
					-- Bounce off the top
					local overlap = ball.radius + dist
					return Collision.pool:withdraw(self, ball, overlap, self.normal.x, self.normal.y)
				end
			else
				-- The ball is overlapping the line from above
				local overlap = ball.radius - dist
				return Collision.pool:withdraw(self, ball, overlap, self.normal.x, self.normal.y)
			end
		end
	end
end

function PhysLine:calculateSectors()
	local x1, y1 = self.x, self.y
	local x2, y2 = self.x + self.segment.x, self.y + self.segment.y
	local sectorMinX = math.floor((math.min(x1, x2) - physics.SECTOR_OVERLAP) / physics.SECTOR_SIZE)
	local sectorMaxX = math.floor(math.max(x1, x2) / physics.SECTOR_SIZE)
	local sectorMinY = math.floor((math.min(y1, y2) - physics.SECTOR_OVERLAP) / physics.SECTOR_SIZE)
	local sectorMaxY = math.floor(math.max(y1, y2) / physics.SECTOR_SIZE)
	local sectors = {}
	for x = sectorMinX, sectorMaxX do
		for y = sectorMinY, sectorMaxY do
			table.insert(sectors, x)
			table.insert(sectors, y)
		end
	end
	return sectors
end

function PhysLine:serialize()
	local data = PhysLine.super.serialize(self)
	data.x2 = self.x + self.segment.x
	data.y2 = self.y + self.segment.y
	if self.facing ~= PhysLine.Facing.TopOnly then
		data.facing = self.facing
	end
	return data
end

function PhysLine.deserialize(data)
	local line = PhysLine(data.x, data.y, data.x2, data.y2)
	if data.facing then
		line.facing = data.facing
	end
	if data.sectors then
		line.sectors = data.sectors
	end
	if data.isStatic == false then
		line.isStatic = false
	end
	return line
end
