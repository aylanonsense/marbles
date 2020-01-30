import "render/camera"
import "level/editor/EditorMenu"
import "level/editor/screen/EditorMenuScreen"
import "level/editor/screen/EditorFreeLookScreen"

local CAMERA_SCALES = { 0.05, 0.10, 0.25, 0.5, 1.0, 1.5, 2.0, 3.0 }
local CURSOR_GRID_SIZES = { 480, 240, 80, 40, 20, 20, 10, 10 }

class("EditorCameraMenuScreen").extends("EditorMenuScreen")

function EditorCameraMenuScreen:init()
	EditorCameraMenuScreen.super.init(self,
		EditorMenu("Camera", {
			{
				text = "Free Look",
				selected = function()
					self:openAndShowSubScreen(EditorFreeLookScreen())
				end
			},
			{
				text = "Scale (" .. camera.scale .. "x)",
				increase = function(menu, option)
					for i = 1, #CAMERA_SCALES do
						if CAMERA_SCALES[i] > camera.scale then
							camera.scale = CAMERA_SCALES[i]
							scene.cursor.gridSize = CURSOR_GRID_SIZES[i]
							option.text = "Scale (" .. camera.scale .. "x)"
							break
						end
					end
				end,
				decrease = function(menu, option)
					for i = #CAMERA_SCALES, 1, -1 do
						if CAMERA_SCALES[i] < camera.scale then
							camera.scale = CAMERA_SCALES[i]
							scene.cursor.gridSize = CURSOR_GRID_SIZES[i]
							option.text = "Scale (" .. camera.scale .. "x)"
							break
						end
					end
				end
			},
			{
				text = "Rotation (" .. camera.rotation .. ")",
				increase = function(menu, option)
					camera.rotation += 15
					if camera.rotation >= 360 then
						camera.rotation -= 360
					end
					option.text = "Rotation (" .. camera.rotation .. ")"
				end,
				decrease = function(menu, option)
					camera.rotation -= 15
					if camera.rotation < 0 then
						camera.rotation += 360
					end
					option.text = "Rotation (" .. camera.rotation .. ")"
				end
			}
		}), true)
end
