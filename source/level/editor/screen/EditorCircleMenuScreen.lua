import "level/editor/EditorMenu"
import "level/editor/screen/EditorMenuScreen"
import "level/editor/screen/EditorMoveGeometryScreen"

class("EditorCircleMenuScreen").extends("EditorMenuScreen")

function EditorCircleMenuScreen:init()
	self.circle = nil
	self.radius = nil
	EditorCircleMenuScreen.super.init(self,
		EditorMenu("Edit Circle", {
			{
				text = "Move",
				selected = function()
					self:openAndShowSubScreen(EditorMoveGeometryScreen(), self.circle)
				end
			},
			{
				text = "Radius",
				increase = function()
					self.radius += 5
					self.circle.radius = math.abs(self.radius)
				end,
				decrease = function()
					self.radius -= 5
					self.circle.radius = math.abs(self.radius)
				end
			},
			{
				text = "Delete",
				selected = function()
					if self.circle:delete() then
						self:close()
					end
				end
			}
		}), true)
end

function EditorCircleMenuScreen:open(circle)
	self.circle = circle
	self.radius = self.circle.radius
end

function EditorCircleMenuScreen:show()
	scene.cursor.x, scene.cursor.y = self.circle:getMidPoint()
end

function EditorCircleMenuScreen:draw()
	EditorCircleMenuScreen.super.draw(self)
	scene.cursor:draw()
end
