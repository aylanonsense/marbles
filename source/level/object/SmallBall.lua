import "level/object/LevelObject"
import "physics/PhysBall"
import "render/camera"
import "render/imageCache"
import "utility/diagnosticStats"

class("SmallBall").extends("LevelObject")

function SmallBall:init(x, y)
	SmallBall.super.init(self, LevelObject.Type.SmallBall)
  self.physObj = self:addPhysicsObject(PhysBall(x, y, 9))
  self.physObj.mass = 1
	self.physObj.restitution = 1.0
  self.image = imageCache.loadImage("images/level/objects/small-ball.png")
  self.imageWidth, self.imageHeight = self.image:getSize()
end

function SmallBall:update()
	self.physObj.accX, self.physObj.accY = -physics.GRAVITY * camera.up.x, -physics.GRAVITY * camera.up.y
end

function SmallBall:draw()
	local x, y = self:getPosition()
	x, y = camera.matrix:transformXY(x, y)
	local scale = camera.scale
  self.image:drawScaled(x - scale * self.imageWidth / 2, y - scale * self.imageHeight / 2, scale)
  diagnosticStats.untransformedImagesDrawn += 1
end

function SmallBall:serialize()
  return SmallBall.super.serialize(self)
end

function SmallBall.deserialize(data)
  local ball = SmallBall(data.x, data.y)
  if data.layer then
    ball.layer = data.layer
  end
  return ball
end
