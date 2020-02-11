import "level/object/LevelObject"
import "render/camera"
import "render/patterns"
import "physics/physObjectByType"

class("Polygon").extends("LevelObject")

function Polygon:init(physPoints, physLinesAndArcs, renderCoordinates)
	Polygon.super.init(self, LevelObject.Type.Polygon)
	self.physPoints = physPoints
	for _, point in ipairs(self.physPoints) do
		self:addPhysicsObject(point)
	end
	self.physLinesAndArcs = physLinesAndArcs
	for _, lineOrArc in ipairs(self.physLinesAndArcs) do
		self:addPhysicsObject(lineOrArc)
	end
	self.renderCoordinates = renderCoordinates
	self.perspectiveRenderCoordinates = {}
end

function Polygon:draw()
	for i = 1, #self.renderCoordinates, 2 do
		local x, y = camera.matrix:transformXY(self.renderCoordinates[i], self.renderCoordinates[i + 1])
		self.perspectiveRenderCoordinates[i] = x
		self.perspectiveRenderCoordinates[i + 1] = y
	end

	-- Fill in the polygon
	playdate.graphics.setPattern(patterns.Checkerboard)
	playdate.graphics.fillPolygon(table.unpack(self.perspectiveRenderCoordinates))

	-- Draw the polygon outline
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.setLineWidth(1)
	playdate.graphics.setLineCapStyle(playdate.graphics.kLineCapStyleRound)
	playdate.graphics.drawPolygon(table.unpack(self.perspectiveRenderCoordinates))
end

function Polygon:setPosition(x, y)
	local dx, dy = Polygon.super.setPosition(self, x, y)
	for i = 1, #self.renderCoordinates, 2 do
		self.renderCoordinates[i] += dx
		self.renderCoordinates[i + 1] += dy
	end
end

function Polygon:serialize()
	local data = {
		type = self.type,
		points = {},
		linesAndArcs = {},
		renderCoordinates = self.renderCoordinates
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
	local renderCoordinates = data.renderCoordinates
	for _, physData in ipairs(data.points) do
		table.insert(physPoints, physObjectByType[physData.type].deserialize(physData))
	end
	for _, physData in ipairs(data.linesAndArcs) do
		table.insert(physLinesAndArcs, physObjectByType[physData.type].deserialize(physData))
	end
	return Polygon(physPoints, physLinesAndArcs, renderCoordinates)
end
