import "level/editor/geometry/EditorGeometry"
import "level/editor/geometry/EditorPoint"
import "level/editor/geometry/EditorLine"
import "level/editor/geometry/EditorPolygon"
import "level/editor/geometry/EditorCircle"
import "level/object/levelObjectByType"
import "level/object/Circle"
import "level/object/Polygon"
import "level/object/WorldBoundary"
import "physics/PhysPoint"
import "physics/PhysLine"

function serializeEditorLevelData()
	local objectData = {}
	local geometryData = {}
	for _, obj in ipairs(scene.objects) do
		table.insert(objectData, obj:serialize())
	end
	for _, geom in ipairs(scene.geometry) do
		-- Serialize a polygon
		if geom.type == EditorGeometry.Type.Polygon then
			local polygonData = {
				type = "Polygon",
				points = {},
				lines = {}
			}
			if geom.isWorldBoundary then
				polygonData.isWorldBoundary = true
			end
			for _, point in ipairs(geom.points) do
				table.insert(polygonData.points, {
					x = point.x,
					y = point.y
				})
				table.insert(polygonData.lines, {})
			end
			table.insert(geometryData, polygonData)
		-- Serialize a circle
		elseif geom.type == EditorGeometry.Type.Circle then
			local circleData = {
				type = "Circle",
				x = geom.x,
				y = geom.y,
				radius = geom.radius
			}
			table.insert(geometryData, circleData)
		end
	end
	return {
		spawn = { x = scene.spawn.x, y = scene.spawn.y },
		geometry = geometryData,
		objects = objectData
	}
end

function deserializeEditorLevelData(levelData)
	scene.spawn = { x = levelData.spawn.x, y = levelData.spawn.y }
	scene.geometry = {}
	scene.objects = {}
	for _, objectData in ipairs(levelData.objects) do
		table.insert(scene.objects, levelObjectByType[objectData.type].deserialize(objectData))
	end
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
			if geomData.isWorldBoundary then
				polygon.isWorldBoundary = true
				scene.worldBoundary = polygon
			end
			table.insert(scene.geometry, polygon)
		-- Deserialize a polygon
		elseif geomData.type == "Circle" then
			table.insert(scene.geometry, EditorCircle(geomData.x, geomData.y, geomData.radius))
		end
	end
end

function serializePlayableLevelData(levelData)
	local objectData = {}
	for _, obj in ipairs(scene.objects) do
		table.insert(objectData, obj:serialize())
	end
	for _, geom in ipairs(scene.geometry) do
		-- Serialize polygons as objects
		if geom.type == EditorGeometry.Type.Polygon then
			local isClockwise = geom:isClockwise()
			local physPoints = {}
			local physLinesAndArcs = {}
			local renderCoordinates = {}
			for _, point in ipairs(geom.points) do
				table.insert(physPoints, PhysPoint(point.x, point.y))
				if isClockwise ~= geom.isWorldBoundary then
					table.insert(physLinesAndArcs, PhysLine(point.outgoingLine.startPoint.x, point.outgoingLine.startPoint.y, point.outgoingLine.endPoint.x, point.outgoingLine.endPoint.y))
				else
					table.insert(physLinesAndArcs, PhysLine(point.outgoingLine.endPoint.x, point.outgoingLine.endPoint.y, point.outgoingLine.startPoint.x, point.outgoingLine.startPoint.y))
				end
				table.insert(renderCoordinates, point.x)
				table.insert(renderCoordinates, point.y)
			end
			if geom.isWorldBoundary then
				local worldBoundary = WorldBoundary(physPoints, physLinesAndArcs, renderCoordinates)
				table.insert(objectData, worldBoundary:serialize())
			else
				local polygon = Polygon(physPoints, physLinesAndArcs, renderCoordinates)
				table.insert(objectData, polygon:serialize())
			end
		-- Serialize circles as objects
		elseif geom.type == EditorGeometry.Type.Circle then
			local circle = Circle(geom.x, geom.y, geom.radius)
			table.insert(objectData, circle:serialize())
		end
	end
	return {
		spawn = { x = scene.spawn.x, y = scene.spawn.y },
		objects = objectData
	}
end
