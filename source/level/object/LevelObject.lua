import "CoreLibs/object"

class("LevelObject").extends()

LevelObject.Type = {
	Circle = "Circle",
	Coin = "Coin",
	Marble = "Marble",
	Polygon = "Polygon",
	WorldBoundary = "WorldBoundary"
}

function LevelObject:init(type)
	LevelObject.super.init(self)
	self.type = type
end

function LevelObject:update() end

function LevelObject:draw() end

function LevelObject:getPosition()
	return 0, 0
end

function LevelObject:setPosition(x, y) end

function LevelObject:serialize()
	local x, y = self:getPosition()
	return {
		type = self.type,
		x = x,
		y = y
	}
end
