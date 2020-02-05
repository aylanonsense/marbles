import "level/editor/geometry/EditorGeometry"
import "level/editor/geometry/EditorPoint"
import "level/editor/geometry/EditorLine"
import "level/editor/geometry/EditorPolygon"

local function serializePolygon(point)
	
end

local function serializePoint(point)

end

function serializeLevelData()
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
		geometry = geometryData
	}
end

function deserializeLevelData(levelData)
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
				local endPoint = points[(i == #points) and 1 or (#points + 1)]
				EditorLine(startPoint, endPoint)
			end
			local polygon = EditorPolygon(startPoint, endPoint)
			table.insert(scene.geometry, polygon)
		end
	end
end
