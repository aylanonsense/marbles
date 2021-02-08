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
  self.hitSounds = {
    soundCache.createSoundEffectPlayer("sound/sfx/exit-hit-1"),
    soundCache.createSoundEffectPlayer("sound/sfx/exit-hit-2"),
    soundCache.createSoundEffectPlayer("sound/sfx/exit-hit-3")
  }
  self.shards = {}
  self.hitSounds[1]:setVolume(config.SOUND_VOLUME)
  self.hitSounds[2]:setVolume(config.SOUND_VOLUME)
  self.hitSounds[3]:setVolume(config.SOUND_VOLUME)
  self.popLinesImage = imageCache.loadImage("images/level/objects/exit/exit-pop-lines.png")
  local score = exitLookup[self.exitId].score
  local icon = exitLookup[self.exitId].icon
  if icon == nil then
    if score == nil or score > 4 then
      icon = "star"
    elseif score < 2 then
      icon = "moon"
    else
      icon = "sun"
    end
  end
  self.shardImageTable = imageCache.loadImageTable("images/level/objects/shard.png")
  if icon == "moon" then
    self.imageTable = imageCache.loadImageTable("images/level/objects/exit/moon-exit.png")
    self.numDestroyedFrames = 8
  elseif icon == "sun" then
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
  for i = 1, #self.shards do
    if self.shards[i].size > 0 then
      self.shards[i].vx *= 0.85
      self.shards[i].vy *= 0.85
      self.shards[i].x += self.shards[i].vx / 20
      self.shards[i].y += self.shards[i].vy / 20
      self.shards[i].rotation += self.shards[i].vr
      self.shards[i].size = math.max(0, self.shards[i].size - 0.03)
    end
  end
end

function Exit:draw()
  self.animationFrame += 1
  local x, y = self:getPosition()
  x, y = camera.matrix:transformXY(x, y)
  local scale = camera.scale

  -- Draw shards
  local shardImageWidth, shardImageHeight = self.shardImageTable[1]:getSize()
  for i = 1, #self.shards do
    if self.shards[i].size > 0 then
      local shardImage = self.shardImageTable[1]
      local xShard, yShard = camera.matrix:transformXY(self.shards[i].x, self.shards[i].y)
      shardImage:drawRotated(xShard - scale * shardImageWidth / 2, yShard - scale * shardImageHeight / 2 + scale * 5, self.shards[i].rotation - camera.rotation, scale * self.shards[i].size)
      diagnosticStats.transformedImagesDrawn += 1
    end
  end

  -- Draw the lightbulb
  local image
  if self.health >= 3 then
    image = self.imageTable[(self.animationFrame % 24 < 12) and 1 or 2]
  elseif self.health >= 2 then
    image = self.imageTable[math.min(3 + math.floor(self.animationFrame / 2), 6)]
  elseif self.health >= 1 then
    image = self.imageTable[math.min(7 + math.floor(self.animationFrame / 2), 10)]
  else
    if self.animationFrame < 6 then
      image = self.imageTable[math.min(11 + math.floor(self.animationFrame / 2), 13)]
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
    local labelX, labelY = x - labelWidth / 2, y + 38 * scale
    -- Draw some pop lines after the exit is first hit
    playdate.graphics.setColor(playdate.graphics.kColorWhite)
    playdate.graphics.fillRect(labelX, labelY, labelWidth, labelHeight)
    playdate.graphics.setColor(playdate.graphics.kColorBlack)
    if self.health >= 2 and self.animationFrame < 15 then
      local imageWidth, imageHeight = self.popLinesImage:getSize()
      self.popLinesImage:drawScaled(labelX + labelWidth / 2 - scale * imageWidth / 2, labelY - 23 * scale, scale)
      diagnosticStats.untransformedImagesDrawn += 1
    end
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
      self.hitSounds[4 - self.health]:play(1)
      self.health -= 1
      local x, y = self:getPosition()
      if #self.shards == 0 then
        for i = 1, 7 do
          self.shards[i] = {}
        end
      end
      for i = 1, #self.shards do
        local speed
        local normalX
        local normalY
        if i < 3 then
          speed = 550
          normalX = (0.2 + 0.8 * math.random()) * collision.normalX
          normalY = (0.2 + 0.8 * math.random()) * collision.normalY
          self.shards[i].x = x - 40 * normalX
          self.shards[i].y = y - 40 * normalY
        else
          speed = 300
          normalX = -1.0 + 2.0 * math.random()
          normalY = -1.0 + 2.0 * math.random()
          self.shards[i].x = x
          self.shards[i].y = y
        end
        self.shards[i].vx = -speed * normalX
        self.shards[i].vy = -speed * normalY
        self.shards[i].vr = math.random(-15, 15)
        self.shards[i].rotation = 0
        self.shards[i].size = 0.5 + 0.5 * math.random()
      end
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
