import "config"
import "scene/time"
import "utility/soundCache"

sceneTransition = {
  TRANSITION_IN_TIME = 2.00,
  TRANSITION_OUT_TIME = 2.00,
  anim = nil,
  time = 0.00,
  callback = nil
}

function sceneTransition:update()
  if self.anim then
    self.time += time.dt
    -- Fade out music
    if self.anim == 'out' then
      local volume = math.min(math.max(0, 1 - self.time / self.TRANSITION_OUT_TIME), 1) * config.MUSIC_VOLUME
      for _, player in pairs(soundCache.musicPlayers) do
        player:setVolume(volume)
      end
    end
    if (self.anim == 'in' and self.time >= self.TRANSITION_IN_TIME) or (self.anim == 'out' and self.time >= self.TRANSITION_OUT_TIME) then
      self.anim = nil
      self.time = 0.00
      local callback = self.callback
      self.callback = nil
      if callback then
        callback()
      end
    end
  end
end

function sceneTransition:draw()
  -- Draw stripey blocks
  playdate.graphics.setPattern(patterns.DiagonalStripesGrey)
  if self.anim == 'in' or self.anim == 'out' then
    local height = 40
    local t
    if self.anim == 'in' then
      t = self.time / self.TRANSITION_IN_TIME
    else
      t = 1 - self.time / self.TRANSITION_OUT_TIME
    end
    for y = 0, 240, height do
      local width = 400 * (1 - t)
      local x = ((y / height) % 2 == ((self.anim == 'in') and 0 or 1)) and 0 or (400 - width)
      playdate.graphics.fillRect(x, y, width, height)
    end
  elseif self.anim == 'hold' then
    playdate.graphics.fillRect(0, 0, 400, 240)
  end
  playdate.graphics.setColor(playdate.graphics.kColorWhite)
end

function sceneTransition:transitionIn(callback)
  self.anim = 'in'
  self.time = 0.00
  self.callback = callback
end

function sceneTransition:transitionOut(callback)
  self.anim = 'out'
  self.time = 0.00
  self.callback = callback
end

function sceneTransition:hold()
  self.anim = 'hold'
  self.time = 0.00
  self.callback = nil
end
