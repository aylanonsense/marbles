function loadLevelList()
	print("Loading a list of all levels")
	local collatedLevelList = {}
	-- Load the levels the user has created
	local userLevels = playdate.datastore.read("user-levels")
	if userLevels then
		print("  Found " .. #userLevels.levels .. " " .. (#userLevels.levels == 1 and "level" or "levels") .. " in user-levels.json in the user's datastore")
		for _, levelInfo in ipairs(userLevels.levels) do
			print("    " .. levelInfo.name .. " (" .. levelInfo.editFile .. ")" .. (levelInfo.overwrittenLevelName and (" [masks level " .. levelInfo.overwrittenLevelName .. "]") or ""))
			levelInfo.isUserCreated = true
			table.insert(collatedLevelList, levelInfo)
		end
	else
		print("  No user-levels.json file found in the user's datastore")
	end
	-- Load the levels packaged with the game
	local levels = json.decodeFile("/data/levels.json")
	print("  Found " .. #levels.levels .. " " .. (#levels.levels == 1 and "level" or "levels") .. " in levels.json")
	for _, levelInfo in ipairs(levels.levels) do
		-- Hide levels if the user has their own modified copy
		local isMasked = false
		if userLevels then
			for _, userLevelInfo in ipairs(userLevels.levels) do
				if userLevelInfo.overwrittenLevelName == levelInfo.name then
					isMasked = true
					break
				end
			end
		end
		print("    " .. levelInfo.name .. " (" .. levelInfo.editFile .. ")" .. (isMasked and (" [masked by user-created level]") or ""))
		if not isMasked then
			levelInfo.isUserCreated = false
			table.insert(collatedLevelList, levelInfo)
		end
	end
	print("  Returning " .. #collatedLevelList .. " " .. (#collatedLevelList == 1 and "level" or "levels") .. " in total")
	return collatedLevelList
end

function loadEditorLevelData(levelInfo)
	if levelInfo.isUserCreated then
		-- Load from the datastore
		print("Loading user-created level " .. levelInfo.name .. " from " .. levelInfo.editFile .. " in the user's datastore")
		return playdate.datastore.read(string.sub(levelInfo.editFile, 1, -6))
	else
		-- Load from the game's files
		print("Loading level " .. levelInfo.name .. " from " .. levelInfo.editFile .. " in the game's files")
		return json.decodeFile("/data/levels/" .. levelInfo.editFile)
	end
end

function loadPlayableLevelData(levelInfo)
	if levelInfo.isUserCreated then
		-- Load from the datastore
		print("Loading user-created level " .. levelInfo.name .. " from " .. levelInfo.playFile .. " in the user's datastore")
		return playdate.datastore.read(string.sub(levelInfo.playFile, 1, -6))
	else
		-- Load from the game's files
		print("Loading level " .. levelInfo.name .. " from " .. levelInfo.playFile .. " in the game's files")
		return json.decodeFile("/data/levels/" .. levelInfo.playFile)
	end
end

function saveLevelData(levelInfo, playableLevelData, editorLevelData)
	if levelInfo.isUserCreated then
		-- If this is a user-created level, save the level to the datastore
		print("Saving user-created level " .. levelInfo.name .. " to " .. levelInfo.playFile .. " and " .. levelInfo.editFile .. " in the user's datastore")
		playdate.datastore.write(playableLevelData, string.sub(levelInfo.playFile, 1, -6), true)
		playdate.datastore.write(editorLevelData, string.sub(levelInfo.editFile, 1, -6), true)
	else
		-- The user edited a level that exists in the game data.
		--   We can't overwrite that file, so save a copy to the
		--  datastore which'll mask that level from now on
		local levelInfoToSave = {
			name = levelInfo.name,
			playFile = levelInfo.playFile,
			editFile = levelInfo.editFile,
			overwrittenLevelName = levelInfo.name
		}
		local isFirstTimeOverwritingLevel = true
		local userLevels = playdate.datastore.read("user-levels") or { levels = {} }
		for i, userLevelInfo in ipairs(userLevels.levels) do
			if userLevelInfo.overwrittenLevelName == levelInfo.name then
				isFirstTimeOverwritingLevel = false
				userLevels.levels[i] = levelInfoToSave
				break
			end
		end
		print("Saving changes to level " .. levelInfo.name .. " to " .. levelInfoToSave.playFile .. " and " .. levelInfoToSave.editFile .. " in the user's datastore")
		playdate.datastore.write(playableLevelData, string.sub(levelInfoToSave.playFile, 1, -6), true)
		playdate.datastore.write(editorLevelData, string.sub(levelInfoToSave.editFile, 1, -6), true)
		if isFirstTimeOverwritingLevel then
			print("  First time overwriting level " .. levelInfo.name .. ", adding to user-levels.json in the user's datastore")
			table.insert(userLevels.levels, levelInfoToSave)
		end
		print("  Saving changes to level " .. levelInfo.name .. " to user-levels.json in the user's datastore")
		playdate.datastore.write(userLevels, "user-levels", true)
	end
end

function createNewLevel(name)
	print("Creating a new level named " .. name)
	local userLevels = playdate.datastore.read("user-levels") or { levels = {} }
	print("  " .. #userLevels.levels .. " user-created " .. (#userLevels.levels == 1 and "level" or "levels") .. " exist already")
	local file = ""
	for i = 1, #name do
		local c = string.sub(name, i, i)
		if c == " " or c == "_" then
			file = file .. "-"
		else
			file = file .. string.lower(c)
		end
	end
	local playFile = file .. "-play.json"
	local editFile = file .. "-edit.json"
	local levelInfo = {
		name = name,
		playFile = playFile,
		editFile = editFile
	}
	local levelData = {
		name = name,
		spawn = { x = 0, y = 0 },
		objects = {},
		geometry = {}
	}
	table.insert(userLevels.levels, levelInfo)
	print("  Saving new level " .. name .. " to " .. editFile .. " in the user's datastore")
	playdate.datastore.write(levelData, string.sub(editFile, 1, -6), true)
	print("  Adding new level " .. name .. " to user-levels.json in the user's datastore")
	playdate.datastore.write(userLevels, "user-levels", true)
	levelInfo.isUserCreated = true
	return levelInfo, levelData
end
