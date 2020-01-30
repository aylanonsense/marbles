import "level/editor/screen/EditorScreen"

class("EditorMenuScreen").extends("EditorScreen")

function EditorMenuScreen:init(menu, canCloseMenu)
	EditorMenuScreen.super.init(self)
	self.menu = menu
	self.canCloseMenu = (canCloseMenu ~= false)
end

function EditorMenuScreen:update()
	self.menu:update()
end

function EditorMenuScreen:draw()
	self.menu:draw()
end

function EditorMenuScreen:AButtonDown()
	self.menu:select()
end

function EditorMenuScreen:BButtonDown()
	if not self.menu:deselect() then
		if self.canCloseMenu then
			self:close()
		end
	end
end

function EditorMenuScreen:upButtonDown()
	self.menu:highlightPreviousOption()
end

function EditorMenuScreen:downButtonDown()
	self.menu:highlightNextOption()
end

function EditorMenuScreen:leftButtonDown()
	self.menu:decrease()
end

function EditorMenuScreen:rightButtonDown()
	self.menu:increase()
end
