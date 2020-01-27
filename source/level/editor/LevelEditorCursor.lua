import "CoreLibs/object"
import "render/camera"
import "fonts/fonts"

class("LevelEditorCursor").extends()

function LevelEditorCursor:init(x, y)
	LevelEditorCursor.super.init(self)
	self.position = playdate.geometry.vector2D.new(x, y)
end

function LevelEditorCursor:update(dt)
	local horizontal = (playdate.buttonIsPressed(playdate.kButtonRight) and 1 or 0) - (playdate.buttonIsPressed(playdate.kButtonLeft) and 1 or 0)
	local vertical = (playdate.buttonIsPressed(playdate.kButtonDown) and 1 or 0) - (playdate.buttonIsPressed(playdate.kButtonUp) and 1 or 0)
	self.position.x += 100 * horizontal * dt
	self.position.y += 100 * vertical * dt
end

function LevelEditorCursor:draw()
	-- Draw an X where the cursor is
	local x, y = camera.matrix:transformXY(self.position.x, self.position.y)
	playdate.graphics.setLineCapStyle(playdate.graphics.kLineCapStyleRound)
	playdate.graphics.setColor(playdate.graphics.kColorWhite)
	playdate.graphics.setLineWidth(4)
	playdate.graphics.drawLine(x - 7, y, x + 7, y)
	playdate.graphics.drawLine(x, y - 7, x, y + 7)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.setLineWidth(2)
	playdate.graphics.drawLine(x - 6, y, x + 6, y)
	playdate.graphics.drawLine(x, y - 6, x, y + 6)
	-- Draw the cursor position in the lower right
	local text = "<" .. math.floor(self.position.x + 0.5) .. "," .. math.floor(self.position.y + 0.5) .. ">"
	local textWidth, textHeight = playdate.graphics.getTextSize(text)
	playdate.graphics.setColor(playdate.graphics.kColorWhite)
	local x, y = camera.screenWidth - textWidth - 4, camera.screenHeight - textHeight - 3
	playdate.graphics.fillRect(x - 2, y - 1, textWidth + 4, textHeight + 2)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.drawText(text, x, y, playdate.graphics.kColorWhite)
end
