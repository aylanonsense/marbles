import "level/object/LevelObject"
import "physics/PhysCircle"
import "render/camera"
import "fonts/fonts"
import "scene/time"
import "utility/soundCache"
import "config"
import "render/imageCache"
import "utility/diagnosticStats"

local MIN_IMPULSE_TO_TRIGGER = 60

local exitsData = json.decodeFile("/data/exits.json").exits
local exitLookup = {}
for _, exitData in ipairs(exitsData) do
  exitLookup[exitData.id] = exitData
end

class("Exit").extends("LevelObject")

function Exit:init(x, y, exitId, icon)
  Exit.super.init(self, LevelObject.Type.Exit)
  self.physCircle = self:addPhysicsObject(PhysCircle(x, y, 18))
  self.health = 3
  self.icon = icon
  if exitLookup[exitId] then
    self.exitId = exitId
  else
    self.exitId = exitsData[1].id
  end
  self.label = exitLookup[self.exitId].label
  self.isInvincible = false
  self.impulseFreezeTimer = 0.0
  self.impulseToTrigger = MIN_IMPULSE_TO_TRIGGER
  self.hitSound = soundCache.createSoundEffectPlayer("sound/sfx/marble-exit-hit")
  self.hitSound:setVolume(config.SOUND_VOLUME)
  local score = exitLookup[self.exitId].score
  if score < 2 then
    self.imageTable = imageCache.loadImageTable("images/level/objects/exit/moon-exit.png")
    self.numDestroyedFrames = 8
  elseif score > 4 then
    self.imageTable = imageCache.loadImageTable("images/level/objects/exit/sun-exit.png")
    self.numDestroyedFrames = 6
  else
    self.imageTable = imageCache.loadImageTable("images/level/objects/exit/star-exit.png")
    self.numDestroyedFrames = 8
  end
  self.animationFrame = 0
end

function Exit:update()
  self.impulseFreezeTimer = math.max(0, self.impulseFreezeTimer - time.dt)
  if self.impulseFreezeTimer <= 0 then
    self.impulseToTrigger = math.max(MIN_IMPULSE_TO_TRIGGER, self.impulseToTrigger - 200 * time.dt)
  end
  self.animationFrame += 1
end

function Exit:draw()
  local x, y = self:getPosition()
  x, y = camera.matrix:transformXY(x, y)
  local scale = camera.scale

  -- Draw the lightbulb
  local image
  if self.health >= 3 then
    image = self.imageTable[(self.animationFrame % 24 < 12) and 1 or 2]
  elseif self.health >= 2 then
    image = self.imageTable[math.min(3 + math.floor(self.animationFrame / 3), 6)]
  elseif self.health >= 1 then
    image = self.imageTable[math.min(7 + math.floor(self.animationFrame / 3), 10)]
  else
    if self.animationFrame < 9 then
      image = self.imageTable[math.min(11 + math.floor(self.animationFrame / 3), 13)]
    else
      image = self.imageTable[14 + math.floor(self.animationFrame / 3) % self.numDestroyedFrames]
    end
  end
  local imageWidth, imageHeight = image:getSize()
  image:drawScaled(x - scale * imageWidth / 2, y - scale * imageHeight / 2 + scale * 5, scale)
  diagnosticStats.untransformedImagesDrawn += 1

  -- Draw the label
  if self.health < 3 then
    playdate.graphics.setFont(fonts.MarbleBasic)
    local labelWidth, labelHeight = playdate.graphics.getTextSize(self.label)
    local labelX, labelY = x - labelWidth / 2, y + 30 * scale
    playdate.graphics.setColor(playdate.graphics.kColorWhite)
    playdate.graphics.fillRect(labelX - 2, labelY - 1, labelWidth + 4, labelHeight + 2)
    playdate.graphics.setColor(playdate.graphics.kColorBlack)
    playdate.graphics.drawText(self.label, labelX, labelY)
  end
end

function Exit:preCollide(other, collision)
  if self.health <= 0 then
    return false
  else
    self.impulseFreezeTimer = 0.50
    if not self.isInvincible and collision.impulse >= self.impulseToTrigger then
      self.impulseToTrigger = collision.impulse + 200
      collision.impulse += 100
      collision.tag = 'exit-trigger'
      self.animationFrame = 0
      self.health -= 1
      self.hitSound:play(1)
      if scene.triggerExitHit then
        scene:triggerExitHit(exitLookup[self.exitId], self, collision)
      end
      if self.health <= 0 then
        if scene.triggerExitTaken then
          scene:triggerExitTaken(exitLookup[self.exitId], self, collision)
        end
      end
    end
  end
end

function Exit:getEditableFields()
  return {
    {
      label = "Exit ID",
      field = "exitId",
      change = function(dir)
        local currIndex = 1
        for i, exitData in ipairs(exitsData) do
          if self.exitId == exitData.id then
            currIndex = i
            break
          end
        end
        local newIndex = currIndex + dir
        if newIndex < 1 then
          newIndex = #exitsData
        elseif newIndex > #exitsData then
          newIndex = 1
        end
        self.exitId = exitsData[newIndex].id
        self.label = exitLookup[self.exitId].label
      end
    }
  }
end

function Exit:serialize()
  local data = Exit.super.serialize(self)
  data.exitId = self.exitId
  data.icon = self.icon
  return data
end

function Exit.deserialize(data)
  local exit = Exit(data.x, data.y, data.exitId, data.icon)
  if data.layer then
    exit.layer = data.layer
  end
  return exit
end
