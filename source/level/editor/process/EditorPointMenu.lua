import "level/editor/EditorMenu"
import "level/editor/process/EditorMenuProcess"
import "level/editor/process/EditorMoveGeometry"

class("EditorPointMenu").extends("EditorMenuProcess")

function EditorPointMenu:init(point)
	self.point = point
	EditorPointMenu.super.init(self,
		EditorMenu("Edit Point", {
			{
				text = "Move",
				selected = function()
					self:spawnProcess(EditorMoveGeometry(self.point))
				end
			},
			{
				text = "Delete",
				selected = function()
					-- TODO
					self:terminate()
				end
			}
		}), true)
end

function EditorPointMenu:draw()
	EditorPointMenu.super.draw(self)
end
