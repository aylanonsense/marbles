import "level/object/LevelObject"
import "physics/PhysBall"
import "render/camera"
import "render/imageCache"

class("BigBall").extends("LevelObject")

function BigBall:init(x, y)
	BigBall.super.init(self, LevelObject.Type.BigBall)
  self.physObj = self:addPhysicsObject(PhysBall(x, y, 29))
  self.physObj.mass = 5
	self.physObj.restitution = 1.0
  self.image = imageCache.loadImage("images/level/objects/big-ball.png")
  self.imageWidth, self.imageHeight = self.image:getSize()
end

function BigBall:update()
	self.physObj.accX, self.physObj.accY = -physics.GRAVITY * camera.up.x, -physics.GRAVITY * camera.up.y
end

function BigBall:draw()
	local x, y = self:getPosition()
	x, y = camera.matrix:transformXY(x, y)
	local scale = camera.scale
	self.image:drawScaled(x - scale * self.imageWidth / 2, y - scale * self.imageHeight / 2, scale)
end

function BigBall:serialize()
  return BigBall.super.serialize(self)
end

function BigBall.deserialize(data)
  local ball = BigBall(data.x, data.y)
  if data.layer then
    ball.layer = data.layer
  end
  return ball
end
