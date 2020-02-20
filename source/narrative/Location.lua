import "CoreLibs/object"

local locationsData = json.decodeFile("/data/narrative/locations.json")

class("Location").extends()

function Location:init(id)
  self.id = id
  local imagePath = locationsData[self.id].image
  local image = playdate.graphics.image.new(imagePath)
  self.sprite = playdate.graphics.sprite.new()
  self.sprite:setImage(image)
  self.sprite:moveTo(200, 120)
  self.sprite:setZIndex(0)
  self.sprite:add()
end

function Location:update() end

function Location:draw()
  self.sprite:update()
end

function Location:remove()
  self.sprite:remove()
end
