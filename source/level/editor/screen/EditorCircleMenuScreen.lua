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
				change = function(dir, menu, option)
					self.radius += dir * 5
					self.circle.radius = math.abs(self.radius)
					option.text = "Radius: " .. self.circle.radius
				end
			},
			{
				text = "Solid",
				change = function(dir, menu, option)
					self.circle.isSolid = not self.circle.isSolid
					option.text = "Solid: " .. (self.circle.isSolid and "true" or "false")
				end
			},
			{
				text = "Visible",
				change = function(dir, menu, option)
					self.circle.isVisible = not self.circle.isVisible
					option.text = "Visible: " .. (self.circle.isVisible and "true" or "false")
				end
			},
			{
				text = "Layer",
				change = function(dir, menu, option)
					self.circle.layer += dir
					option.text = "Layer: " .. self.circle.layer
					scene:sortGeometryAndObjects()
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
	self.menu.options[2].text	= "Radius: " .. self.circle.radius
	self.menu.options[3].text	= "Solid: " .. (self.circle.isSolid and "true" or "false")
	self.menu.options[4].text	= "Visible: " .. (self.circle.isVisible and "true" or "false")
	self.menu.options[5].text	= "Layer: " .. self.circle.layer
end

function EditorCircleMenuScreen:show()
	scene.cursor.x, scene.cursor.y = self.circle:getMidPoint()
end

function EditorCircleMenuScreen:draw()
	EditorCircleMenuScreen.super.draw(self)
	scene.cursor:draw()
end
