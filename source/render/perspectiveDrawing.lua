import "CoreLibs/graphics"
import "render/camera"

perspectiveDrawing = {}

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
	playdate.graphics.drawCircle(x, y, r)
end

function perspectiveDrawing.fillCircle(x, y, r)
	x, y = camera.matrix:transformXY(x, y)
	playdate.graphics.fillCircleAtPoint(x, y, r)
end
