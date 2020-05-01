import "fonts/fonts"

diagnosticStats = {
  collisionChecks = 0,
  dynamicPhysicsObjects = 0,
  staticPhysicsObjects = 0,
  untransformedImagesDrawn = 0,
  transformedImagesDrawn = 0,
  polygonPointsDrawn = 0
}

function diagnosticStats:update()
  self.collisionChecks = 0
  self.dynamicPhysicsObjects = 0
  self.staticPhysicsObjects = 0
  self.untransformedImagesDrawn = 0
  self.transformedImagesDrawn = 0
  self.polygonPointsDrawn = 0
end

function diagnosticStats:render()
  playdate.graphics.setFont(fonts.FullCircle)
  playdate.drawFPS(250+48, 182-175)
  local stats = {
    "fps: ",
    "checks: " .. self.collisionChecks,
    "physobjs: " .. (self.dynamicPhysicsObjects + self.staticPhysicsObjects) .. " (" .. self.dynamicPhysicsObjects .. ")",
    "polypts: " .. self.polygonPointsDrawn,
    "images: " .. (self.untransformedImagesDrawn + self.transformedImagesDrawn) .. " (" .. self.transformedImagesDrawn .. ")"
  }
  local x, y = 250+10, 180-175
  for _, text in ipairs(stats) do
    local textWidth, textHeight = playdate.graphics.getTextSize(text)
    playdate.graphics.setColor(playdate.graphics.kColorWhite)
    playdate.graphics.fillRect(x - 2, y - 1, textWidth + 4, textHeight + 2)
    playdate.graphics.setColor(playdate.graphics.kColorBlack)
    playdate.graphics.drawText(text, x, y, playdate.graphics.kColorBlack)
    y += textHeight + 2
  end
end
