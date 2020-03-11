import "level/editor/EditorMenu"
import "level/editor/screen/EditorMenuScreen"
import "level/editor/screen/EditorMoveGeometryScreen"
import "render/patterns"

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
				text = "Solid",
				change = function(dir, menu, option)
					self.polygon.isSolid = not self.polygon.isSolid
					for _, point in ipairs(self.polygon.points) do
						point.isSolid = self.polygon.isSolid
						if point.outgoingLine then
							point.outgoingLine.isSolid = self.polygon.isSolid
						end
					end
					option.text = "Solid: " .. (self.polygon.isSolid and "true" or "false")
				end
			},
			{
				text = "Visible",
				change = function(dir, menu, option)
					self.polygon.isVisible = not self.polygon.isVisible
					for _, point in ipairs(self.polygon.points) do
						point.isVisible = self.polygon.isVisible
						if point.outgoingLine then
							point.outgoingLine.isVisible = self.polygon.isVisible
						end
					end
					option.text = "Visible: " .. (self.polygon.isVisible and "true" or "false")
				end
			},
			{
				text = "Pattern",
				change = function(dir, menu, option)
					local patternIndex
					for i, patternName in ipairs(patternNames) do
						if self.polygon.fillPattern == patternName then
							patternIndex = i
							break
						end
					end
					patternIndex += dir
					if patternIndex < 1 then
						patternIndex = #patternNames
					elseif patternIndex > #patternNames then
						patternIndex = 1
					end
					self.polygon.fillPattern = patternNames[patternIndex]
					option.text = "Pattern: " .. self.polygon.fillPattern
				end
			},
			{
				text = "Layer",
				change = function(dir, menu, option)
					self.polygon.layer += dir
					option.text = "Layer: " .. self.polygon.layer
					scene:sortGeometryAndObjects()
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
	self.menu.options[3].text	= "Solid: " .. (self.polygon.isSolid and "true" or "false")
	self.menu.options[4].text	= "Visible: " .. (self.polygon.isVisible and "true" or "false")
	self.menu.options[5].text	= "Pattern: " .. self.polygon.fillPattern
	self.menu.options[6].text	= "Layer: " .. self.polygon.layer
end

function EditorPolygonMenuScreen:show()
	scene.cursor.x, scene.cursor.y = self.polygon:getMidPoint()
end

function EditorPolygonMenuScreen:draw()
	EditorPolygonMenuScreen.super.draw(self)
	scene.cursor:draw()
end
