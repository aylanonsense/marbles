import "CoreLibs/object"
import "CoreLibs/graphics"
import "level/editor/geometry/EditorGeometry"
import "render/camera"
import "utility/table"
import "render/patterns"

class("EditorPolygon").extends("EditorGeometry")

function EditorPolygon:init(points)
	EditorPolygon.super.init(self, EditorGeometry.Type.Polygon)
	self.points = points
	self.isWorldBoundary = false
	self.fillPattern = 'Grey'
	for _, point in ipairs(self.points) do
		point.polygon = self
	end
end

function EditorPolygon:draw()
	if self.isVisible then
		if self.fillPattern ~= 'Transparent' then
			if not self.isWorldBoundary then
				local coordinates = {}
				for i = 1, #self.points do
					self:addRenderCoordinatesToList(coordinates, self.points[i])
				end
				playdate.graphics.setColor(playdate.graphics.kColorBlack)
				playdate.graphics.setPattern(patterns[self.fillPattern])
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
					self:addRenderCoordinatesToList(coordinates, self.points[i])
				end
				for i = 1, leftmostPointIndex - 1 do
					self:addRenderCoordinatesToList(coordinates, self.points[i])
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
				playdate.graphics.setPattern(patterns[self.fillPattern])
				playdate.graphics.fillPolygon(table.unpack(coordinates))
			end
		end
	end
	-- Draw lines
	playdate.graphics.setPattern({})
	for i = 1, #self.points do
		local point = self.points[i]
		point:draw()
		point.outgoingLine:draw()
	end
end

function EditorPolygon:addRenderCoordinatesToList(list, point)
	local arcX, arcY, radius, startAngle, endAngle
	if point.outgoingLine.radius ~= 0 then
		arcX, arcY, radius, startAngle, endAngle = point.outgoingLine:getArcProps()
	end
	if arcX and arcY then
		local circumference = 2 * math.pi * radius
		local degrees = endAngle - startAngle
		if degrees < 0 then
			degrees += 360
		end
		local arcLength = circumference * degrees / 360
		local numPoints = math.ceil(arcLength / 10)
		for i = 1, numPoints do
			local angle
			if point.outgoingLine.radius > 0 then
				angle = startAngle + (i - 1) * degrees / numPoints
			else
				angle = startAngle + (numPoints - i + 1) * degrees / numPoints
			end
			if angle > 360 then
				angle -= 360
			end
			local actualAngle = (angle - 90) * math.pi / 180
			local c = math.cos(actualAngle)
			local s = math.sin(actualAngle)
			local x, y = camera.matrix:transformXY(arcX + radius * c, arcY + radius * s)
			table.insert(list, x)
			table.insert(list, y)
		end
	else
		local x, y = camera.matrix:transformXY(point.x, point.y)
		table.insert(list, x)
		table.insert(list, y)
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
