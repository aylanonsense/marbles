import "level/object/LevelObject"
import "physics/PhysCircle"
import "render/camera"
import "fonts/fonts"
import "scene/time"
import "utility/soundCache"

local MIN_IMPULSE_TO_TRIGGER = 100

local exitsData = json.decodeFile("/data/exits.json").exits
local exitLookup = {}
for _, exitData in ipairs(exitsData) do
  exitLookup[exitData.id] = exitData
end

local imageTable = playdate.graphics.imagetable.new("images/lightbulbspecial.png")
local imageTableBad = playdate.graphics.imagetable.new("images/lightbulbbad.png")
local imageTableGood = playdate.graphics.imagetable.new("images/lightbulbgood.png")

class("Exit").extends("LevelObject")

function Exit:init(x, y, exitId, icon)
  Exit.super.init(self, LevelObject.Type.Exit)
  self.physCircle = self:addPhysicsObject(PhysCircle(x, y, 14))
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
end

function Exit:update()
  self.impulseFreezeTimer = math.max(0, self.impulseFreezeTimer - time.dt)
  if self.impulseFreezeTimer <= 0 then
    self.impulseToTrigger = math.max(MIN_IMPULSE_TO_TRIGGER, self.impulseToTrigger - 100 * time.dt)
  end
end

function Exit:draw()
  local x, y = self:getPosition()
  x, y = camera.matrix:transformXY(x, y)
  local scale = camera.scale

  -- Draw the lightbulb
  local image = imageTable[4 - self.health]
  if self.icon == "Bad" then
    image = imageTableBad[4 - self.health]
  end
  if self.icon == "Good" then
    image = imageTableGood[4 - self.health]
  end
  local imageWidth, imageHeight = image:getSize()
  image:drawScaled(x - scale * imageWidth / 2, y - scale * imageHeight / 2 + scale * 5, scale)

  -- Draw the label
  if self.health < 3 then
    playdate.graphics.setFont(fonts.FullCircle)
    local labelWidth, labelHeight = playdate.graphics.getTextSize(self.label)
    local labelX, labelY = x - labelWidth / 2, y + 30 * scale
    playdate.graphics.setColor(playdate.graphics.kColorWhite)
    playdate.graphics.fillRect(labelX - 2, labelY - 1, labelWidth + 4, labelHeight + 2)
    playdate.graphics.setColor(playdate.graphics.kColorBlack)
    playdate.graphics.drawText(self.label, labelX, labelY)
  end
end

function Exit:preCollide(other, collision)
  self.impulseFreezeTimer = 0.50
  if self.health > 0 and not self.isInvincible and collision.impulse >= self.impulseToTrigger then
    self.impulseToTrigger = collision.impulse + 200
    collision.impulse += 100
    collision.tag = 'exit-trigger'
    self.health -= 1
    self.hitSound:play(1)
    if scene.triggerExitHit then
      scene:triggerExitHit(exitLookup[self.exitId], self)
    end
    if self.health <= 0 then
      if scene.triggerExitTaken then
        scene:triggerExitTaken(exitLookup[self.exitId], self)
      end
      self:despawn()
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
