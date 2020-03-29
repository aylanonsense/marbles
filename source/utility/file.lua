function loadJsonFile(path)
  local data = json.decodeFile(path)
  if not data then
    print("Failed to load data at " .. path .. ": the file may not exist or may contain invalid JSON")
  end
  return data
end
