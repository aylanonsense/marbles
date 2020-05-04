import "level/object/LevelObject"
import "physics/PhysBall"
import "render/camera"
import "render/imageCache"
import "utility/soundCache"
import "physics/physics"
import "config"
import "utility/diagnosticStats"

class("Marble").extends("LevelObject")

function Marble:init(x, y)
	Marble.super.init(self, LevelObject.Type.Marble)
	self.physObj = self:addPhysicsObject(PhysBall(x, y, 9))
	self.physObj.restitution = 1.0
  self.image = imageCache.loadImage("images/marble.png")
  self.imageWidth, self.imageHeight = self.image:getSize()
  self.recentImpulses = { 0, 0, 0 }
  self.isGrounded = false
  self.framesSinceGrounded = 0
  self.framesOfSilence = 0 
  self.groundBounceSound = soundCache.createSoundEffectPlayer("sound/sfx/marble-ground-bounce")
  self.rollingSound = soundCache.createSoundEffectPlayer("sound/sfx/marble-roll-loop")
  self.rollingSound:setVolume(0)
  self.rollingSound:play(0)
end

function Marble:update()
  self.framesOfSilence = math.max(0, self.framesOfSilence - 1)
  local vx = self.physObj.velX
  local vy = self.physObj.velY
  local speed = math.sqrt(vx * vx + vy * vy)
  self.physObj.accX, self.physObj.accY = -physics.GRAVITY * camera.up.x, -physics.GRAVITY * camera.up.y
    -- Trigger a bump sound effect
  local minImpulseForBumpSound = math.min(math.max(30, 30 + 40 * (speed / 300)), 70)
  if self.recentImpulses[1] > minImpulseForBumpSound and self.recentImpulses[1] > self.recentImpulses[2] + minImpulseForBumpSound and self.recentImpulses[1] > self.recentImpulses[3] + minImpulseForBumpSound and self.framesOfSilence <= 0 then
    local volume = 0.5 * math.min(math.max(0.05, 0.05 + 0.95 * (self.recentImpulses[1] - minImpulseForBumpSound) / (350 - minImpulseForBumpSound)), 1.0)
    local rate = math.min(math.max(0.70, 0.70 + 0.30 * (self.recentImpulses[1] - minImpulseForBumpSound) / (200 - minImpulseForBumpSound)), 1.0)
    self.groundBounceSound:stop()
    self.groundBounceSound:setVolume(config.SOUND_VOLUME * volume)
    self.groundBounceSound:setRate(rate)
    self.groundBounceSound:play(1)
  end
  -- Figure out if the ball is grounded
  if not self.isGrounded and self.recentImpulses[1] > 0 and self.recentImpulses[2] > 0 and self.recentImpulses[3] > 0 then
    self.isGrounded = true
  elseif self.isGrounded and self.recentImpulses[1] <= 0 and self.recentImpulses[2] <= 0 then
    self.isGrounded = false
  end
  if self.isGrounded then
    self.framesSinceGrounded = 0
  else
    self.framesSinceGrounded += 1
  end
  -- Play the rolling sound at the right pitch and volume
  local targetRate
  if self.isGrounded or self.framesSinceGrounded > 8 then
    targetRate = 1.0
  else
    targetRate = 1.30
  end
  local targetVolume
  if self.isGrounded then
    targetVolume = math.min(math.max(0.00, 0.00 + 1.00 * (speed - 20) / 175), 1.00)
  else
    targetVolume = 0.0
  end
  self.rollingSound:setRate(0.5 * targetRate + 0.5 * self.rollingSound:getRate())
  self.rollingSound:setVolume(config.SOUND_VOLUME * (0.4 * targetVolume + 0.6 * self.rollingSound:getVolume()))
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
  diagnosticStats.untransformedImagesDrawn += 1
end

function Marble:onCollide(other, collision, isObjectA)
  if collision.tag == 'exit-trigger' then
    self.framesOfSilence = 5
  end
  self.recentImpulses[1] = math.max(self.recentImpulses[1], collision.impulse)
end

function Marble:serialize()
  return Marble.super.serialize(self)
end

function Marble.deserialize(data)
  local marble = Marble(data.x, data.y)
  if data.layer then
    marble.layer = data.layer
  end
  return marble
end
