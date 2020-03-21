import "level/object/LevelObject"
import "physics/PhysBall"
import "render/camera"

class("Marble").extends("LevelObject")

local GRAVITY = 10000

local image = playdate.graphics.image.new("images/marble.png")
local imageWidth, imageHeight = image:getSize()

function Marble:init(x, y)
	Marble.super.init(self, LevelObject.Type.Marble)
	self.physObj = self:addPhysicsObject(PhysBall(x, y, 9))
	self.physObj.restitution = 1.0
end

function Marble:update()
	self.physObj.accX, self.physObj.accY = -GRAVITY * camera.up.x, -GRAVITY * camera.up.y
end

function Marble:draw()
	local x, y = self:getPosition()
	x, y = camera.matrix:transformXY(x, y)
	local scale = camera.scale
	image:drawScaled(x - scale * imageWidth / 2, y - scale * imageHeight / 2, scale)
end
