import "CoreLibs/object"
import "CoreLibs/graphics"
import "level/editor/geometry/EditorGeometry"
import "render/camera"
import "utility/table"

class("EditorPolygon").extends("EditorGeometry")

function EditorPolygon:init(points)
	EditorPolygon.super.init(self, EditorGeometry.Type.Polygon)
	self.points = points
	self.isWorldBoundary = false
	for _, point in ipairs(self.points) do
		point.polygon = self
	end
end

function EditorPolygon:draw()
	if not self.isWorldBoundary then
		local coordinates = {}
		for i = 1, #self.points do
			local x, y = camera.matrix:transformXY(self.points[i].x, self.points[i].y)
			table.insert(coordinates, x)
			table.insert(coordinates, y)
		end
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.setPattern({ 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55 })
		playdate.graphics.fillPolygon(table.unpack(coordinates))
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
	else
		-- Draw inverted polygon
		local leftmostPoint, leftmostPointIndex
		for i, point in ipairs(self.points) do
			if not leftmostPoint or point.x < leftmostPoint.x then
				leftmostPoint = point
				leftmostPointIndex = i
			end
		end
		local coordinates = {}
		for i = leftmostPointIndex, #self.points do
			local x, y = camera.matrix:transformXY(self.points[i].x, self.points[i].y)
			table.insert(coordinates, x)
			table.insert(coordinates, y)
		end
		for i = 1, leftmostPointIndex - 1 do
			local x, y = camera.matrix:transformXY(self.points[i].x, self.points[i].y)
			table.insert(coordinates, x)
			table.insert(coordinates, y)
		end
		local isClockwise = self:isClockwise()
		local x2, y2 = camera.matrix:transformXY(leftmostPoint.x, leftmostPoint.y)
		table.insert(coordinates, x2)
		table.insert(coordinates, y2)
		x2, y2 = camera.matrix:transformXY(leftmostPoint.x - 9999, leftmostPoint.y)
		table.insert(coordinates, x2)
		table.insert(coordinates, y2)
		x2, y2 = camera.matrix:transformXY(leftmostPoint.x, leftmostPoint.y + (isClockwise and 9999 or -9999))
		table.insert(coordinates, x2)
		table.insert(coordinates, y2)
		x2, y2 = camera.matrix:transformXY(leftmostPoint.x + 9999, leftmostPoint.y)
		table.insert(coordinates, x2)
		table.insert(coordinates, y2)
		x2, y2 = camera.matrix:transformXY(leftmostPoint.x, leftmostPoint.y + (isClockwise and -9999 or 9999))
		table.insert(coordinates, x2)
		table.insert(coordinates, y2)
		x2, y2 = camera.matrix:transformXY(leftmostPoint.x - 9999, leftmostPoint.y)
		table.insert(coordinates, x2)
		table.insert(coordinates, y2)
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.setPattern({ 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55 })
		playdate.graphics.fillPolygon(table.unpack(coordinates))
	end
	-- Draw lines
	playdate.graphics.setPattern({})
	for i = 1, #self.points do
		local point = self.points[i]
		point:draw()
		point.outgoingLine:draw()
	end
end

function EditorPolygon:getEditTargets()
	local midX, midY = self:getMidPoint()
	local editTargets = { { x = midX, y = midY, size = 5, geom = self } }
	for _, point in ipairs(self.points) do
		local pointEditTargets = point:getEditTargets()
		for _, target in ipairs(pointEditTargets) do
			table.insert(editTargets, target)
		end
		local lineEditTargets = point.outgoingLine:getEditTargets()
		for _, target in ipairs(lineEditTargets) do
			table.insert(editTargets, target)
		end
	end
	return editTargets
end

function EditorPolygon:getMidPoint()
	local avgX, avgY = 0, 0
	local minX, maxX, minY, maxY
	for _, point in ipairs(self.points) do
		avgX += point.x / #self.points
		avgY += point.y / #self.points
		minX = (minX == null or point.x < minX) and point.x or minX
		maxX = (maxX == null or point.x > maxX) and point.x or maxX
		minY = (minY == null or point.y < minY) and point.y or minY
		maxY = (maxY == null or point.y > maxY) and point.y or maxY
	end
	return (minX + maxX + 2 * avgX) / 4, (minY + maxY + 2 * avgY) / 4
end

function EditorPolygon:getTranslationPoint()
	return self.points[1].x, self.points[1].y
end

function EditorPolygon:translate(x, y)
	for _, point in ipairs(self.points) do
		point:translate(x, y)
	end
end

function EditorPolygon:delete()
	return removeItem(scene.geometry, self)
end

function EditorPolygon:isClockwise()
	local sum = 0
	for i, point in ipairs(self.points) do
		local point2 = self.points[(i == #self.points) and 1 or (i + 1)]
		sum += (point2.x - point.x) * (point2.y + point.y)
	end
	return sum < 0
end
