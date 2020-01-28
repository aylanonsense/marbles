import "process/Process"

class("EditorMenuProcess").extends("Process")

function EditorMenuProcess:init(menu, canCloseMenu)
	EditorMenuProcess.super.init(self)
	self.menu = menu
	self.canCloseMenu = (canCloseMenu ~= false)
end

function EditorMenuProcess:update()
	self.menu:update()
end

function EditorMenuProcess:draw()
	self.menu:draw(10, 10)
end

function EditorMenuProcess:AButtonDown()
	self.menu:select()
end

function EditorMenuProcess:BButtonDown()
	if not self.menu:deselect() then
		if self.canCloseMenu then
			self:terminate()
		end
	end
end

function EditorMenuProcess:upButtonDown()
	self.menu:highlightPreviousOption()
end

function EditorMenuProcess:downButtonDown()
	self.menu:highlightNextOption()
end

function EditorMenuProcess:leftButtonDown()
	self.menu:decrease()
end

function EditorMenuProcess:rightButtonDown()
	self.menu:increase()
end
