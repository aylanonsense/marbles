import "level/editor/EditorMenu"
import "level/editor/screen/EditorMenuScreen"
import "level/editor/screen/EditorMoveObjectScreen"
import "utility/table"

class("EditorObjectMenuScreen").extends("EditorMenuScreen")

function EditorObjectMenuScreen:init()
	self.obj = nil
	EditorObjectMenuScreen.super.init(self,
		EditorMenu("Edit Object", {
			{
				text = "Move",
				selected = function()
					self:openAndShowSubScreen(EditorMoveObjectScreen(), self.obj)
				end
			},
			{
				text = "Delete",
				selected = function()
					removeItem(scene.objects, self.obj)
					self:close()
				end
			}
		}), true)
end

function EditorObjectMenuScreen:open(obj)
	self.obj = obj
end

function EditorObjectMenuScreen:show()
	scene.cursor.position.x, scene.cursor.position.y = self.obj:getPosition()
end

function EditorObjectMenuScreen:draw()
	EditorObjectMenuScreen.super.draw(self)
	scene.cursor:draw()
end
