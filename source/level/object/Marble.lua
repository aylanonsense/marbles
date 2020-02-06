import "level/object/LevelObject"
import "physics/PhysBall"
import "render/camera"

class("Marble").extends("LevelObject")

local RESTITUTION = 0.5
local GRAVITY = 7000

local image = playdate.graphics.image.new("images/marble.png")
local imageWidth, imageHeight = image:getSize()

function Marble:init(x, y)
	Marble.super.init(self, LevelObject.Type.Marble)
	self.physObj = PhysBall(x, y, 16):add()
	self.physObj.restitution = RESTITUTION
end

function Marble:update()
	-- Set the ball's gravity to be relative to the current perspective
	self.physObj.acceleration.x, self.physObj.acceleration.y = -GRAVITY * camera.up.x, -GRAVITY * camera.up.y
end

function Marble:draw()
	local x, y = self:getPosition()
	x, y = camera.matrix:transformXY(x, y)
	local scale = camera.scale
	image:drawScaled(x - scale * imageWidth / 2, y - scale * imageHeight / 2, scale)
end

function Marble:getPosition()
	return self.physObj.position.x, self.physObj.position.y
end

function Marble:setPosition(x, y)
	self.physObj.position.x, self.physObj.position.y = x, y
end

function Marble.deserialize(data)
	return Marble(data.x, data.y)
end
