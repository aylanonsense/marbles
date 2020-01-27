import "CoreLibs/object"
import "render/camera"
import "render/perspectiveDrawing"
import "level/editor/procedure/Procedure"

class("SelectEditTargetProcedure").extends(Procedure)

function SelectEditTargetProcedure:init()
	SelectEditTargetProcedure.super.init(self)
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

function SelectEditTargetProcedure:update(dt)
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

function SelectEditTargetProcedure:draw()
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
end

function SelectEditTargetProcedure:advance()
	if self.highlightedEditTarget then
		return true
	end
end

function SelectEditTargetProcedure:finish()
	if self.highlightedEditTarget then
		scene:editGeometry(self.highlightedEditTarget.geom, self.highlightedEditTarget)
	end
end

function SelectEditTargetProcedure:back()
	return true
end
