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
				text = "Set as world boundary",
				selected = function(menu, option)
					if self.polygon.isWorldBoundary then
						self.polygon.isWorldBoundary = false
						scene.worldBoundary = nil
						option.text = "Set as world boundary"
					else
						if scene.worldBoundary then
							scene.worldBoundary.isWorldBoundary = false
						end
						scene.worldBoundary = self.polygon
						self.polygon.isWorldBoundary = true
						option.text = "Convert to polygon"
					end
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
	self.menu.options[2].text = polygon.isWorldBoundary and "Convert to polygon" or "Set as world boundary"
end

function EditorPolygonMenuScreen:show()
	scene.cursor.x, scene.cursor.y = self.polygon:getMidPoint()
end

function EditorPolygonMenuScreen:draw()
	EditorPolygonMenuScreen.super.draw(self)
	scene.cursor:draw()
end
