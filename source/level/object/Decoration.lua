import "level/object/LevelObject"
import "render/camera"
import "render/imageCache"
import "utility/diagnosticStats"

class("Decoration").extends("LevelObject")

local DECO_IMAGE_NAMES = {
  'yield-sign',
  'sandwich-sign',
  'big-questionmark',
  'fluffy-cloud',
  'small-x',
  'signpost',
  'basic-arrow',
  'double-arrow'
}

function Decoration:init(x, y, imageName, rotation)
  Decoration.super.init(self, LevelObject.Type.Decoration)
  self.x = x
  self.y = y
  self.lastDrawnRotation = nil
  self.rotation = rotation or 0
  self.imageName = imageName or DECO_IMAGE_NAMES[1]
  self.image = imageCache.loadImage("images/level/decoration/" .. self.imageName .. ".png")
  self.imageWidth, self.imageHeight = self.image:getSize()
  self.rotatedImage = playdate.graphics.image.new(1.4 * self.imageWidth, 1.4 * self.imageHeight)
end

function Decoration:draw(skipRegeneratingImages)
  local x, y = self:getPosition()
  x, y = camera.matrix:transformXY(x, y)
  local scale = camera.scale
  local image = self.rotatedImage
	if not skipRegeneratingImages and self.lastDrawnRotation ~= self.rotation - camera.rotation then
    self.lastDrawnRotation = self.rotation - camera.rotation
		self.rotatedImage:clear(playdate.graphics.kColorClear)
		playdate.graphics.pushContext(self.rotatedImage)
		self.image:drawRotated(self.rotatedImage.width / 2, self.rotatedImage.height / 2, self.rotation - camera.rotation, scale)
		diagnosticStats.transformedImagesDrawn += 1
    playdate.graphics.popContext()
	end
	image:draw(x - image.width / 2, y - image.height / 2)
	diagnosticStats.untransformedImagesDrawn += 1
end

function Decoration:getPosition()
  return self.x, self.y
end

function Decoration:setPosition(x, y)
  self.x, self.y = x, y
end

function Decoration:getEditableFields()
  return {
    {
      label = "Image",
      field = "imageName",
      change = function(dir)
        local index
        for i, name in ipairs(DECO_IMAGE_NAMES) do
          if name == self.imageName then
            index = i
            break
          end
        end
        index += dir
        if index < 1 then
          index = #DECO_IMAGE_NAMES
        elseif index > #DECO_IMAGE_NAMES then
          index = 1
        end
        self.imageName = DECO_IMAGE_NAMES[index]
        self.image = imageCache.loadImage("images/level/decoration/" .. self.imageName .. ".png")
        self.imageWidth, self.imageHeight = self.image:getSize()
      end
    },
    {
      label = "Rotation",
      field = "rotation",
      change = function(dir)
        self.rotation += dir * 15
        if self.rotation < 0 then
          self.rotation += 360
        elseif self.rotation >= 360 then
          self.rotation -= 360
        end
      end
    }
  }
end

function Decoration:serialize()
  local data = Decoration.super.serialize(self)
  data.rotation = self.rotation
  data.imageName = self.imageName
  return data
end

function Decoration.deserialize(data)
  local decoration = Decoration(data.x, data.y, data.imageName, data.rotation or 0)
  if data.layer then
    decoration.layer = data.layer
  end
  return decoration
end
