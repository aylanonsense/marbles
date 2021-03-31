import "config"
import "scene/time"
import "utility/soundCache"

sceneTransition = {
  anim = nil,
  time = 0.00,
  keepMusicPlaying = false,
  callback = nil
}

local transitionInSound = playdate.sound.sampleplayer.new(playdate.sound.sample.new("sound/sfx/transition-in"))
transitionInSound:setVolume(config.SOUND_VOLUME)
local transitionOutSound = playdate.sound.sampleplayer.new(playdate.sound.sample.new("sound/sfx/transition-out"))
transitionOutSound:setVolume(config.SOUND_VOLUME)

function sceneTransition.getTransitionInTime()
  return config.DEBUG_MODE_ENABLED and 0.01 or 1.85
end

function sceneTransition.getTransitionOutTime()
  return config.DEBUG_MODE_ENABLED and 0.01 or 1.85
end

function sceneTransition:update()
  if self.anim then
    self.time += time.dt
    -- Fade out music
    if self.anim == 'out' then
      if not self.keepMusicPlaying then
        local volume = math.min(math.max(0, 1 - self.time / sceneTransition.getTransitionOutTime()), 1) * config.MUSIC_VOLUME
        for _, player in pairs(soundCache.musicPlayers) do
          player:setVolume(volume)
        end
      end
    end
    if (self.anim == 'in' and self.time >= sceneTransition.getTransitionInTime()) or (self.anim == 'out' and self.time >= sceneTransition.getTransitionOutTime()) then
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
      t = self.time / sceneTransition.getTransitionInTime()
    else
      t = 1 - self.time / sceneTransition.getTransitionOutTime()
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
  if not config.DEBUG_MODE_ENABLED then
    transitionInSound:play(1)
  end
end

function sceneTransition:transitionOut(callback, keepMusicPlaying)
  self.anim = 'out'
  self.time = 0.00
  self.callback = callback
  self.keepMusicPlaying = keepMusicPlaying or false
  if not config.DEBUG_MODE_ENABLED then
    transitionOutSound:play(1)
  end
end

function sceneTransition:hold()
  self.anim = 'hold'
  self.time = 0.00
  self.callback = nil
end
