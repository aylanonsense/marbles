import "CoreLibs/object"
import "CoreLibs/graphics"
import "level/editor/geometry/LevelEditorGeometry"
import "render/camera"

class("LevelEditorPolygon").extends("LevelEditorGeometry")

function LevelEditorPolygon:init(points)
	LevelEditorPolygon.super.init(self, LevelEditorGeometry.Type.Polygon)
	self.points = points
	for _, point in ipairs(self.points) do
		point.polygon = self
	end
end

function LevelEditorPolygon:draw()
	local coordinates = {}
	for i = 1, #self.points do
		local x, y = camera.matrix:transformXY(self.points[i].x, self.points[i].y)
		table.insert(coordinates, x)
		table.insert(coordinates, y)
	end
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.setPattern({ 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55 })
	playdate.graphics.fillPolygon(table.unpack(coordinates))
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.setPattern({})
	for i = 1, #self.points do
		local point = self.points[i]
		point:draw()
		point.outgoingLine:draw()
	end
end

function LevelEditorPolygon:getEditTargets()
	local minX, maxX, minY, maxY
	for k, point in ipairs(self.points) do
		minX = (minX == null or point.x < minX) and point.x or minX
		maxX = (maxX == null or point.x > maxX) and point.x or maxX
		minY = (minY == null or point.y < minY) and point.y or minY
		maxY = (maxY == null or point.y > maxY) and point.y or maxY
	end
	local editTargets = { { x = (minX + maxX) / 2, y = (minY + maxY) / 2, size = 5, geom = self } }
	for _, point in ipairs(self.points) do
		local pointEditTargets = point:getEditTargets()
		for _, target in ipairs(pointEditTargets) do
			table.insert(editTargets, target)
		end
		local lineEditTargets = point.outgoingLine:getEditTargets()
		for _, target in ipairs(lineEditTargets) do
			table.insert(editTargets, target)
		end
	end
	return editTargets
end
