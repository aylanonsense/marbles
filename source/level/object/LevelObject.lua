import "CoreLibs/object"

class("LevelObject").extends()

LevelObject.Type = {
	Circle = "Circle",
	Coin = "Coin",
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
			minX = (minX == nil or physObj.position.x < minX) and physObj.position.x or minX
			maxX = (maxX == nil or physObj.position.x > maxX) and physObj.position.x or maxX
			minY = (minY == nil or physObj.position.y < minY) and physObj.position.y or minY
			maxY = (maxY == nil or physObj.position.y > maxY) and physObj.position.y or maxY
		end
		return (minX + maxX) / 2, (minY + maxY) / 2
	end
end

function LevelObject:setPosition(x, y)
	local currX, currY = self:getPosition()
	local dx, dy = x - currX, y - currY
	for _, physObj in ipairs(self.physObjects) do
		physObj.position.x += dx
		physObj.position.y += dy
	end
	return dx, dy
end

function LevelObject:translate(dx, dy)
	local x, y = self:getPosition()
	self:setPosition(x + dx, y + dy)
	return x + dx, y + dy
end

function LevelObject:serialize()
	local x, y = self:getPosition()
	return {
		type = self.type,
		x = x,
		y = y
	}
end

function LevelObject:addPhysicsObject(physObj)
	table.insert(self.physObjects, physObj)
	physObj:setParent(self)
	physObj:add()
	return physObj
end
