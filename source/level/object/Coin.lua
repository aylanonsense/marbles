import "level/object/LevelObject"
import "physics/PhysCircle"
import "render/camera"

class("Coin").extends("LevelObject")

local image = playdate.graphics.image.new("images/coin.png")
local imageWidth, imageHeight = image:getSize()

function Coin:init(x, y)
	Coin.super.init(self, LevelObject.Type.Coin)
	self.physCircle = self:addPhysicsObject(PhysCircle(x, y, 10))
end

function Coin:draw()
	local x, y = self:getPosition()
	x, y = camera.matrix:transformXY(x, y)
	local scale = camera.scale
	image:drawScaled(x - scale * imageWidth / 2, y - scale * imageHeight / 2, scale)
end

function Coin:preCollide(other, collision)
	self:despawn()
	return false
end

function Coin:serialize()
	return Coin.super.serialize(self)
end

function Coin.deserialize(data)
	local coin = Coin(data.x, data.y)
	if data.layer then
		coin.layer = data.layer
	end
	return coin
end
