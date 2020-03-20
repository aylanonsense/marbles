imageCache = {
  cache = {}
}

function imageCache.loadImage(path)
  if not imageCache.cache[path] then
    imageCache.cache[path] = playdate.graphics.image.new(path)
  end
  return imageCache.cache[path]
end

function imageCache.loadImageTable(path)
  if not imageCache.cache[path] then
    imageCache.cache[path] = playdate.graphics.imagetable.new(path)
  end
  return imageCache.cache[path]
end

function imageCache.clearCache()
  imageCache.cache = {}
end
