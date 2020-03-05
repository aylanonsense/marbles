import "CoreLibs/object"
import "CoreLibs/nineslice"
import "fonts/fonts"
import "scene/time"

class("DialogueBox").extends()

local dialogueBoxImage = playdate.graphics.nineSlice.new("/images/narrative/dialogue-box.png", 27, 27, 3, 3)
local speakerBoxImage = playdate.graphics.nineSlice.new("/images/narrative/speaker-box.png", 10, 10, 1, 1)
local dialogueBoxFont = fonts.FullCircle

function DialogueBox:init()
  self.x = 200
  self.y = 194
  self.width = 388 -- should be 3n + 1
  self.height = 79 -- should be 3n + 1
  self.maxTextWidth = self.width - 40
  self.speakerName = nil
  self.speakerSide = "left"
  self.text = nil
  self.textLines = nil
  self.isVisible = false
  self.numCharactersShown = 0
  self.framesUntilNextCharacterShown = 0
  -- Calculate the font line height
  playdate.graphics.setFont(dialogueBoxFont)
  local lineWidth, lineHeight = playdate.graphics.getTextSize("ABC")
  self.lineHeight = lineHeight
end

function DialogueBox:update()
  if self.text and self.numCharactersShown < #self.text then
    self.framesUntilNextCharacterShown -= 1
    if self.framesUntilNextCharacterShown <= 0 then
      self.numCharactersShown += 1
      local char = string.sub(self.text, self.numCharactersShown, self.numCharactersShown)
      local nextChar = string.sub(self.text, self.numCharactersShown + 1, self.numCharactersShown + 1)
      self.framesUntilNextCharacterShown = 1
      if char == "." or char == "?" or char == "!" then
        self.framesUntilNextCharacterShown += 3
      elseif nextChar ~= "." and nextChar ~= "?" and nextChar ~= "!" then
        self.numCharactersShown += 1
      end
    end
  end
end

function DialogueBox:draw()
  if self.isVisible then
    local boxX, boxY = math.floor(self.x - self.width / 2), math.floor(self.y - self.height / 2)
    dialogueBoxImage:drawInRect(boxX, boxY, self.width, self.height)
    local speakerBoxWidth, speakerBoxHeight = 63, 25
    local speakerBoxX, speakerBoxY = boxX + ((self.speakerSide == "left") and 10 or (self.width - speakerBoxWidth - 10)), boxY - 10
    local speakerNameX, speakerNameY = speakerBoxX + 10, speakerBoxY + 4
    if self.speakerName then
      speakerBoxImage:drawInRect(speakerBoxX, speakerBoxY, speakerBoxWidth, speakerBoxHeight)
    end
    -- Invert colors to draw white text from here on out
    playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeInverted)
    playdate.graphics.setFont(dialogueBoxFont)
    -- Draw the speaker's name
    if self.speakerName then
      playdate.graphics.drawText(self.speakerName, speakerNameX, speakerNameY)
    end
    -- Draw the lines of dialogue
    if self.textLines then
      local charactersLeft = self.numCharactersShown
      local lineX, lineY = boxX + 20, boxY + 20
      for _, line in ipairs(self.textLines) do
        if charactersLeft >= #line then
          playdate.graphics.drawText(line, lineX, lineY)
          charactersLeft -= #line
        elseif charactersLeft > 0 then
          playdate.graphics.drawText(string.sub(line, 0, charactersLeft), lineX, lineY)
          charactersLeft = 0
        end
        charactersLeft -= 1 -- To account for newline
        lineY += self.lineHeight
      end
    end
    playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeCopy)
  end
end

function DialogueBox:showDialogue(name, text, side)
  self.text = text
  self.framesUntilNextCharacterShown = 0
  self.numCharactersShown = 0
  self.isVisible = true
  self.speakerName = name
  self.speakerSide = side
  -- Break up the text into lines
  playdate.graphics.setFont(dialogueBoxFont)
  self.textLines = {}
  local line = ""
  local word = ""
  for i = 1, #text do
    local c = string.sub(text, i, i)
    if i == #text then
      word = word .. c
    end
    if c == " " or i == #text then
      local lineWithWord = line .. (#line == 0 and "" or " ") .. word
      local textWidth, textHeight = playdate.graphics.getTextSize(lineWithWord)
      if textWidth <= self.maxTextWidth then
        line = lineWithWord
      else
        table.insert(self.textLines, line)
        line = word
      end
      word = ""
    else
      word = word .. c
    end
  end
  if #line > 0 then
    table.insert(self.textLines, line)
  end
end

function DialogueBox:canSkipTextCrawl()
  return self.text and 2 < self.numCharactersShown and self.numCharactersShown < #self.text
end

function DialogueBox:skipTextCrawl()
  self.numCharactersShown = #self.text
end

function DialogueBox:isDoneShowingDialogue()
  return true
end

function DialogueBox:remove() end
