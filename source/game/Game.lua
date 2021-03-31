import "CoreLibs/object"
import "utility/file"
import "narrative/DialogueScene"
import "level/MazeScene"
import "game/CreditsScene"
import "scene/time"
import "narrative/StorylineSimulationScene"
import "narrative/DialogueSimulationScene"
import "narrative/MazeSimulationScene"
import "game/TitleScreenScene"
import "game/WorldMapScene"
import "render/imageCache"
import "utility/soundCache"
import "config"

class("Game").extends()

function Game:init()
  -- Load game files
  self.playthroughData = loadJsonFile("/data/narrative/playthrough.json")
  self.storylineData = nil

  -- Get save data
  self.playthrough = nil

  -- Open the title screen
  if config.ALLOW_DEBUG_MODE then
    playdate.getSystemMenu():addCheckmarkMenuItem("Debug", config.DEBUG_MODE_ENABLED, function(value)
      config.DEBUG_MODE_ENABLED = value
    end)
  end
  self:showTitleScreen()
end

function Game:showTitleScreen()
  soundCache.stopAllSoundEffects()
  soundCache.stopAllMusic()
  local saveData = playdate.datastore.read("lost-your-marbles-save-data")
  local musicPlayer = soundCache.createMusicPlayer("sound/music/title")
  musicPlayer:setVolume(config.MUSIC_VOLUME)
  musicPlayer:play(0)
  Scene.setScene(TitleScreenScene(saveData ~= nil and not saveData.isComplete), function(option)
    if option == "CONTINUE" then
      self:continueGame(saveData)
    else
      self:startNewGame()
    end
  end)
end

function Game:continueGame(saveData)
  self.playthrough = saveData
  time.playtime.paused = false
  if self.playthrough.playtime ~= nil then
    time.playtime.seconds = self.playthrough.playtime.seconds
    time.playtime.minutes = self.playthrough.playtime.minutes
    time.playtime.hours = self.playthrough.playtime.hours
  end
  self:resumeCurrentStoryline()
end

function Game:startNewGame()
  self.playthrough = {
    isComplete = false,
    storyline = nil,
    playtime = {
      seconds = 0.0,
      minutes = 0,
      hours = 0
    },
    actorVariants = {},
    finishedStorylines = {}
  }
  time.playtime.paused = false
  time.playtime.seconds = 0.0
  time.playtime.minutes = 0
  time.playtime.hours = 0
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
  self.storylineData = loadJsonFile("/data/narrative/storylines/" .. storylineName .. ".json")

  -- Play the first storyline scene, unless we choose to skip it and simulate the results instead
  if config.DEBUG_MODE_ENABLED then
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

function Game:advanceCurrentStoryline(startSceneInstantly)
  soundCache.stopAllSoundEffects()
  if not startSceneInstantly then
    soundCache.stopAllMusic()
  end
  self.playthrough.storyline.stage += 1
  -- Save the data
  self:playNextStorylineScene(startSceneInstantly)
end

