extends RefCounted
## Red source step rows; no persistent passed flags needed: badges never consumed.
const ROWS={136:"cascade",119:"thunder",105:"rainbow",96:"soul",85:"marsh",56:"volcano",35:"earth"}
const NAMES={"boulder":"灰色","cascade":"蓝色","thunder":"雷电","rainbow":"彩虹","soul":"粉红","marsh":"金色","volcano":"深红","earth":"绿色"}
var latch:String=""
func badge(mid:String,cell:Vector2i)->String:
 if mid=="route22-gate" and cell.y==2 and cell.x in [4,5]:return "boulder"
 if mid=="route23" and ROWS.has(cell.y) and (cell.y!=35 or cell.x<14):return ROWS[cell.y]
 return ""
func valid(s:Dictionary)->bool:
 if not preload("res://scripts/victory_road.gd").new().valid(s):return false
 if not s.has("victory_road_1f_open"):return true
 return s["victory_road_1f_open"] is bool
