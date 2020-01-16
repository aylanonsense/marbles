import "CoreLibs/graphics"
import "physics/physics"
import "physics/Circle"

class("Ball").extends(Circle)

function Ball:init(x, y, radius)
	Ball.super.init(self, x, y, radius)
	self.mass = 1
end

function Ball:add()
	Ball.super.add(self)
	table.insert(physics.balls, self)
end
