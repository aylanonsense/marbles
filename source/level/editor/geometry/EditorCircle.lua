import "CoreLibs/object"
import "level/editor/geometry/EditorGeometry"
import "render/perspectiveDrawing"
import "utility/table"

class("EditorCircle").extends("EditorGeometry")

function EditorCircle:init(x, y, radius)
	EditorCircle.super.init(self, EditorGeometry.Type.Circle)
	self.x = x
	self.y = y
	self.radius = radius
	self.layer = 0
	self.moveX = 0
	self.moveY = 0
end

function EditorCircle:draw()
	if self.isVisible then
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.setPattern({ 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55 })
		perspectiveDrawing.fillCircle(self.x, self.y, self.radius)
		playdate.graphics.setPattern({})
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.setLineWidth(1)
		perspectiveDrawing.drawCircle(self.x, self.y, self.radius)
	else
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		perspectiveDrawing.drawDottedCircle(self.x, self.y, self.radius)
	end
	-- Draw move trajectory
	if self.moveX ~= 0 or self.moveY ~= 0 then
		perspectiveDrawing.drawDottedLine(self.x, self.y, self.x + self.moveX, self.y + self.moveY)
	end
end

function EditorCircle:getEditTargets()
	return { { x = self.x, y = self.y, size = 5, geom = self } }
end

function EditorCircle:getMidPoint()
	return self.x, self.y
end

function EditorCircle:getTranslationPoint()
	return self.x, self.y
end

function EditorCircle:translate(x, y)
	self.x += x
	self.y += y
end

function EditorCircle:delete()
	return removeItem(scene.geometry, self)
end
