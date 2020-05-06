import "scene/Scene"
import "scene/sceneTransition"
import "utility/soundCache"
import "config"
import "render/imageCache"
import "fonts/fonts"
import "scene/time"

class("CreditsScene").extends(Scene)

function CreditsScene:init(canContinue)
  CreditsScene.super.init(self)
  self.scroll = 0
  self.isEndingScene = false
  self.credits = {
    {
      "LOST YOUR MARBLES STAFF"
    },
    {},
    {
      "DIRECTION",
      "David Bedard"
    },
    {
      "WRITING",
      "Kim Belair"
    },
    {
      "DESIGN",
      "Will Stacey"
    },
    {
      "PROGRAMMING",
      "Ayla Myers"
    },
    {
      "ART",
      "Will Herring"
    },
    {
      "SOUND AND MUSIC",
      "Neha Patel"
    },
    {
      "EDITING AND CONCEPT ART",
      "Ariadne MacGillivray"
    },
    {
      "EDITING",
      "Sean Hannigan"
    },
    {
      "SPECIAL THANKS",
      "Felix Kramer",
      "... and you!"
    },
    {
      "MARBLE-OUS!"
    },
    {
      "THE END...?"
    }
  }
  sceneTransition:transitionIn()
end

function CreditsScene:update()
  local scrollSpeed = (playdate.buttonIsPressed(playdate.kButtonA) or playdate.buttonIsPressed(playdate.kButtonB)) and 120 or 20
  self.scroll += scrollSpeed * time.dt
  sceneTransition:update()
end

function CreditsScene:draw()
  local y = 320 - self.scroll
  playdate.graphics.clear(playdate.graphics.kColorBlack)
  playdate.graphics.setFont(fonts.MarbleBasic)
  playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeInverted)
  for _, section in ipairs(self.credits) do
    for i, text in ipairs(section) do
      playdate.graphics.setFont((i == 1) and fonts.MarbleHeading or fonts.MarbleBasic)
      local textWidth, textHeight = playdate.graphics.getTextSize(text)
      playdate.graphics.drawText(text, 200 - textWidth / 2, y)
      y += textHeight
    end
    y += 50
  end
  -- If we've scrolled to the end, move on to the next scene
  if not self.isEndingScene and y < 30 then
    self.isEndingScene = true
    sceneTransition:transitionOut(function()
      self:endScene()
    end)
  end
  playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeCopy)
  sceneTransition:draw()
end
