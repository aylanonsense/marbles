import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/graphics"
import "render/imageCache"
import "utility/file"
import "scene/sceneTransition"

local cinematicsData = loadJsonFile("/data/narrative/cinematics.json")

class("Cinematic").extends()

function Cinematic:init(id)
  if not cinematicsData[id] then
    print("No cinematic data defined for " .. (id or "nil"))
    self.isValid = false
  else
    self.isValid = true
  end
  self.id = id
  self.waitingForInputFrames = 0
  if self.isValid then
    self.data = cinematicsData[self.id]
    self.imageTable = imageCache.loadImageTable(self.data.image)
    self.sprite = playdate.graphics.sprite.new()
    self.sprite:setZIndex(300)
    self.sprite:moveTo(200, 120)
    self.sprite:add()
    self.sequenceNum = 1
    self.stepNum = 1
    self.frame = 0
    self.framesOfSequence = 0
    self.isInRepeatSection = not self.data.sequences[self.sequenceNum].playOnce
    self.step = self:getCurrentStep()
    self:refreshSpriteImage()
    self.AButtonImage = imageCache.loadImage("images/a-button")
    self.AButtonSprite = playdate.graphics.sprite.new()
    self.AButtonSprite:setZIndex(400)
    self.AButtonSprite:moveTo(372, 214)
    self.AButtonSprite:add()
    self.AButtonSprite:setImage(self.AButtonImage)
  end
end

function Cinematic:update()
  if self:readyToMoveOn() then
    self.waitingForInputFrames += 1
  else
    self.waitingForInputFrames = 0
  end
  if self.waitingForInputFrames % 60 == 30 then
    self.AButtonSprite:setVisible(true)
  elseif self.waitingForInputFrames % 60 == 0 then
    self.AButtonSprite:setVisible(false)
  end
  self.frame += 1
  self.framesOfSequence += 1
  if self.step.duration and self.frame > self.step.duration then
    self.stepNum += 1
    self.frame = 0
    self.step = self:getCurrentStep()
    if not self.step then
      self.stepNum = 1
      self.isInRepeatSection = true
      self.step = self:getCurrentStep()
    end
    self:refreshSpriteImage()
  end
end

function Cinematic:advance()
  self.sequenceNum += 1
  self.stepNum = 1
  self.frame = 0
  self.framesOfSequence = 0
  self.isInRepeatSection = not self.data.sequences[self.sequenceNum].playOnce
  self.step = self:getCurrentStep()
  self:refreshSpriteImage()
end

function Cinematic:readyToMoveOn()
  return self.framesOfSequence > self.data.sequences[self.sequenceNum].minWatchTime + ((self.sequenceNum == 1) and sceneTransition.getTransitionInTime() or 0)
end

function Cinematic:draw()
  self.sprite:update()
  self.AButtonSprite:update()
end

function Cinematic:remove()
  if self.sprite then
    self.sprite:remove()
  end
end

function Cinematic:getCurrentStep()
  return self.data.sequences[self.sequenceNum][(not self.isInRepeatSection) and "playOnce" or "repeat"][self.stepNum]
end

function Cinematic:refreshSpriteImage()
  self.sprite:setImage(self.imageTable[self.step.frame])
end
