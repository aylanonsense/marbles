import "level/editor/EditorMenu"
import "level/editor/screen/EditorMenuScreen"
import "level/editor/screen/EditorMoveGeometryScreen"

class("EditorPointMenuScreen").extends("EditorMenuScreen")

function EditorPointMenuScreen:init()
	self.point = nil
	EditorPointMenuScreen.super.init(self,
		EditorMenu("Edit Point", {
			{
				text = "Move",
				selected = function()
					self:openAndShowSubScreen(EditorMoveGeometryScreen(), self.point)
				end
			},
			{
				text = "Solid",
				change = function(dir, menu, option)
					self.point.isSolid = not self.point.isSolid
					option.text = "Solid: " .. (self.point.isSolid and "true" or "false")
				end
			},
			{
				text = "Delete",
				selected = function()
					if self.point:delete() then
						self:close()
					end
				end
			}
		}), true)
end

function EditorPointMenuScreen:open(point)
	self.point = point
	self.menu.options[2].text	= "Solid: " .. (self.point.isSolid and "true" or "false")
end

function EditorPointMenuScreen:show()
	scene.cursor.x, scene.cursor.y = self.point:getMidPoint()
end

function EditorPointMenuScreen:draw()
	EditorPointMenuScreen.super.draw(self)
	scene.cursor:draw()
end
