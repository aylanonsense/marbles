import "CoreLibs/object"
import "utility/file"
import "narrative/DialogueScene"
import "level/MazeScene"
import "narrative/StorylineSimulationScene"
import "narrative/DialogueSimulationScene"
import "narrative/MazeSimulationScene"
import "render/imageCache"
import "utility/soundCache"

class("Game").extends()

local SHOW_DEBUG_SCREENS = true

function Game:init()
  -- Load game files
  self.playthroughData = loadJsonFile("/data/narrative/playthrough.json")
  self.storylineData = nil

  -- Store the player's playthrough as a nice JSON object
  self.playthrough = {
    storyline = nil,
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
  if SHOW_DEBUG_SCREENS then
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
    if SHOW_DEBUG_SCREENS and sceneData.maze then
      Scene.setScene(MazeSimulationScene(sceneData.maze, sceneData.exits), function(shouldPlayMaze, exit)
        if shouldPlayMaze then
          local scene = self:createStorylineScene(self.storylineData, self.playthrough.storyline.stage)
          Scene.setScene(scene, advance)
        else
          advance(exit)
        end
      end)
    elseif SHOW_DEBUG_SCREENS and sceneData.dialogue then
      Scene.setScene(DialogueSimulationScene(sceneData.dialogue), function(shouldPlayDialogue)
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
    if sceneData.dialogue then
      local dialogueData = loadJsonFile("/data/narrative/dialogue/" .. sceneData.dialogue .. ".json")
      if sceneData.music then
        local musicPlayer = soundCache.createMusicPlayer("sound/music/" .. sceneData.music)
        musicPlayer:play()
      end
      return DialogueScene(dialogueData)
    elseif sceneData.maze then
      local mazeData = loadJsonFile("/data/levels/" .. sceneData.maze .. "-play.json")
      if sceneData.music then
        local musicPlayer = soundCache.createMusicPlayer("sound/music/" .. sceneData.music)
        musicPlayer:play()
      end
      return MazeScene(mazeData)
    end
  end
end

function Game:recordExitTaken(exit)
  table.insert(self.playthrough.storyline.exits, exit)
end

function Game:getStorylineResult()
  local averageScore = 0
  for _, exit in ipairs(game.playthrough.storyline.exits) do
    averageScore += (exit.score or 3) / #game.playthrough.storyline.exits
  end
  if averageScore < 1.9 then
    return "fail"
  elseif averageScore < 3.9 then
    return "normal"
  else
    return "special"
  end
end
