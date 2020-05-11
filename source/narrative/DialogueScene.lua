import "scene/Scene"
import "narrative/Actor"
import "narrative/DialogueBox"
import "narrative/Location"
import "narrative/ShownObject"
import "narrative/Cinematic"
import "narrative/dialogueMethods"
import "scene/time"
import "scene/sceneTransition"
import "utility/file"

class("DialogueScene").extends(Scene)

function DialogueScene:init(convoData, musicPlayer, startInstantly)
  DialogueScene.super.init(self)
  self.dialogueBox = DialogueBox()
  self.location = Location(self:evalDialogueField(convoData.location))
  self.cinematic = nil
  self.shownObject = nil
  -- Create the actors and slide them onto stage
  self.actorLookup = {}
  self.actorsOnStage = { left = nil, right = nil }
  for _, actorData in ipairs(self:evalDialogueField(convoData.actors)) do
    local actorId = self:evalDialogueField(actorData.actor)
    if actorId ~= "Narrator" then
      if not actorId then
        print("Falsey actor id " .. actorId .. " while evaluating dialogue actors")
      end
      local actor = self:addOrFindActor(actorId)
      local expression = self:evalDialogueField(actorData.expression)
      if expression then
        actor:setExpression(expression)
      end
      actor.startingSide = self:evalDialogueField(actorData.side)
    end
  end
  self.hasBegunScene = false
  -- Prep the script
  self.scripts = { convoData.script }
  self.scriptIndexes = { 0 }
  -- Wait for a bit before beginning the script
  if startInstantly then
    self.waitingFor = nil
    self.waitTime = 0.00
    self.hasBegunScene = true
    for _, actor in pairs(self.actorLookup) do
      if actor.startingSide then
        if self.actorsOnStage[actor.startingSide] then
          self.actorsOnStage[actor.startingSide]:slideOffStage(startInstantly)
        end
        actor:slideOnStage(actor.startingSide, startInstantly)
        self.actorsOnStage[actor.startingSide] = actor
        actor.startingSide = nil
      end
    end
    self.dialogueBox:show()
    self:processNextDialogueAction(true)
  else
    self.waitingFor = "time"
    self.waitTime = sceneTransition.TRANSITION_IN_TIME + 0.75
    sceneTransition:transitionIn()
  end
  self.musicPlayer = musicPlayer
  if self.musicPlayer then
    self.musicPlayer:play(0)
  end
end

function DialogueScene:update()
  -- Wait a certain amount of time before proceeding
  if self.waitingFor == "time" then
    self.waitTime -= time.dt
    if self.waitTime <= 0 then
      self.waitingFor = nil
      if self.hasBegunScene then
        self:processNextDialogueAction()
      else
        self.hasBegunScene = true
        self.waitingFor = "time"
        self.waitTime = 1.5
        for _, actor in pairs(self.actorLookup) do
          if actor.startingSide then
            if self.actorsOnStage[actor.startingSide] then
              self.actorsOnStage[actor.startingSide]:slideOffStage()
            end
            actor:slideOnStage(actor.startingSide)
            self.actorsOnStage[actor.startingSide] = actor
            actor.startingSide = nil
          end
        end
        self.dialogueBox:show()
      end
    end
  -- Wait for the dialogue box text to crawl and then for the player to press a button
  elseif self.waitingFor == "dialogue-box" then
    if playdate.buttonIsPressed(playdate.kButtonB) then
      if self.dialogueBox:canSkipTextCrawl() then
        self.dialogueBox:skipTextCrawl()
      end
    end
    if playdate.buttonJustPressed(playdate.kButtonA) then
      if self.dialogueBox:canSkipTextCrawl() then
        self.dialogueBox:skipTextCrawl()
      elseif self.dialogueBox:isDoneShowingDialogue() then
        self:processNextDialogueAction()
      end
    end
  elseif self.waitingFor == "button-press" then
    if playdate.buttonJustPressed(playdate.kButtonA) then
      self:processNextDialogueAction()
    end
  elseif self.waitingFor == "cinematic" then
    if not self.cinematic or (self.cinematic:readyToMoveOn() and playdate.buttonJustPressed(playdate.kButtonA)) then
      self:processNextDialogueAction()
    end
  end
  if self.location then
    self.location:update()
  end
  for _, actor in ipairs(self.actorLookup) do
    actor:update()
  end
  if self.shownObject then
    self.shownObject:update()
  end
  if self.cinematic then
    self.cinematic:update()
  end
  self.dialogueBox:update()
  sceneTransition:update()
