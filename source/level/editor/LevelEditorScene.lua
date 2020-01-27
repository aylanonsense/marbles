import "CoreLibs/object"
import "scene/Scene"
import "render/camera"
import "render/perspectiveDrawing"
import "level/editor/LevelEditorMenu"
import "level/editor/LevelEditorCursor"
import "level/editor/procedure/CreatePolygonProcedure"

class("LevelEditorScene").extends(Scene)

LevelEditorScene.MenuMode = 1
LevelEditorScene.ProcedureMode = 2
LevelEditorScene.FreeLookMode = 3

LevelEditorScene.CameraScales = { 0.05, 0.10, 0.25, 0.5, 1.0, 1.5, 2.0, 3.0 }
LevelEditorScene.CursorGridSizes = { 480, 160, 80, 40, 20, 20, 10, 10 }

function LevelEditorScene:init()
	LevelEditorScene.super.init(self)
	camera:reset()
	self.cameraScaleIndex = 5
	camera.scale = LevelEditorScene.CameraScales[self.cameraScaleIndex]
	self.cursor = LevelEditorCursor(camera.position.x, camera.position.y)
	self.mode = LevelEditorScene.MenuMode
	self.procedure = nil
	self.geometry = {}
	self.menu = LevelEditorMenu("Level Editor", {
		{
			text = "Create",
			submenu = LevelEditorMenu("Create", {
				{
					text = "Geometry",
					submenu = LevelEditorMenu("Create Geometry", {
						{
							text = "Polygon",
							selected = function()
								self.mode = LevelEditorScene.ProcedureMode
								self.procedure = CreatePolygonProcedure()
								self.cursor:startSnappingToGrid()
							end
						}
					})
				}
			})
		},
		{
			text = "Camera",
			submenu = LevelEditorMenu("Camera", {
				{
					text = "Free Look",
					selected = function()
						self.mode = LevelEditorScene.FreeLookMode
						self.cursor.position.x, self.cursor.position.y = camera.position.x, camera.position.y
					end
				},
				{
					text = "Scale (" .. camera.scale .. "x)",
					increase = function(menu, option)
						if self.cameraScaleIndex < #LevelEditorScene.CameraScales then
							self.cameraScaleIndex += 1
							camera.scale = LevelEditorScene.CameraScales[self.cameraScaleIndex]
							self.cursor.gridSize = LevelEditorScene.CursorGridSizes[self.cameraScaleIndex]
							option.text = "Scale (" .. camera.scale .. "x)"
						end
					end,
					decrease = function(menu, option)
						if self.cameraScaleIndex > 1 then
							self.cameraScaleIndex -= 1
							camera.scale = LevelEditorScene.CameraScales[self.cameraScaleIndex]
							self.cursor.gridSize = LevelEditorScene.CursorGridSizes[self.cameraScaleIndex]
							option.text = "Scale (" .. camera.scale .. "x)"
						end
					end
				},
				{
					text = "Rotation (0)",
					increase = function(menu, option)
						camera.rotation += 15
						if camera.rotation >= 360 then
							camera.rotation -= 360
						end
						option.text = "Rotation (" .. camera.rotation .. ")"
					end,
					decrease = function(menu, option)
						camera.rotation -= 15
						if camera.rotation < 0 then
							camera.rotation += 360
						end
						option.text = "Rotation (" .. camera.rotation .. ")"
					end
				}
			})
		}
	})
end

function LevelEditorScene:update(dt)
	if self.mode == LevelEditorScene.MenuMode then
		self.menu:update(dt)
	elseif self.mode == LevelEditorScene.ProcedureMode then
		self.cursor:update(dt)
		self.procedure:update(dt)
	elseif self.mode == LevelEditorScene.FreeLookMode then
		self.cursor:update(dt)
		camera.position.x, camera.position.y = self.cursor.position.x, self.cursor.position.y
	end
	-- Loosely follow the camera
	local followDist = 50 / camera.scale
	camera.position.x = math.min(math.max(self.cursor.position.x - followDist, camera.position.x), self.cursor.position.x + followDist)
	camera.position.y = math.min(math.max(self.cursor.position.y - followDist, camera.position.y), self.cursor.position.y + followDist)
	camera:recalculatePerspective()
end

function LevelEditorScene:draw()
	-- Clear the screen
	playdate.graphics.clear()
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	-- Draw grid points
	if camera.scale > 0.25 then
		local gridSize = 40
		local xMid = gridSize * math.floor(camera.position.x / gridSize + 0.5)
		local yMid = gridSize * math.floor(camera.position.y / gridSize + 0.5)
		for x = xMid - 10 * gridSize, xMid + 10 * gridSize, gridSize do
				perspectiveDrawing.drawDottedLine(x, camera.position.y - 10 * gridSize, x, camera.position.y + 10 * gridSize, 5)
		end
		for y = yMid - 10 * gridSize, yMid + 10 * gridSize, gridSize do
				perspectiveDrawing.drawDottedLine(camera.position.x - 10 * gridSize, y, camera.position.x + 10 * gridSize, y, 5)
		end
	end
	-- Draw all the level geometry
	for k, geom in pairs(self.geometry) do
		geom:draw()
	end
	-- Draw the current menu or procedure
	if self.mode == LevelEditorScene.MenuMode then
		self.menu:draw(10, 10)
	elseif self.mode == LevelEditorScene.ProcedureMode then
		self.procedure:draw()
		self.cursor:draw()
	end
end

function LevelEditorScene:addGeometry(geom)
	table.insert(self.geometry, geom)
end

function LevelEditorScene:upButtonDown()
	if self.mode == LevelEditorScene.MenuMode then
		self.menu:highlightPreviousOption()
	end
end

function LevelEditorScene:downButtonDown()
	if self.mode == LevelEditorScene.MenuMode then
		self.menu:highlightNextOption()
	end
end

function LevelEditorScene:leftButtonDown()
	if self.mode == LevelEditorScene.MenuMode then
		self.menu:decrease()
	end
end

function LevelEditorScene:rightButtonDown()
	if self.mode == LevelEditorScene.MenuMode then
		self.menu:increase()
	end
end

function LevelEditorScene:AButtonDown()
	if self.mode == LevelEditorScene.MenuMode then
		self.menu:select()
	elseif self.mode == LevelEditorScene.ProcedureMode then
		local isDone = self.procedure:advance()
		if isDone then
			self.procedure:finish()
			self.procedure = nil
			self.cursor:stopSnappingToGrid()
			self.mode = LevelEditorScene.MenuMode
		end
	end
end

function LevelEditorScene:BButtonDown()
	if self.mode == LevelEditorScene.MenuMode then
		self.menu:deselect()
	elseif self.mode == LevelEditorScene.ProcedureMode then
		local isDone = self.procedure:back()
		if isDone then
			self.procedure:cancel()
			self.procedure = nil
			self.cursor:stopSnappingToGrid()
			self.mode = LevelEditorScene.MenuMode
		end
	elseif self.mode == LevelEditorScene.FreeLookMode then
		self.mode = LevelEditorScene.MenuMode
	end
end
