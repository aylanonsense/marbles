import "CoreLibs/object"
import "CoreLibs/graphics"
import "level/LevelGeometry"
import "render/camera"

class("LevelPolygon").extends("LevelGeometry")

function LevelPolygon:init(points)
	LevelPolygon.super.init(self)
	self.points = points
end

function LevelPolygon:draw()
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
