import "CoreLibs/object"
import "render/camera"
import "fonts/fonts"
import "scene/time"

class("EditorCursor").extends()

function EditorCursor:init(x, y)
	EditorCursor.super.init(self)
	self.position = playdate.geometry.vector2D.new(x, y)
	self.snapToGrid = false
	self.gridSize = 20
end

function EditorCursor:update()
	if self.snapToGrid then
		local horizontal = (playdate.buttonJustPressed(playdate.kButtonRight) and 1 or 0) - (playdate.buttonJustPressed(playdate.kButtonLeft) and 1 or 0)
		local vertical = (playdate.buttonJustPressed(playdate.kButtonDown) and 1 or 0) - (playdate.buttonJustPressed(playdate.kButtonUp) and 1 or 0)
		local movement = self.gridSize
		local x, y = horizontal, vertical
		if camera.rotation <= 45 or camera.rotation > 315 then
			x, y = horizontal, vertical
		elseif camera.rotation <= 135 then
			x, y = -vertical, horizontal
		elseif camera.rotation <= 225 then
			x, y = -horizontal, -vertical
		else
			x, y = vertical, -horizontal
		end
		self.position.x = self.position.x + movement * x
		self.position.y = self.position.y + movement * y
	else
		local horizontal = (playdate.buttonIsPressed(playdate.kButtonRight) and 1 or 0) - (playdate.buttonIsPressed(playdate.kButtonLeft) and 1 or 0)
		local vertical = (playdate.buttonIsPressed(playdate.kButtonDown) and 1 or 0) - (playdate.buttonIsPressed(playdate.kButtonUp) and 1 or 0)
		local movement = 100 * time.dt / camera.scale
		local x, y = (horizontal * camera.right.x - vertical * camera.up.x), (horizontal * camera.right.y - vertical * camera.up.y)
		self.position.x += movement * x
		self.position.y += movement * y
	end
end

function EditorCursor:draw()
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
	local text = "<" .. math.floor(self.position.x) .. "," .. math.floor(self.position.y) .. ">"
	local textWidth, textHeight = playdate.graphics.getTextSize(text)
	playdate.graphics.setColor(playdate.graphics.kColorWhite)
	local x, y = camera.screenWidth - textWidth - 4, camera.screenHeight - textHeight - 3
	playdate.graphics.fillRect(x - 2, y - 1, textWidth + 4, textHeight + 2)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.drawText(text, x, y, playdate.graphics.kColorWhite)
end

function EditorCursor:startSnappingToGrid()
	self.snapToGrid = true
	self.position.x = self.gridSize * math.floor(self.position.x / self.gridSize + 0.5)
	self.position.y = self.gridSize * math.floor(self.position.y / self.gridSize + 0.5)
end

function EditorCursor:stopSnappingToGrid()
	self.snapToGrid = false
end
