import "CoreLibs/object"
import "level/editor/geometry/EditorGeometry"
import "level/editor/geometry/EditorPoint"
import "render/perspectiveDrawing"
import "physics/PhysLine"

class("EditorLine").extends("EditorGeometry")

function EditorLine:init(startPoint, endPoint)
	EditorLine.super.init(self, EditorGeometry.Type.Line)
	self.startPoint = startPoint
	self.endPoint = endPoint
	self.startPoint.outgoingLine = self
	self.endPoint.incomingLine = self
end

function EditorLine:draw()
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.setLineWidth(1)
	playdate.graphics.setLineCapStyle(playdate.graphics.kLineCapStyleRound)
	perspectiveDrawing.drawLine(self.startPoint.x, self.startPoint.y, self.endPoint.x, self.endPoint.y)
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
