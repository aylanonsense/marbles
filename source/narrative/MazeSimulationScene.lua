import "CoreLibs/object"
import "scene/Scene"
import "ui/DebugMenu"
import "utility/file"

class("MazeSimulationScene").extends(Scene)

local exitsData = loadJsonFile("/data/exits.json")

function MazeSimulationScene:init(mazeName, exits)
  local options = {
    {
      text = "Play maze",
      selected = function()
        self:endScene(true)
      end
    }
  }
  for _, exitId in ipairs(exits) do
    for _, exitData in ipairs(exitsData.exits) do
      if exitData.id == exitId then
        table.insert(options, {
          text = "Skip with " .. exitData.label .. " (" .. (exitData.score < 2 and "fail" or (exitData.score > 4 and "special" or "normal")) .. ")",
          selected = function()
            self:endScene(false, exitData)
          end
        })
        break
      end
    end
  end
  self.menu = DebugMenu("Maze: " .. mazeName, options)
end

function MazeSimulationScene:update()
  self.menu:update()
end

function MazeSimulationScene:draw()
  playdate.graphics.clear()
  self.menu:draw()
end

function MazeSimulationScene:AButtonDown()
  self.menu:select()
end

function MazeSimulationScene:BButtonDown()
  if not self.menu:deselect() then
    if self.canCloseMenu then
      self:close()
    end
  end
end

function MazeSimulationScene:upButtonDown()
  self.menu:highlightPreviousOption()
end

function MazeSimulationScene:downButtonDown()
  self.menu:highlightNextOption()
end

function MazeSimulationScene:leftButtonDown()
  self.menu:change(-1)
end

function MazeSimulationScene:rightButtonDown()
  self.menu:change(1)
end

