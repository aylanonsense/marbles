import "render/camera"
import "process/Process"

class("EditorFreeLook").extends("Process")

function EditorFreeLook:init()
	EditorFreeLook.super.init(self)
end

function EditorFreeLook:start()
	scene.cursor.position.x, scene.cursor.position.y = camera.position.x, camera.position.y
end

function EditorFreeLook:update()
	scene.cursor:update()
	camera.position.x, camera.position.y = scene.cursor.position.x, scene.cursor.position.y
end

function EditorFreeLook:BButtonDown()
	self:terminate()
end
