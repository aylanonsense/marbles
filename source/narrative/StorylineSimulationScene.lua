import "CoreLibs/object"
import "scene/Scene"
import "ui/DebugMenu"

class("StorylineSimulationScene").extends(Scene)

function StorylineSimulationScene:init(storylineData, playthroughData)
  local options = {
    {
      text = "Play level",
      selected = function()
        self:endScene(true)
      end
    }
  }
  if storylineData.special then
    table.insert(options, {
      text = "Skip to " .. playthroughData.storylines[storylineData.special].symbol .. ". " .. playthroughData.storylines[storylineData.special].label .. " (special)",
      selected = function()
        self:endScene(false, "special")
      end
    })
  end
  if storylineData.normal then
    table.insert(options, {
      text = "Skip to " .. playthroughData.storylines[storylineData.normal].symbol .. ". " .. playthroughData.storylines[storylineData.normal].label .. " (normal)",
      selected = function()
        self:endScene(false, "normal")
      end
    })
  end
  if storylineData.fail then
    table.insert(options, {
      text = "Skip to " .. playthroughData.storylines[storylineData.fail].symbol .. ". " .. playthroughData.storylines[storylineData.fail].label .. " (fail)",
      selected = function()
        self:endScene(false, "fail")
      end
    })
  end
  if storylineData.next then
    table.insert(options, {
      text = "Skip to " .. playthroughData.storylines[storylineData.next].symbol .. ". " .. playthroughData.storylines[storylineData.next].label,
      selected = function()
        self:endScene(false, nil)
      end
    })
  end
  self.menu = DebugMenu(storylineData.symbol .. ". " .. storylineData.label, options)
end

function StorylineSimulationScene:update()
  self.menu:update()
end

function StorylineSimulationScene:draw()
  playdate.graphics.clear()
  self.menu:draw()
end

function StorylineSimulationScene:AButtonDown()
  self.menu:select()
end

function StorylineSimulationScene:BButtonDown()
  if not self.menu:deselect() then
    if self.canCloseMenu then
      self:close()
    end
  end
end

function StorylineSimulationScene:upButtonDown()
  self.menu:highlightPreviousOption()
end

function StorylineSimulationScene:downButtonDown()
  self.menu:highlightNextOption()
end

function StorylineSimulationScene:leftButtonDown()
  self.menu:change(-1)
end

function StorylineSimulationScene:rightButtonDown()
  self.menu:change(1)
end

