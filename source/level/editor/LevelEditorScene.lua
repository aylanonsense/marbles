import "CoreLibs/object"
import "scene/Scene"
import "render/camera"
import "level/editor/LevelEditorMenu"
import "level/editor/LevelEditorCursor"
import "level/editor/procedure/CreatePolygonProcedure"

class("LevelEditorScene").extends(Scene)

LevelEditorScene.MenuMode = 1
LevelEditorScene.ProcedureMode = 2

function LevelEditorScene:init()
	LevelEditorScene.super.init(self)
	camera:reset()
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
							end
						}
					})
				}
			})
		}
	})
	self.mode = LevelEditorScene.MenuMode
	self.procedure = nil
	self.cursor = LevelEditorCursor(camera.position.x, camera.position.y)
	self.geometry = {}
end

function LevelEditorScene:update(dt)
	if self.mode == LevelEditorScene.MenuMode then
		self.menu:update(dt)
	elseif self.mode == LevelEditorScene.ProcedureMode then
		self.cursor:update(dt)
		self.procedure:update(dt)
	end
	camera:recalculatePerspective()
end

function LevelEditorScene:draw()
	-- Clear the screen
	playdate.graphics.clear()
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
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

function LevelEditorScene:AButtonDown()
	if self.mode == LevelEditorScene.MenuMode then
		self.menu:select()
	elseif self.mode == LevelEditorScene.ProcedureMode then
		local isDone = self.procedure:advance()
		if isDone then
			self.procedure:finish()
			self.procedure = nil
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
			self.mode = LevelEditorScene.MenuMode
		end
	end
end
