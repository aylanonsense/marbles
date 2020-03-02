import "level/object/LevelObject"
import "physics/PhysCircle"
import "render/camera"
import "fonts/fonts"
import "scene/time"

local exitsData = json.decodeFile("/data/exits.json").exits
local exitLookup = {}
for _, exitData in ipairs(exitsData) do
  exitLookup[exitData.id] = exitData
end

local imageTable = playdate.graphics.imagetable.new("images/lightbulb.png")

class("Exit").extends("LevelObject")

function Exit:init(x, y, exitId)
  Exit.super.init(self, LevelObject.Type.Exit)
  self.physCircle = self:addPhysicsObject(PhysCircle(x, y, 10))
  self.health = 3
  if exitLookup[exitId] then
    self.exitId = exitId
  else
    self.exitId = exitsData[1].id
  end
  self.label = exitLookup[self.exitId].label
  self.cooldown = 0
end

function Exit:update()
  self.cooldown = math.max(0, self.cooldown - time.dt)
end

function Exit:draw()
  local x, y = self:getPosition()
  x, y = camera.matrix:transformXY(x, y)
  local scale = camera.scale

  -- Draw the lightbulb
  local image = imageTable[4 - self.health]
  local imageWidth, imageHeight = image:getSize()
  image:drawScaled(x - scale * imageWidth / 2, y - scale * imageHeight / 2 + scale * 5, scale)

  -- Draw the label
  if self.health < 3 then
    playdate.graphics.setFont(fonts.FullCircle)
    local labelWidth, labelHeight = playdate.graphics.getTextSize(self.label)
    local labelX, labelY = x - labelWidth / 2, y + 23 * scale
    playdate.graphics.setColor(playdate.graphics.kColorWhite)
    playdate.graphics.fillRect(labelX - 2, labelY - 1, labelWidth + 4, labelHeight + 2)
    playdate.graphics.setColor(playdate.graphics.kColorBlack)
    playdate.graphics.drawText(self.label, labelX, labelY)
  end
end

function Exit:preCollide(other, collision)
  if self.health > 0 and self.cooldown <= 0 then
    self.health -= 1
    self.cooldown = 0.25
    if self.health <= 0 then
      if scene.storyline then
        scene.storyline:recordExitTaken(exitLookup[self.exitId])
        scene.storyline:advance()
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
  return data
end

function Exit.deserialize(data)
  return Exit(data.x, data.y, data.exitId)
end
