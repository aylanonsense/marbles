time = {
	dt = 0.05,
	timescale = 1.00,
	targetTimescale = 1.00,
	playtime = {
		paused = false,
		seconds = 0.0,
		minutes = 0,
		hours = 0
	}
}

function time:advance(dt)
	if not self.playtime.paused then
		self.playtime.seconds += dt
		if self.playtime.seconds >= 60.0 then
			self.playtime.seconds -= 60.0
			self.playtime.minutes += 1
		end
		if self.playtime.minutes >= 60 then
			self.playtime.minutes -= 60
			self.playtime.hours += 1
		end
	end
	if self.timescale < self.targetTimescale then
		self.timescale = math.min(self.timescale + 0.5 * dt, self.targetTimescale)
	end
	if self.timescale > self.targetTimescale then
		self.timescale = math.max(self.timescale - 1.5 * dt, self.targetTimescale)
	end
	self.dt = dt * self.timescale
end

function time:setTimescale(scale)
	self.timescale = scale
	self.targetTimescale = scale
end

function time:transitionTimeScale(scale)
	self.targetTimescale = scale
end
