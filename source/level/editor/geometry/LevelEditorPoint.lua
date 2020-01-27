import "CoreLibs/object"
import "CoreLibs/graphics"
import "level/editor/geometry/LevelEditorGeometry"
import "render/camera"
import "render/perspectiveDrawing"

class("LevelEditorPoint").extends("LevelEditorGeometry")

function LevelEditorPoint:init(x, y)
	LevelEditorPoint.super.init(self, LevelEditorGeometry.Type.Point)
	self.x = x
	self.y = y
	self.incomingLine = nil
	self.outgoingLine = nil
	self.polygon = nil
end

function LevelEditorPoint:draw()
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	perspectiveDrawing.fillCircle(self.x, self.y, math.min(2, 2 / camera.scale))
end

function LevelEditorPoint:getEditTargets()
	return { { x = self.x, y = self.y, size = 5, geom = self } }
end
