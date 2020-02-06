import "level/object/LevelObject"
import "level/object/Circle"
import "level/object/Coin"
import "level/object/Marble"
import "level/object/Polygon"
import "level/object/WorldBoundary"

levelObjectByType = {
	[LevelObject.Type.Circle] = Circle,
	[LevelObject.Type.Coin] = Coin,
	[LevelObject.Type.Marble] = Marble,
	[LevelObject.Type.Polygon] = Polygon,
	[LevelObject.Type.WorldBoundary] = WorldBoundary
}
