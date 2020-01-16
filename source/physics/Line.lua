import "physics/PhysicsObject"
import "physics/Collision"

class("Line").extends(PhysicsObject)

function Line:init(x1, y1, x2, y2)
	Line.super.init(self, x1, y1)
	local dx, dy = x2 - x1, y2 - y1
	self.segment = playdate.geometry.vector2D.new(dx, dy)
	-- Cache some information about the line that's useful for physics calculations
	self.segmentNormalized = self.segment:normalized()
	self.normal = self.segmentNormalized:copy():leftNormal()
	self.length = self.segment:magnitude()
end

function Line:draw()
	local pos, segment, normal, length = self.position, self.segment, self.normal, self.length
	local x1, y1, x2, y2 = pos.x, pos.y, pos.x + segment.x, pos.y + segment.y
	-- Draw the line
	playdate.graphics.drawLine(x1, y1, x2, y2)
	-- Draw hash marks on the "solid" side of the line
	local xMid, yMid = (x1 + x2) / 2, (y1 + y2) / 2
	playdate.graphics.drawLine(xMid, yMid, xMid - 7 * self.normal.x, yMid - 7 * self.normal.y)
end

function Line:checkForCollisionWithBall(ball)
	-- Check if the ball is above/below the line
	local vectorFromStartPoint = playdate.geometry.vector2D.new(ball.position.x - self.position.x, ball.position.y - self.position.y) -- TODO pool
	local dot = vectorFromStartPoint:dotProduct(self.segmentNormalized)
	if 0 <= dot and dot <= self.length then
		-- The ball is either above or below the line!
		local contactPoint = playdate.geometry.vector2D.new(self.position.x + self.segmentNormalized.x * dot, self.position.y + self.segmentNormalized.y * dot) -- TODO pool
		local vectorFromContactPoint = playdate.geometry.vector2D.new(ball.position.x - contactPoint.x, ball.position.y - contactPoint.y) -- TODO pool
		local squareDist = vectorFromContactPoint:magnitudeSquared()
		if squareDist < ball.radius * ball.radius then
			-- The ball is overlapping the line!
			local dot2 = vectorFromContactPoint:dotProduct(self.normal)
			local dist = math.sqrt(squareDist)
			local overlap
			if dot2 < 0 then
				-- The ball is overlapping the line from below
				overlap = ball.radius + dist
			else
				-- The ball is overlapping the line from above
				overlap = ball.radius - dist
			end
			return Collision(self, ball, overlap, self.normal.x, self.normal.y) -- TODO pool
		end
	end
end
