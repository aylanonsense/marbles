import "CoreLibs/object"

local locationsData = json.decodeFile("/data/narrative/locations.json")

class("Location").extends()

function Location:init(id)
  self.id = id
  local imagePath = locationsData[self.id].image
  if imagePath then
    local image = playdate.graphics.image.new(imagePath)
    self.sprite = playdate.graphics.sprite.new()
    self.sprite:setImage(image)
    self.sprite:moveTo(200, 120)
    self.sprite:setZIndex(0)
    self.sprite:add()
  end
end

function Location:update() end

function Location:draw()
  if self.sprite then
    self.sprite:update()
  end
end

function Location:remove()
  if self.sprite then
    self.sprite:remove()
  end
end
