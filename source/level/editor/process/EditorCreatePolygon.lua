import "process/Process"
import "render/perspectiveDrawing"
import "level/editor/geometry/EditorPoint"
import "level/editor/geometry/EditorLine"
import "level/editor/geometry/EditorPolygon"

class("EditorCreatePolygon").extends(Process)

function EditorCreatePolygon:init()
	EditorCreatePolygon.super.init(self)
	self.coordinates = {}
end

function EditorCreatePolygon:start()
	scene.cursor:startSnappingToGrid()
end

function EditorCreatePolygon:pause()
	scene.cursor:stopSnappingToGrid()
end

function EditorCreatePolygon:unpause()
	scene.cursor:startSnappingToGrid()
end

function EditorCreatePolygon:terminate()
	scene.cursor:stopSnappingToGrid()
	EditorCreatePolygon.super.terminate(self)
end

function EditorCreatePolygon:update()
	scene.cursor:update()
end

function EditorCreatePolygon:draw()
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
	scene.cursor:draw()
end

function EditorCreatePolygon:AButtonDown()
	if self:canClosePolygon() then
		local points = {}
		local prevPoint
		for i = 1, #self.coordinates, 2 do
			local x, y = self.coordinates[i], self.coordinates[i + 1]
			local point = EditorPoint(x, y)
			if prevPoint then
				EditorLine(prevPoint, point)
			end
			table.insert(points, point)
			prevPoint = point
		end
		EditorLine(points[#points], points[1])
		local polygon = EditorPolygon(points)
		table.insert(scene.geometry, polygon)
		self:terminate()
	else
		local x, y = scene.cursor.position.x, scene.cursor.position.y
		if #self.coordinates < 2 or x ~= self.coordinates[#self.coordinates - 1] or y ~= self.coordinates[#self.coordinates] then
			table.insert(self.coordinates, x)
			table.insert(self.coordinates, y)
		end
	end
end

function EditorCreatePolygon:BButtonDown()
	if #self.coordinates > 2 then
		table.remove(self.coordinates)
		table.remove(self.coordinates)
	else
		self:terminate()
	end
end

function EditorCreatePolygon:canClosePolygon()
	if #self.coordinates / 2 > 1 then
		local dx = self.coordinates[1] - scene.cursor.position.x
		local dy = self.coordinates[2] - scene.cursor.position.y
		local squareDist = dx * dx + dy * dy
		return squareDist < 4 * 4
	end
end
