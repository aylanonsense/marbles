import "CoreLibs/object"
import "scene/Scene"
import "render/camera"
import "render/perspectiveDrawing"
import "level/editor/EditorMenu"
import "level/editor/EditorCursor"
import "level/editor/procedure/CreatePolygonProcedure"
import "level/editor/procedure/SelectEditTargetProcedure"
import "level/editor/geometry/EditorPoint"
import "level/editor/geometry/EditorLine"
import "level/editor/geometry/EditorPolygon"

class("EditorScene").extends(Scene)

EditorScene.MainMenuMode = 1
EditorScene.ProcedureMode = 2
EditorScene.FreeLookMode = 3
EditorScene.EditGeometryMenuMode = 4

EditorScene.CameraScales = { 0.05, 0.10, 0.25, 0.5, 1.0, 1.5, 2.0, 3.0 }
EditorScene.CursorGridSizes = { 480, 160, 80, 40, 20, 20, 10, 10 }

function EditorScene:init()
	EditorScene.super.init(self)
	camera:reset()
	self.cameraScaleIndex = 5
	camera.scale = EditorScene.CameraScales[self.cameraScaleIndex]
	self.cursor = EditorCursor(camera.position.x, camera.position.y)
	self.mode = EditorScene.MainMenuMode
	self.procedure = nil
	-- Create a piece of geometry as a starting point
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
	self.selectedGeometry = nil
	self.mainMenu = EditorMenu("Level Editor", {
		{
			text = "Create",
			submenu = EditorMenu("Create", {
				{
					text = "Geometry",
					submenu = EditorMenu("Create Geometry", {
						{
							text = "Polygon",
							selected = function()
								self.mode = EditorScene.ProcedureMode
								self.procedure = CreatePolygonProcedure()
							end
						}
					})
				}
			})
		},
		{
			text = "Edit",
			selected = function()
				self.mode = EditorScene.ProcedureMode
				self.procedure = SelectEditTargetProcedure()
			end
		},
		{
			text = "Camera",
			submenu = EditorMenu("Camera", {
				{
					text = "Free Look",
					selected = function()
						self.mode = EditorScene.FreeLookMode
						self.cursor.position.x, self.cursor.position.y = camera.position.x, camera.position.y
					end
				},
				{
					text = "Scale (" .. camera.scale .. "x)",
					increase = function(menu, option)
						if self.cameraScaleIndex < #EditorScene.CameraScales then
							self.cameraScaleIndex += 1
							camera.scale = EditorScene.CameraScales[self.cameraScaleIndex]
							self.cursor.gridSize = EditorScene.CursorGridSizes[self.cameraScaleIndex]
							option.text = "Scale (" .. camera.scale .. "x)"
						end
					end,
					decrease = function(menu, option)
						if self.cameraScaleIndex > 1 then
							self.cameraScaleIndex -= 1
							camera.scale = EditorScene.CameraScales[self.cameraScaleIndex]
							self.cursor.gridSize = EditorScene.CursorGridSizes[self.cameraScaleIndex]
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
	self.editGeometryMenu = nil
	self.editPointMenu = EditorMenu("Edit Point", {
		{
			text = "Move"
		},
		{
			text = "Delete"
		}
	})
end

function EditorScene:update()
	if self.mode == EditorScene.MainMenuMode then
		self.mainMenu:update()
	elseif self.mode == EditorScene.EditGeometryMenuMode then
		self.editGeometryMenu:update()
	elseif self.mode == EditorScene.ProcedureMode then
		self.cursor:update()
		self.procedure:update()
	elseif self.mode == EditorScene.FreeLookMode then
		self.cursor:update()
		camera.position.x, camera.position.y = self.cursor.position.x, self.cursor.position.y
	end
	-- Loosely follow the camera
	local followDist = 50 / camera.scale
	camera.position.x = math.min(math.max(self.cursor.position.x - followDist, camera.position.x), self.cursor.position.x + followDist)
	camera.position.y = math.min(math.max(self.cursor.position.y - followDist, camera.position.y), self.cursor.position.y + followDist)
	camera:recalculatePerspective()
end

function EditorScene:draw()
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
	if self.mode == EditorScene.MainMenuMode then
		self.mainMenu:draw(10, 10)
	elseif self.mode == EditorScene.EditGeometryMenuMode then
		self.editGeometryMenu:draw(10, 10)
	elseif self.mode == EditorScene.ProcedureMode then
		self.procedure:draw()
		self.cursor:draw()
	end
end

function EditorScene:upButtonDown()
	if self.mode == EditorScene.MainMenuMode then
		self.mainMenu:highlightPreviousOption()
	elseif self.mode == EditorScene.EditGeometryMenuMode then
		self.editGeometryMenu:highlightPreviousOption()
	end
end

function EditorScene:downButtonDown()
	if self.mode == EditorScene.MainMenuMode then
		self.mainMenu:highlightNextOption()
	elseif self.mode == EditorScene.EditGeometryMenuMode then
		self.editGeometryMenu:highlightNextOption()
	end
end

function EditorScene:leftButtonDown()
	if self.mode == EditorScene.MainMenuMode then
		self.mainMenu:decrease()
	elseif self.mode == EditorScene.EditGeometryMenuMode then
		self.editGeometryMenu:decrease()
	end
end

function EditorScene:rightButtonDown()
	if self.mode == EditorScene.MainMenuMode then
		self.mainMenu:increase()
	elseif self.mode == EditorScene.EditGeometryMenuMode then
		self.editGeometryMenu:increase()
	end
end

function EditorScene:AButtonDown()
	if self.mode == EditorScene.MainMenuMode then
		self.mainMenu:select()
	elseif self.mode == EditorScene.EditGeometryMenuMode then
		self.editGeometryMenu:select()
	elseif self.mode == EditorScene.ProcedureMode then
		local isDone = self.procedure:advance()
		if isDone then
			local procedure = self.procedure
			self.mode = EditorScene.MainMenuMode
			self.procedure = nil
			procedure:finish()
		end
	end
end

function EditorScene:BButtonDown()
	if self.mode == EditorScene.MainMenuMode then
		self.mainMenu:deselect()
	elseif self.mode == EditorScene.EditGeometryMenuMode then
		self.mode = EditorScene.MainMenuMode
		self.selectedGeometry = nil
		self.editGeometryMenu = nil
	elseif self.mode == EditorScene.ProcedureMode then
		local isDone = self.procedure:back()
		if isDone then
			local procedure = self.procedure
			self.mode = EditorScene.MainMenuMode
			self.procedure = nil
			procedure:terminate()
		end
	elseif self.mode == EditorScene.FreeLookMode then
		self.mode = EditorScene.MainMenuMode
	end
end

function EditorScene:addGeometry(geom)
	table.insert(self.geometry, geom)
end

function EditorScene:editGeometry(geom, target)
	self.selectedGeometry = geom
	self.editGeometryMenu = self.editPointMenu
	self.mode = EditorScene.EditGeometryMenuMode
end
