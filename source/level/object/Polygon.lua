import "level/object/LevelObject"
import "render/camera"
import "render/patterns"
import "physics/physObjectByType"

class("Polygon").extends("LevelObject")

function Polygon:init(physPoints, physLinesAndArcs, fillCoordinates, lineCoordinates)
	Polygon.super.init(self, LevelObject.Type.Polygon)
	self.physPoints = physPoints
	for _, point in ipairs(self.physPoints) do
		self:addPhysicsObject(point)
	end
	self.physLinesAndArcs = physLinesAndArcs
	for _, lineOrArc in ipairs(self.physLinesAndArcs) do
		self:addPhysicsObject(lineOrArc)
	end
	self.fillCoordinates = fillCoordinates
	self.lineCoordinates = lineCoordinates
	self.perspectiveFillCoordinates = {}
end

function Polygon:draw()
	if self.fillCoordinates and #self.fillCoordinates > 0 then
		for i = 1, #self.fillCoordinates, 2 do
			local x, y = camera.matrix:transformXY(self.fillCoordinates[i], self.fillCoordinates[i + 1])
			self.perspectiveFillCoordinates[i] = x
			self.perspectiveFillCoordinates[i + 1] = y
		end
		-- Fill in the polygon
		playdate.graphics.setPattern(patterns.Checkerboard)
		playdate.graphics.fillPolygon(table.unpack(self.perspectiveFillCoordinates))
	end

	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.setLineWidth(1)
	playdate.graphics.setLineCapStyle(playdate.graphics.kLineCapStyleRound)
	if self.lineCoordinates then
		-- Draw the outline as a series of lines
		for i = 1, #self.lineCoordinates, 4 do
			local x1, y1 = camera.matrix:transformXY(self.lineCoordinates[i], self.lineCoordinates[i + 1])
			local x2, y2 = camera.matrix:transformXY(self.lineCoordinates[i + 2], self.lineCoordinates[i + 3])
			playdate.graphics.drawLine(x1, y1, x2, y2)
		end
	elseif self.fillCoordinates and #self.fillCoordinates > 0 then
		-- Draw the outline as a polygon
		playdate.graphics.drawPolygon(table.unpack(self.perspectiveFillCoordinates))
	end
end

function Polygon:setPosition(x, y)
	local dx, dy = Polygon.super.setPosition(self, x, y)
	if self.fillCoordinates then
		for i = 1, #self.fillCoordinates, 2 do
			self.fillCoordinates[i] += dx
			self.fillCoordinates[i + 1] += dy
		end
	end
	if self.lineCoordinates then
		for i = 1, #self.lineCoordinates, 2 do
			self.lineCoordinates[i] += dx
			self.lineCoordinates[i + 1] += dy
		end
	end
end

function Polygon:serialize()
	local data = {
		type = self.type,
		points = {},
		linesAndArcs = {},
		fillCoordinates = self.fillCoordinates,
		lineCoordinates = self.lineCoordinates
	}
	for _, point in ipairs(self.physPoints) do
		table.insert(data.points, point:serialize())
	end
	for _, physObj in ipairs(self.physLinesAndArcs) do
		table.insert(data.linesAndArcs, physObj:serialize())
	end
	return data
end

function Polygon.deserialize(data)
	local physPoints = {}
	local physLinesAndArcs = {}
	local fillCoordinates = data.fillCoordinates
	local lineCoordinates = data.lineCoordinates
	for _, physData in ipairs(data.points) do
		table.insert(physPoints, physObjectByType[physData.type].deserialize(physData))
	end
	for _, physData in ipairs(data.linesAndArcs) do
		table.insert(physLinesAndArcs, physObjectByType[physData.type].deserialize(physData))
	end
	return Polygon(physPoints, physLinesAndArcs, fillCoordinates, lineCoordinates)
end
