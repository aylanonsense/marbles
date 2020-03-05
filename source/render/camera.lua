-- The main camera for the game
camera = {
	screenWidth = 400,
	screenHeight = 240,
	x = 0,
	y = 0,
	rotation = 0,
	scale = 1,
	matrix = playdate.geometry.affineTransform.new(),
	up = { x = 0, y = -1 },
	right = { x = 1, y = 0 }
}

function camera:reset()
	self.x, self.y = 0, 0
	self.rotation = 0
	self.scale = 1
	self:recalculatePerspective()
end

-- Recalculates the matrix necessary for objects to quickly do perspective calculations
function camera:recalculatePerspective()
	-- Calculate the up vector
	self.matrix:reset()
	self.matrix:rotate(self.rotation)
	self.up.x, self.up.y = self.matrix:transformXY(0, -1)
	self.right.x, self.right.y = -self.up.y, self.up.x
	-- And now actually calculate the perspective matrix
	self.matrix:reset()
	self.matrix:translate(-self.x, -self.y)
	self.matrix:rotate(-self.rotation)
	self.matrix:scale(self.scale)
	self.matrix:translate(self.screenWidth / 2, self.screenHeight / 2)
end

-- Let's just update the camera once at the very start
camera:recalculatePerspective()
