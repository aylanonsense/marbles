import "render/camera"
import "level/editor/EditorMenu"
import "level/editor/screen/EditorMenuScreen"
import "level/editor/screen/EditorCreatePolygonScreen"
import "level/editor/screen/EditorCreateCircleScreen"
import "level/editor/screen/EditorCreateObjectScreen"
import "level/editor/screen/EditorSelectGeometryScreen"
import "level/editor/screen/EditorPointMenuScreen"
import "level/editor/screen/EditorLineMenuScreen"
import "level/editor/screen/EditorPolygonMenuScreen"
import "level/editor/screen/EditorCircleMenuScreen"
import "level/editor/screen/EditorCameraMenuScreen"
import "level/editor/geometry/EditorGeometry"
import "level/object/Coin"

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
					},
					{
						text = "Object",
						submenu = EditorMenu("Create Object", {
							{
								text = "Coin",
								selected = function()
									local coin = Coin(scene.cursor.position.x, scene.cursor.position.y)
									self:openAndShowSubScreen(EditorCreateObjectScreen(), coin)
								end
							},
							{
								text = "Gravity Well"
							},
							{
								text = "Marble"
							},
							{
								text = "Spring Pad"
							}
						})
					}
				})
			},
			{
				text = "Edit",
				selected = function()
					self:openAndShowSubScreen(EditorSelectGeometryScreen(), function(screen, geometry)
						if geometry.type == EditorGeometry.Type.Point then
							screen:openAndShowSubScreen(EditorPointMenuScreen(), geometry)
						elseif geometry.type == EditorGeometry.Type.Line then
							screen:openAndShowSubScreen(EditorLineMenuScreen(), geometry)
						elseif geometry.type == EditorGeometry.Type.Polygon then
							screen:openAndShowSubScreen(EditorPolygonMenuScreen(), geometry)
						elseif geometry.type == EditorGeometry.Type.Circle then
							screen:openAndShowSubScreen(EditorCircleMenuScreen(), geometry)
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
