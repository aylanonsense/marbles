import "CoreLibs/object"

class("DialogueBox").extends()

function DialogueBox:init()
  self.speaker = nil
  self.text = nil
  self.isVisible = false
end

function DialogueBox:update()
end

function DialogueBox:draw()
  if self.isVisible then
    playdate.graphics.setColor(playdate.graphics.kColorWhite)
    playdate.graphics.fillRect(10, 130, 380, 100)
    playdate.graphics.setColor(playdate.graphics.kColorBlack)
    playdate.graphics.drawRect(10, 130, 380, 100)
    playdate.graphics.drawText(self.speaker, 20, 140)
    playdate.graphics.drawText(self.text, 20, 170)
  end
end

function DialogueBox:showDialogue(speaker, text)
  self.isVisible = true
  self.speaker = speaker
  self.text = text
end
