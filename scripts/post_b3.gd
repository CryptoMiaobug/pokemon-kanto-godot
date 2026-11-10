extends RefCounted
## Explicit optional v3 story; each item/stage commits atomically.
var door: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/post-b3-door.json"))
var actors: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/post-b3-actors.json"))
func story(state: Dictionary) -> Dictionary:return state.get("rocket_story",{})
func has_item(state: Dictionary,item: String) -> bool:return story(state).get("items",{}).get(item,0)==1
func valid(state: Dictionary) -> bool:
 if not state.has("rocket_story"):return true
 var v: Variant = state["rocket_story"]
 if not v is Dictionary:return false
 for key in v:
  if key=="items":
   if not v[key] is Dictionary:return false
   for item in v[key]:
    if item not in ["lift_key","silph_scope"] or not (v[key][item] is int or v[key][item] is float) or (v[key][item]!=0 and v[key][item]!=1):return false
  elif key=="key_dropped":
   if not v[key] is bool:return false
  elif key=="lift_floor":
   if v[key] not in ["rocket-hideout-b1f","rocket-hideout-b2f","rocket-hideout-b4f"]:return false
  else:return false
 return true
func visible(actor: Dictionary,state: Dictionary) -> bool:
 if actor["map"]=="rocket-hideout-b4f":
  if actor["redObject"]==1:return not state.get("trainers",{}).get("rocket_giovanni",false)
  if actor["item"]=="LIFT_KEY":return story(state).get("key_dropped",false) and not has_item(state,"lift_key")
  if actor["item"]=="SILPH_SCOPE":return state.get("trainers",{}).get("rocket_giovanni",false) and not has_item(state,"silph_scope")
 if actor["map"]=="pokemon-tower-2f" and actor["redObject"]==1:return not state.get("trainers",{}).get("tower_rival",false)
 return not actor.get("startsHidden",false)
func door_open(state: Dictionary) -> bool:return state.get("trainers",{}).get("rocket_b4_2",false) and state.get("trainers",{}).get("rocket_b4_3",false)
func lift_floor(state: Dictionary) -> String:return story(state).get("lift_floor","rocket-hideout-b1f")
func apply(map: String,layout: Dictionary,state: Dictionary) -> void:
 if map=="rocket-hideout-b4f" and door_open(state):
  for patch in door["cells"]:
   layout["solid"][patch["cell"][1]][patch["cell"][0]] = patch["solid"]
   layout["footTiles"][patch["cell"][1]][patch["cell"][0]] = patch["foot"]
 for actor in actors:
  if actor["map"]==map:
   var c: Array = actor["cell"]
   if actor["map"]=="pokemon-tower-2f" and actor["redObject"]==1:layout["solid"][c[1]][c[0]] = int(visible(actor,state))
   if actor["map"]=="rocket-hideout-b4f" and (actor["redObject"]==1 or actor["item"] in ["LIFT_KEY","SILPH_SCOPE"]):layout["solid"][c[1]][c[0]] = int(visible(actor,state))
func transition(store: RefCounted,action: String,value: String = "") -> String:
 var before: Dictionary = store.state.duplicate(true)
 var v: Dictionary = story(store.state).duplicate(true)
 if action=="drop":
  if not store.state.get("trainers",{}).get("rocket_b4_4",false):return "先击败看守钥匙的队员。"
  if v.get("key_dropped",false):return ""
  v["key_dropped"] = true
 elif action=="take":
  if value not in ["lift_key","silph_scope"]:return "未知道具。"
  if has_item(store.state,value):return ""
  if value=="lift_key" and not v.get("key_dropped",false):return "钥匙尚未掉落。"
  if value=="silph_scope" and not store.state.get("trainers",{}).get("rocket_giovanni",false):return "检视镜尚未出现。"
  if store.inventory.receive_error(store.state,value)!="":return "关键物品口袋已满。"
  if not v.has("items"):v["items"] = {}
  v["items"][value] = 1
 elif action=="enter_lift" or action=="select_floor":
  if value not in ["rocket-hideout-b1f","rocket-hideout-b2f","rocket-hideout-b4f"]:return "没有这个电梯楼层。"
  if action=="select_floor" and not has_item(store.state,"lift_key"):return "看来需要一把钥匙。"
  if lift_floor(store.state)==value and v.has("lift_floor"):return ""
  v["lift_floor"] = value
 else:return "未知剧情操作。"
 store.state["rocket_story"] = v
 if not store.save_game():
  store.state = before
  return store.error
 return ""
