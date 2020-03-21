import "level/object/LevelObject"
import "physics/PhysCircle"
import "render/camera"
import "render/imageCache"
import "scene/time"

class("CircleBumper").extends("LevelObject")

function CircleBumper:init(x, y)
  CircleBumper.super.init(self, LevelObject.Type.CircleBumper)
  self.image = imageCache.loadImage("images/level/objects/circle-bumper.png")
  self:addPhysicsObject(PhysCircle(x, y, 25))
end

function CircleBumper:draw()
  local x, y = self:getPosition()
  x, y = camera.matrix:transformXY(x, y)
  local scale = camera.scale
  local rotation = -camera.rotation
  self.image:drawRotated(x, y, rotation, scale, scale)
end

function CircleBumper:addPhysicsObject(physObj)
  physObj.restitution = 1.0
  return CircleBumper.super.addPhysicsObject(self, physObj)
end

function CircleBumper:preCollide(other, collision)
  other:scaleVelocity(0.3)
  collision.impulse = 0.2 * collision.impulse + 275
end

function CircleBumper:serialize()
  return CircleBumper.super.serialize(self)
end

function CircleBumper.deserialize(data)
  local bumper = CircleBumper(data.x, data.y)
  if data.layer then
    bumper.layer = data.layer
  end
  return bumper
end
