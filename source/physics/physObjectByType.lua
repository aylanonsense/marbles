import "physics/PhysObject"
import "physics/PhysArc"
import "physics/PhysBall"
import "physics/PhysCircle"
import "physics/PhysLine"
import "physics/PhysPoint"

physObjectByType = {
	[PhysObject.Type.PhysArc] = PhysArc,
	[PhysObject.Type.PhysBall] = PhysBall,
	[PhysObject.Type.PhysCircle] = PhysCircle,
	[PhysObject.Type.PhysLine] = PhysLine,
	[PhysObject.Type.PhysPoint] = PhysPoint
}
