extends RefCounted
var blocks: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/rocket-entry-blocks.json"))
func opened(state: Dictionary) -> bool:return state.get("rocket_hideout_open",false)
func guard_gone(state: Dictionary) -> bool:return state.get("trainers",{}).get("rocket_poster",false)
func valid(state: Dictionary) -> bool:return not state.has("rocket_hideout_open") or state["rocket_hideout_open"] is bool
func active(map: String,state: Dictionary) -> bool:return opened(state) if map=="game-corner" else state.get("trainers",{}).get("rocket_b1_5",false)
func apply(map: String,layout: Dictionary,state: Dictionary) -> void:
 if map=="game-corner" and guard_gone(state):layout["solid"][5][9] = 0
 for block in blocks:
  if block["map"]==map and active(map,state):
   for patch in block["cells"]:
    layout["solid"][patch["cell"][1]][patch["cell"][0]] = patch["solid"]
    layout["footTiles"][patch["cell"][1]][patch["cell"][0]] = patch["foot"]
func push(store: RefCounted) -> String:
 if opened(store.state):return ""
 var before: Dictionary = store.state.duplicate(true)
 store.state["rocket_hideout_open"] = true
 if not store.save_game():
  store.state = before
  return store.error+" 开关尚未保存，可以重试。"
 return ""
