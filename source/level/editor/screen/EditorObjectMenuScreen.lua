import "level/editor/EditorMenu"
import "level/editor/screen/EditorMenuScreen"
import "level/editor/screen/EditorMoveObjectScreen"
import "utility/table"

class("EditorObjectMenuScreen").extends("EditorMenuScreen")

function EditorObjectMenuScreen:init()
	self.obj = nil
	EditorObjectMenuScreen.super.init(self,
		EditorMenu("Edit Object", {}), true)
end

function EditorObjectMenuScreen:open(obj)
	self.obj = obj
	local options = {}
	table.insert(options, {
		text = "Move",
		selected = function()
			self:openAndShowSubScreen(EditorMoveObjectScreen(), self.obj)
		end
	})
	table.insert(options, {
		text = "Layer: " .. self.obj.layer,
		change = function(dir, menu, option)
			self.obj.layer += dir
			option.text = "Layer: " .. self.obj.layer
		end
	})
	for _, fieldData in ipairs(self.obj:getEditableFields()) do
		local label
		if fieldData.field then
			label = (fieldData.label or fieldData.field) .. ": " .. self.obj[fieldData.field]
		else
			label = fieldData.label
		end
		local option = {
			text = label,
			change = function(dir, menu, option)
				local label
				if fieldData.change then
					label = fieldData.change(dir)
				end
				if not label and fieldData.field then
					label = (fieldData.label or fieldData.field) .. ": " .. self.obj[fieldData.field]
				end
				if label then
					option.text = label
				end
			end
		}
		table.insert(options, option)
	end
	table.insert(options, {
		text = "Delete",
		selected = function()
			removeItem(scene.objects, self.obj)
			self:close()
		end
	})
	self.menu.title = "Edit Object: " .. self.obj.type
	self.menu:setOptions(options)
end

function EditorObjectMenuScreen:show()
	scene.cursor.x, scene.cursor.y = self.obj:getPosition()
end

function EditorObjectMenuScreen:draw()
	EditorObjectMenuScreen.super.draw(self)
	scene.cursor:draw()
end
