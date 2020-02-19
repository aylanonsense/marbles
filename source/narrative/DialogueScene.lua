import "scene/Scene"
import "narrative/Actor"
import "narrative/DialogueBox"
import "narrative/Location"

class("DialogueScene").extends(Scene)

function DialogueScene:init(convoData)
  DialogueScene.super.init(self)
  self.actors = {}
  self.dialogueBox = DialogueBox()
  self.location = Location(convoData.location)
  self.leftActor = nil
  self.rightActor = nil
  if convoData.left then
    self.leftActor = self:addActor(convoData.left.actor, convoData.left.expression)
    self.leftActor:slideOnStage('left')
  end
  if convoData.right then
    self.rightActor = self:addActor(convoData.right.actor, convoData.right.expression)
    self.rightActor:slideOnStage('right')
  end
end

function DialogueScene:update()
  self.location:update()
  for _, actor in ipairs(self.actors) do
    actor:update()
  end
  self.dialogueBox:update()
end

function DialogueScene:draw()
  playdate.graphics.clear()
  self.location:draw()
  for _, actor in pairs(self.actors) do
    actor:draw()
  end
  self.dialogueBox:draw()
end

function DialogueScene:addActor(id, expression)
  if not self.actors[id] then
    self.actors[id] = Actor(id, expression)
  end
  return self.actors[id]
end
