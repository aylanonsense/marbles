-- The main camera for the game
camera = {
	screenWidth = 400,
	screenHeight = 240,
	position = playdate.geometry.vector2D.new(0, 0),
	rotation = 0,
	matrix = playdate.geometry.affineTransform.new(),
	up = playdate.geometry.vector2D.new(0, -1)
}

-- Recalculates the matrix necessary for objects to quickly do perspective calculations
function camera:recalculatePerspective()
	-- Calculate the up vector
	self.matrix:reset()
	self.matrix:rotate(self.rotation)
	self.up.x, self.up.y = self.matrix:transformXY(0, -1)
	-- And now actually calculate the perspective matrix
	self.matrix:reset()
	self.matrix:translate(-self.position.x, -self.position.y)
	self.matrix:rotate(-self.rotation)
	self.matrix:translate(self.screenWidth / 2, self.screenHeight / 2)
end

-- Let's just update the camera once at the very start
camera:recalculatePerspective()
