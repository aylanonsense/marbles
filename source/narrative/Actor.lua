import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/animator"
import "CoreLibs/easing"

local actorsData = json.decodeFile("/data/narrative/actors.json")
if not actorsData then
  print("Failed to load actor data at /data/narrative/actors.json: the file may not exist or may contain invalid JSON")
end

class("Actor").extends()

function Actor:init(id)
  self.id = id
  self.name = actorsData[self.id].name
  self.side = nil
  self.preferredSide = "left"
  self.expression = nil
  local imagePath = actorsData[self.id].image
  if imagePath then
    self.imageTable = playdate.graphics.imagetable.new(imagePath)
    self.sprite = playdate.graphics.sprite.new()
    self.sprite:moveTo(-999, 154)
    self.sprite:setCenter(0.5, 1.0)
    self.sprite:setZIndex(100)
    self.sprite:add()
  end
end

function Actor:update() end

function Actor:draw()
  if self.sprite then
    self.sprite:update()
  end
end

function Actor:remove()
  if self.sprite then
    self.sprite:remove()
  end
end

function Actor:slideOnStage(side)
  if self.sprite then
    local startX = 200 + 300 * ((side == "left") and -1 or 1)
    local endX = 200 + 100 * ((side == "left") and -1 or 1)
    local y = 154
    local path = playdate.geometry.lineSegment.new(startX, y, endX, y)
    local animator = playdate.graphics.animator.new(1000, path, playdate.easingFunctions.outCubic)
    self.sprite:setAnimator(animator)
    self.sprite:setImageFlip((side == "right") and playdate.graphics.kImageFlippedX or playdate.graphics.kImageUnflipped)
    self.side = side
    self.preferredSide = side
  end
end

function Actor:slideOffStage()
  if self.sprite then
    local startX = 200 + 100 * ((self.side == "left") and -1 or 1)
    local endX = 200 + 300 * ((self.side == "left") and -1 or 1)
    local y = 154
    local path = playdate.geometry.lineSegment.new(startX, y, endX, y)
    local animator = playdate.graphics.animator.new(1000, path, playdate.easingFunctions.outCubic)
    self.sprite:setAnimator(animator)
    self.side = nil
  end
end

function Actor:setExpression(expression)
  if expression and expression ~= self.expression then
    self.expression = expression
    if self.sprite then
      local frame = actorsData[self.id].expressions[expression].frame
      local image = self.imageTable:getImage(frame)
      self.sprite:setImage(image, ((self.side or self.preferredSide) == "right") and playdate.graphics.kImageFlippedX or playdate.graphics.kImageUnflipped)
    end
  end
end