import "level/editor/screen/EditorCreateObjectScreen"
import "level/object/Booster"
import "level/object/CircleBumper"
import "level/object/Coin"
import "level/object/CrumblingPlatform"
import "level/object/Exit"
import "level/object/Decoration"
import "level/object/TriangleBumper"

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
        text = "Crumbling Platform",
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
      },
      {
        text = "Triangle Bumper",
        selected = function()
          self:openAndShowSubScreen(EditorCreateObjectScreen(), TriangleBumper(scene.cursor.x, scene.cursor.y, false, false))
        end
      },
      {
        text = "Circle Bumper",
        selected = function()
          self:openAndShowSubScreen(EditorCreateObjectScreen(), CircleBumper(scene.cursor.x, scene.cursor.y))
        end
      }
    }))
end
