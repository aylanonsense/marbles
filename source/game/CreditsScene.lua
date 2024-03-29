import "scene/Scene"
import "scene/sceneTransition"
import "utility/soundCache"
import "config"
import "render/imageCache"
import "fonts/fonts"
import "scene/time"

class("CreditsScene").extends(Scene)

function CreditsScene:init(unlocks, musicPlayer)
  CreditsScene.super.init(self)
  self.checkboxImage = imageCache.loadImageTable("images/checkbox.png")
  self.checkboxImageWidth, self.checkboxImageHeight = self.checkboxImage:getSize()
  self.scroll = 0
  self.isEndingScene = false
  self.unlocksCounter = unlocks.counter
  self.canEndScene = false
  self.musicPlayer = musicPlayer
  self.unlocks = {
    { name = "Prota's Home", unlocks = unlocks.storylinesPlayed["protas-home"], possibilities = { "finished" } },
    { name = "Marbel's Lab", unlocks = unlocks.storylinesPlayed["marbels-lab"], possibilities = { "finished", "secret" } },
    { name = "Library", unlocks = unlocks.storylinesPlayed["library"], possibilities = { "fail", "normal", "special" } },
    { name = "Skate Park", unlocks = unlocks.storylinesPlayed["skate-park"], possibilities = { "fail", "normal", "special" } },
    { name = "Sandwich Shop", unlocks = unlocks.storylinesPlayed["sandwich-shop"], possibilities = { "fail", "normal", "special" } },
    { name = "Daycare", unlocks = unlocks.storylinesPlayed["daycare"], possibilities = { "fail", "normal", "special" } },
    { name = "Ball Museum", unlocks = unlocks.storylinesPlayed["ball-museum"], possibilities = { "fail", "normal", "special" } },
    { name = "Security City", unlocks = unlocks.storylinesPlayed["security-city"], possibilities = { "fail", "normal", "special" } },
    { name = "Pickle Yard", unlocks = unlocks.storylinesPlayed["pickle-yard"], possibilities = { "fail", "normal", "special" } },
    { name = "Vintage Viper", unlocks = unlocks.storylinesPlayed["vintage-viper"], possibilities = { "fail", "normal", "special" } },
    { name = "Festi-Ball", unlocks = unlocks.storylinesPlayed["festi-ball"], possibilities = { "finished" } },
    { name = "Credits", unlocks = unlocks.storylinesPlayed["credits"], possibilities = { "finished" } },
    { name = "Endings", unlocks = unlocks.storylinesPlayed["endings"], possibilities = { "ending1", "ending2", "ending3", "ending4", "ending5", "ending6", "ending7", "ending8", "ending9", "complete" } }
  }
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
      "Sean Hennegan"
    },
    {
      "SPECIAL THANKS",
      "Felix Kramer",
      "Pelo Brisson-Tsavoussis",
      "Hanny Duong",
      "The cast of Ball Review",
      "Stacey D'Souza",
      "RC Woodmass",
      "Charlie and Nora Bedard",
      "Our families and pets",
      "... and you!"
    },
    {
      "MARBLE-OUS!"
    }
  }
  sceneTransition:transitionIn()
  self.musicPlayer:play(1)
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
    y += 46
  end
  y = self:drawUnlocks(80, y)
  y += 46
  playdate.graphics.setFont(fonts.MarbleHeading)
  local textWidth, textHeight = playdate.graphics.getTextSize("THE END...?")
  playdate.graphics.drawText("THE END...?", 200 - textWidth / 2, y)
  y += textHeight
  if y < -20 and not self.isEndingScene then
    self.isEndingScene = true
    sceneTransition:transitionOut(function()
      self:endScene()
    end)
  end
  -- If we've scrolled to the end, move on to the next scene
  playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeCopy)
  sceneTransition:draw()
end

function CreditsScene:drawUnlocks(x, y)
  playdate.graphics.setFont(fonts.MarbleHeading)
  playdate.graphics.setFont(fonts.MarbleMini)
  for n, storyline in ipairs(self.unlocks) do
    local hasPlayedStoryline = false
    for i, result in ipairs(storyline.possibilities) do
      local hasGottenResult = storyline.unlocks and storyline.unlocks[result] and storyline.unlocks[result] > 0
      local frame
      if hasGottenResult then
        if storyline.unlocks[result] >= self.unlocksCounter then
          frame = math.min(math.max(1, math.floor((100 + 9 * n - y) / 2)), 5)
        else
          frame = 5
        end
      else
        frame = 1
      end
      self.checkboxImage[frame]:draw(x + 180 + 16 * ((i - 1) % 5) - self.checkboxImageWidth / 2, math.floor(y + 16 * math.floor((i - 1) / 5) + 4 - self.checkboxImageHeight / 2))
      if hasGottenResult then
        hasPlayedStoryline = true
      end
    end
    playdate.graphics.drawText(hasPlayedStoryline and storyline.name or "???", x, y)
    y += 16
  end
  y += 32
  local playtimeText = time.playtime.hours .. " : " .. (time.playtime.minutes < 10 and "0" or "") .. time.playtime.minutes .. " : " .. (time.playtime.seconds < 10 and "0" or "") .. (math.floor(100 * time.playtime.seconds) / 100)
  playdate.graphics.drawText(playtimeText, x + 60, y)
  y += 16
  return y
end

function CreditsScene:AButtonDown()
  if self.canEndScene and not self.isEndingScene then
    self.isEndingScene = true
    sceneTransition:transitionOut(function()
      self:endScene()
    end)
  end
end
