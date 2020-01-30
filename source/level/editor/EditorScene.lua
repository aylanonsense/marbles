import "CoreLibs/object"
import "scene/Scene"
import "render/camera"
import "render/perspectiveDrawing"
import "level/editor/screen/EditorMainMenuScreen"
import "level/editor/EditorCursor"
import "level/editor/geometry/EditorPoint"
import "level/editor/geometry/EditorLine"
import "level/editor/geometry/EditorPolygon"

class("EditorScene").extends(Scene)

function EditorScene:init()
	EditorScene.super.init(self)
	camera:reset()
	camera:recalculatePerspective()
	-- Create some basic geometry
	local points = {
		EditorPoint(-40, -40),
		EditorPoint(40, -40),
		EditorPoint(40, 40),
		EditorPoint(-40, 40)
	}
	EditorLine(points[1], points[2])
	EditorLine(points[2], points[3])
	EditorLine(points[3], points[4])
	EditorLine(points[4], points[1])
	self.geometry = { EditorPolygon(points) }
	-- Create a cursor that child processes will use
	self.cursor = EditorCursor(camera.position.x, camera.position.y)
	-- Create the main menu process
	self.screen = EditorMainMenuScreen():openAndShow()
end

function EditorScene:update()
	self.screen:getOpenScreen():update()
	-- Loosely follow the camera
	local followDist = 80 / camera.scale
	camera.position.x = math.min(math.max(self.cursor.position.x - followDist, camera.position.x), self.cursor.position.x + followDist)
	camera.position.y = math.min(math.max(self.cursor.position.y - followDist, camera.position.y), self.cursor.position.y + followDist)
	camera:recalculatePerspective()
end

function EditorScene:draw()
	-- Clear the screen
	playdate.graphics.clear()
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	-- Draw grid lines
	local gridSize = (camera.scale >= 0.5) and 40 or 480
	local xMid = gridSize * math.floor(camera.position.x / gridSize + 0.5)
	local yMid = gridSize * math.floor(camera.position.y / gridSize + 0.5)
	for x = xMid - 10 * gridSize, xMid + 10 * gridSize, gridSize do
		perspectiveDrawing.drawDottedLine(x, camera.position.y - 10 * gridSize, x, camera.position.y + 10 * gridSize, 5)
	end
	for y = yMid - 10 * gridSize, yMid + 10 * gridSize, gridSize do
		perspectiveDrawing.drawDottedLine(camera.position.x - 10 * gridSize, y, camera.position.x + 10 * gridSize, y, 5)
	end
	-- Draw all the level geometry
	for k, geom in pairs(self.geometry) do
		geom:draw()
	end
	-- Draw the current screen
	self.screen:getOpenScreen():draw()
end

function EditorScene:handleCallback(callbackName, ...)
	local screen = self.screen:getOpenScreen()
	screen[callbackName](screen, ...)
end
