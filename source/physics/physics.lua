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
	-- Update all physics objects
	for i = 1, #self.objects do
		if self.objects[i].isEnabled then
			self.objects[i]:update()
		end
	end

	-- Check for collisions between balls and objects
	for _, ball in ipairs(self.balls) do
		for _, obj in ipairs(self.objects) do
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
