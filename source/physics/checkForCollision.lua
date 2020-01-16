import "utility/math"
import "physics/Collision"

local function checkForCircleToCircleCollision(a, b)
	-- Check to see if the circles are overlapping
	local dx, dy = b.position.x - a.position.x, b.position.y - a.position.y
	local squareDist = dx * dx + dy * dy
	local minDist, maxDist = 0, a.radius + b.radius
	if minDist * minDist < squareDist and squareDist < maxDist * maxDist then
		-- They are overlapping!
		local dist = math.sqrt(squareDist)
		return Collision(a, b, a.radius + b.radius - dist, dx / dist, dy / dist) -- TODO pool
	end
end

local function checkForCircleToLineCollision(circle, line)
	-- Check if the circle is above/below the line
	local vectorFromStartPoint = playdate.geometry.vector2D.new(circle.position.x - line.position.x, circle.position.y - line.position.y) -- TODO pool
	local dot = vectorFromStartPoint:dotProduct(line.segmentNormalized)
	if 0 <= dot and dot <= line.length then
		-- The circle is either above or below the line!
		local pointOnLine = playdate.geometry.vector2D.new(line.position.x + line.segmentNormalized.x * dot, line.position.y + line.segmentNormalized.y * dot) -- TODO pool
		local vectorToCircle = playdate.geometry.vector2D.new(circle.position.x - pointOnLine.x, circle.position.y - pointOnLine.y) -- TODO pool
		local squareDist = vectorToCircle:magnitudeSquared()
		if squareDist < circle.radius * circle.radius then
			-- The circle is overlapping the line!
			local dot2 = vectorToCircle:dotProduct(line.normal)
			local dist = math.sqrt(squareDist)
			local penetration
			if dot2 < 0 then
				-- The circle is overlapping the line from below
				penetration = circle.radius + dist
			else
				-- The circle is overlapping the line from above
				penetration = circle.radius - dist
			end
			return Collision(circle, line, penetration, -line.normal.x, -line.normal.y) -- TODO pool
		end
	end
end

local function checkForCircleToArcCollision(circle, arc)
	-- Check to see if they are overlapping
	local dx, dy = circle.position.x - arc.position.x, circle.position.y - arc.position.y
	local squareDist = dx * dx + dy * dy
	-- TODO minDist changes based on whether the arc is inverted
	local minDist = (arc.radius > circle.radius) and (arc.radius - circle.radius) or 0
	local maxDist = circle.radius + arc.radius
	if minDist * minDist < squareDist and squareDist < maxDist * maxDist then
		-- They are overlapping! Figure out if it's on the solid part of the arc though
		local angle = atan2(dy, dx)
		local isOnArc
		if arc.startAngle > arc.endAngle then
			isOnArc = arc.startAngle <= angle or angle <= arc.endAngle
		else
			isOnArc = arc.startAngle <= angle and angle <= arc.endAngle
		end
		if isOnArc then
			local dist = math.sqrt(squareDist)
			local penetration = dist - (arc.radius - circle.radius)
			return Collision(circle, arc, penetration, dx / dist, dy / dist) -- TODO pool
		end
	end
end

function checkForCollision(a, b)
	-- To simplify logic, let's have our circle always be the first argument
	if a.type ~= PhysicsObject.Type.Circle and b.type == PhysicsObject.Type.Circle then
		local collision = checkForCollision(b, a)
		if collision then
			collision:swap()
		end
		return collision
	end
	-- Choose the right method for the physics objects
	if a.type == PhysicsObject.Type.Circle then
		if b.type == PhysicsObject.Type.Circle then
			return checkForCircleToCircleCollision(a, b)
		elseif b.type == PhysicsObject.Type.Line then
			return checkForCircleToLineCollision(a, b)
		elseif b.type == PhysicsObject.Type.Arc then
			return checkForCircleToArcCollision(a, b)
		end
	end
end
