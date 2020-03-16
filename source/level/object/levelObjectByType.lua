import "level/object/LevelObject"
import "level/object/Booster"
import "level/object/Circle"
import "level/object/Coin"
import "level/object/Decoration"
import "level/object/Exit"
import "level/object/Marble"
import "level/object/Polygon"
import "level/object/WorldBoundary"

levelObjectByType = {
	[LevelObject.Type.Booster] = Booster,
	[LevelObject.Type.Circle] = Circle,
	[LevelObject.Type.Coin] = Coin,
  [LevelObject.Type.Decoration] = Decoration,
	[LevelObject.Type.Exit] = Exit,
	[LevelObject.Type.Marble] = Marble,
	[LevelObject.Type.Polygon] = Polygon,
	[LevelObject.Type.WorldBoundary] = WorldBoundary
}
