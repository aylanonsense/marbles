-- Like math.random, but exclusive on the upper end
function randomEx(lower, upper)
	return math.min(math.random(lower, upper), (upper or lower or 1) - 0.0001)
end

-- Inclusive on both ends
function randomInt(lower, upper)
	if not lower and not upper then
		lower, upper = 0, 1
	elseif not upper then
		lower, upper = 0, lower
	end
	return math.floor(randomEx(lower, upper + 1))
end
