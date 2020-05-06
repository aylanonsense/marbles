import "scene/Scene"
import "scene/sceneTransition"
import "utility/soundCache"
import "config"
import "render/imageCache"
import "fonts/fonts"

class("TitleScreenScene").extends(Scene)

function TitleScreenScene:init(canContinue)
  TitleScreenScene.super.init(self)
  self.backgroundImage = imageCache.loadImage("images/title/title-bg.png")
  self.selectionBackgroundImage = imageCache.loadImage("images/title/selection-bg.png")
  self.selectionBackgroundImageWidth, self.selectionBackgroundImageHeight = self.selectionBackgroundImage:getSize()
  self.cursorImage = imageCache.loadImage("images/title/cursor.png")
  self.cursorImageWidth, self.cursorImageHeight = self.cursorImage:getSize()
  self.cursorBlinkFrames = 0
  self.selectionIndex = 1
  if canContinue then
    self.options = {
      "CONTINUE",
      "NEW GAME"
    }
  else
    self.options = {
      "NEW GAME"
    }
  end
  self.hasChosenOption = false
  sceneTransition:transitionIn()
end

function TitleScreenScene:update()
  self.cursorBlinkFrames = (self.cursorBlinkFrames + 1) % (self.hasChosenOption and 10 or 48)
  sceneTransition:update()
end

function TitleScreenScene:draw()
  self.backgroundImage:draw(0, 0)
  self.selectionBackgroundImage:draw(200 - self.selectionBackgroundImageWidth / 2, 170)
  playdate.graphics.setFont(fonts.MarbleHeading)
  local y = 200 - 10 * #self.options
  for i, option in ipairs(self.options) do
    local textWidth, textHeight = playdate.graphics.getTextSize(option)
    playdate.graphics.drawText(option, 160, y)
    if i == self.selectionIndex then
      if self.cursorBlinkFrames < (self.hasChosenOption and 5 or 34) then
        self.cursorImage:draw(132, y - 1)
      end
    end
    y += textHeight
  end
  sceneTransition:draw()
end

function TitleScreenScene:upButtonDown()
  if not self.hasChosenOption then
    self.selectionIndex -= 1
    if self.selectionIndex < 1 then
      self.selectionIndex = #self.options
    end
    self.cursorBlinkFrames = 0
  end
end

function TitleScreenScene:downButtonDown()
  if not self.hasChosenOption then
    self.selectionIndex += 1
    if self.selectionIndex > #self.options then
      self.selectionIndex = 1
    end
    self.cursorBlinkFrames = 0
  end
end

function TitleScreenScene:AButtonDown()
  if not self.hasChosenOption then
    self.hasChosenOption = true
    self.cursorBlinkFrames = 0
    sceneTransition:transitionOut(function()
      self:endScene(self.options[self.selectionIndex])
    end)
  end
end
