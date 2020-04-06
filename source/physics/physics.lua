import "scene/time"
import "utility/table"

local MAX_MOVEMENT_PER_FRAME = 8.9

-- This object represents the physics engine
physics = {
	SECTOR_SIZE = 50,
	SECTOR_OVERLAP = 20,
	GRAVITY = 10000,
	balls = {},
	dynamicObjects = {},
	staticObjects = {},
	staticObjectsBySector = {},
	onCollideCallback = nil
}

function physics:reset()
	self.balls = {}
	self.dynamicObjects = {}
	self.staticObjects = {}
	self.staticObjectsBySector = {}
	self.onCollideCallback = nil
end

function physics:update()
	-- Figure out the max ball speed
	local maxBallSpeedSquared = 0
	for _, ball in ipairs(self.balls) do
		local speedSquared = ball.velX * ball.velX + ball.velY * ball.velY
		maxBallSpeedSquared = math.max(maxBallSpeedSquared, speedSquared)
	end
	local maxBallSpeed = math.sqrt(maxBallSpeedSquared)
	local maxSpeed = maxBallSpeed + (#self.dynamicObjects > 0 and 50 or 0)

	-- Accelerate all dynamic physics objects and balls
	for _, obj in ipairs(self.dynamicObjects) do
		if obj.isEnabled then
			obj:applyAcceleration(time.dt)
		end
	end
	for _, ball in ipairs(self.balls) do
		if ball.isEnabled then
			ball:applyAcceleration(time.dt)
		end
	end

	-- Calculate the number of physics steps we need to perform
	local numSteps = math.max(1, math.ceil((maxSpeed * time.dt) / MAX_MOVEMENT_PER_FRAME))
	local dt = time.dt / numSteps
	for step = 1, numSteps do
		-- Move all dynamic physics objects and balls
		for _, obj in ipairs(self.dynamicObjects) do
			if obj.isEnabled then
				obj:applyVelocity(dt)
			end
		end
		for _, ball in ipairs(self.balls) do
			if ball.isEnabled then
				ball:enforceMaxSpeed()
				ball:applyVelocity(dt)
			end
		end

		-- Check for collisions between balls and objects
		for _, ball in ipairs(self.balls) do
			if ball.isEnabled then
				-- Check against dynamic objects
				for _, obj in ipairs(self.dynamicObjects) do
					if obj.isEnabled then
						local collision = obj:checkForCollisionWithBall(ball)
						if collision then
							-- There was a collision!
							if self.onCollideCallback then
								self.onCollideCallback(collision)
							else
								collision:handle()
							end
							collision:discard()
						end
					end
				end
				-- Check against static objects
				local minSectorX, maxSectorX, minSectorY, maxSectorY
				if ball.radius < 10 then
					minSectorX = math.floor((ball.x - self.SECTOR_OVERLAP / 2) / self.SECTOR_SIZE)
					maxSectorX = minSectorX
					minSectorY = math.floor((ball.y - self.SECTOR_OVERLAP / 2) / self.SECTOR_SIZE)
					maxSectorY = minSectorY
				else
					minSectorX = math.floor((ball.x - ball.radius) / self.SECTOR_SIZE)
					maxSectorX = math.floor((ball.x + ball.radius) / self.SECTOR_SIZE)
					minSectorY = math.floor((ball.y - ball.radius) / self.SECTOR_SIZE)
					maxSectorY = math.floor((ball.y + ball.radius) / self.SECTOR_SIZE)
				end
				-- local sectorX = math.floor((ball.x - self.SECTOR_OVERLAP / 2) / self.SECTOR_SIZE)
				-- local sectorY = math.floor((ball.y - self.SECTOR_OVERLAP / 2) / self.SECTOR_SIZE)
				for sectorX = minSectorX, maxSectorX do
					if self.staticObjectsBySector[sectorX] then
						for sectorY = minSectorY, maxSectorY do
							if self.staticObjectsBySector[sectorX][sectorY] then
								for _, obj in ipairs(self.staticObjectsBySector[sectorX][sectorY]) do
									if obj.isEnabled then
										local collision = obj:checkForCollisionWithBall(ball)
										if collision then
											-- There was a collision!
											if self.onCollideCallback then
												self.onCollideCallback(collision)
											else
												collision:handle()
											end
											collision:discard()
										end
									end
								end
							end
						end
					end
				end
			end
		end

		-- Check for collisions between balls
		for i = 1, #self.balls do
			local ball1 = self.balls[i]
			if ball1.isEnabled then
				for j = i + 1, #self.balls do
					local ball2 = self.balls[j]
					if ball2.isEnabled then
						local collision = ball1:checkForCollisionWithBall(ball2)
						if collision then
							-- There was a collision!
							if self.onCollideCallback then
								self.onCollideCallback(collision)
							else
								collision:handle()
							end
							collision:discard()
						end
					end
				end
			end
		end
	end
end

function physics:draw()
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.setLineWidth(1)
	playdate.graphics.setLineCapStyle(playdate.graphics.kLineCapStyleRound)
	-- Just draw all the physics objects
	for i = 1, #self.staticObjects do
		if self.staticObjects[i].isEnabled then
			self.staticObjects[i]:draw()
		end
	end
end

local function sortSector(a, b)
	-- Sort sectors in this order:
	-- 1. non-points
	-- 2. low priority non-points
	-- 3. points
	-- 4. low priority points
	local priorityA = (a.lowPriority and 0 or 50) + ((a.type == "PhysPoint") and 0 or 100)
	local priorityB = (b.lowPriority and 0 or 50) + ((b.type == "PhysPoint") and 0 or 100)
	return priorityA > priorityB
end

function physics:sortSectors()
	for _, sectorX in pairs(self.staticObjectsBySector) do
		for _, sectorXY in pairs(sectorX) do
			table.sort(sectorXY, sortSector)
		end
	end
end

function physics:onCollide(callback)
	self.onCollideCallback = callback
end

function physics:addBall(ball)
	table.insert(self.balls, ball)
end

function physics:removeBall(ball)
	removeItem(self.balls, ball)
end

function physics:addDynamicObject(obj)
	table.insert(self.dynamicObjects, obj)
end

function physics:removeDynamicObject(obj)
	removeItem(self.dynamicObjects, obj)
end

function physics:addStaticObject(obj)
	table.insert(self.staticObjects, obj)
	if obj.sectors then
		for i = 1, #obj.sectors, 2 do
			local x = obj.sectors[i]
			local y = obj.sectors[i + 1]
			if not self.staticObjectsBySector[x] then
				self.staticObjectsBySector[x] = {}
			end
			if not self.staticObjectsBySector[x][y] then
				self.staticObjectsBySector[x][y] = {}
			end
			table.insert(self.staticObjectsBySector[x][y], obj)
		end
	end
end

function physics:removeStaticObject(obj)
	removeItem(self.staticObjects, obj)
	if obj.sectors then
		for i = 1, #obj.sectors, 2 do
			local x = obj.sectors[i]
			local y = obj.sectors[i + 1]
			if self.staticObjectsBySector[x] and self.staticObjectsBySector[x][y] then
				removeItem(self.staticObjectsBySector[x][y], obj)
			end
		end
	end
end
