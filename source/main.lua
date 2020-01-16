import "physics/Circle"
import "physics/Line"
import "utility/math"
import "CoreLibs/utilities/printer"

playdate.graphics.setBackgroundColor(playdate.graphics.kColorWhite)

-- Keep track of marbles + pegs
local marbles = {}
local pegs = {}
local lines = {}

-- Define some methods to add new marbles and pegs
function addNewMarble(x, y)
	local marble = Circle(x or randomInt(20, 380), y or 20, 10)
	marble.restitution = 0.5
	marble.acceleration.y = 10000
	table.insert(marbles, marble)
	return marble
end
function addNewPeg(x, y)
	local peg = Circle(x or randomInt(0, 400), y or randomInt(90, 240), 10)
	peg.mass = 0
	table.insert(pegs, peg)
	return peg
end
function addNewLine(x1, y1, x2, y2)
	local line = Line(x1 or randomInt(0, 400), y1 or randomInt(90, 240), x2 or randomInt(0, 400), y2 or randomInt(90, 240))
	line.mass = 0
	table.insert(lines, line)
	return line
end

-- Add one marble and ten pegs to start
addNewMarble(200)
-- for i = 1, 3 do
-- 	addNewPeg(400 * i / 11)
-- end
addNewLine(0, 170, 400, 200)
for i = 1, 3 do
	-- addNewLine()
end

function playdate.update()
	-- Clear the screen
	playdate.graphics.clear()
	playdate.graphics.setColor(playdate.graphics.kColorBlack)

	-- Update the marbles
	for i = 1, #marbles do
		local marble = marbles[i]
		marble:update(1 / 20)
		-- Add some friction
		marble.velocity.x *= 0.96
		marble.velocity.y *= 0.96
		-- Wrap marbles around the screen
		if marble.position.x > 400 + marble.radius then
			marble.position.x = 0 - marble.radius
		elseif marble.position.x < 0 - marble.radius then
			marble.position.x = 400 + marble.radius
		end
		if marble.position.y > 240 + marble.radius then
			marble.position.y = 0 - marble.radius
		end
	end

	-- Check for collisions between marbles
	for i = 1, #marbles do
		for j = i + 1, #marbles do
			local collision = marbles[i]:checkForCollision(marbles[j])
			if collision then
				collision:handle()
			end
		end
	end

	-- Handle collisions between marbles and pegs
	for i = 1, #marbles do
		for j = 1, #pegs do
			local collision = marbles[i]:checkForCollision(pegs[j])
			if collision then
				collision:handle()
			end
		end
	end

	-- Handle collisions between marbles and lines
	for i = 1, #marbles do
		for j = 1, #lines do
			local collision = marbles[i]:checkForCollision(lines[j])
			if collision then
				collision:handle()
			end
		end
	end

	-- Draw the lines
	for i = 1, #lines do
		lines[i]:draw()
	end

	-- Draw the pegs
	for i = 1, #pegs do
		pegs[i]:draw()
	end

	-- Draw the marbles
	for i = 1, #marbles do
		marbles[i]:draw()
	end

	-- Draw some debug info
  playdate.drawFPS(10, 10)
  playdate.graphics.drawText(#marbles .. " marble" .. (#marbles == 1 and "" or "s"), 10, 30)
  playdate.graphics.drawText(#pegs .. " peg" .. (#pegs == 1 and "" or "s"), 10, 50)
end

-- Whenever A is pressed, add a new marble to the game
function playdate.AButtonDown()
	addNewMarble()
end

-- Whenever B is pressed, add a new peg to the game
function playdate.BButtonDown()
	-- addNewPeg()
	addNewLine()
end
