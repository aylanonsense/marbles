soundCache = {
  samples = {},
  soundEffectPlayers = {},
  musicPlayers = {}
}

function soundCache.loadSample(path)
  if not soundCache.samples[path] then
    soundCache.samples[path] = playdate.sound.sample.new(path)
  end
  return soundCache.samples[path]
end

function soundCache.createSoundEffectPlayer(path)
  local player = playdate.sound.sampleplayer.new(soundCache.loadSample(path))
  table.insert(soundCache.soundEffectPlayers, player)
  return player
end

function soundCache.createMusicPlayer(path)
  if not soundCache.musicPlayers[path] then
    soundCache.musicPlayers[path] = playdate.sound.fileplayer.new(path)
  end
  return soundCache.musicPlayers[path]
end

function soundCache.stopAllSoundEffects()
  for _, player in ipairs(soundCache.soundEffectPlayers) do
    player:stop()
  end
end

function soundCache.stopAllMusic()
  for _, player in pairs(soundCache.musicPlayers) do
    player:stop()
  end
end

function soundCache.clearCache()
  soundCache.samples = {}
  soundCache.soundEffectPlayers = {}
  soundCache.musicPlayers = {}
end
