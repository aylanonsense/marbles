import "level/editor/geometry/EditorGeometry"
import "level/editor/geometry/EditorPoint"
import "level/editor/geometry/EditorLine"
import "level/editor/geometry/EditorPolygon"

function serializeEditorLevelData()
	local geometryData = {}
	for _, geom in ipairs(scene.geometry) do
		-- Serialize a polygon
		if geom.type == EditorGeometry.Type.Polygon then
			local polygonData = {
				type = "Polygon",
				points = {},
				lines = {}
			}
			for _, point in ipairs(geom.points) do
				table.insert(polygonData.points, {
					x = point.x,
					y = point.y
				})
				table.insert(polygonData.lines, {})
			end
			table.insert(geometryData, polygonData)
		end
	end
	return {
		spawn = { x = scene.spawn.x, y = scene.spawn.y },
		geometry = geometryData
	}
end

function deserializeEditorLevelData(levelData)
	scene.spawn = { x = levelData.spawn.x, y = levelData.spawn.y }
	scene.geometry = {}
	for _, geomData in ipairs(levelData.geometry) do
		-- Deserialize a polygon
		if geomData.type == "Polygon" then
			local points = {}
			for _, pointData in ipairs(geomData.points) do
				table.insert(points, EditorPoint(pointData.x, pointData.y))
			end
			for i, lineData in ipairs(geomData.lines) do
				local startPoint = points[i]
				local endPoint = points[(i == #points) and 1 or (i + 1)]
				EditorLine(startPoint, endPoint)
			end
			local polygon = EditorPolygon(points)
			table.insert(scene.geometry, polygon)
		end
	end
end

function serializePlayableLevelData(levelData)
	local geometryData = {}
	for _, geom in ipairs(scene.geometry) do
		-- Serialize a polygon
		if geom.type == EditorGeometry.Type.Polygon then
			local polygonData = {
				type = "Polygon",
				render = {},
				physics = {}
			}
			local isClockwise = geom:isClockwise()
			for _, point in ipairs(geom.points) do
				table.insert(polygonData.render, point.x)
				table.insert(polygonData.render, point.y)
				if isClockwise then
					table.insert(polygonData.physics, {
						type = "Line",
						x1 = point.outgoingLine.startPoint.x,
						y1 = point.outgoingLine.startPoint.y,
						x2 = point.outgoingLine.endPoint.x,
						y2 = point.outgoingLine.endPoint.y
					})
				else
					table.insert(polygonData.physics, {
						type = "Line",
						x1 = point.outgoingLine.endPoint.x,
						y1 = point.outgoingLine.endPoint.y,
						x2 = point.outgoingLine.startPoint.x,
						y2 = point.outgoingLine.startPoint.y
					})
				end
				table.insert(polygonData.physics, {
					type = "Point",
					x = point.x,
					y = point.y
				})
			end
			table.insert(geometryData, polygonData)
		end
	end
	return {
		spawn = { x = scene.spawn.x, y = scene.spawn.y },
		geometry = geometryData
	}
end
