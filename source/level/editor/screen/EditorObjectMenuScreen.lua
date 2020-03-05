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
	for _, fieldData in ipairs(self.obj:getEditableFields()) do
		local option = {
			text = (fieldData.label or fieldData.field) .. ": " .. self.obj[fieldData.field],
			increase = function(menu, option)
				if fieldData.change then
					fieldData.change(1)
				end
				option.text = (fieldData.label or fieldData.field) .. ": " .. self.obj[fieldData.field]
			end,
			decrease = function(menu, option)
				if fieldData.change then
					fieldData.change(-1)
				end
				option.text = (fieldData.label or fieldData.field) .. ": " .. self.obj[fieldData.field]
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
