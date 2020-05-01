import "level/object/LevelObject"
import "level/object/Polygon"
import "render/camera"
import "render/patterns"
import "physics/physObjectByType"
import "utility/diagnosticStats"

class("WorldBoundary").extends("Polygon")

function WorldBoundary:init(physPoints, physLinesAndArcs, fillCoordinates, lineCoordinates)
	WorldBoundary.super.init(self, physPoints, physLinesAndArcs, fillCoordinates, lineCoordinates)
	self.type = LevelObject.Type.WorldBoundary
end

function WorldBoundary:draw()
	if self.fillCoordinates and #self.fillCoordinates > 0 then
		for i = 1, #self.fillCoordinates, 2 do
			local x, y = camera.matrix:transformXY(self.fillCoordinates[i], self.fillCoordinates[i + 1])
			self.perspectiveFillCoordinates[i] = x
			self.perspectiveFillCoordinates[i + 1] = y
		end
		-- Fill in the polygon
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		playdate.graphics.fillPolygon(table.unpack(self.perspectiveFillCoordinates))
		diagnosticStats.polygonPointsDrawn += #self.perspectiveFillCoordinates
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
		diagnosticStats.polygonPointsDrawn += #self.lineCoordinates
	elseif self.fillCoordinates and #self.fillCoordinates > 0 then
		-- Draw the outline as a polygon
		playdate.graphics.drawPolygon(table.unpack(self.perspectiveFillCoordinates))
		diagnosticStats.polygonPointsDrawn += #self.perspectiveFillCoordinates
	end
end

function WorldBoundary.deserialize(data)
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
	local worldBoundary = WorldBoundary(physPoints, physLinesAndArcs, fillCoordinates, lineCoordinates)
	if data.fillPattern then
		worldBoundary.fillPattern = data.fillPattern
	end
	if data.layer then
		worldBoundary.layer = data.layer
	end
	return worldBoundary
end
