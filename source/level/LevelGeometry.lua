import "CoreLibs/object"

class("LevelGeometry").extends()

LevelGeometry.Type = {
	Point = 1,
	Line = 2,
	Polygon = 3
}

function LevelGeometry:init(type)
	LevelGeometry.super.init(self)
	self.type = type
end

function LevelGeometry:draw() end
