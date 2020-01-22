import "CoreLibs/object"
import "scene/Scene"
import "render/camera"
import "level/editor/Menu"

class("LevelEditorScene").extends(Scene)

LevelEditorScene.MainMenuMode = 1
LevelEditorScene.CameraMode = 2
LevelEditorScene.CreateMenuMode = 3

function LevelEditorScene:init()
	LevelEditorScene.super.init(self)
	camera:reset()
	self.mainMenu = Menu(10, 10, {
		{
			text = "Camera",
			selected = function()
				self:setMode(LevelEditorScene.CameraMode)
			end
		},
		{
			text = "Create",
			selected = function()
				self:setMode(LevelEditorScene.CreateMenuMode)
			end
		}
	})
	self.createMenu = Menu(10, 10, {
		{
			text = "Geometry"
		}
	})
	self:setMode(LevelEditorScene.MainMenuMode)
end

function LevelEditorScene:update(dt)
	if self.menu then
		self.menu:update(dt)
	end
end

function LevelEditorScene:draw()
	-- Clear the screen
	playdate.graphics.clear()
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	-- Draw the menu
	if self.menu then
		self.menu:draw()
	end
end

function LevelEditorScene:setMode(mode)
	self.mode = mode
	if self.mode == LevelEditorScene.MainMenuMode then
		self.menu = self.mainMenu
	elseif self.mode == LevelEditorScene.CameraMode then
		self.menu = nil
	elseif self.mode == LevelEditorScene.CreateMenuMode then
		self.menu = self.createMenu
	end
end

function LevelEditorScene:upButtonDown()
	if self.menu then
		self.menu:navigateUp()
	end
end

function LevelEditorScene:downButtonDown()
	if self.menu then
		self.menu:navigateDown()
	end
end

function LevelEditorScene:AButtonDown()
	if self.menu then
		self.menu:select()
	end
end

function LevelEditorScene:BButtonDown()
	if self.mode == LevelEditorScene.CameraMode then
		self:setMode(LevelEditorScene.MainMenuMode)
	elseif self.mode == LevelEditorScene.CreateMenuMode then
		self:setMode(LevelEditorScene.MainMenuMode)
	end
end
