import "CoreLibs/object"
import "level/editor/geometry/EditorGeometry"
import "render/perspectiveDrawing"

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

function EditorLine:translate(x, y)
	self.startPoint:translate(x, y)
	self.endPoint:translate(x, y)
end
