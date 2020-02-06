import "CoreLibs/object"
import "physics/PhysObject"
import "physics/physics"
import "physics/PhysCircle"

class("PhysBall").extends(PhysCircle)

function PhysBall:init(x, y, radius)
	PhysBall.super.init(self, x, y, radius)
	self.type = PhysObject.Type.PhysBall
	self.mass = 1
end

function PhysBall:add()
	table.insert(physics.balls, self)
	return PhysBall.super.add(self)
end
