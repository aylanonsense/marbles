import "scene/Scene"
import "narrative/DialogueScene"
import "level/levelIO"
import "level/editor/EditorTestLevelScene"

local levels = loadLevelList()
local levelLookup = {}
for _, levelData in ipairs(levels) do
  levelLookup[levelData.name] = levelData
end

class("Storyline").extends()

function Storyline:init(storylineName)
  local storylineData = json.decodeFile("/data/narrative/storylines/" .. storylineName .. ".json")
  self.scenes = storylineData.scenes
  self.sceneIndex = 1
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
    return DialogueScene(dialogueData, self)
  elseif sceneData.level then
    local levelInfo = levelLookup[sceneData.level]
    local levelData = loadPlayableLevelData(levelInfo)
    return EditorTestLevelScene(levelInfo, levelData, self)
  end
end
