import "CoreLibs/object"
import "level/editor/geometry/LevelEditorGeometry"
import "render/perspectiveDrawing"

class("LevelEditorLine").extends("LevelEditorGeometry")

function LevelEditorLine:init(startPoint, endPoint)
	LevelEditorLine.super.init(self, LevelEditorGeometry.Type.Line)
	self.startPoint = startPoint
	self.endPoint = endPoint
	self.startPoint.outgoingLine = self
	self.endPoint.incomingLine = self
end

function LevelEditorLine:draw()
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.setLineWidth(1)
	playdate.graphics.setLineCapStyle(playdate.graphics.kLineCapStyleRound)
	perspectiveDrawing.drawLine(self.startPoint.x, self.startPoint.y, self.endPoint.x, self.endPoint.y)
end

function LevelEditorLine:getEditTargets()
	return { { x = (self.startPoint.x + self.endPoint.x) / 2, y = (self.startPoint.y + self.endPoint.y) / 2, size = 4, geom = self } }
end
