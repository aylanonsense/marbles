import "level/editor/screen/EditorScreen"

class("EditorMoveGeometryScreen").extends(EditorScreen)

function EditorMoveGeometryScreen:init()
	self.geometry = nil
	self.translationX, self.translationY = 0, 0
	EditorMoveGeometryScreen.super.init(self)
end

function EditorMoveGeometryScreen:open(geometry)
	self.geometry = geometry
end

function EditorMoveGeometryScreen:show()
	local x, y = self.geometry:getTranslationPoint()
	scene.cursor.x, scene.cursor.y = x, y
	scene.cursor:startSnappingToGrid()
	local dx, dy = scene.cursor.x - x, scene.cursor.y - y
	self.geometry:translate(dx, dy)
	self.translationX, self.translationY = dx, dy
	scene.cursor.x, scene.cursor.y = self.geometry:getMidPoint()
end

function EditorMoveGeometryScreen:hide()
	scene.cursor:stopSnappingToGrid()
end

function EditorMoveGeometryScreen:update()
	scene.cursor.x, scene.cursor.y = self.geometry:getTranslationPoint()
	local x, y = scene.cursor.x, scene.cursor.y
	scene.cursor:update()
	local dx, dy = scene.cursor.x - x, scene.cursor.y - y
	self.geometry:translate(dx, dy)
	self.translationX += dx
	self.translationY += dy
	scene.cursor.x, scene.cursor.y = self.geometry:getMidPoint()
end

function EditorMoveGeometryScreen:draw()
	scene.cursor:draw()
end

function EditorMoveGeometryScreen:AButtonDown()
	self:close()
end

function EditorMoveGeometryScreen:BButtonDown()
	self.geometry:translate(-self.translationX, -self.translationY)
	self:close()
end
