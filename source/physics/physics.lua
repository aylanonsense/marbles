import "scene/time"

local MAX_MOVEMENT_PER_FRAME = 8.9

-- This object represents the physics engine
physics = {
	balls = {},
	objects = {},
	onCollideCallback = nil
}

function physics:reset()
	self.balls = {}
	self.objects = {}
	self.onCollideCallback = nil
end

function physics:update()
	-- Figure out the max ball speed
	local maxBallSpeedSquared = 0
	for _, ball in ipairs(self.balls) do
		local speedSquared = ball.velocity.x * ball.velocity.x + ball.velocity.y * ball.velocity.y
		maxBallSpeedSquared = math.max(maxBallSpeedSquared, speedSquared)
	end
	local maxBallSpeed = math.sqrt(maxBallSpeedSquared)

	-- Accelerate all physics objects
	for _, obj in ipairs(self.objects) do
		if obj.isEnabled then
			obj:applyAcceleration(time.dt)
		end
	end

	-- Calculate the number of physics steps we need to perform
	local numSteps = math.max(1, math.ceil(maxBallSpeed / MAX_MOVEMENT_PER_FRAME))
	local dt = time.dt / numSteps
	for step = 1, numSteps do
		-- Move all physics objects
		for _, obj in ipairs(self.objects) do
			if obj.isEnabled then
				obj:enforceMaxSpeed()
				obj:applyVelocity(dt)
			end
		end

		-- Check for collisions between balls and objects
		for _, ball in ipairs(self.balls) do
			for _, obj in ipairs(self.objects) do
				-- Do a pass for points second, since other physics objects should take priority
				if ball ~= obj and ball.isEnabled and obj.isEnabled then
					local collision = obj:checkForCollisionWithBall(ball)
					if collision then
						-- There was a collision!
						if physics.onCollideCallback then
							physics.onCollideCallback(collision)
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

function physics:draw()
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.setLineWidth(1)
	playdate.graphics.setLineCapStyle(playdate.graphics.kLineCapStyleRound)
	-- Just draw all the physics objects
	for i = 1, #self.objects do
		if self.objects[i].isEnabled then
			self.objects[i]:draw()
		end
	end
end

function physics:onCollide(callback)
	self.onCollideCallback = callback
end
