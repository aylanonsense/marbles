import "render/camera"
import "level/editor/screen/EditorScreen"

class("EditorCreateObjectScreen").extends("EditorScreen")

function EditorCreateObjectScreen:init()
	EditorCreateObjectScreen.super.init(self)
end

function EditorCreateObjectScreen:open(object)
	self.object = object
end

function EditorCreateObjectScreen:show()
	scene.cursor:startSnappingToGrid()
end

function EditorCreateObjectScreen:hide()
	scene.cursor:stopSnappingToGrid()
end

function EditorCreateObjectScreen:update()
	scene.cursor:update()
	self.object:setPosition(scene.cursor.x, scene.cursor.y)
end

function EditorCreateObjectScreen:draw()
	self.object:draw()
	scene.cursor:draw()
end

function EditorCreateObjectScreen:AButtonDown()
	table.insert(scene.objects, self.object)
	self:close()
end

function EditorCreateObjectScreen:BButtonDown()
	self:close()
end
