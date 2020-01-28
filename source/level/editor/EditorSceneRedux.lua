import "CoreLibs/object"
import "scene/Scene"
import "render/camera"
import "render/perspectiveDrawing"
import "process/ProcessStack"
import "level/editor/process/EditorMainMenu"
import "level/editor/EditorCursor"
import "level/editor/geometry/EditorPoint"
import "level/editor/geometry/EditorLine"
import "level/editor/geometry/EditorPolygon"

class("EditorSceneRedux").extends(Scene)

function EditorSceneRedux:init()
	EditorSceneRedux.super.init(self)
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
	self.processes = ProcessStack(EditorMainMenu())
	self.processes:start()
end

function EditorSceneRedux:update()
	self.processes:update()
	-- Loosely follow the camera
	local followDist = 80 / camera.scale
	camera.position.x = math.min(math.max(self.cursor.position.x - followDist, camera.position.x), self.cursor.position.x + followDist)
	camera.position.y = math.min(math.max(self.cursor.position.y - followDist, camera.position.y), self.cursor.position.y + followDist)
	camera:recalculatePerspective()
end

function EditorSceneRedux:draw()
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
	-- Draw the current process
	self.processes:draw()
end

function EditorSceneRedux:handleCallback(callbackName, ...)
	self.processes[callbackName](self.processes, ...)
end
