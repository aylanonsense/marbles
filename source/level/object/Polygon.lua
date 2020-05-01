import "level/object/LevelObject"
import "render/camera"
import "render/patterns"
import "physics/physObjectByType"
import "scene/time"
import "utility/diagnosticStats"

class("Polygon").extends("LevelObject")

function Polygon:init(physPoints, physLinesAndArcs, fillCoordinates, lineCoordinates, moveX, moveY)
	Polygon.super.init(self, LevelObject.Type.Polygon)
	self.physPoints = physPoints
	for _, point in ipairs(self.physPoints) do
		self:addPhysicsObject(point)
	end
	self.physLinesAndArcs = physLinesAndArcs
	for _, lineOrArc in ipairs(self.physLinesAndArcs) do
		self:addPhysicsObject(lineOrArc)
	end
	self.fillCoordinates = fillCoordinates
	self.lineCoordinates = lineCoordinates
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
	if self.fillCoordinates and #self.fillCoordinates > 0 then
		for i = 1, #self.fillCoordinates, 2 do
			local x, y = camera.matrix:transformXY(self.fillCoordinates[i], self.fillCoordinates[i + 1])
			self.perspectiveFillCoordinates[i] = x
			self.perspectiveFillCoordinates[i + 1] = y
		end
		if self.fillPattern ~= 'Transparent' then
			-- Fill in the polygon
			playdate.graphics.setPattern(patterns[self.fillPattern])
			playdate.graphics.fillPolygon(table.unpack(self.perspectiveFillCoordinates))
			diagnosticStats.polygonPointsDrawn += #self.perspectiveFillCoordinates
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
			playdate.graphics.drawLine(x1, y1, x2, y2)
		end
		diagnosticStats.polygonPointsDrawn += #self.lineCoordinates
	elseif self.fillCoordinates and #self.fillCoordinates > 0 then
		-- Draw the outline as a polygon
		playdate.graphics.drawPolygon(table.unpack(self.perspectiveFillCoordinates))
		diagnosticStats.polygonPointsDrawn += #self.perspectiveFillCoordinates
	end
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
