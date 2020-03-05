import "render/camera"
import "level/editor/screen/EditorScreen"
import "fonts/fonts"

class("EditorFreeLookScreen").extends("EditorScreen")

function EditorFreeLookScreen:init()
	EditorFreeLookScreen.super.init(self)
end

function EditorFreeLookScreen:open()
	scene.cursor.x, scene.cursor.y = camera.x, camera.y
end

function EditorFreeLookScreen:update()
	scene.cursor:update()
	camera.x, camera.y = scene.cursor.x, scene.cursor.y
end

function EditorFreeLookScreen:draw()
	-- Draw the cursor position in the lower right
	playdate.graphics.setFont(fonts.FullCircle)
	local text = "<" .. math.floor(camera.x) .. "," .. math.floor(camera.y) .. ">"
	local textWidth, textHeight = playdate.graphics.getTextSize(text)
	playdate.graphics.setColor(playdate.graphics.kColorWhite)
	local x, y = camera.screenWidth - textWidth - 4, camera.screenHeight - textHeight - 3
	playdate.graphics.fillRect(x - 2, y - 1, textWidth + 4, textHeight + 2)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.drawText(text, x, y, playdate.graphics.kColorWhite)
end

function EditorFreeLookScreen:BButtonDown()
	self:close()
end
