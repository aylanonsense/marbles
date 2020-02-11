import "level/editor/screen/EditorScreen"

class("EditorMoveObjectScreen").extends(EditorScreen)

function EditorMoveObjectScreen:init()
	self.obj = nil
	self.translationX, self.translationY = 0, 0
	EditorMoveObjectScreen.super.init(self)
end

function EditorMoveObjectScreen:open(obj)
	self.obj = obj
end

function EditorMoveObjectScreen:show()
	local x, y = self.obj:getPosition()
	scene.cursor.position.x, scene.cursor.position.y = x, y
	scene.cursor:startSnappingToGrid()
	local dx, dy = scene.cursor.position.x - x, scene.cursor.position.y - y
	self.obj:translate(dx, dy)
	self.translationX, self.translationY = dx, dy
end

function EditorMoveObjectScreen:hide()
	scene.cursor:stopSnappingToGrid()
end

function EditorMoveObjectScreen:update()
	local x, y = scene.cursor.position.x, scene.cursor.position.y
	scene.cursor:update()
	local dx, dy = scene.cursor.position.x - x, scene.cursor.position.y - y
	self.obj:translate(dx, dy)
	self.translationX += dx
	self.translationY += dy
end

function EditorMoveObjectScreen:draw()
	scene.cursor:draw()
end

function EditorMoveObjectScreen:AButtonDown()
	self:close()
end

function EditorMoveObjectScreen:BButtonDown()
	self.obj:translate(-self.translationX, -self.translationY)
	self:close()
end
