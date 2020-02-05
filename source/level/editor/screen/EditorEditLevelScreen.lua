import "render/camera"
import "level/editor/EditorMenu"
import "level/editor/screen/EditorMenuScreen"
import "level/editor/screen/EditorCreatePolygonScreen"
import "level/editor/screen/EditorCreateCircleScreen"
import "level/editor/screen/EditorSelectGeometryScreen"
import "level/editor/screen/EditorPointMenuScreen"
import "level/editor/screen/EditorLineMenuScreen"
import "level/editor/screen/EditorPolygonMenuScreen"
import "level/editor/screen/EditorCircleMenuScreen"
import "level/editor/screen/EditorCameraMenuScreen"
import "level/editor/geometry/EditorGeometry"

class("EditorEditLevelScreen").extends("EditorMenuScreen")

function EditorEditLevelScreen:init()
	self.levelInfo = nil
	EditorEditLevelScreen.super.init(self,
		EditorMenu("Level", {
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
							},
							{
								text = "Circle",
								selected = function()
									self:openAndShowSubScreen(EditorCreateCircleScreen())
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
						elseif geometry.type == EditorGeometry.Type.Circle then
							self:openAndShowSubScreen(EditorCircleMenuScreen(), geometry)
						end
					end)
				end
			},
			{
				text = "Camera",
				selected = function()
					self:openAndShowSubScreen(EditorCameraMenuScreen())
				end
			},
			{
				text = "Save",
				selected = function()
					scene:saveLevel(self.levelInfo)
				end
			},
			{
				text = "Save & run",
				selected = function()
					scene:saveAndTestLevel(self.levelInfo)
				end
			},
			{
				text = "Close",
				selected = function()
					self:close()
				end
			}
		}), false)
end

function EditorEditLevelScreen:open(levelInfo)
	self.levelInfo = levelInfo
	self.menu.title = "Level: " .. levelInfo.name
end
