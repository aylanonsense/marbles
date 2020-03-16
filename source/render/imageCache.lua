imageCache = {
  cache = {}
}

function imageCache.loadImage(path)
  if allowCaching then
    if not imageCache.cache[path] then
      imageCache.cache[path] = playdate.graphics.image.new(path)
    end
    return imageCache.cache[path]
  else
    return playdate.graphics.image.new(path)
  end
end

function imageCache.clearCache()
  imageCache.cache = {}
end
