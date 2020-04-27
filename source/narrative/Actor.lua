import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/animator"
import "CoreLibs/easing"
import "render/imageCache"
import "utility/file"

local actorsData = loadJsonFile("/data/narrative/actors.json")

class("Actor").extends()

function Actor:init(id)
  if not actorsData[id] then
    print("No actor data defined for actor " .. (id or "nil"))
  end
  self.id = id
  self.name = actorsData[self.id].name
  self.facing = actorsData[self.id].facing
  self.variant = game.playthrough.actorVariants[id]
  self.side = nil
  self.preferredSide = "left"
  self.expression = nil
  self:reloadImage()
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
    local flipped = (side == self.facing)
    local startX = 200 + 300 * ((side == "left") and -1 or 1)
    local endX = 200 + 100 * ((side == "left") and -1 or 1)
    local y = 154
    local path = playdate.geometry.lineSegment.new(startX, y, endX, y)
    local animator = playdate.graphics.animator.new(1000, path, playdate.easingFunctions.outCubic)
    self.sprite:setAnimator(animator)
    self.sprite:setImageFlip(flipped and playdate.graphics.kImageFlippedX or playdate.graphics.kImageUnflipped)
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
      if actorsData[self.id].expressions[expression] then
        self:setFrame(actorsData[self.id].expressions[expression].frame)
      else
        print("Actor " .. (self.name or "nil") .. " does not have a " .. (expression or "nil") .. " expression")
      end
    end
  end
end

function Actor:reloadImage()
  local imagePath
  if self.variant then
    imagePath = actorsData[self.id].variants[self.variant]
  else
    imagePath = actorsData[self.id].image
  end
  if imagePath then
    self.imageTable = imageCache.loadImageTable(imagePath)
    print(imagePath)
    print(self.imageTable)
    if not self.sprite then
      self.sprite = playdate.graphics.sprite.new()
      self.sprite:moveTo(-999, 154)
      self.sprite:setCenter(0.5, 1.0)
      self.sprite:setZIndex(100)
      self.sprite:add()
    end
  end
end

function Actor:setVariant(variant)
  self.variant = variant
  self:reloadImage()
  if self.expression and actorsData[self.id].expressions[self.expression] then
    self:setFrame(actorsData[self.id].expressions[self.expression].frame)
  end
end

function Actor:setFrame(frame)
  local image = self.imageTable:getImage(frame)
  local flipped = ((self.side or self.preferredSide) == self.facing)
  self.sprite:setImage(image, (flipped and playdate.graphics.kImageFlippedX or playdate.graphics.kImageUnflipped))
end
