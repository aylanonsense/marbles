import "render/camera"
import "level/editor/EditorMenu"
import "level/editor/process/EditorMenuProcess"
import "level/editor/process/EditorCameraMenu"
import "level/editor/process/EditorCreatePolygon"
import "level/editor/process/EditorSelectGeometry"

class("EditorMainMenu").extends("EditorMenuProcess")

function EditorMainMenu:init()
	EditorMainMenu.super.init(self,
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
									self:spawnProcess(EditorCreatePolygon())
								end
							}
						})
					}
				})
			},
			{
				text = "Edit",
				selected = function()
					self:spawnProcess(EditorSelectGeometry())
				end
			},
			{
				text = "Camera",
				selected = function()
					self:spawnProcess(EditorCameraMenu())
				end
			}
		}), false)
end
