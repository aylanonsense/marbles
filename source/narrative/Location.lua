import "CoreLibs/object"

local locationsData = json.decodeFile("/data/narrative/locations.json")

class("Location").extends()

function Location:init(id)
  self.sprite = playdate.graphics.sprite.new()
  self.sprite:moveTo(200, 120)
  self.sprite:setZIndex(0)
  self.sprite:add()
  self:setLocation(id)
end

function Location:update() end

function Location:draw()
  self.sprite:update()
end

function Location:setLocation(id)
  self.id = id
  local imagePath = locationsData[self.id].image
  local image = playdate.graphics.image.new(imagePath)
  self.sprite:setImage(image)
end
