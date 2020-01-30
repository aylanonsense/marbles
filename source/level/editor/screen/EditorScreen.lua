import "CoreLibs/object"
import "utility/CallbackHandler"

class("EditorScreen").extends("CallbackHandler")

function EditorScreen:init()
	EditorScreen.super.init(self)
	self.subScreen = nil
	self.onCloseCallback = nil
	self.isOpen = false
end

function EditorScreen:openAndShow(...)
	self.isOpen = true
	self:open(...)
	if self.isOpen then
		self:show()
	end
	return self
end

function EditorScreen:open(...) end

function EditorScreen:update() end

function EditorScreen:draw() end

function EditorScreen:show() end

function EditorScreen:hide() end

function EditorScreen:close(...)
	self.isOpen = false
	self:hide()
	if self.onCloseCallback then
		self.onCloseCallback(...)
	end
end

function EditorScreen:onClose(callback)
	self.onCloseCallback = callback
end

function EditorScreen:openAndShowSubScreen(subScreen, ...)
	self.subScreen = subScreen
	subScreen:onClose(function()
		self:show()
		self.subScreen = nil
	end)
	self:hide()
	subScreen:openAndShow(...)
end

function EditorScreen:getOpenScreen()
	if self.subScreen then
		return self.subScreen:getOpenScreen()
	else
		return self
	end
end