function Game:playNextStorylineScene(startSceneInstantly)
  self.playthrough.playtime.seconds = time.playtime.seconds
  self.playthrough.playtime.minutes = time.playtime.minutes
  self.playthrough.playtime.hours = time.playtime.hours
  playdate.datastore.write(self.playthrough, "lost-your-marbles-save-data", true)
  local advance = function(exit, secretExit, startNextSceneInstantly, returnToTitle)
    playdate.getSystemMenu():removeAllMenuItems()
    if config.ALLOW_DEBUG_MODE then
      playdate.getSystemMenu():addCheckmarkMenuItem("Debug", config.DEBUG_MODE_ENABLED, function(value)
        config.DEBUG_MODE_ENABLED = value
      end)
    end
    if returnToTitle then
      self:showTitleScreen()
    elseif secretExit then
      self:finishCurrentStorylineAndStartNextOne("secret")
    else
      if exit then
        self:recordExitTaken(exit)
      end
      self:advanceCurrentStoryline(startNextSceneInstantly)
    end
  end
  local sceneData = self.storylineData.scenes[self.playthrough.storyline.stage]
  if sceneData then
    if config.DEBUG_MODE_ENABLED and sceneData.maze then
      Scene.setScene(MazeSimulationScene(sceneData.maze, sceneData.exits), function(shouldPlayMaze, exit)
        if shouldPlayMaze then
          local scene = self:createStorylineScene(self.storylineData, self.playthrough.storyline.stage, startSceneInstantly)
          Scene.setScene(scene, advance)
        else
          advance(exit)
        end
      end)
    elseif config.DEBUG_MODE_ENABLED and sceneData.dialogue then
      local dialogueFileName = self:getDialogueFileName(sceneData)
      Scene.setScene(DialogueSimulationScene(dialogueFileName), function(shouldPlayDialogue)
        if shouldPlayDialogue then
          local scene = self:createStorylineScene(self.storylineData, self.playthrough.storyline.stage, startSceneInstantly)
          Scene.setScene(scene, advance)
        else
          advance()
        end
      end)
    else
      local scene = self:createStorylineScene(self.storylineData, self.playthrough.storyline.stage, startSceneInstantly)
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
    result = result,
    exits = storyline.exits
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
  if nextStorylineName and (nextStorylineName ~= "ending" or #self.playthrough.finishedStorylines > 5) then
    local prevStorylineName
    if #self.playthrough.finishedStorylines > 0 then
      prevStorylineName = self.playthrough.finishedStorylines[#self.playthrough.finishedStorylines].name
    end
    if not config.DEBUG_MODE_ENABLED and prevStorylineName and WorldMapScene.hasTransition(prevStorylineName, nextStorylineName) then
      Scene.setScene(WorldMapScene(prevStorylineName, nextStorylineName), function()
        self:startStoryline(nextStorylineName)
      end)
    else
      self:startStoryline(nextStorylineName)
    end
  else
    self.playthrough.isComplete = true
    self.playthrough.playtime.seconds = time.playtime.seconds
    self.playthrough.playtime.minutes = time.playtime.minutes
    self.playthrough.playtime.hours = time.playtime.hours
    playdate.datastore.write(self.playthrough, "lost-your-marbles-save-data", true)
    self:showTitleScreen()
  end
end

function Game:createStorylineScene(storylineData, stage, startSceneInstantly)
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
      return DialogueScene(dialogueData, musicPlayer, startSceneInstantly)
    elseif sceneData.maze then
      local mazeData = loadJsonFile("/data/levels/" .. sceneData.maze .. "-play.json")
      return MazeScene(mazeData, sceneData.prompt, musicPlayer, startSceneInstantly)
    elseif sceneData.credits then
      local unlocks = self:calculateUnlocks()
      time.playtime.paused = true
      return CreditsScene(unlocks, musicPlayer)
    end
  end
end

function Game:calculateUnlocks()
  -- Retrieves saved unlock data
  local unlockData = playdate.datastore.read("lost-your-marbles-unlock-data")
  if not unlockData then
    unlockData = {
      counter = 0,
      storylinesPlayed = {
        credits = {},
        endings = {}
      }
    }
  end
  unlockData.counter += 1
  -- Record unlocks
  for _, storyline in ipairs(self.playthrough.finishedStorylines) do
    if not unlockData.storylinesPlayed[storyline.name] then
      unlockData.storylinesPlayed[storyline.name] = {}
    end
    unlockData.storylinesPlayed[storyline.name][storyline.result or "finished"] = unlockData.counter
  end
  unlockData.storylinesPlayed["credits"].finished = unlockData.counter
  if #self.playthrough.finishedStorylines > 5 then
    unlockData.storylinesPlayed["endings"][self:getPlaythroughResult(unlockData)] = unlockData.counter
  end
  -- Save the unlock data
  playdate.datastore.write(unlockData, "lost-your-marbles-unlock-data", true)
  return unlockData
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

function Game:getPlaythroughResult(unlockData)
  local numUnlocks = 0
  if not unlockData then
    unlockData = playdate.datastore.read("lost-your-marbles-unlock-data")
  end
  if unlockData then
    for _, storyline in pairs(unlockData.storylinesPlayed) do
      for result, _ in pairs(storyline) do
        numUnlocks += 1
      end
    end
  end
  if numUnlocks >= 38 then
    return "complete"
  elseif self:finishedStoryline("daycare") and self:finishedStoryline("vintage-viper") then
    return "ending1"
  elseif self:finishedStoryline("daycare") and self:finishedStoryline("pickle-yard") then
    return "ending2"
  elseif self:finishedStoryline("daycare") and self:finishedStoryline("security-city") then
    return "ending3"
  elseif self:finishedStoryline("sandwich-shop") and self:finishedStoryline("vintage-viper") then
    return "ending4"
  elseif self:finishedStoryline("sandwich-shop") and self:finishedStoryline("pickle-yard") then
    return "ending5"
  elseif self:finishedStoryline("sandwich-shop") and self:finishedStoryline("security-city") then
    return "ending6"
  elseif self:finishedStoryline("skate-park") and self:finishedStoryline("vintage-viper") then
    return "ending7"
  elseif self:finishedStoryline("skate-park") and self:finishedStoryline("pickle-yard") then
    return "ending8"
  elseif self:finishedStoryline("skate-park") and self:finishedStoryline("security-city") then
    return "ending9"
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
