extends RefCounted
var tables: Dictionary = {"viridian-gym":JSON.parse_string(FileAccess.get_file_as_string("res://data/viridian-gym-arrows.json")), "rocket-hideout-b3f":JSON.parse_string(FileAccess.get_file_as_string("res://data/rocket-b3-arrows.json")), "rocket-hideout-b2f":JSON.parse_string(FileAccess.get_file_as_string("res://data/rocket-b2-arrows.json"))}
var route: Array = []
var index: int = 0
var elapsed: float = 0.0
var active: bool = false
var latch := Vector2i(-1,-1)
const DIRECTIONS := {"up":Vector2i.UP,"down":Vector2i.DOWN,"left":Vector2i.LEFT,"right":Vector2i.RIGHT}
func path(map: String,cell: Vector2i) -> Array:
 for entry in tables.get(map,[]):
  if cell==Vector2i(entry["cell"][0],entry["cell"][1]):
   var result: Array = [];var here: Vector2i = cell
   var pairs: Array = entry["rle"].duplicate();pairs.reverse()
   for pair in pairs:
    for n in range(int(pair[1])):
     here += DIRECTIONS[pair[0]];result.append(here)
   return result
 return []
func reset() -> void:
 route.clear();index = 0;elapsed = 0;active = false;latch = Vector2i(-1,-1)
func begin(map: String,cell: Vector2i) -> bool:
 if cell==latch:return false
 route = path(map,cell)
 if route.is_empty():latch = Vector2i(-1,-1);return false
 index = 0;elapsed = 0;active = true;return true
func destination() -> Vector2:
 var cell: Vector2i = route[-1]
 return Vector2(cell.x*16+8,cell.y*16+9)
func tick(player: CharacterBody2D,delta: float) -> bool:
 if not active:return false
 player.active = false;player.velocity = Vector2.ZERO;elapsed += delta
 while elapsed>=0.08 and index<route.size():
  elapsed -= 0.08
  var cell: Vector2i = route[index];var next := Vector2(cell.x*16+8,cell.y*16+9);var direction: Vector2 = (next-player.position).normalized();player.position = next;player.facing = direction
  var frame: int = [0,2,1,2][index%4];player.sprite.texture = load("res://assets/pokemon/red-%d.png" % frame);player.sprite.flip_h = index%4==3;index += 1
 if index==route.size():
  active = false;player.active = true;latch = route[-1]
  return true
 return false
