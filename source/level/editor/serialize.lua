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
				lines = {},
				isSolid = geom.isSolid,
				isVisible = geom.isVisible
			}
			if geom.fillPattern ~= 'Grey' then
				polygonData.fillPattern = geom.fillPattern
			end
			if geom.isWorldBoundary then
				polygonData.isWorldBoundary = true
			end
			if geom.layer ~= 0 then
				polygonData.layer = geom.layer
			end
			for _, point in ipairs(geom.points) do
				table.insert(polygonData.points, {
					x = point.x,
					y = point.y,
					isSolid = point.isSolid
				})
				table.insert(polygonData.lines, {
					radius = point.outgoingLine.radius,
					isSolid = point.outgoingLine.isSolid,
					isVisible = point.outgoingLine.isVisible
				})
			end
			table.insert(geometryData, polygonData)
		-- Serialize a circle
		elseif geom.type == EditorGeometry.Type.Circle then
			local circleData = {
				type = "Circle",
				x = geom.x,
				y = geom.y,
				radius = geom.radius,
				isSolid = geom.isSolid,
				isVisible = geom.isVisible
			}
			if geom.fillPattern ~= 'Grey' then
				circleData.fillPattern = geom.fillPattern
			end
			if geom.layer ~= 0 then
				circleData.layer = geom.layer
			end
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
				local point = EditorPoint(pointData.x, pointData.y)
				if pointData.isSolid == false then
					point.isSolid = false
				end
				table.insert(points, point)
			end
			for i, lineData in ipairs(geomData.lines) do
				local startPoint = points[i]
				local endPoint = points[(i == #points) and 1 or (i + 1)]
				local line = EditorLine(startPoint, endPoint)
				if lineData.isSolid == false then
					line.isSolid = false
				end
				if lineData.isVisible == false then
					line.isVisible = false
				end
				line.radius = lineData.radius or 0
			end
			local polygon = EditorPolygon(points)
			if geomData.isSolid == false then
				polygon.isSolid = false
			end
			if geomData.isVisible == false then
				polygon.isVisible = false
			end
			if geomData.fillPattern then
				polygon.fillPattern = geomData.fillPattern
			end
			if geomData.layer then
				polygon.layer = geomData.layer
			end
			if geomData.isWorldBoundary then
				polygon.isWorldBoundary = true
				scene.worldBoundary = polygon
			end
			table.insert(scene.geometry, polygon)
		-- Deserialize a polygon
		elseif geomData.type == "Circle" then
			local circle = EditorCircle(geomData.x, geomData.y, geomData.radius)
			if geomData.isSolid == false then
				circle.isSolid = false
			end
			if geomData.isVisible == false then
				circle.isVisible = false
			end
			if geomData.fillPattern then
				circle.fillPattern = geomData.fillPattern
			end
			if geomData.layer then
				circle.layer = geomData.layer
			end
			table.insert(scene.geometry, circle)
		end
	end
	scene:sortGeometryAndObjects()
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
			local fillCoordinates
			local lineCoordinates
			local useFillCoordinatesForLines = true
			for _, point in ipairs(geom.points) do
				local line = point.outgoingLine
				if not line.isVisible then
					useFillCoordinatesForLines = false
				end
			end
			if geom.isVisible then
				fillCoordinates = {}
			end
			if not useFillCoordinatesForLines then
				lineCoordinates = {}
			end
			for _, point in ipairs(geom.points) do
				if point.isSolid then
					table.insert(physPoints, PhysPoint(point.x, point.y))
				end
				local line = point.outgoingLine
				if line.radius == 0 then
					if line.isSolid then
						if isClockwise ~= geom.isWorldBoundary then
							table.insert(physLinesAndArcs, PhysLine(line.startPoint.x, line.startPoint.y, line.endPoint.x, line.endPoint.y))
						else
							table.insert(physLinesAndArcs, PhysLine(line.endPoint.x, line.endPoint.y, line.startPoint.x, line.startPoint.y))
						end
					end
					if geom.isVisible then
						table.insert(fillCoordinates, point.x)
						table.insert(fillCoordinates, point.y)
					end
					if not useFillCoordinatesForLines and line.isVisible then
						table.insert(lineCoordinates, line.startPoint.x)
						table.insert(lineCoordinates, line.startPoint.y)
						table.insert(lineCoordinates, line.endPoint.x)
						table.insert(lineCoordinates, line.endPoint.y)
					end
				else
					local arcX, arcY, radius, startAngle, endAngle = line:getArcProps()
					local facingInwards = (line.radius > 0) == geom.isWorldBoundary
					if arcX and arcY then
						if line.isSolid then
							local arc = PhysArc(arcX, arcY, radius, startAngle, endAngle)
							if facingInwards == isClockwise then
								arc.facing = PhysArc.Facing.Inwards
							else
								arc.facing = PhysArc.Facing.Outwards
							end
							table.insert(physLinesAndArcs, arc)
						end
						-- Generate render coordinates for the arc
						local circumference = 2 * math.pi * radius
						local degrees = endAngle - startAngle
						if degrees < 0 then
							degrees += 360
						end
						local arcLength = circumference * degrees / 360
						local numPoints = math.ceil(arcLength / 18)
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
							if geom.isVisible then
								table.insert(fillCoordinates, arcX + radius * c)
								table.insert(fillCoordinates, arcY + radius * s)
							end
							if not useFillCoordinatesForLines and line.isVisible then
									table.insert(lineCoordinates, arcX + radius * c)
									table.insert(lineCoordinates, arcY + radius * s)
									local nextAngle
									if line.radius > 0 then
										nextAngle = startAngle + (i) * degrees / numPoints
									else
										nextAngle = startAngle + (numPoints - i) * degrees / numPoints
									end
									if nextAngle > 360 then
										nextAngle -= 360
									end
									local actualNextAngle = (nextAngle - 90) * math.pi / 180
									local c2 = math.cos(actualNextAngle)
									local s2 = math.sin(actualNextAngle)
									table.insert(lineCoordinates, arcX + radius * c2)
									table.insert(lineCoordinates, arcY + radius * s2)
							end
						end
					else
						if line.isSolid then
							if isClockwise ~= geom.isWorldBoundary then
								table.insert(physLinesAndArcs, PhysLine(line.startPoint.x, line.startPoint.y, line.endPoint.x, line.endPoint.y))
							else
								table.insert(physLinesAndArcs, PhysLine(line.endPoint.x, line.endPoint.y, line.startPoint.x, line.startPoint.y))
							end
						end
						if geom.isVisible then
							table.insert(fillCoordinates, point.x)
							table.insert(fillCoordinates, point.y)
						end
						if not useFillCoordinatesForLines and line.isVisible then
							table.insert(lineCoordinates, line.startPoint.x)
							table.insert(lineCoordinates, line.startPoint.y)
							table.insert(lineCoordinates, line.endPoint.x)
							table.insert(lineCoordinates, line.endPoint.y)
						end
					end
				end
			end
			if geom.isWorldBoundary then
				local worldBoundary = WorldBoundary(physPoints, physLinesAndArcs, fillCoordinates, lineCoordinates)
				if geom.fillpattern ~= 'Grey' then
					worldBoundary.fillPattern = geom.fillPattern
				end
				table.insert(objectData, worldBoundary:serialize())
			else
				local polygon = Polygon(physPoints, physLinesAndArcs, fillCoordinates, lineCoordinates)
				polygon.layer = geom.layer
				if geom.fillpattern ~= 'Grey' then
					polygon.fillPattern = geom.fillPattern
				end
				table.insert(objectData, polygon:serialize())
			end
		-- Serialize circles as objects
		elseif geom.type == EditorGeometry.Type.Circle then
			local circle = Circle(geom.x, geom.y, geom.radius)
			circle.layer = geom.layer
			if not geom.isVisible then
				circle.isVisible = false
			end
			if not geom.isSolid then
				circle.physCircle.isEnabled = false
			end
			if geom.fillpattern ~= 'Grey' then
				circle.fillPattern = geom.fillPattern
			end
			table.insert(objectData, circle:serialize())
		end
	end
	table.sort(objectData, function(a, b)
    return (a.layer or 0) < (b.layer or 0)
  end)
	return {
		spawn = { x = scene.spawn.x, y = scene.spawn.y },
		objects = objectData
	}
end
