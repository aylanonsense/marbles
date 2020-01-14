function playdate.update()
  playdate.graphics.setColor(playdate.graphics.kColorWhite)
  playdate.graphics.fillRect(0, 0, playdate.display.getWidth(), playdate.display.getHeight())
  playdate.graphics.setColor(playdate.graphics.kColorBlack)
  playdate.drawFPS(10, 10)
  playdate.graphics.drawLocalizedText("greeting", 10, 30)
end
