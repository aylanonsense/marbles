import "CoreLibs/object"
import "scene/Scene"
import "render/camera"
import "render/perspectiveDrawing"
import "level/editor/serialize"
import "level/editor/screen/EditorSelectLevelScreen"
import "level/editor/EditorCursor"
import "level/editor/geometry/EditorPoint"
import "level/editor/geometry/EditorLine"
import "level/editor/geometry/EditorPolygon"
import "level/editor/EditorTestLevelScene"
import "level/levelIO"

class("EditorScene").extends(Scene)

function EditorScene:init()
	EditorScene.super.init(self)
	camera:reset()
	camera:recalculatePerspective()
	self.spawn = { x = 0, y = 0 }
	self.geometry = {}
	self.objects = {}
	-- Create a cursor that child screens will use
	self.cursor = EditorCursor(camera.x, camera.y)
	-- Create the main screen
	self.screen = EditorSelectLevelScreen():openAndShow()
	self.level = nil
	self.worldBoundary = nil
end

function EditorScene:update()
	self.screen:getOpenScreen():update()
	-- Loosely follow the camera
	local followDist = 80 / camera.scale
	camera.x = math.min(math.max(self.cursor.x - followDist, camera.x), self.cursor.x + followDist)
	camera.y = math.min(math.max(self.cursor.y - followDist, camera.y), self.cursor.y + followDist)
	camera:recalculatePerspective()
end

function EditorScene:draw()
	-- Clear the screen
	playdate.graphics.clear()
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.setLineWidth(1)
	playdate.graphics.setLineCapStyle(playdate.graphics.kLineCapStyleRound)
	-- Draw grid lines
	local gridSize = (camera.scale >= 0.5) and 40 or 480
	local xMid = gridSize * math.floor(camera.x / gridSize + 0.5)
	local yMid = gridSize * math.floor(camera.y / gridSize + 0.5)
	for x = xMid - 10 * gridSize, xMid + 10 * gridSize, gridSize do
		perspectiveDrawing.drawDottedLine(x, camera.y - 10 * gridSize, x, camera.y + 10 * gridSize, 5)
	end
	for y = yMid - 10 * gridSize, yMid + 10 * gridSize, gridSize do
		perspectiveDrawing.drawDottedLine(camera.x - 10 * gridSize, y, camera.x + 10 * gridSize, y, 5)
	end
	-- Draw a cross at the origin
	perspectiveDrawing.drawLine(-7 / camera.scale, 0, 7 / camera.scale, 0)
	perspectiveDrawing.drawLine(0, -7 / camera.scale, 0, 7 / camera.scale)
	-- Draw the spawn point
	perspectiveDrawing.drawDottedCircle(self.spawn.x, self.spawn.y, 15, 2)
	-- Draw all the level geometry
	for _, geom in pairs(self.geometry) do
		geom:draw()
	end
	-- Draw all the objects
	for _, obj in pairs(self.objects) do
		obj:draw()
	end
	-- Draw the current screen
	self.screen:getOpenScreen():draw()
end

function EditorScene:handleCallback(callbackName, ...)
	local screen = self.screen:getOpenScreen()
	screen[callbackName](screen, ...)
end

function EditorScene:loadLevel(levelInfo, editorLevelData)
	deserializeEditorLevelData(editorLevelData)
end

function EditorScene:saveLevel(levelInfo)
	local playableLevelData = serializePlayableLevelData()
	local editorLevelData = serializeEditorLevelData()
	saveLevelData(levelInfo, playableLevelData, editorLevelData)
end

function EditorScene:saveAndTestLevel(levelInfo)
	self:saveLevel(levelInfo)
	Scene.setScene(EditorTestLevelScene(levelInfo, self))
end
