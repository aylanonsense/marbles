import "level/object/LevelObject"
import "render/camera"
import "render/patterns"
import "physics/physObjectByType"
import "scene/time"
import "utility/diagnosticStats"

class("Polygon").extends("LevelObject")

function Polygon:init(physPoints, physLinesAndArcs, fillCoordinates, lineCoordinates, moveX, moveY)
	Polygon.super.init(self, LevelObject.Type.Polygon)
	self.minX = 9999
	self.maxX = -9999
	self.minY = 9999
	self.maxY = -9999
	self.physPoints = physPoints
	for _, point in ipairs(self.physPoints) do
		self:addPhysicsObject(point)
	end
	self.physLinesAndArcs = physLinesAndArcs
	for _, lineOrArc in ipairs(self.physLinesAndArcs) do
		self:addPhysicsObject(lineOrArc)
	end
	self.fillCoordinates = fillCoordinates
	if self.fillCoordinates then
		for i = 1, #self.fillCoordinates, 2 do
			self.minX = math.min(self.minX, self.fillCoordinates[i])
			self.maxX = math.max(self.maxX, self.fillCoordinates[i])
			self.minY = math.min(self.minY, self.fillCoordinates[i + 1])
			self.maxY = math.max(self.maxY, self.fillCoordinates[i + 1])
		end
	end
	self.lineCoordinates = lineCoordinates
	if self.lineCoordinates then
		for i = 1, #self.lineCoordinates, 2 do
			self.minX = math.min(self.minX, self.lineCoordinates[i])
			self.maxX = math.max(self.maxX, self.lineCoordinates[i])
			self.minY = math.min(self.minY, self.lineCoordinates[i + 1])
			self.maxY = math.max(self.maxY, self.lineCoordinates[i + 1])
		end
	end
	self.perspectiveFillCoordinates = {}
	self.fillPattern = 'Grey'
	self.moveX = moveX or 0
	self.moveY = moveY or 0
	if self.moveX ~= 0 or self.moveY ~= 0 then
		local dist = math.sqrt(self.moveX * self.moveX + self.moveY * self.moveY)
		self.moveState = 'still'
		self.moveTimer = 0
		self.moveVelX = 50 * self.moveX / dist
		self.moveVelY = 50 * self.moveY / dist
		self.moveDuration = dist / 50
	end
	self.prevX, self.prevY = self:getPosition()
	fillCoordinates, lineCoordinates
end

function Polygon:update()
	if self.moveX ~= 0 or self.moveY ~= 0 then
		-- Change platform movement
		self.moveTimer = self.moveTimer + time.dt
		if self.moveState == 'still' and self.moveTimer >= 1.5 then
			self.moveState = 'moving'
			self.moveTimer = 0
			self:setVelocity(self.moveVelX, self.moveVelY)
		elseif self.moveState == 'moving' and self.moveTimer >= self.moveDuration then
			self.moveState = 'still-reverse'
			self.moveTimer = 0
			self:setVelocity(0, 0)
		elseif self.moveState == 'still-reverse' and self.moveTimer >= 1.5 then
			self.moveState = 'moving-reverse'
			self.moveTimer = 0
			self:setVelocity(-self.moveVelX, -self.moveVelY)
		elseif self.moveState == 'moving-reverse' and self.moveTimer >= self.moveDuration then
			self.moveState = 'still'
			self.moveTimer = 0
			self:setVelocity(0, 0)
		end
		-- Update graphics
		local x, y = self:getPosition()
		local dx, dy = (x - self.prevX), (y - self.prevY)
		if self.fillCoordinates then
			for i = 1, #self.fillCoordinates, 2 do
				self.fillCoordinates[i] += dx
				self.fillCoordinates[i + 1] += dy
			end
		end
		if self.lineCoordinates then
			for i = 1, #self.lineCoordinates, 2 do
				self.lineCoordinates[i] += dx
				self.lineCoordinates[i + 1] += dy
			end
		end
		self.prevX, self.prevY = x, y
	end
end

