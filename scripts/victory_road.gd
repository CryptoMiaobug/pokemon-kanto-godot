extends RefCounted
const FLAGS=["victory_road_2f_open1","victory_road_2f_open2","victory_road_3f_open","victory_road_fallen"]
var data:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://data/victory-road-upper-puzzles.json"))
func valid(s:Dictionary)->bool:
 for key in FLAGS:
  if s.has(key) and not s[key] is bool:return false
 return true
func visible(a:Dictionary,s:Dictionary)->bool:
 if a.get("fallen",false):return s.get("victory_road_fallen",false)
 if a.get("falling",false):return not s.get("victory_road_fallen",false)
 return true
func patches(mid:String,s:Dictionary)->Array:
 var out:Array=[]
 for p in data["patches"].get(mid,[]):
  if s.get(p["flag"],false):out.append(p)
 return out
func apply(mid:String,d:Dictionary,s:Dictionary,actors:Array)->void:
 for a in actors:
  if a["map"]==mid and not visible(a,s):d["solid"][a["cell"][1]][a["cell"][0]]=0
 for p in patches(mid,s):
  for c in p["cells"]:d["solid"][c["cell"][1]][c["cell"][0]]=c["solid"];d["footTiles"][c["cell"][1]][c["cell"][0]]=c["foot"]
func pushed(mid:String,cell:Array,s:Dictionary)->bool:
 var changed:bool=false
 for p in data["patches"].get(mid,[]):
  if Vector2i(cell[0],cell[1])==Vector2i(p["switch"][0],p["switch"][1]) and not s.get(p["flag"],false):s[p["flag"]]=true;changed=true
 if mid=="victory-road-3f" and Vector2i(cell[0],cell[1])==Vector2i(23,15) and not s.get("victory_road_fallen",false):s["victory_road_fallen"]=true;changed=true
 return changed
func transition(mid:String,s:Dictionary)->bool:
 var before:Dictionary=s.duplicate(true)
 if mid=="route23":
  for key in FLAGS:
   if s.has(key):s[key]=false
 if mid=="victory-road-2f" and s.has("victory_road_1f_open"):s["victory_road_1f_open"]=false
 return s!=before
