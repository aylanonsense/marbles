import "CoreLibs/object"

class("CallbackHandler").extends()

-- Define empty callbacks
function CallbackHandler:handleCallback(callbackName, ...) end

function CallbackHandler:AButtonDown(...)
	self:handleCallback("AButtonDown", ...)
end

function CallbackHandler:AButtonHeld(...)
	self:handleCallback("AButtonHeld", ...)
end

function CallbackHandler:AButtonUp(...)
	self:handleCallback("AButtonUp", ...)
end

function CallbackHandler:BButtonDown(...)
	self:handleCallback("BButtonDown", ...)
end

function CallbackHandler:BButtonHeld(...)
	self:handleCallback("BButtonHeld", ...)
end

function CallbackHandler:BButtonUp(...)
	self:handleCallback("BButtonUp", ...)
end

function CallbackHandler:downButtonDown(...)
	self:handleCallback("downButtonDown", ...)
end

function CallbackHandler:downButtonHeld(...)
	self:handleCallback("downButtonHeld", ...)
end

function CallbackHandler:downButtonUp(...)
	self:handleCallback("downButtonUp", ...)
end

function CallbackHandler:leftButtonDown(...)
	self:handleCallback("leftButtonDown", ...)
end

function CallbackHandler:leftButtonHeld(...)
	self:handleCallback("leftButtonHeld", ...)
end

function CallbackHandler:leftButtonUp(...)
	self:handleCallback("leftButtonUp", ...)
end

function CallbackHandler:rightButtonDown(...)
	self:handleCallback("rightButtonDown", ...)
end

function CallbackHandler:rightButtonHeld(...)
	self:handleCallback("rightButtonHeld", ...)
end

function CallbackHandler:rightButtonUp(...)
	self:handleCallback("rightButtonUp", ...)
end

function CallbackHandler:upButtonDown(...)
	self:handleCallback("upButtonDown", ...)
end

function CallbackHandler:upButtonHeld(...)
	self:handleCallback("upButtonHeld", ...)
end

function CallbackHandler:upButtonUp(...)
	self:handleCallback("upButtonUp", ...)
end

function CallbackHandler:cranked(...)
	self:handleCallback("cranked", ...)
end

function CallbackHandler:keyPressed(...)
	self:handleCallback("keyPressed", ...)
end

function CallbackHandler:keyReleased(...)
	self:handleCallback("keyReleased", ...)
end

function CallbackHandler:debugDraw(...)
	self:handleCallback("debugDraw", ...)
end
