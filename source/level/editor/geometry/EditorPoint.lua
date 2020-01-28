import "CoreLibs/object"
import "CoreLibs/graphics"
import "level/editor/geometry/EditorGeometry"
import "render/camera"
import "render/perspectiveDrawing"

class("EditorPoint").extends("EditorGeometry")

function EditorPoint:init(x, y)
	EditorPoint.super.init(self, EditorGeometry.Type.Point)
	self.x = x
	self.y = y
	self.incomingLine = nil
	self.outgoingLine = nil
	self.polygon = nil
end

function EditorPoint:draw()
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	perspectiveDrawing.fillCircle(self.x, self.y, math.min(2, 2 / camera.scale))
end

function EditorPoint:getEditTargets()
	return { { x = self.x, y = self.y, size = 5, geom = self } }
end

function EditorPoint:translate(x, y)
	self.x += x
	self.y += y
end
