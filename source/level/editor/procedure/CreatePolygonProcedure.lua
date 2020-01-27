import "CoreLibs/object"
import "render/perspectiveDrawing"
import "level/editor/procedure/Procedure"
import "level/editor/geometry/LevelEditorPoint"
import "level/editor/geometry/LevelEditorLine"
import "level/editor/geometry/LevelEditorPolygon"

class("CreatePolygonProcedure").extends(Procedure)

function CreatePolygonProcedure:init()
	CreatePolygonProcedure.super.init(self)
	self.coordinates = {}
	scene.cursor:startSnappingToGrid()
end

function CreatePolygonProcedure:draw()
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.setLineWidth(1)
	playdate.graphics.setLineCapStyle(playdate.graphics.kLineCapStyleRound)
	if #self.coordinates > 0 then
		-- Draw lines
		local prevX, prevY = nil, nil
		for i = 1, #self.coordinates, 2 do
			local x, y = self.coordinates[i], self.coordinates[i + 1]
			perspectiveDrawing.fillCircle(x, y, 2)
			if prevX and prevY then
				perspectiveDrawing.drawLine(x, y, prevX, prevY)
			end
			prevX, prevY = x, y
		end
		-- Draw dotted line to cursor
		if self:canClosePolygon() then
			perspectiveDrawing.drawDottedLine(prevX, prevY, self.coordinates[1], self.coordinates[2])
		else
			perspectiveDrawing.drawDottedLine(prevX, prevY, scene.cursor.position.x, scene.cursor.position.y)
		end
	end
end

function CreatePolygonProcedure:advance()
	if self:canClosePolygon() then
		return true
	else
		local x, y = scene.cursor.position.x, scene.cursor.position.y
		if #self.coordinates < 2 or x ~= self.coordinates[#self.coordinates - 1] or y ~= self.coordinates[#self.coordinates] then
			table.insert(self.coordinates, x)
			table.insert(self.coordinates, y)
		end
	end
end

function CreatePolygonProcedure:finish()
	local points = {}
	local prevPoint
	for i = 1, #self.coordinates, 2 do
		local x, y = self.coordinates[i], self.coordinates[i + 1]
		local point = LevelEditorPoint(x, y)
		if prevPoint then
			LevelEditorLine(prevPoint, point)
		end
		table.insert(points, point)
		prevPoint = point
	end
	LevelEditorLine(points[#points], points[1])
	local polygon = LevelEditorPolygon(points)
	scene:addGeometry(polygon)
	scene.cursor:stopSnappingToGrid()
end

function CreatePolygonProcedure:cancel()
	scene.cursor:stopSnappingToGrid()
end

function CreatePolygonProcedure:back()
	table.remove(self.coordinates)
	table.remove(self.coordinates)
	return #self.coordinates < 1
end

function CreatePolygonProcedure:canClosePolygon()
	if #self.coordinates / 2 > 1 then
		local dx = self.coordinates[1] - scene.cursor.position.x
		local dy = self.coordinates[2] - scene.cursor.position.y
		local squareDist = dx * dx + dy * dy
		return squareDist < 4 * 4
	end
end
