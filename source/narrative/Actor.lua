import "CoreLibs/object"

local actorsData = json.decodeFile("/data/narrative/actors.json")

class("Actor").extends()

function Actor:init(id, expression)
  self.id = id
  local imagePath = actorsData[self.id].image
  self.imageTable = playdate.graphics.imagetable.new(imagePath)
  self.sprite = playdate.graphics.sprite.new()
  self.sprite:moveTo(200, 120)
  self.sprite:setCenter(0.5, 1.0)
  self.sprite:setZIndex(100)
  self:setExpression(expression)
  self.sprite:add()
end

function Actor:update()
end

function Actor:draw()
  self.sprite:update()
end

function Actor:slideOnStage(side)
  self.sprite:moveTo(200 + ((side == 'left') and -100 or 100), 180)
  self.sprite:setImageFlip(side == 'left' and playdate.graphics.kImageUnflipped or playdate.graphics.kImageFlippedX)
end

function Actor:setExpression(expression)
  self.expression = expression
  local frame = actorsData[self.id].expressions[expression].frame
  local image = self.imageTable:getImage(frame)
  self.sprite:setImage(image)
end
