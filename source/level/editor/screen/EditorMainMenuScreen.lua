import "render/camera"
import "level/editor/EditorMenu"
import "level/editor/screen/EditorMenuScreen"
import "level/editor/screen/EditorCreatePolygonScreen"
import "level/editor/screen/EditorSelectGeometryScreen"
import "level/editor/screen/EditorPointMenuScreen"
import "level/editor/screen/EditorLineMenuScreen"
import "level/editor/screen/EditorPolygonMenuScreen"
import "level/editor/screen/EditorCameraMenuScreen"
import "level/editor/geometry/EditorGeometry"

class("EditorMainMenuScreen").extends("EditorMenuScreen")

function EditorMainMenuScreen:init()
	EditorMainMenuScreen.super.init(self,
		EditorMenu("Level Editor", {
			{
				text = "Create",
				submenu = EditorMenu("Create", {
					{
						text = "Geometry",
						submenu = EditorMenu("Create Geometry", {
							{
								text = "Polygon",
								selected = function()
									self:openAndShowSubScreen(EditorCreatePolygonScreen())
								end
							}
						})
					}
				})
			},
			{
				text = "Edit",
				selected = function()
					self:openAndShowSubScreen(EditorSelectGeometryScreen(), function(screen, geometry)
						screen:close()
						if geometry.type == EditorGeometry.Type.Point then
							self:openAndShowSubScreen(EditorPointMenuScreen(), geometry)
						elseif geometry.type == EditorGeometry.Type.Line then
							self:openAndShowSubScreen(EditorLineMenuScreen(), geometry)
						elseif geometry.type == EditorGeometry.Type.Polygon then
							self:openAndShowSubScreen(EditorPolygonMenuScreen(), geometry)
						end
					end)
				end
			},
			{
				text = "Camera",
				selected = function()
					self:openAndShowSubScreen(EditorCameraMenuScreen())
				end
			}
		}), false)
end
