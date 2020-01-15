import "physics/Circle"
import "utility/math"

-- Set the background to white
playdate.graphics.setBackgroundColor(playdate.graphics.kColorWhite)

-- Create a marble
local marble = Circle(170, 90, 15)
marble.velocity.y = 60

-- Create some pegs for the marble to bounce off of
local pegs = {}
table.insert(pegs, Circle(160, 190, 30))

function playdate.update()
	-- Update the marble
	marble:update(1 / 20)

	-- Clear the screen
	playdate.graphics.clear()
	playdate.graphics.setColor(playdate.graphics.kColorBlack)

	-- Draw the pegs
	for i = 1, #pegs do
		pegs[i]:draw()
	end

	-- Draw the marble
	marble:draw()
end
