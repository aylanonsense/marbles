-- This object represents the physics engine
physics = {
	balls = {},
	objects = {}
}

function physics:update(dt)
	-- Update all physics objects
	for i = 1, #self.objects do
		self.objects[i]:update(dt)
	end

	-- Check for collisions between balls and objects
	for i = 1, #self.balls do
		local ball = self.balls[i]
		for j = 1, #self.objects do
			local obj = self.objects[j]
			if ball ~= obj then
				local collision = obj:checkForCollisionWithBall(ball)
				if collision then
					-- There was a collision! Just handle is straight-away
					collision:handle()
					collision:discard()
				end
			end
		end
	end
end

function physics:draw()
	-- Just draw all the physics objects
	for i = 1, #self.objects do
		self.objects[i]:draw()
	end
end
