import "render/camera"
import "level/editor/screen/EditorScreen"

class("EditorFreeLookScreen").extends("EditorScreen")

function EditorFreeLookScreen:init()
	EditorFreeLookScreen.super.init(self)
end

function EditorFreeLookScreen:open()
	scene.cursor.position.x, scene.cursor.position.y = camera.position.x, camera.position.y
end

function EditorFreeLookScreen:update()
	scene.cursor:update()
	camera.position.x, camera.position.y = scene.cursor.position.x, scene.cursor.position.y
end

function EditorFreeLookScreen:BButtonDown()
	self:close()
end
