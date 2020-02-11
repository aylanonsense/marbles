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
import "physics/PhysArc"

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
				table.insert(polygonData.lines, {
					radius = point.outgoingLine.radius
				})
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
				local line = EditorLine(startPoint, endPoint)
				line.radius = lineData.radius or 0
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
				local line = point.outgoingLine
				if line.radius == 0 then
					if isClockwise ~= geom.isWorldBoundary then
						table.insert(physLinesAndArcs, PhysLine(line.startPoint.x, line.startPoint.y, line.endPoint.x, line.endPoint.y))
					else
						table.insert(physLinesAndArcs, PhysLine(line.endPoint.x, line.endPoint.y, line.startPoint.x, line.startPoint.y))
					end
					table.insert(renderCoordinates, point.x)
					table.insert(renderCoordinates, point.y)
				else
					local arcX, arcY, radius, startAngle, endAngle = line:getArcProps()
					local facingInwards = (line.radius > 0) == geom.isWorldBoundary
					if arcX and arcY then
						local arc = PhysArc(arcX, arcY, radius, startAngle, endAngle)
						if facingInwards == isClockwise then
							arc.facing = PhysArc.Facing.Inwards
						else
							arc.facing = PhysArc.Facing.Outwards
						end
						table.insert(physLinesAndArcs, arc)
						-- Generate render coordinates for the arc
						local circumference = 2 * math.pi * radius
						local degrees = endAngle - startAngle
						if degrees < 0 then
							degrees += 360
						end
						local arcLength = circumference * degrees / 360
						local numPoints = math.ceil(arcLength / 5)
						for i = 1, numPoints do
							local angle
							if line.radius > 0 then
								angle = startAngle + (i - 1) * degrees / numPoints
							else
								angle = startAngle + (numPoints - i + 1) * degrees / numPoints
							end
							if angle > 360 then
								angle -= 360
							end
							local actualAngle = (angle - 90) * math.pi / 180
							local c = math.cos(actualAngle)
							local s = math.sin(actualAngle)
							table.insert(renderCoordinates, arcX + radius * c)
							table.insert(renderCoordinates, arcY + radius * s)
						end
					else
						if isClockwise ~= geom.isWorldBoundary then
							table.insert(physLinesAndArcs, PhysLine(line.startPoint.x, line.startPoint.y, line.endPoint.x, line.endPoint.y))
						else
							table.insert(physLinesAndArcs, PhysLine(line.endPoint.x, line.endPoint.y, line.startPoint.x, line.startPoint.y))
						end
						table.insert(renderCoordinates, point.x)
						table.insert(renderCoordinates, point.y)
					end
				end
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
