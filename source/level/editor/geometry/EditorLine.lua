import "CoreLibs/object"
import "level/editor/geometry/EditorGeometry"
import "level/editor/geometry/EditorPoint"
import "render/perspectiveDrawing"
import "physics/PhysLine"
import "utility/math"

class("EditorLine").extends("EditorGeometry")

function EditorLine:init(startPoint, endPoint)
	EditorLine.super.init(self, EditorGeometry.Type.Line)
	self.startPoint = startPoint
	self.endPoint = endPoint
	self.startPoint.outgoingLine = self
	self.endPoint.incomingLine = self
	self.radius = 0
end

function EditorLine:draw()
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.setLineWidth(1)
	playdate.graphics.setLineCapStyle(playdate.graphics.kLineCapStyleRound)
	if self.radius == 0 then
		perspectiveDrawing.drawLine(self.startPoint.x, self.startPoint.y, self.endPoint.x, self.endPoint.y)
	else
		local arcX, arcY, radius, startAngle, endAngle = self:getArcProps()
		if arcX and arcY then
			perspectiveDrawing.drawArc(arcX, arcY, radius, startAngle, endAngle)
		end
	end
end

function EditorLine:getArcProps()
	-- Treat the endpoints as circles and test for their intersection
	local radius = math.abs(self.radius)
	local x1, y1, r1 = self.startPoint.x, self.startPoint.y, radius
	local x2, y2, r2 = self.endPoint.x, self.endPoint.y, radius
	local midX, midY = (x1 + x2) / 2, (y1 + y2) / 2
	local dx, dy = x2 - x1, y2 - y1
	local dist = math.sqrt(dx * dx + dy * dy)
	if math.abs(r2 - r1) <= dist and dist <= r1 + r2 then
		local a = (r1 * r1 - r2 * r2 + dist * dist) / (2 * dist)
		local h = math.sqrt(r1 * r1 - a * a) * ((self.radius > 0) and -1 or 1)
		local intersectX = midX + h * (y2 - y1) / dist
		local intersectY = midY - h * (x2 - x1) / dist
		local angle1 = trigAngleToDrawableAngle(math.atan2(self.startPoint.y - intersectY, self.startPoint.x - intersectX))
		local angle2 = trigAngleToDrawableAngle(math.atan2(self.endPoint.y - intersectY, self.endPoint.x - intersectX))
		if self.radius > 0 then
			return intersectX, intersectY, radius, angle1, angle2
		else
			return intersectX, intersectY, radius, angle2, angle1
		end
	end
end

function EditorLine:getEditTargets()
	return { { x = (self.startPoint.x + self.endPoint.x) / 2, y = (self.startPoint.y + self.endPoint.y) / 2, size = 4, geom = self } }
end

function EditorLine:getMidPoint()
	return (self.startPoint.x + self.endPoint.x) / 2, (self.startPoint.y + self.endPoint.y) / 2
end

function EditorLine:getTranslationPoint()
	return self.startPoint.x, self.startPoint.y
end

function EditorLine:translate(x, y)
	self.startPoint:translate(x, y)
	self.endPoint:translate(x, y)
end

function EditorLine:split()
	local polygon = self.startPoint.polygon
	if polygon then
		for i = 1, #polygon.points do
			if polygon.points[i] == self.startPoint then
				local x, y = self:getMidPoint()
				local midPoint = EditorPoint(x, y)
				EditorLine(midPoint, self.endPoint)
				self.endPoint = midPoint
				self.endPoint.incomingLine = self
				table.insert(polygon.points, i + 1, midPoint)
				midPoint.polygon = polygon
				break
			end
		end
	end
end

function EditorLine:extrude()
	local polygon = self.startPoint.polygon
	if polygon then
		local beforeStartPoint = EditorPoint(self.startPoint.x, self.startPoint.y)
		local afterEndPoint = EditorPoint(self.endPoint.x, self.endPoint.y)
		-- Add a point before the start point
		for i = 1, #polygon.points do
			if polygon.points[i] == self.startPoint then
				table.insert(polygon.points, i, beforeStartPoint)
				beforeStartPoint.polygon = polygon
				break
			end
		end
		-- Add a point after the end point
		for i = 1, #polygon.points do
			if polygon.points[i] == self.endPoint then
				table.insert(polygon.points, i + 1, afterEndPoint)
				afterEndPoint.polygon = polygon
				break
			end
		end
		-- Connect them with lines
		beforeStartPoint.incomingLine = self.startPoint.incomingLine
		self.startPoint.incomingLine.endPoint = beforeStartPoint
		afterEndPoint.outgoingLine = self.endPoint.outgoingLine
		self.endPoint.outgoingLine.startPoint = afterEndPoint
		EditorLine(beforeStartPoint, self.startPoint)
		EditorLine(self.endPoint, afterEndPoint)
	end
end

function EditorLine:delete()
	local polygon = self.startPoint.polygon
	if polygon then
		local x, y = self:getMidPoint()
		if self.endPoint:delete() then
			self.startPoint.x, self.startPoint.y = x, y
			return true
		end
	end
end
