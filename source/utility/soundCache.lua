soundCache = {
  samples = {},
  players = {}
}

function soundCache.loadSample(path)
  if not soundCache.samples[path] then
    soundCache.samples[path] = playdate.sound.sample.new(path)
  end
  return soundCache.samples[path]
end

function soundCache.createPlayer(path)
  local player = playdate.sound.sampleplayer.new(soundCache.loadSample(path))
  table.insert(soundCache.players, player)
  return player
end

function soundCache.stopAll()
  for _, player in ipairs(soundCache.players) do
    player:stop()
  end
end

function soundCache.clearCache()
  soundCache.samples = {}
  soundCache.players = {}
end
