import "level/object/LevelObject"
import "level/object/BigBall"
import "level/object/Booster"
import "level/object/Circle"
import "level/object/CircleBumper"
import "level/object/Coin"
import "level/object/CrumblingPlatform"
import "level/object/Decoration"
import "level/object/Exit"
import "level/object/Marble"
import "level/object/Polygon"
import "level/object/TriangleBumper"
import "level/object/SmallBall"
import "level/object/WorldBoundary"

levelObjectByType = {
	[LevelObject.Type.BigBall] = BigBall,
	[LevelObject.Type.Booster] = Booster,
	[LevelObject.Type.Circle] = Circle,
  [LevelObject.Type.CircleBumper] = CircleBumper,
	[LevelObject.Type.Coin] = Coin,
  [LevelObject.Type.CrumblingPlatform] = CrumblingPlatform,
  [LevelObject.Type.Decoration] = Decoration,
	[LevelObject.Type.Exit] = Exit,
	[LevelObject.Type.Marble] = Marble,
	[LevelObject.Type.Polygon] = Polygon,
  [LevelObject.Type.SmallBall] = SmallBall,
  [LevelObject.Type.TriangleBumper] = TriangleBumper,
	[LevelObject.Type.WorldBoundary] = WorldBoundary
}
