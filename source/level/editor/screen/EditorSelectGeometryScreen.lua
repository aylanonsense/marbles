import "level/editor/screen/EditorScreen"
import "level/editor/geometry/EditorGeometry"

class("EditorSelectGeometryScreen").extends(EditorScreen)

function EditorSelectGeometryScreen:init()
	EditorSelectGeometryScreen.super.init(self)
	self.highlightedEditTarget = nil
	self.onSelectCallback = nil
	self.editTargets = {}
end

function EditorSelectGeometryScreen:open(callback)
	self.onSelectCallback = callback
end

function EditorSelectGeometryScreen:show()
	self.highlightedEditTarget = nil
	self.editTargets = {}
	for _, geom in ipairs(scene.geometry) do
		local editTargets = geom:getEditTargets()
		for _, target in ipairs(editTargets) do
			table.insert(self.editTargets, target)
		end
	end
end

function EditorSelectGeometryScreen:update()
	scene.cursor:update()
	-- Figure out if the cursor is highlighting an edit target
	self.highlightedEditTarget = nil
	local closestSquareDist
	for _, target in ipairs(self.editTargets) do
		local dx, dy = target.x - scene.cursor.position.x, target.y - scene.cursor.position.y
		local squareDist = dx * dx + dy * dy
		if (closestSquareDist == nil or squareDist < closestSquareDist) and squareDist < (20 / camera.scale) ^ 2 then
			closestSquareDist = squareDist
			self.highlightedEditTarget = target
		end
	end
end

function EditorSelectGeometryScreen:draw()
	-- Draw all edit targets
	for _, target in ipairs(self.editTargets) do
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		perspectiveDrawing.fillCircle(target.x, target.y, target.size / camera.scale)
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		perspectiveDrawing.drawCircle(target.x, target.y, target.size / camera.scale)
		if target == self.highlightedEditTarget then
			perspectiveDrawing.fillCircle(target.x, target.y, (target.size - 2) / camera.scale)
		end
	end
	-- Draw the cursor
	scene.cursor:draw()
end

function EditorSelectGeometryScreen:AButtonDown()
	if self.highlightedEditTarget and self.onSelectCallback then
		self.onSelectCallback(self, self.highlightedEditTarget.geom)
	end
end

function EditorSelectGeometryScreen:BButtonDown()
	self:close()
end
