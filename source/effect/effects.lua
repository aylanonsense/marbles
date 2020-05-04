effects = {
  freezeFrames = 0,
  screenShakeFrames = 0,
  screenShakeX = 0,
  screenShakeY = 0,
  screenShakeNormalX = 0,
  screenShakeNormalY = 0
}

function effects:update()
  self.freezeFrames = math.max(0, self.freezeFrames - 1)
  self.screenShakeFrames = math.max(0, self.screenShakeFrames - 1)
  self:calculateScreenShake()
end

function effects:freeze(frames)
  self.freezeFrames = math.max(self.freezeFrames, frames)
end

function effects:shake(frames, normalX, normalY)
  self.screenShakeFrames = frames
  self.screenShakeNormalX = normalX
  self.screenShakeNormalY = normalY
  self:calculateScreenShake()
end

function effects:calculateScreenShake()
  if self.screenShakeFrames > 0 then
    local dir = (2 * (self.screenShakeFrames % 2) - 1)
    self.screenShakeX = self.screenShakeNormalX * dir * 1.5 * math.min(math.max(1, 2 * math.floor(self.screenShakeFrames / 2)), 3)
    self.screenShakeY = self.screenShakeNormalY * dir * 1.5 * math.min(math.max(1, 2 * math.floor(self.screenShakeFrames / 2)), 3)
  else
    self.screenShakeX = 0
    self.screenShakeY = 0
  end
end