function Polygon:draw()
	local minX = 99999
	local maxX = -99999
	local minY = 99999
	local maxY = -99999
	if self.fillCoordinates and #self.fillCoordinates > 0 then
		for i = 1, #self.fillCoordinates, 2 do
			local x, y = camera.matrix:transformXY(self.fillCoordinates[i], self.fillCoordinates[i + 1])
			self.perspectiveFillCoordinates[i] = x
			self.perspectiveFillCoordinates[i + 1] = y
			minX = math.min(minX, x)
			maxX = math.max(maxX, x)
			minY = math.min(minY, y)
			maxY = math.max(maxY, y)
		end
		if self.fillPattern ~= 'Transparent' and minX < 420 and maxX > -20 and minY < 260 and maxY > -20 then
			-- Fill in the polygon
			playdate.graphics.setPattern(patterns[self.fillPattern])
			playdate.graphics.fillPolygon(table.unpack(self.perspectiveFillCoordinates))
			diagnosticStats.polygonPointsDrawn += #self.perspectiveFillCoordinates / 2
		end
	end

	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.setLineWidth(1)
	playdate.graphics.setLineCapStyle(playdate.graphics.kLineCapStyleRound)
	if self.lineCoordinates then
		-- Draw the outline as a series of lines
		for i = 1, #self.lineCoordinates, 4 do
			local x1, y1 = camera.matrix:transformXY(self.lineCoordinates[i], self.lineCoordinates[i + 1])
			local x2, y2 = camera.matrix:transformXY(self.lineCoordinates[i + 2], self.lineCoordinates[i + 3])
			if math.min(x1, x2) < 410 and math.max(x1, x2) > -10 and math.min(y1, y2) < 250 and math.max(y1, y2) > -10 then
				playdate.graphics.drawLine(x1, y1, x2, y2)
				diagnosticStats.polygonPointsDrawn += 2
			end
		end
	elseif self.fillCoordinates and #self.fillCoordinates > 0 and minX < 420 and maxX > -20 and minY < 260 and maxY > -20 then
		-- Draw the outline as a polygon
		playdate.graphics.drawPolygon(table.unpack(self.perspectiveFillCoordinates))
		diagnosticStats.polygonPointsDrawn += #self.perspectiveFillCoordinates / 2
	end
end

function Polygon:isOnScreen()
  return camera.x + 220 > self.minX and camera.x - 220 < self.maxX and camera.y + 220 > self.minY and camera.y - 220 < self.maxY
end

function Polygon:setPosition(x, y)
	local dx, dy = Polygon.super.setPosition(self, x, y)
	if self.fillCoordinates then
		for i = 1, #self.fillCoordinates, 2 do
			self.fillCoordinates[i] += dx
			self.fillCoordinates[i + 1] += dy
		end
	end
	if self.lineCoordinates then
		for i = 1, #self.lineCoordinates, 2 do
			self.lineCoordinates[i] += dx
			self.lineCoordinates[i + 1] += dy
		end
	end
end

function Polygon:serialize()
	local data = {
		type = self.type,
		points = {},
		linesAndArcs = {},
		fillCoordinates = self.fillCoordinates,
		lineCoordinates = self.lineCoordinates
	}
	if self.moveX ~= 0 then
		data.moveX = self.moveX
	end
	if self.moveY ~= 0 then
		data.moveY = self.moveY
	end
	if self.layer ~= 0 then
		data.layer = self.layer
	end
	for _, point in ipairs(self.physPoints) do
		table.insert(data.points, point:serialize())
	end
	for _, physObj in ipairs(self.physLinesAndArcs) do
		table.insert(data.linesAndArcs, physObj:serialize())
	end
	if self.fillPattern ~= 'Grey' then
		data.fillPattern = self.fillPattern
	end
	return data
end

function Polygon.deserialize(data)
	local physPoints = {}
	local physLinesAndArcs = {}
	local fillCoordinates = data.fillCoordinates
	local lineCoordinates = data.lineCoordinates
	local moveX = data.moveX or 0
	local moveY = data.moveY or 0
	local isStatic = (moveX == 0) and (moveY == 0)
	for _, physData in ipairs(data.points) do
		local point = physObjectByType[physData.type].deserialize(physData)
		point.isStatic = isStatic
		table.insert(physPoints, point)
	end
	for _, physData in ipairs(data.linesAndArcs) do
		local lineOrArc = physObjectByType[physData.type].deserialize(physData)
		lineOrArc.isStatic = isStatic
		table.insert(physLinesAndArcs, lineOrArc)
	end
	local polygon = Polygon(physPoints, physLinesAndArcs, fillCoordinates, lineCoordinates, moveX, moveY)
	if data.fillPattern then
		polygon.fillPattern = data.fillPattern
	end
	if data.layer then
		polygon.layer = data.layer
	end
	return polygon
end
