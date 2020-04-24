time = {
	dt = 1 / 20,
	timescale = 1.00,
	targetTimescale = 1.00
}

function time:advance(dt)
	if self.timescale < self.targetTimescale then
		self.timescale = math.min(self.timescale + 0.75 * dt, self.targetTimescale)
	end
	if self.timescale > self.targetTimescale then
		self.timescale = math.min(self.timescale - 1.5 * dt, self.targetTimescale)
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
