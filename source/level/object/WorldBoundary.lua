import "level/object/LevelObject"
import "render/camera"
import "render/patterns"
import "physics/physObjectByType"

class("WorldBoundary").extends("LevelObject")

function WorldBoundary:init(physPoints, physLinesAndArcs, renderCoordinates)
	WorldBoundary.super.init(self, LevelObject.Type.WorldBoundary)
	self.physPoints = physPoints
	self.physLinesAndArcs = physLinesAndArcs
	self.renderCoordinates = renderCoordinates
	self.perspectiveRenderCoordinates = {}
end

function WorldBoundary:draw()
	for i = 1, #self.renderCoordinates, 2 do
		local x, y = camera.matrix:transformXY(self.renderCoordinates[i], self.renderCoordinates[i + 1])
		self.perspectiveRenderCoordinates[i] = x
		self.perspectiveRenderCoordinates[i + 1] = y
	end

	-- -- Fill in the WorldBoundary
	playdate.graphics.setColor(playdate.graphics.kColorWhite)
	playdate.graphics.fillPolygon(table.unpack(self.perspectiveRenderCoordinates))

	-- Draw the WorldBoundary outline
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.setLineWidth(1)
	playdate.graphics.setLineCapStyle(playdate.graphics.kLineCapStyleRound)
	playdate.graphics.drawPolygon(table.unpack(self.perspectiveRenderCoordinates))
end

function WorldBoundary:getPosition()
	-- Find the center point
	local minX, maxX, minY, maxY
	for _, point in ipairs(self.physPoints) do
		minX = (minX == nil or point.position.x < minX) and point.position.x or minX
		maxX = (maxX == nil or point.position.x > maxX) and point.position.x or maxX
		minY = (minY == nil or point.position.y < minY) and point.position.y or minY
		maxY = (maxY == nil or point.position.y > maxY) and point.position.y or maxY
	end
	return (minX + maxX) / 2, (minY + maxY) / 2
end

function WorldBoundary:setPosition(x, y)
	-- Translate all children to achieve the move
	local x2, y2 = self:getPosition()
	local dx, dy = x - x2, y - y2
	for _, point in ipairs(self.physPoints) do
		point.position.x += dx
		point.position.y += dy
	end
	for _, physObj in ipairs(self.physLinesAndArcs) do
		physObj.position.x += dx
		physObj.position.y += dy
	end
	for i = 1, #self.renderCoordinates, 2 do
		self.renderCoordinates[i] += dx
		self.renderCoordinates[i + 1] += dy
	end
end

function WorldBoundary:serialize()
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

function WorldBoundary.deserialize(data)
	local physPoints = {}
	local physLinesAndArcs = {}
	local renderCoordinates = data.renderCoordinates
	for _, physData in ipairs(data.points) do
		table.insert(physPoints, physObjectByType[physData.type].deserialize(physData):add())
	end
	for _, physData in ipairs(data.linesAndArcs) do
		table.insert(physLinesAndArcs, physObjectByType[physData.type].deserialize(physData):add())
	end
	return WorldBoundary(physPoints, physLinesAndArcs, renderCoordinates)
end
