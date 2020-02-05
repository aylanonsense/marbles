import "level/editor/screen/EditorScreen"
import "render/perspectiveDrawing"
import "level/editor/geometry/EditorCircle"

class("EditorCreateCircleScreen").extends(EditorScreen)

function EditorCreateCircleScreen:init()
	EditorCreateCircleScreen.super.init(self)
end

function EditorCreateCircleScreen:open()
	self.centerPoint = nil
	self.radius = 10
end

function EditorCreateCircleScreen:update()
	if not self.centerPoint then
		scene.cursor:update()
	else
		local horizontal = (playdate.buttonJustPressed(playdate.kButtonRight) and 1 or 0) - (playdate.buttonJustPressed(playdate.kButtonLeft) and 1 or 0)
		local vertical = (playdate.buttonJustPressed(playdate.kButtonDown) and 1 or 0) - (playdate.buttonJustPressed(playdate.kButtonUp) and 1 or 0)
		self.radius += 5 * horizontal - 5 * vertical
	end
end

function EditorCreateCircleScreen:draw()
	if self.centerPoint then
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.setLineWidth(1)
		playdate.graphics.setLineCapStyle(playdate.graphics.kLineCapStyleRound)
		perspectiveDrawing.drawCircle(self.centerPoint.x, self.centerPoint.y, math.abs(self.radius))
		perspectiveDrawing.drawLine(self.centerPoint.x, self.centerPoint.y, self.centerPoint.x + self.radius, self.centerPoint.y)
	else
		scene.cursor:draw()
	end
end

function EditorCreateCircleScreen:show()
	scene.cursor:startSnappingToGrid()
end

function EditorCreateCircleScreen:hide()
	scene.cursor:stopSnappingToGrid()
end

function EditorCreateCircleScreen:AButtonDown()
	if self.centerPoint then
		local circle = EditorCircle(self.centerPoint.x, self.centerPoint.y, math.abs(self.radius))
		table.insert(scene.geometry, circle)
		self:close()
	else
		self.centerPoint = { x = scene.cursor.position.x, y = scene.cursor.position.y }
		self.radius = 10
	end
end

function EditorCreateCircleScreen:BButtonDown()
	if self.centerPoint then
		self.centerPoint = nil
		self.radius = 10
	else
		self:close()
	end
end
