extends RefCounted
const BADGES := ["boulder","cascade","thunder","rainbow","soul","marsh","volcano"]
var actors: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/viridian-gym-actors.json"))
func opened(state: Dictionary) -> bool:
 for badge in BADGES:
  if not state.get("badges",{}).get(badge,false):return false
 return true
func news(state: Dictionary) -> String:
 return "常青道馆的馆主回来了！道馆已经开放。" if opened(state) else "常青道馆一直关着，不知道馆主是谁。"
func geometry(id: String,layout: Dictionary) -> void:
 if id=="viridian-city":layout["solid"][7][32]=0
 for actor in actors:
  if actor["map"]==id:layout["solid"][actor["cell"][1]][actor["cell"][0]]=1
