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

function Location:update()
end

function Location:draw()
  -- playdate.graphics.setColor(playdate.graphics.kColorBlack)
  -- playdate.graphics.drawRect(2, 2, 396, 236)
  -- playdate.graphics.drawText(self.id, 12, 12)
  self.sprite:update()
end
