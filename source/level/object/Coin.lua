import "level/object/LevelObject"
import "physics/PhysCircle"
import "render/camera"

class("Coin").extends("LevelObject")

local image = playdate.graphics.image.new("images/coin.png")
local imageWidth, imageHeight = image:getSize()

function Coin:init(x, y)
	Coin.super.init(self, LevelObject.Type.Coin)
	self.physObj = PhysCircle(x, y, 10):add()
end

function Coin:draw()
	local x, y = self:getPosition()
	x, y = camera.matrix:transformXY(x, y)
	local scale = camera.scale
	image:drawScaled(x - scale * imageWidth / 2, y - scale * imageHeight / 2, scale)
end

function Coin:getPosition()
	return self.physObj.position.x, self.physObj.position.y
end

function Coin:setPosition(x, y)
	self.physObj.position.x, self.physObj.position.y = x, y
end

function Coin.deserialize(data)
	return Coin(data.x, data.y)
end
