import "process/Process"
import "level/editor/geometry/EditorGeometry"
import "level/editor/process/EditorPointMenu"

class("EditorSelectGeometry").extends(Process)

function EditorSelectGeometry:init()
	EditorSelectGeometry.super.init(self)
	self.highlightedEditTarget = nil
	self.editTargets = {}
end

function EditorSelectGeometry:start()
	self:findEditTargets()
end

function EditorSelectGeometry:unpause()
	self:findEditTargets()
end

function EditorSelectGeometry:findEditTargets()
	self.highlightedEditTarget = nil
	-- Find all edit targets
	self.editTargets = {}
	for _, geom in ipairs(scene.geometry) do
		local editTargets = geom:getEditTargets()
		for _, target in ipairs(editTargets) do
			table.insert(self.editTargets, target)
		end
	end
end

function EditorSelectGeometry:update()
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

function EditorSelectGeometry:draw()
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

function EditorSelectGeometry:AButtonDown()
	if self.highlightedEditTarget then
		if self.highlightedEditTarget.geom.type == EditorGeometry.Type.Point then
			self:spawnProcess(EditorPointMenu(self.highlightedEditTarget.geom))
		end
	end
end

function EditorSelectGeometry:BButtonDown()
	self:terminate()
end
