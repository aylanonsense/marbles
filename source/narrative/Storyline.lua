import "scene/Scene"
import "narrative/DialogueScene"
import "level/MazeScene"

class("Storyline").extends()

function Storyline:init(storylineName)
  local storylineData = json.decodeFile("/data/narrative/storylines/" .. storylineName .. ".json")
  self.scenes = storylineData.scenes
  self.sceneIndex = 1
  self.exitsTaken = {}
end

function Storyline:start()
  Scene.setScene(self:createScene(self.scenes[self.sceneIndex]))
end

function Storyline:advance()
  if self.sceneIndex < #self.scenes then
    self.sceneIndex += 1
    Scene.setScene(self:createScene(self.scenes[self.sceneIndex]))
  end
end

function Storyline:createScene(sceneData)
  if sceneData.dialogue then
    local dialogueData = json.decodeFile("/data/narrative/dialogue/" .. sceneData.dialogue .. ".json")
    if not dialogueData then
      print("Failed to load dialogue data at /data/narrative/dialogue/" .. sceneData.dialogue .. ".json: the file may not exist or may contain invalid JSON")
    end
    return DialogueScene(dialogueData, self)
  elseif sceneData.maze then
    local levelData = json.decodeFile("/data/levels/" .. sceneData.maze .. "-play.json")
    if not levelData then
      print("Failed to load maze data at /data/levels/" .. sceneData.maze .. "-play.json: the file may not exist or may contain invalid JSON")
    end
    return MazeScene(levelData, self)
  end
end

function Storyline:recordExitTaken(exitData)
  table.insert(self.exitsTaken, exitData)
end
