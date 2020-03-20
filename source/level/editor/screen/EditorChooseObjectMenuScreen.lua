import "level/editor/screen/EditorCreateObjectScreen"
import "level/object/Booster"
import "level/object/Coin"
import "level/object/CrumblingPlatform"
import "level/object/Exit"
import "level/object/Decoration"


class("EditorChooseObjectMenuScreen").extends("EditorMenuScreen")

function EditorChooseObjectMenuScreen:init()
  EditorChooseObjectMenuScreen.super.init(self,
    EditorMenu("Create Object", {
      {
        text = "Booster",
        selected = function()
          self:openAndShowSubScreen(EditorCreateObjectScreen(), Booster(scene.cursor.x, scene.cursor.y, 0))
        end
      },
      {
        text = "Coin",
        selected = function()
          self:openAndShowSubScreen(EditorCreateObjectScreen(), Coin(scene.cursor.x, scene.cursor.y))
        end
      },
      {
        text = "CrumblingPlatform",
        selected = function()
          self:openAndShowSubScreen(EditorCreateObjectScreen(), CrumblingPlatform(scene.cursor.x, scene.cursor.y))
        end
      },
      {
        text = "Exit",
        selected = function()
          self:openAndShowSubScreen(EditorCreateObjectScreen(), Exit(scene.cursor.x, scene.cursor.y))
        end
      },
      {
        text = "Decoration",
        selected = function()
          self:openAndShowSubScreen(EditorCreateObjectScreen(), Decoration(scene.cursor.x, scene.cursor.y, "yield-sign"))
        end
      }
    }))
end
