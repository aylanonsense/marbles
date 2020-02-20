import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/animator"
import "CoreLibs/easing"

local objectsData = json.decodeFile("/data/narrative/objects.json")

class("ShownObject").extends()

function ShownObject:init(id)
  self.id = id
  local imagePath = objectsData[self.id].image
  local image = playdate.graphics.image.new(imagePath)
  self.sprite = playdate.graphics.sprite.new()
  self.sprite:moveTo(200, -999)
  self.sprite:setZIndex(200)
  self.sprite:setImage(image)
  self.sprite:add()
end

function ShownObject:update() end

function ShownObject:draw()
  self.sprite:update()
end

function ShownObject:slideIntoView()
  local x = 200
  local startY = -100
  local endY = 100
  local path = playdate.geometry.lineSegment.new(x, startY, x, endY)
  local animator = playdate.graphics.animator.new(1000, path, playdate.easingFunctions.outCubic)
  self.sprite:setAnimator(animator)
end

function ShownObject:slideOutOfView()
  local x = 200
  local startY = 100
  local endY = -100
  local path = playdate.geometry.lineSegment.new(x, startY, x, endY)
  local animator = playdate.graphics.animator.new(1000, path, playdate.easingFunctions.outCubic)
  self.sprite:setAnimator(animator)
end

function ShownObject:remove()
  self.sprite:remove()
end
