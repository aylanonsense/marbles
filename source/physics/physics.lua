import "scene/time"
import "utility/table"

local MAX_MOVEMENT_PER_FRAME = 8.9

-- This object represents the physics engine
physics = {
	SECTOR_SIZE = 50,
	SECTOR_OVERLAP = 20,
	balls = {},
	staticObjects = {},
	staticObjectsBySector = {},
	onCollideCallback = nil
}

function physics:reset()
	self.balls = {}
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

	-- Accelerate all dynamic physics objects
	for _, ball in ipairs(self.balls) do
		if ball.isEnabled then
			ball:applyAcceleration(time.dt)
		end
	end

	-- Calculate the number of physics steps we need to perform
	local numSteps = math.max(1, math.ceil((maxBallSpeed * time.dt) / MAX_MOVEMENT_PER_FRAME))
	local dt = time.dt / numSteps
	for step = 1, numSteps do
		-- Move all balls
		for _, ball in ipairs(self.balls) do
			if ball.isEnabled then
				ball:enforceMaxSpeed()
				ball:applyVelocity(dt)
			end
		end

		-- Check for collisions between balls and objects
		for _, ball in ipairs(self.balls) do
			if ball.isEnabled then
				local sectorX = math.floor((ball.x - self.SECTOR_OVERLAP / 2) / self.SECTOR_SIZE)
				local sectorY = math.floor((ball.y - self.SECTOR_OVERLAP / 2) / self.SECTOR_SIZE)
				if self.staticObjectsBySector[sectorX] and self.staticObjectsBySector[sectorX][sectorY] then
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
