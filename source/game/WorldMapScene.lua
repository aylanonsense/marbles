import "scene/Scene"
import "scene/sceneTransition"
import "utility/soundCache"
import "config"
import "render/imageCache"
import "fonts/fonts"
import "scene/time"

local travelPathData = loadJsonFile("/data/travel-paths.json")

class("WorldMapScene").extends(Scene)

function WorldMapScene:init(fromLocation, toLocation)
  WorldMapScene.super.init(self)
  self.worldMapImage = imageCache.loadImage("images/world-map.png")
  self.dotImage = imageCache.loadImage("images/world-map-dot.png")
  self.dotImageWidth, self.dotImageHeight = self.dotImage:getSize()
  self.popImage = imageCache.loadImage("images/world-map-pop-lines.png")
  self.popImageWidth, self.popImageHeight = self.popImage:getSize()
  self.pathData = travelPathData[fromLocation][toLocation]
  self.frames = 0
  self.numThingsDrawn = 0
  self.isEndingScene = false
  sceneTransition:transitionIn()
end

function WorldMapScene:update()
  self.frames += 1
  if self.numThingsDrawn <= 0 then
    if self.frames > 40 then
      self.numThingsDrawn += 1
      self.frames = 0
    end
  elseif self.frames > 15 then
    self.numThingsDrawn += 1
    self.frames = 0
  end
  if not self.isEndingScene and self.numThingsDrawn > math.floor(#self.pathData / 2) + 4 then
    self.isEndingScene = true
    -- TODO end scene
  end
  sceneTransition:update()
end

function WorldMapScene:draw()
  self.worldMapImage:draw(0, 0)
  sceneTransition:draw()
  for i = 1, #self.pathData, 2 do
    local x = self.pathData[i]
    local y = self.pathData[i + 1]
    if i == 1 and self.numThingsDrawn == 1 then
      self.popImage:draw(x - self.popImageWidth / 2, y - self.popImageHeight / 2 - 15)
    elseif i == #self.pathData - 1 and self.numThingsDrawn == math.floor(i / 2) + 1 then
      self.popImage:draw(x - self.popImageWidth / 2, y - self.popImageHeight / 2 - 15)
    elseif i > 1 and i < #self.pathData - 1 and math.floor(i / 2) + 1 <= self.numThingsDrawn then
      self.dotImage:draw(x - self.dotImageWidth / 2, y - self.dotImageHeight / 2)
    end
  end
end
