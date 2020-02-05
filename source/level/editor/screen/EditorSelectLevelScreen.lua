import "level/editor/EditorMenu"
import "level/editor/screen/EditorMenuScreen"
import "level/editor/screen/EditorEditLevelScreen"
import "level/editor/screen/EditorKeyboardScreen"
import "level/levelIO"

class("EditorSelectLevelScreen").extends("EditorMenuScreen")

function EditorSelectLevelScreen:init()
	EditorSelectLevelScreen.super.init(self,
		EditorMenu("Select a level to edit", {
			{
				text = "New level",
				selected = function()
					self:openAndShowSubScreen(EditorKeyboardScreen(), "Level name", function(screen, text)
						if #text > 0 then
							createNewLevel(text)
						end
						screen:close()
					end)
				end
			}
		}), false)
end

function EditorSelectLevelScreen:show()
	local levelList = loadLevelList()
	local options = {
		self.menu.options[1]
	}
	for _, levelInfo in ipairs(levelList) do
		table.insert(options, {
			text = levelInfo.name .. (levelInfo.isUserCreated and (levelInfo.overwrittenLevelName and " (user-modified)" or " (user-created)") or ""),
			selected = function()
				local levelData = loadLevelData(levelInfo)
				if levelData then
					scene:loadLevel(levelInfo, levelData)
					self:openAndShowSubScreen(EditorEditLevelScreen(), levelInfo)
				end
			end
		})
	end
	self.menu:setOptions(options)
end
