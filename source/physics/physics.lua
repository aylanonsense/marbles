-- This object represents the physics engine
physics = {
	balls = {},
	objects = {}
}

function physics:reset()
	self.balls = {}
	self.objects = {}
end

function physics:update()
	-- Update all physics objects
	for i = 1, #self.objects do
		if self.objects[i].isEnabled then
			self.objects[i]:update()
		end
	end

	-- Check for collisions between balls and objects
	for i = 1, #self.balls do
		local ball = self.balls[i]
		for j = 1, #self.objects do
			local obj = self.objects[j]
			if ball ~= obj and ball.isEnabled and obj.isEnabled then
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
