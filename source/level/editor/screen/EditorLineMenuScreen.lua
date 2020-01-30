import "level/editor/EditorMenu"
import "level/editor/screen/EditorMenuScreen"
import "level/editor/screen/EditorMoveGeometryScreen"

class("EditorLineMenuScreen").extends("EditorMenuScreen")

function EditorLineMenuScreen:init()
	self.line = nil
	EditorLineMenuScreen.super.init(self,
		EditorMenu("Edit Line", {
			{
				text = "Move",
				selected = function()
					self:openAndShowSubScreen(EditorMoveGeometryScreen(), self.line)
				end
			},
			{
				text = "Split",
				selected = function()
					self.line:split()
					self:close()
				end
			},
			{
				text = "Delete",
				selected = function()
					if self.line:delete() then
						self:close()
					end
				end
			}
		}), true)
end

function EditorLineMenuScreen:open(line)
	self.line = line
end

function EditorLineMenuScreen:show()
	scene.cursor.position.x, scene.cursor.position.y = self.line:getMidPoint()
end

function EditorLineMenuScreen:draw()
	EditorLineMenuScreen.super.draw(self)
	scene.cursor:draw()
end
