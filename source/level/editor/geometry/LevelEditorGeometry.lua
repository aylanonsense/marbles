import "CoreLibs/object"

class("LevelEditorGeometry").extends()

LevelEditorGeometry.Type = {
	Point = 1,
	Line = 2,
	Polygon = 3
}

function LevelEditorGeometry:init(type)
	LevelEditorGeometry.super.init(self)
	self.type = type
end

function LevelEditorGeometry:draw() end

function LevelEditorGeometry:getEditTargets()
	return {}
end
