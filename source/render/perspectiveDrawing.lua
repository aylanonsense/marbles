import "CoreLibs/graphics"
import "render/camera"

perspectiveDrawing = {}

function perspectiveDrawing.drawPixel(x, y)
	x, y = camera.matrix:transformXY(x, y)
	playdate.graphics.drawPixel(x, y)
end

function perspectiveDrawing.drawLine(x1, y1, x2, y2)
	x1, y1 = camera.matrix:transformXY(x1, y1)
	x2, y2 = camera.matrix:transformXY(x2, y2)
	playdate.graphics.drawLine(x1, y1, x2, y2)
end

function perspectiveDrawing.drawDottedLine(x1, y1, x2, y2, distanceBetweenDots)
	x1, y1 = camera.matrix:transformXY(x1, y1)
	x2, y2 = camera.matrix:transformXY(x2, y2)
	local dx, dy = x2 - x1, y2 - y1
	local dist = math.sqrt(dx * dx + dy * dy)
	for d = 0, dist, (distanceBetweenDots or 3) do
		playdate.graphics.drawPixel(x1 + d * dx / dist, y1 + d * dy / dist)
	end
end

function perspectiveDrawing.drawCircle(x, y, r)
	x, y = camera.matrix:transformXY(x, y)
	playdate.graphics.drawCircleAtPoint(x, y, r * camera.scale)
end

function perspectiveDrawing.drawDottedCircle(x, y, r, distanceBetweenDots)
	x, y = camera.matrix:transformXY(x, y)
	local circumference = 2 * math.pi * r
	local numDots = math.ceil(circumference / distanceBetweenDots)
	for i = 1, numDots do
		local x2, y2 = x + r * camera.scale * math.cos(2 * math.pi * i / numDots), y + r * camera.scale * math.sin(2 * math.pi * i / numDots)
		playdate.graphics.drawPixel(x2, y2)
	end
end

function perspectiveDrawing.fillCircle(x, y, r)
	x, y = camera.matrix:transformXY(x, y)
	playdate.graphics.fillCircleAtPoint(x, y, r * camera.scale)
end
