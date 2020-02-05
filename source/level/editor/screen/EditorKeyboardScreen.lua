import "fonts/fonts"
import "level/editor/screen/EditorScreen"

class("EditorKeyboardScreen").extends("EditorScreen")

function EditorKeyboardScreen:init()
	EditorKeyboardScreen.super.init(self)
	self.label = nil
	self.textEnteredCallback = nil
end

function EditorKeyboardScreen:open(label, textEnteredCallback)
	self.label = label
	self.textEnteredCallback = textEnteredCallback
end

function EditorKeyboardScreen:show()
	playdate.keyboard.show()
end

function EditorKeyboardScreen:hide()
	playdate.keyboard.hide()
end

function EditorKeyboardScreen:draw()
	local x, y = 10, 10
	local text = self.label .. ": " .. playdate.keyboard.text
	playdate.graphics.setFont(fonts.FullCircle)
	local textWidth, textHeight = playdate.graphics.getTextSize(text)
	playdate.graphics.setColor(playdate.graphics.kColorWhite)
	playdate.graphics.fillRect(x - 2, y - 1, textWidth + 4, textHeight + 2)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.drawText(text, x + 2, y)
end

function EditorKeyboardScreen:keyboardWillHideCallback()
	if self.textEnteredCallback then
		self.textEnteredCallback(self, playdate.keyboard.text)
	end
end
