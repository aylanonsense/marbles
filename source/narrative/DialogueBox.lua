import "CoreLibs/object"

class("DialogueBox").extends()

function DialogueBox:init()
end

function DialogueBox:update()
end

function DialogueBox:draw()
  playdate.graphics.setColor(playdate.graphics.kColorWhite)
  playdate.graphics.fillRect(10, 130, 380, 100)
  playdate.graphics.setColor(playdate.graphics.kColorBlack)
  playdate.graphics.drawRect(10, 130, 380, 100)
  playdate.graphics.drawText("speaker", 20, 140)
  playdate.graphics.drawText("test conversation", 20, 170)
end
