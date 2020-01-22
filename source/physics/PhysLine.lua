import "CoreLibs/object"
import "physics/PhysObject"
import "physics/Collision"
import "render/camera"

class("PhysLine").extends(PhysObject)

-- Facing constants
PhysLine.TopOnly = 1
PhysLine.DoubleSided = 2

function PhysLine:init(x1, y1, x2, y2)
	PhysLine.super.init(self, x1, y1)
	local dx, dy = x2 - x1, y2 - y1
	self.segment = playdate.geometry.vector2D.new(dx, dy)
	self.facing = PhysLine.TopOnly
	self.ignoreReverseSideCollisions = false
	-- Cache some information about the line that's useful for physics calculations
	self.segmentNormalized = self.segment:normalized()
	self.normal = self.segmentNormalized:copy():leftNormal()
	self.length = self.segment:magnitude()
end

function PhysLine:draw()
	local pos, segment, normal, length = self.position, self.segment, self.normal, self.length
	local x1, y1 = camera.matrix:transformXY(pos.x, pos.y)
	local x2, y2 = camera.matrix:transformXY(pos.x + segment.x, pos.y + segment.y)
	-- Draw the line
	playdate.graphics.drawLine(x1, y1, x2, y2)
	-- Draw a hash mark on the back side of the line
	if self.facing == PhysLine.TopOnly then
		local xMid, yMid = (pos.x + pos.x + segment.x) / 2, (pos.y + pos.y + segment.y) / 2
		local x3, y3 = camera.matrix:transformXY(xMid, yMid)
		local x4, y4 = camera.matrix:transformXY(xMid - 7 * self.normal.x, yMid - 7 * self.normal.y)
		playdate.graphics.drawLine(x3, y3, x4, y4)
	end
end

function PhysLine:checkForCollisionWithBall(ball)
	-- Check if the ball is above/below the line
	local dx, dy = ball.position.x - self.position.x, ball.position.y - self.position.y
	local dot = dx * self.segmentNormalized.x + dy * self.segmentNormalized.dy
	if 0 <= dot and dot <= self.length then
		-- The ball is either above or below the line!
		local contactX, contactY = self.position.x + self.segmentNormalized.x * dot, self.position.y + self.segmentNormalized.y * dot
		local squareDist = (ball.position.x - contactX) ^ 2 + (ball.position.y - contactY) ^ 2
		if squareDist < ball.radius * ball.radius then
			-- The ball is overlapping the line!
			local dot2 = (ball.position.x - contactX) * self.normal.x + (ball.position.y - contactY) * self.normal.y
			local dist = math.sqrt(squareDist)
			if dot2 < 0 then
				-- The ball is overlapping the line from below
				if self.facing == PhysLine.DoubleSided then
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
