import "level/editor/EditorMenu"
import "level/editor/screen/EditorMenuScreen"
import "level/editor/screen/EditorMoveGeometryScreen"

class("EditorPolygonMenuScreen").extends("EditorMenuScreen")

function EditorPolygonMenuScreen:init()
	self.polygon = nil
	EditorPolygonMenuScreen.super.init(self,
		EditorMenu("Edit Polygon", {
			{
				text = "Move",
				selected = function()
					self:openAndShowSubScreen(EditorMoveGeometryScreen(), self.polygon)
				end
			},
			{
				text = "Delete",
				selected = function()
					if self.polygon:delete() then
						self:close()
					end
				end
			}
		}), true)
end

function EditorPolygonMenuScreen:open(polygon)
	self.polygon = polygon
end

function EditorPolygonMenuScreen:show()
	scene.cursor.position.x, scene.cursor.position.y = self.polygon:getMidPoint()
end

function EditorPolygonMenuScreen:draw()
	EditorPolygonMenuScreen.super.draw(self)
	scene.cursor:draw()
end
