import "CoreLibs/object"

class("EditorGeometry").extends()

EditorGeometry.Type = {
	Point = 1,
	Line = 2,
	Polygon = 3,
	Circle = 4
}

function EditorGeometry:init(type)
	EditorGeometry.super.init(self)
	self.type = type
  self.isSolid = true
  self.isVisible = true
end

function EditorGeometry:draw() end

function EditorGeometry:getEditTargets()
	return {}
end

function EditorGeometry:getMidPoint() end

function EditorGeometry:getTranslationPoint() end

function EditorGeometry:translate(x, y) end

function EditorGeometry:delete() end
