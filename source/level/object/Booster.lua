import "level/object/LevelObject"
import "physics/PhysCircle"
import "render/camera"
import "scene/time"
import "utility/math"
import "render/imageCache"
import "utility/diagnosticStats"
import "utility/soundCache"
import "config"
import "effect/effects"

class("Booster").extends("LevelObject")

local numRecentBoosts = 0
local framesUntilBoostReset = 0

function Booster.updateSoundCombo()
	if framesUntilBoostReset > 0 then
		framesUntilBoostReset -= 1
		if framesUntilBoostReset <= 0 then
			numRecentBoosts = 0
		end
	end
end

function Booster:init(x, y, rotation)
	Booster.super.init(self, LevelObject.Type.Booster)
	self.physCircle = self:addPhysicsObject(PhysCircle(x, y, 10))
	self.cooldown = 0
	self.rotation = rotation
	local angle = drawableAngleToTrigAngle(self.rotation)
	self.launchX = math.cos(angle)
	self.launchY = math.sin(angle)
	self.imageTable = imageCache.loadImageTable("images/level/objects/booster.png")
  self.boostSound = soundCache.createSoundEffectPlayer("sound/sfx/booster")
	self.boostSound:setVolume(config.SOUND_VOLUME * 0.3)
	self.highlightFrames = 0
end

function Booster:update()
	self.cooldown = math.max(0, self.cooldown - time.dt)
	self.highlightFrames = math.max(0, self.highlightFrames - 1)
end

function Booster:draw()
	local x, y = self:getPosition()
	x, y = camera.matrix:transformXY(x, y)
	local scale = camera.scale
	local frame
	if self.highlightFrames <= 0 then
		frame = 1
	else
		frame = math.max(2, 4 - math.floor((self.highlightFrames - 1) / 2))
	end
	self.imageTable[frame]:drawRotated(x, y, self.rotation - camera.rotation, scale)
	diagnosticStats.transformedImagesDrawn += 1
end

function Booster:preCollide(other, collision)
	if self.cooldown <= 0 then
		self.cooldown = 0.25
		other:setVelocity(375 * self.launchX, 375 * self.launchY)

		self.boostSound:setRate(math.min(0.9 + 0.05 * numRecentBoosts, 1.2))
		self.boostSound:play(1)
		numRecentBoosts += 1
		framesUntilBoostReset = 20
		self.highlightFrames = 7
		effects:shake(3, -self.launchX, -self.launchY)
	end
	return false
end

function Booster:getEditableFields()
	return {
		{
			label = "Rotation",
			field = "rotation",
			change = function(dir)
				self.rotation += dir * 15
				if self.rotation < 0 then
					self.rotation += 360
				elseif self.rotation >= 360 then
					self.rotation -= 360
				end
			end
		}
	}
end

function Booster:serialize()
	local data = Booster.super.serialize(self)
	data.rotation = self.rotation
	return data
end

function Booster.deserialize(data)
	local booster = Booster(data.x, data.y, data.rotation)
	if data.layer then
		booster.layer = data.layer
	end
	return booster
end
