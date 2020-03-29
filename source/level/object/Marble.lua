import "level/object/LevelObject"
import "physics/PhysBall"
import "render/camera"
import "render/imageCache"
import "utility/soundCache"

class("Marble").extends("LevelObject")

local GRAVITY = 10000

function Marble:init(x, y)
	Marble.super.init(self, LevelObject.Type.Marble)
	self.physObj = self:addPhysicsObject(PhysBall(x, y, 9))
	self.physObj.restitution = 1.0
  self.image = imageCache.loadImage("images/marble.png")
  self.imageWidth, self.imageHeight = self.image:getSize()
  self.recentImpulses = { 0, 0, 0 }
  self.isGrounded = false
  self.rollSoundState = nil
  self.rollStartSound = soundCache.createSoundEffectPlayer("sound/sfx/marble-roll-start")
  self.rollLoopSound = soundCache.createSoundEffectPlayer("sound/sfx/marble-roll-loop")
  self.rollEndSound = soundCache.createSoundEffectPlayer("sound/sfx/marble-roll-end")
  self.rollStartSound:setFinishCallback(function()
    if self.rollSoundState == 'start' then
      self.rollSoundState = 'loop'
      self.rollLoopSound:play(0)
    end
  end)
  self.rollEndSound:setFinishCallback(function()
    if self.rollSoundState == 'end' then
      self.rollSoundState = nil
    end
  end)
end

function Marble:update()
	self.physObj.accX, self.physObj.accY = -GRAVITY * camera.up.x, -GRAVITY * camera.up.y
  if self.recentImpulses[1] > 80 and self.recentImpulses[2] <= 0 and self.recentImpulses[3] <= 0 then
    -- Trigger a bump sound effect
  end
  if not self.isGrounded and self.recentImpulses[1] > 0 and self.recentImpulses[2] > 0 and self.recentImpulses[3] > 0 then
    self.isGrounded = true
  elseif self.isGrounded and self.recentImpulses[1] <= 0 and self.recentImpulses[2] <= 0 then
    self.isGrounded = false
  end
  local vx = self.physObj.velX
  local vy = self.physObj.velY
  local speed = math.sqrt(vx * vx + vy * vy)
  -- Start the roll sound
  if self.isGrounded and (not self.rollSoundState or self.rollSoundState == 'end') and speed > 25 then
    self.rollSoundState = 'start'
    self.rollEndSound:stop()
    self.rollStartSound:play()
  end
  -- Stop rolling if it lifts off the ground or slows down
  if (not self.isGrounded or speed < 20) and (self.rollSoundState == 'start' or self.rollSoundState == 'loop') then
    self.rollSoundState = 'end'
    self.rollStartSound:stop()
    self.rollLoopSound:stop()
    self.rollEndSound:play()
  end
  for i = 2, #self.recentImpulses do
    self.recentImpulses[i] = self.recentImpulses[i - 1]
  end
  self.recentImpulses[1] = 0
end

function Marble:draw()
	local x, y = self:getPosition()
	x, y = camera.matrix:transformXY(x, y)
	local scale = camera.scale
	self.image:drawScaled(x - scale * self.imageWidth / 2, y - scale * self.imageHeight / 2, scale)
end

function Marble:onCollide(other, collision, isObjectA)
  self.recentImpulses[1] = math.max(self.recentImpulses[1], collision.impulse)
end
