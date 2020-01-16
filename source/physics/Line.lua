import "physics/PhysicsObject"

class("Line").extends(PhysicsObject)

function Line:init(x1, y1, x2, y2)
	Line.super.init(self, x1, y1)
	self.type = PhysicsObject.Type.Line
	local dx, dy = x2 - x1, y2 - y1
	self.segment = playdate.geometry.vector2D.new(dx, dy)
	-- Cache some information about the line that's useful for physics calculations
	self.segmentNormalized = self.segment:normalized()
	self.normal = self.segmentNormalized:copy():leftNormal()
	self.length = self.segment:magnitude()
end

function Line:draw()
	local pos, segment, normal, length = self.position, self.segment, self.normal, self.length
	-- Draw the line
	playdate.graphics.drawLine(pos.x, pos.y, pos.x + segment.x, pos.y + segment.y)
	-- Draw hash marks on the "solid" side of the line
	for i = 0, length, 7 do
		local hashX, hashY = pos.x + segment.x * i / length, pos.y + segment.y * i / length
		playdate.graphics.drawLine(hashX, hashY, hashX - 7 * normal.x, hashY - 7 * normal.y)
	end
end
