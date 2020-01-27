import "CoreLibs/object"
import "CoreLibs/graphics"
import "level/LevelGeometry"
import "render/camera"
import "render/perspectiveDrawing"

class("LevelPoint").extends("LevelGeometry")

function LevelPoint:init(x, y)
	LevelPoint.super.init(self)
	self.x = x
	self.y = y
	self.incomingLine = nil
	self.outgoingLine = nil
end

function LevelPoint:draw()
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	perspectiveDrawing.fillCircle(self.x, self.y, 2.5)
end
