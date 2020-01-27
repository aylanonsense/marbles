function drawDottedLine(x1, y1, x2, y2, distanceBetweenDots)
	local dx, dy = x2 - x1, y2 - y1
	local dist = math.sqrt(dx * dx + dy * dy)
	for d = 0, dist, distanceBetweenDots do
		playdate.graphics.drawPixel(x1 + d * dx / dist, y1 + d * dy / dist)
	end
end
