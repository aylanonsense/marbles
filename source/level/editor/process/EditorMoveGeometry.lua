import "process/Process"

class("EditorMoveGeometry").extends(Process)

function EditorMoveGeometry:init(geometry)
	EditorMoveGeometry.super.init(self)
	self.geometry = geometry
	self.translationX, self.translationY = 0, 0
end

function EditorMoveGeometry:pause()
	scene.cursor:stopSnappingToGrid()
end

function EditorMoveGeometry:terminate()
	scene.cursor:stopSnappingToGrid()
	EditorMoveGeometry.super.terminate(self)
end

function EditorMoveGeometry:start()
	scene.cursor:startSnappingToGrid()
	-- scene.cursor.position.x, scene.cursor.position.y = self.geometry:getCenter()
	self.translationX, self.translationY = 0, 0
end

function EditorMoveGeometry:unpause()
	scene.cursor:startSnappingToGrid()
	-- scene.cursor.position.x, scene.cursor.position.y = self.geometry:getCenter()
	self.translationX, self.translationY = 0, 0
end

function EditorMoveGeometry:update()
	local x, y = scene.cursor.position.x, scene.cursor.position.y
	scene.cursor:update()
	local dx, dy = scene.cursor.position.x - x, scene.cursor.position.y - y
	self.geometry:translate(dx, dy)
	self.translationX += dx
	self.translationY += dy
end

function EditorMoveGeometry:draw()
	scene.cursor:draw()
end

function EditorMoveGeometry:AButtonDown()
	self:terminate()
end

function EditorMoveGeometry:BButtonDown()
	self.geometry:translate(-self.translationX, -self.translationY)
	self:terminate()
end
