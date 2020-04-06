import "CoreLibs/object"

class("LevelObject").extends()

LevelObject.Type = {
	Booster = "Booster",
	Circle = "Circle",
	CircleBumper = "CircleBumper",
	Coin = "Coin",
	CrumblingPlatform = "CrumblingPlatform",
	Decoration = "Decoration",
	Exit = "Exit",
	Marble = "Marble",
	Polygon = "Polygon",
	TriangleBumper = "TriangleBumper",
	WorldBoundary = "WorldBoundary"
}

function LevelObject:init(type)
	LevelObject.super.init(self)
	self.type = type
	self.physObjects = {}
	self.waitingToDespawn = false
	self.layer = 0
end

function LevelObject:update() end

function LevelObject:draw() end

function LevelObject:preCollide(other, collision, isObjectA) end

function LevelObject:onCollide(other, collision, isObjectA) end

function LevelObject:onDespawn() end

function LevelObject:despawn()
	self.waitingToDespawn = true
	for _, physObj in ipairs(self.physObjects) do
		physObj:remove()
	end
	self.physObjects = {}
end

function LevelObject:getPosition()
	if #self.physObjects == 0 then
		return 0, 0
	else
		local minX, maxX, minY, maxY
		for _, physObj in ipairs(self.physObjects) do
			minX = (minX == nil or physObj.x < minX) and physObj.x or minX
			maxX = (maxX == nil or physObj.x > maxX) and physObj.x or maxX
			minY = (minY == nil or physObj.y < minY) and physObj.y or minY
			maxY = (maxY == nil or physObj.y > maxY) and physObj.y or maxY
		end
		return (minX + maxX) / 2, (minY + maxY) / 2
	end
end

function LevelObject:setPosition(x, y)
	local currX, currY = self:getPosition()
	local dx, dy = x - currX, y - currY
	for _, physObj in ipairs(self.physObjects) do
		physObj.x += dx
		physObj.y += dy
	end
	return dx, dy
end

function LevelObject:translate(dx, dy)
	local x, y = self:getPosition()
	self:setPosition(x + dx, y + dy)
	return x + dx, y + dy
end

function LevelObject:getEditableFields()
	return {}
end

function LevelObject:serialize()
	local x, y = self:getPosition()
	local data = {
		type = self.type,
		x = x,
		y = y
	}
	if self.layer ~= 0 then
		data.layer = self.layer
	end
	return data
end

function LevelObject:setVelocity(x, y)
	for _, physObj in ipairs(self.physObjects) do
		physObj.velX = x
		physObj.velY = y
	end
end

function LevelObject:scaleVelocity(n)
	for _, physObj in ipairs(self.physObjects) do
		physObj.velX *= n
		physObj.velY *= n
	end
end

function LevelObject:addPhysicsObject(physObj)
	table.insert(self.physObjects, physObj)
	if physObj.isStatic and not physObj.sectors then
		physObj.sectors = physObj:calculateSectors()
	end
	physObj:setParent(self)
	physObj:add()
	return physObj
end
