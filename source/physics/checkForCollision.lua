import "physics/Collision"

local function checkForCircleToCircleCollision(a, b)
	-- Check to see if the circles are overlapping
	local dx, dy = b.position.x - a.position.x, b.position.y - a.position.y
	local squareDist = dx * dx + dy * dy
	if squareDist > 0 and squareDist < (a.radius + b.radius) ^ 2 then
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
		if squareDist <= circle.radius * circle.radius then
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
		end
	end
end
