import "CoreLibs/object"
import "physics/physics"
import "physics/Circle"

class("Ball").extends(Circle)

function Ball:init(x, y, radius)
	Ball.super.init(self, x, y, radius)
	self.mass = 1
end

function Ball:add()
	table.insert(physics.balls, self)
	return Ball.super.add(self)
end
