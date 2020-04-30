import "CoreLibs/object"
import "utility/file"
import "narrative/DialogueScene"
import "level/MazeScene"
import "narrative/StorylineSimulationScene"
import "narrative/DialogueSimulationScene"
import "narrative/MazeSimulationScene"
import "render/imageCache"
import "utility/soundCache"
import "config"

class("Game").extends()

function Game:init()
  -- Load game files
  self.playthroughData = loadJsonFile("/data/narrative/playthrough.json")
  self.storylineData = nil

  -- Store the player's playthrough as a nice JSON object
  self.playthrough = {
    storyline = nil,
    actorVariants = {},
    finishedStorylines = {}
  }

  -- Kick off the first storyline
  self:startStoryline(self.playthroughData.start)
end

function Game:startStoryline(storylineName)
  self.playthrough.storyline = {
    name = storylineName,
    stage = 1,
    exits = {}
  }
  self:resumeCurrentStoryline()
end

function Game:resumeCurrentStoryline()
  local storylineName = self.playthrough.storyline.name
  local branchingData = self.playthroughData.storylines[storylineName]
  -- Load storyline data (a list of scenes)
  if branchingData.isMissing then
    self.storylineData = loadJsonFile("/data/narrative/storylines/missing.json")
  else
    self.storylineData = loadJsonFile("/data/narrative/storylines/" .. storylineName .. ".json")
  end

  -- Play the first storyline scene, unless we choose to skip it and simulate the results instead
  if config.SHOW_DEBUG_SCREENS then
    Scene.setScene(StorylineSimulationScene(branchingData, self.playthroughData), function(shouldPlayStoryline, result)
      if shouldPlayStoryline then
        self:playNextStorylineScene()
      else
        self:finishCurrentStorylineAndStartNextOne(result)
      end
    end)
  else
    self:playNextStorylineScene()
  end
end

function Game:advanceCurrentStoryline()
  soundCache.stopAllSoundEffects()
  soundCache.stopAllMusic()
  self.playthrough.storyline.stage += 1
  self:playNextStorylineScene()
end

function Game:playNextStorylineScene()
  local advance = function(exit)
    if exit then
      self:recordExitTaken(exit)
    end
    self:advanceCurrentStoryline()
  end
  local sceneData = self.storylineData.scenes[self.playthrough.storyline.stage]
  if sceneData then
    if config.SHOW_DEBUG_SCREENS and sceneData.maze then
      Scene.setScene(MazeSimulationScene(sceneData.maze, sceneData.exits), function(shouldPlayMaze, exit)
        if shouldPlayMaze then
          local scene = self:createStorylineScene(self.storylineData, self.playthrough.storyline.stage)
          Scene.setScene(scene, advance)
        else
          advance(exit)
        end
      end)
    elseif config.SHOW_DEBUG_SCREENS and sceneData.dialogue then
      local dialogueFileName = self:getDialogueFileName(sceneData)
      Scene.setScene(DialogueSimulationScene(dialogueFileName), function(shouldPlayDialogue)
        if shouldPlayDialogue then
          local scene = self:createStorylineScene(self.storylineData, self.playthrough.storyline.stage)
          Scene.setScene(scene, advance)
        else
          advance()
        end
      end)
    else
      local scene = self:createStorylineScene(self.storylineData, self.playthrough.storyline.stage)
      Scene.setScene(scene, advance)
    end
  else
    -- There are no more scenes in the current storyline
    self:finishCurrentStorylineAndStartNextOne(self:getStorylineResult())
  end
end

function Game:finishCurrentStoryline(result)
  local storyline = self.playthrough.storyline

  -- Move the current storyline to the list of finished storylines
  self.playthrough.storyline = nil
  table.insert(self.playthrough.finishedStorylines, {
    name = storyline.name,
    result = result
  })

  -- Stop all sounds and clear all caches
  soundCache.stopAllSoundEffects()
  soundCache.stopAllMusic()
  soundCache.clearCache()
  imageCache.clearCache()

  -- Figure out what the next storyline is
  local storylineData = self.playthroughData.storylines[storyline.name]
  return storylineData[result] or storylineData.next or storylineData.normal
end

function Game:finishCurrentStorylineAndStartNextOne(result)
  local nextStorylineName = self:finishCurrentStoryline(result)
  if nextStorylineName then
    self:startStoryline(nextStorylineName)
  else
    print("The game is over!! This is where the credits would play")
  end
end

function Game:createStorylineScene(storylineData, stage)
  -- Create a scene from an individual storyline item (a dialogue or a maze)
  local sceneData = storylineData.scenes[stage]
  if sceneData then
    local musicPlayer
    if sceneData.music then
      musicPlayer = soundCache.createMusicPlayer("sound/music/" .. sceneData.music)
      musicPlayer:setVolume(config.MUSIC_VOLUME)
    end
    if sceneData.dialogue then
      local dialogueFileName = self:getDialogueFileName(sceneData)
      local dialogueData = loadJsonFile("/data/narrative/dialogue/" .. dialogueFileName .. ".json")
      return DialogueScene(dialogueData, musicPlayer)
    elseif sceneData.maze then
      local mazeData = loadJsonFile("/data/levels/" .. sceneData.maze .. "-play.json")
      return MazeScene(mazeData, musicPlayer)
    end
  end
end

function Game:recordExitTaken(exit)
  table.insert(self.playthrough.storyline.exits, exit)
end

function Game:getStorylineResult()
  local averageScore = 0
  for _, exit in ipairs(self.playthrough.storyline.exits) do
    averageScore += (exit.score or 3) / #self.playthrough.storyline.exits
  end
  if averageScore < 1.9 then
    return "fail"
  elseif averageScore < 3.9 then
    return "normal"
  else
    return "special"
  end
end

function Game:getPlaythroughResult()
  local averageScore = 0
  local numScoringStorylines = 0
  for _, storyline in ipairs(self.playthrough.finishedStorylines) do
    if storyline.result then
      numScoringStorylines += 1
      if storyline.result == "fail" then
        averageScore += 1
      elseif storyline.result == "special" then
        averageScore += 5
      else
        averageScore += 3
      end
    end
  end
  averageScore = averageScore / (numScoringStorylines or 1)
  if averageScore < 1.9 then
    return "fail"
  elseif averageScore < 3.9 then
    return "normal"
  else
    return "special"
  end
end

function Game:recordActorVariant(actor, variant)
  self.playthrough.actorVariants[actor] = variant
end

function Game:finishedStoryline(storylineName)
  for _, storyline in ipairs(self.playthrough.finishedStorylines) do
    if storyline.name == storylineName then
      return true
    end
  end
  return false
end

function Game:finishedStorylineWithResult(storylineName, result)
  for _, storyline in ipairs(self.playthrough.finishedStorylines) do
    if storyline.name == storylineName then
      return storyline.result == result
    end
  end
  return false
end

function Game:getDialogueFileName(sceneData)
  local dialogueFileName = sceneData.dialogue
  -- For the festiball, process the file name as nested conditionals
  while dialogueFileName and type(dialogueFileName) == "table" do
    local obj = dialogueFileName
    dialogueFileName = nil
    for storylineName, result in pairs(obj) do
      if self:finishedStoryline(storylineName) then
        dialogueFileName = result
      end
    end
  end
  return dialogueFileName
end
