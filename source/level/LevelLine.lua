import "CoreLibs/object"
import "level/LevelGeometry"
import "render/perspectiveDrawing"

class("LevelLine").extends("LevelGeometry")

function LevelLine:init(startPoint, endPoint)
	LevelLine.super.init(self, LevelGeometry.Type.Line)
	self.startPoint = startPoint
	self.endPoint = endPoint
	self.startPoint.outgoingLine = self
	self.endPoint.incomingLine = self
end

function LevelLine:draw()
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.setLineWidth(1)
	playdate.graphics.setLineCapStyle(playdate.graphics.kLineCapStyleRound)
	perspectiveDrawing.drawLine(self.startPoint.x, self.startPoint.y, self.endPoint.x, self.endPoint.y)
end
