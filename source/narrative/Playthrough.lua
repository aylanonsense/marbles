import "CoreLibs/object"

class("Playthrough").extends()

function Playthrough:init()
  -- self.playthroughData = json.decodeFile("/data/narrative/playthrough.json")
  -- if not self.playthroughData then
  --   print("Failed to load actor data at /data/narrative/playthrough.json: the file may not exist or may contain invalid JSON")
  -- end
  -- self.nextStorylineName = self.playthroughData.start
  self.storylines = {}
end

function Playthrough:recordStorylineStarted(storylineName)
  table.insert(self.storylines, {
    name = storylineName,
    finished = false
  })
  return self.nextStorylineName
end

function Playthrough:recordStorylineFinished(result)
  self.storylines[#self.storylines].finished = true
  self.storylines[#self.storylines].result = result
end

function Playthrough:recordStorylineAdvanced()
end
