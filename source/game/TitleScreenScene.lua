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
  self.warningImage = imageCache.loadImage("images/title/warning.png")
  self.warningImageWidth, self.warningImageHeight = self.warningImage:getSize()
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
  self.canContinue = canContinue
  self.hasChosenOption = false
  self.isDisplayingWarning = false
  self.framesUntilActive = config.SKIP_SCENE_TRANSITIONS and 0 or 50
  sceneTransition:transitionIn()
end

function TitleScreenScene:update()
  self.framesUntilActive = math.max(0, self.framesUntilActive - 1)
  self.cursorBlinkFrames = (self.cursorBlinkFrames + 1) % (self.hasChosenOption and 6 or 48)
  sceneTransition:update()
end

function TitleScreenScene:draw()
  self.backgroundImage:draw(0, 0)
  self.selectionBackgroundImage:draw(200 - self.selectionBackgroundImageWidth / 2, 170)
  playdate.graphics.setFont(fonts.MarbleHeading)
  local y = 200 - 10 * #self.options
  for i, option in ipairs(self.options) do
    local textWidth, textHeight = playdate.graphics.getTextSize(option)
    playdate.graphics.drawText(option, 150, y)
    if i == self.selectionIndex then
      if self.cursorBlinkFrames < (self.hasChosenOption and 3 or 34) then
        self.cursorImage:draw(124, y - 1)
      end
    end
    y += textHeight
  end
  if self.isDisplayingWarning then
    self.warningImage:draw(200 - self.warningImageWidth / 2, 120 - self.warningImageHeight / 2)
  end
  sceneTransition:draw()
end

function TitleScreenScene:upButtonDown()
  if not self.hasChosenOption and not self.isDisplayingWarning then
    self.selectionIndex -= 1
    if self.selectionIndex < 1 then
      self.selectionIndex = #self.options
    end
    self.cursorBlinkFrames = 0
  end
end

function TitleScreenScene:downButtonDown()
  if not self.hasChosenOption and not self.isDisplayingWarning then
    self.selectionIndex += 1
    if self.selectionIndex > #self.options then
      self.selectionIndex = 1
    end
    self.cursorBlinkFrames = 0
  end
end

function TitleScreenScene:AButtonDown()
  if not self.hasChosenOption and self.framesUntilActive <= 0 then
    if self.canContinue and self.options[self.selectionIndex] == "NEW GAME" and not self.isDisplayingWarning then
      self.isDisplayingWarning = true
    else
      self.hasChosenOption = true
      self.cursorBlinkFrames = 0
      self.isDisplayingWarning = false
      sceneTransition:transitionOut(function()
        self:endScene(self.options[self.selectionIndex])
      end)
    end
  end
end

function TitleScreenScene:BButtonDown()
  self.isDisplayingWarning = false
end
