import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/animator"
import "CoreLibs/easing"
import "CoreLibs/graphics"
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
  self.pitch = actorsData[self.id].pitch
  self.variant = game.playthrough.actorVariants[id]
  self.side = nil
  self.preferredSide = "left"
  self.expression = nil
  self.isTalking = true
  self.frame = 1
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
    local y = self.isTalking and 154 or 160
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
    local x, y = self.sprite:getPosition()
    local startX = 200 + 100 * ((self.side == "left") and -1 or 1)
    local endX = 200 + 380 * ((self.side == "left") and -1 or 1)
    local path = playdate.geometry.lineSegment.new(startX, y, endX, y)
    local animator = playdate.graphics.animator.new(1200, path, playdate.easingFunctions.outCubic)
    self.sprite:setAnimator(animator)
    self.side = nil
  end
end

function Actor:setExpression(expression)
  if expression and expression ~= self.expression then
    self.expression = expression
    if self.sprite then
      if actorsData[self.id].expressions[expression] then
        self.frame = actorsData[self.id].expressions[self.expression].frame
        self:setImage(self.frame, self.isTalking)
      else
        print("Actor " .. (self.name or "nil") .. " does not have a " .. (expression or "nil") .. " expression")
      end
    end
  end
end

function Actor:setIsTalking(isTalking)
  if self.isTalking ~= isTalking then
    self.isTalking = isTalking
    self:setImage(self.frame, self.isTalking)
    if self.side then
      if self.sprite then
        local startX, y = self.sprite:getPosition()
        local startY = self.isTalking and 160 or 154
        local endY = self.isTalking and 154 or 160
        local endX = 200 + 100 * ((self.side == "left") and -1 or 1)
        local path = playdate.geometry.lineSegment.new(startX, startY, endX, endY)
        local animator = playdate.graphics.animator.new(600, path, playdate.easingFunctions.outCubic)
        self.sprite:setAnimator(animator)
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
    self.fadedImageTable = {}
    for i = 1, #self.imageTable do
      self.fadedImageTable[i] = self.imageTable[i]:invertedImage():blendWithImage(self.imageTable[i], 0.1, playdate.graphics.image.kDitherTypeBayer4x4)
    end
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
  self:setImage(self.frame, self.isTalking)
end

function Actor:setImage(frame, isFaded)
  if self.sprite then
    local flipped = ((self.side or self.preferredSide) == self.facing)
    local image
    if not self.isTalking then
      image = self.fadedImageTable[frame]
    else
      image = self.imageTable[frame]
    end
    if image then
      self.sprite:setImage(image, (flipped and playdate.graphics.kImageFlippedX or playdate.graphics.kImageUnflipped))
    end
  end
end