end

function DialogueScene:draw()
  playdate.graphics.clear()
  if self.location then
    self.location:draw()
  end
  if self.cinematic then
    self.cinematic:draw()
  end
  for _, actor in pairs(self.actorLookup) do
    actor:draw()
  end
  if self.shownObject then
    self.shownObject:draw()
  end
  self.dialogueBox:draw()
  sceneTransition:draw()
end

function DialogueScene:addOrFindActor(id)
  if not self.actorLookup[id] then
    self.actorLookup[id] = Actor(id)
  end
  return self.actorLookup[id]
end

function DialogueScene:processNextDialogueAction(instantly)
  self.scriptIndexes[#self.scriptIndexes] += 1
  -- We have reached the end of the current script
  if self.scriptIndexes[#self.scriptIndexes] > #(self.scripts[#self.scripts]) then
    -- Pop off the topmost script and process the next action immediately
    table.remove(self.scripts)
    table.remove(self.scriptIndexes)
    if #self.scripts > 0 then
      self:processNextDialogueAction()
    else
      self:transitionOut()
    end
  else
    local script = self.scripts[#self.scripts]
    local index = self.scriptIndexes[#self.scriptIndexes]
    if not self:processDialogueAction(script[index], instantly) then
      -- If we weren't able to process the action, just try the next one immediately
      self:processNextDialogueAction()
    end
  end
end

function DialogueScene:transitionOut(secretExit)
  self.waitingFor = nil
  sceneTransition:transitionOut(function()
    self:close(secretExit, false)
  end)
end

function DialogueScene:close(secretExit, startNextSceneInstantly)
  for _, actor in pairs(self.actorLookup) do
    actor:remove()
  end
  self.dialogueBox:remove()
  self.location:remove()
  if self.shownObject then
    self.shownObject:remove()
  end
  if self.cinematic then
    self.cinematic:remove()
  end
  self:endScene(nil, secretExit, startNextSceneInstantly)
end

function DialogueScene:processDialogueAction(action, instantly)
  if not action or action.skip then
    return false
  end
  -- The action is a conditional, evaluate the conditional before processing the action
  while action["if"] or action.method do
    action = self:evalDialogueField(action)
    if not action or action.skip then
      return false
    end
  end
  -- We're skipping the action
  if action.skip then
    return false
  -- The action represents a subscript, push it onto the script stack
  elseif #action > 0 then
    table.insert(self.scripts, action)
    table.insert(self.scriptIndexes, 0)
    return false
  -- Say a dialogue line
  elseif action.line then
    local line = self:evalDialogueField(action.line)
    local actorName = self:evalDialogueField(action.actor)
    if not actorName or actorName == "Narrator" then
      self.dialogueBox:showDialogue(null, line, null)
      if self.actorsOnStage.left then
        self.actorsOnStage.left:setIsTalking(false, instantly)
      end
      if self.actorsOnStage.right then
        self.actorsOnStage.right:setIsTalking(false, instantly)
      end
    else
      local actor = self:addOrFindActor(actorName)
      local side = self:evalDialogueField(action.side) or actor.side or actor.preferredSide
      local replacements = self:evalDialogueField(action.replacements)
      if replacements then
        for key, value in pairs(replacements) do
          local textBefore = "${" .. key .. "}"
          local textAfter = self:evalDialogueField(value)
          line = string.gsub(line, textBefore, textAfter)
        end
      end
      actor:setExpression(self:evalDialogueField(action.expression))
      local otherSide = (side == "left") and "right" or "left"
      if self.actorsOnStage[otherSide] then
        self.actorsOnStage[otherSide]:setIsTalking(false, instantly)
      end
      if self.actorsOnStage[side] ~= actor then
        if self.actorsOnStage[side] then
          self.actorsOnStage[side]:setIsTalking(false, instantly)
          self.actorsOnStage[side]:slideOffStage()
        end
        self.actorsOnStage[side] = actor
        self.actorsOnStage[side]:setIsTalking(true, instantly)
        actor:slideOnStage(side)
      else
        self.actorsOnStage[side]:setIsTalking(true, instantly)
      end
      self.dialogueBox:showDialogue(actor.name, line, actor.side, actor.pitch)
    end
    self.waitingFor = "dialogue-box"
  -- Change the location
  elseif action.action == "change-location" then
    if self.location then
      self.location:remove()
    end
    self.location = Location(self:evalDialogueField(action.location))
    self.dialogueBox:clear()
    self.waitingFor = "button-press"
  -- Show an object
  elseif action.action == "show-object" then
    if self.shownObject then
      self.shownObject:remove()
    end
    self.shownObject = ShownObject(self:evalDialogueField(action.object))
    self.shownObject:slideIntoView()
    self.waitingFor = "time"
    self.waitTime = 1.00
  -- Hide the shown object
  elseif action.action == "hide-object" then
    self.shownObject:slideOutOfView()
    self.waitingFor = "time"
    self.waitTime = 1.00
  -- Move an actor off-stage without replacing them
  elseif action.action == "dismiss-actor" then
    if action.side == "left" or action.side == "both" then
      if self.actorsOnStage.left then
        self.actorsOnStage.left:slideOffStage()
      end
      self.actorsOnStage.left = nil
    end
    if action.side == "right" or action.side == "both" then
      if self.actorsOnStage.right then
        self.actorsOnStage.right:slideOffStage()
      end
      self.actorsOnStage.right = nil
    end
    self.waitingFor = "time"
    self.waitTime = 1.00
  -- Add an accessory or decoration to an actor for the rest of the playthrough
  elseif action.action == "set-actor-variant" then
    game:recordActorVariant(action.actor, action.variant)
    if self.actorLookup[action.actor] then
      self.actorLookup[action.actor]:setVariant(action.variant)
    end
  elseif action.action == "play-cinematic" then
    if self.cinematic then
      self.cinematic:remove()
    end
    self.dialogueBox:hide()
    self.cinematic = Cinematic(action.cinematic)
    if self.cinematic.isValid then
      self.waitingFor = "cinematic"
    else
      self.cinematic:remove()
      self.cinematic = nil
      self.waitingFor = "time"
      self.waitTime = 0
    end
  elseif action.action == "advance-cinematic" then
    self.dialogueBox:hide()
    self.cinematic:advance()
    self.waitingFor = "cinematic"
  elseif action.action == "dismiss-cinematic" then
    if self.cinematic then
      self.cinematic:remove()
    end
    self.cinematic = nil
    self.dialogueBox:clear()
    self.dialogueBox:show()
    self.waitingFor = "time"
    self.waitTime = 0.0
  elseif action.action == "stream-next-dialogue" then
    self:close(nil, true)
  elseif action.action == "roll-credits" then
    self:transitionOut(true)
  -- Unknown action, return false to indicate we weren't able to process it
  else
    return false
  end
  -- Return true to indicate we were able to process the action
  return true
end

function DialogueScene:evalDialogueField(fieldData)
  -- The field is a conditional, so process it and figure out which value to return
  if type(fieldData) == "table" and fieldData["if"] then
    local condition = fieldData["if"]
    local conditionIsTrue
    if type(condition) == "table" then
      local method = self:evalDialogueField(condition.method)
      local args = self:evalDialogueField(condition.arguments) or {}
      if not dialogueMethods[method] then
        print("Dialogue method " .. method .. " does not exist")
      end
      conditionIsTrue = dialogueMethods[method](table.unpack(args))
    else
      if not dialogueMethods[condition] then
        print("Dialogue method " .. condition .. " does not exist")
      end
      conditionIsTrue = dialogueMethods[condition]()
    end
    if conditionIsTrue then
      return fieldData["then"]
    else
      return fieldData["else"]
    end
  -- The field should be replaced with the value of a method call
  elseif type(fieldData) == "table" and fieldData.method then
    local method = self:evalDialogueField(fieldData.method)
    local args = self:evalDialogueField(fieldData.arguments) or {}
    return dialogueMethods[method](table.unpack(args))
  -- The field is a simple value, so just return it
  else
    return fieldData
  end
end
