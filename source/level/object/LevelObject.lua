import "CoreLibs/object"

class("LevelObject").extends()

LevelObject.Type = {
	Booster = "Booster",
	Circle = "Circle",
	Coin = "Coin",
	Exit = "Exit",
	Marble = "Marble",
	Polygon = "Polygon",
	WorldBoundary = "WorldBoundary"
}

function LevelObject:init(type)
	LevelObject.super.init(self)
	self.type = type
	self.physObjects = {}
	self.waitingToDespawn = false
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
	return {
		type = self.type,
		x = x,
		y = y
	}
end

function LevelObject:setVelocity(x, y)
	for _, physObj in ipairs(self.physObjects) do
		physObj.velX = x
		physObj.velY = y
	end
end

function LevelObject:addPhysicsObject(physObj)
	table.insert(self.physObjects, physObj)
	physObj:setParent(self)
	physObj:add()
	return physObj
end
