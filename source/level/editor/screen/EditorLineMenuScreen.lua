import "level/editor/EditorMenu"
import "level/editor/screen/EditorMenuScreen"
import "level/editor/screen/EditorMoveGeometryScreen"

class("EditorLineMenuScreen").extends("EditorMenuScreen")

function EditorLineMenuScreen:init()
	self.line = nil
	EditorLineMenuScreen.super.init(self,
		EditorMenu("Edit Line", {
			{
				text = "Move",
				selected = function()
					self:openAndShowSubScreen(EditorMoveGeometryScreen(), self.line)
				end
			},
			{
				text = "Split",
				selected = function()
					self.line:split()
					self:close()
				end
			},
			{
				text = "Extrude",
				selected = function()
					self.line:extrude()
					self:openAndShowSubScreen(EditorMoveGeometryScreen(), self.line)
				end
			},
			{
				text = "Radius",
				change = function(dir, screen, option)
					local prevRadius = self.line.radius
					local dx = self.line.endPoint.x - self.line.startPoint.x
					local dy = self.line.endPoint.y - self.line.startPoint.y
					local smallestRadius = math.sqrt(dx * dx + dy * dy) / 2
					if dir > 0 then
						if self.line.radius == 0 then
							self.line.radius = smallestRadius
						else
							self.line.radius = 5 * math.floor(self.line.radius / 5) + ((self.line.radius >= 100 or self.line.radius <= -110) and 10 or 5)
						end
						if prevRadius < -smallestRadius and self.line.radius > -smallestRadius then
							self.line.radius = -smallestRadius
						elseif -smallestRadius < self.line.radius and self.line.radius < smallestRadius then
							self.line.radius = 0
						end
					else
						if self.line.radius == 0 then
							self.line.radius = -smallestRadius
						else
							self.line.radius = 5 * math.ceil(self.line.radius / 5) - ((self.line.radius <= -100 or self.line.radius >= 110) and 10 or 5)
						end
						if prevRadius > smallestRadius and self.line.radius < smallestRadius then
							self.line.radius = smallestRadius
						elseif -smallestRadius < self.line.radius and self.line.radius < smallestRadius then
							self.line.radius = 0
						end
					end
					option.text = "Radius: " .. self.line.radius
				end
			},
			{
				text = "Solid",
				change = function(dir, menu, option)
					self.line.isSolid = not self.line.isSolid
					option.text = "Solid: " .. (self.line.isSolid and "true" or "false")
				end
			},
			{
				text = "Visible",
				change = function(dir, menu, option)
					self.line.isVisible = not self.line.isVisible
					option.text = "Visible: " .. (self.line.isVisible and "true" or "false")
				end
			},
			{
				text = "Delete",
				selected = function()
					if self.line:delete() then
						self:close()
					end
				end
			}
		}), true)
end

function EditorLineMenuScreen:open(line)
	self.line = line
end

function EditorLineMenuScreen:show()
	scene.cursor.x, scene.cursor.y = self.line:getMidPoint()
	self.menu.options[4].text = "Radius: " .. self.line.radius
	self.menu.options[5].text	= "Solid: " .. (self.line.isSolid and "true" or "false")
	self.menu.options[6].text	= "Visible: " .. (self.line.isVisible and "true" or "false")
end

function EditorLineMenuScreen:draw()
	EditorLineMenuScreen.super.draw(self)
	scene.cursor:draw()
end
