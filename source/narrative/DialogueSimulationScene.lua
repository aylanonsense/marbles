import "CoreLibs/object"
import "scene/Scene"
import "ui/DebugMenu"

class("DialogueSimulationScene").extends(Scene)

function DialogueSimulationScene:init(dialogueName)
  self.menu = DebugMenu("Dialogue: " .. dialogueName:gsub("_", "-"), {
    {
      text = "Play dialogue",
      selected = function()
        self:endScene(true)
      end
    },
    {
      text = "Skip",
      selected = function()
        self:endScene(false)
      end
    }
  })
end

function DialogueSimulationScene:update()
  self.menu:update()
end

function DialogueSimulationScene:draw()
  playdate.graphics.clear()
  self.menu:draw()
end

function DialogueSimulationScene:AButtonDown()
  self.menu:select()
end

function DialogueSimulationScene:BButtonDown()
  if not self.menu:deselect() then
    if self.canCloseMenu then
      self:close()
    end
  end
end

function DialogueSimulationScene:upButtonDown()
  self.menu:highlightPreviousOption()
end

function DialogueSimulationScene:downButtonDown()
  self.menu:highlightNextOption()
end

function DialogueSimulationScene:leftButtonDown()
  self.menu:change(-1)
end

function DialogueSimulationScene:rightButtonDown()
  self.menu:change(1)
end

