import "level/editor/screen/EditorScreen"
import "level/editor/geometry/EditorGeometry"

class("EditorSelectGeometryOrObjectScreen").extends(EditorScreen)

function EditorSelectGeometryOrObjectScreen:init()
	EditorSelectGeometryOrObjectScreen.super.init(self)
	self.highlightedEditTarget = nil
	self.onSelectCallback = nil
	self.editTargets = {}
end

function EditorSelectGeometryOrObjectScreen:open(callback)
	self.onSelectCallback = callback
end

function EditorSelectGeometryOrObjectScreen:show()
	self.highlightedEditTarget = nil
	self.editTargets = {}
	for _, geom in ipairs(scene.geometry) do
		local editTargets = geom:getEditTargets()
		for _, target in ipairs(editTargets) do
			table.insert(self.editTargets, target)
		end
	end
	for _, obj in ipairs(scene.objects) do
		local x, y = obj:getPosition()
		table.insert(self.editTargets, { x = x, y = y, size = 5, obj = obj })
	end
end

function EditorSelectGeometryOrObjectScreen:update()
	scene.cursor:update()
	-- Figure out if the cursor is highlighting an edit target
	self.highlightedEditTarget = nil
	local closestSquareDist
	for _, target in ipairs(self.editTargets) do
		local dx, dy = target.x - scene.cursor.x, target.y - scene.cursor.y
		local squareDist = dx * dx + dy * dy
		if (closestSquareDist == nil or squareDist < closestSquareDist) and squareDist < (20 / camera.scale) ^ 2 then
			closestSquareDist = squareDist
			self.highlightedEditTarget = target
		end
	end
end

function EditorSelectGeometryOrObjectScreen:draw()
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

function EditorSelectGeometryOrObjectScreen:AButtonDown()
	if self.highlightedEditTarget and self.onSelectCallback then
		if self.highlightedEditTarget.geom then
			self.onSelectCallback(self, self.highlightedEditTarget.geom, true)
		else
			self.onSelectCallback(self, self.highlightedEditTarget.obj, false)
		end
	end
end

function EditorSelectGeometryOrObjectScreen:BButtonDown()
	self:close()
end
