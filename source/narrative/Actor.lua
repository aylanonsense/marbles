import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/animator"
import "CoreLibs/easing"

local actorsData = json.decodeFile("/data/narrative/actors.json")

class("Actor").extends()

function Actor:init(id, expression)
  self.id = id
  self.name = actorsData[self.id].name
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
  local startX = 200 + 300 * ((side == 'left') and -1 or 1)
  local endX = 200 + 100 * ((side == 'left') and -1 or 1)
  local y = 180
  local path = playdate.geometry.lineSegment.new(startX, y, endX, y)
  local animator = playdate.graphics.animator.new(1500, path, playdate.easingFunctions.outCubic)
  self.sprite:setAnimator(animator)
end

function Actor:setExpression(expression)
  self.expression = expression
  local frame = actorsData[self.id].expressions[expression].frame
  local image = self.imageTable:getImage(frame)
  self.sprite:setImage(image)
end
