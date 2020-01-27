import "CoreLibs/object"
import "render/camera"
import "render/perspectiveDrawing"
import "level/editor/procedure/Procedure"
import "level/LevelGeometry"

class("EditProcedure").extends(Procedure)

function EditProcedure:init()
	EditProcedure.super.init(self)
	self.editTargets = {}
	self.highlightedEditTarget = nil
end

function EditProcedure:update(dt)
	self.editTargets = self:findAllEditTargets()
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

function EditProcedure:draw()
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

function EditProcedure:findAllEditTargets()
	local targets = {}
	for _, geom in ipairs(scene.geometry) do
		if geom.type == LevelGeometry.Type.Point then
			table.insert(targets, self:getEditTargetForPoint(geom))
		elseif geom.type == LevelGeometry.Type.Line then
			table.insert(targets, self:getEditTargetForLine(geom))
			self:drawLineSnapTargets(geom)
		elseif geom.type == LevelGeometry.Type.Polygon then
			table.insert(targets, self:getEditTargetForPolygon(geom))
			for k, point in ipairs(geom.points) do
				table.insert(targets, self:getEditTargetForPoint(point))
				table.insert(targets, self:getEditTargetForLine(point.outgoingLine))
			end
		end
	end
	return targets
end

function EditProcedure:getEditTargetForPoint(point)
	return { x = point.x, y = point.y, size = 5, geom = point }
end

function EditProcedure:getEditTargetForLine(line)
	return { x = (line.startPoint.x + line.endPoint.x) / 2, y = (line.startPoint.y + line.endPoint.y) / 2, size = 4, geom = line }
end

function EditProcedure:getEditTargetForPolygon(polygon)
	local minX, maxX, minY, maxY
	for k, point in ipairs(polygon.points) do
		minX = (minX == null or point.x < minX) and point.x or minX
		maxX = (maxX == null or point.x > maxX) and point.x or maxX
		minY = (minY == null or point.y < minY) and point.y or minY
		maxY = (maxY == null or point.y > maxY) and point.y or maxY
	end
	return { x = (minX + maxX) / 2, y = (minY + maxY) / 2, size = 5, geom = polygon }
end

function EditProcedure:advance()
end

function EditProcedure:finish()
end

function EditProcedure:back()
	return true
end

function EditProcedure:cancel()
end
