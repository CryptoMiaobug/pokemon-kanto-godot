extends RefCounted
## Optional v3 elevator/key/door transitions; source door patches and atomic rollback.
const MAX_FLOOR := 11
var liberation: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/silph-liberation.json"))
var doors: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/silph-doors.json"))
func floor_id(state: Dictionary) -> String:return state.get("silph_story",{}).get("lift_floor","silph-co-1f")
func valid(state: Dictionary) -> bool:
 if not state.has("silph_story"):return true
 var v: Variant = state["silph_story"]
 if not v is Dictionary:return false
 for key in v:
  if key=="lift_floor":
   if v[key] not in floors():return false
  elif key in ["master_ball_received","lapras_received","card_key"]:
   if not v[key] is bool:return false
  elif key=="doors":
   if not v[key] is Dictionary:return false
   for id in v[key]:
    var known: bool = false
    for d in doors:
     if d["id"]==id:known = true
    if not known or not v[key][id] is bool or v[key][id] and not v.get("card_key",false):return false
  else:return false
 return true
func floors() -> Array:
 var result: Array = []
 for i in range(1,MAX_FLOOR+1):result.append("silph-co-%df" % i)
 return result
func select_floor(store: RefCounted,value: String) -> String:
 if value not in floors():return "此楼层将在后续切片接入。"
 if floor_id(store.state)==value and store.state.has("silph_story"):return ""
 var before: Dictionary = store.state.duplicate(true)
 if not store.state.has("silph_story"):store.state["silph_story"] = {}
 store.state["silph_story"]["lift_floor"] = value
 if not store.save_game():store.state = before;return store.error
 return ""
func has_key(state: Dictionary) -> bool:return state.get("silph_story",{}).get("card_key",false)
func door_open(state: Dictionary,id: String) -> bool:return state.get("silph_story",{}).get("doors",{}).get(id,false)
func visible(actor: Dictionary,state: Dictionary) -> bool:
 if liberated(state):
  for change in liberation:
   if change["map"]==actor["map"] and change["redObject"]==actor["redObject"]:return change["visible_after"]
 if actor["map"]=="silph-co-7f" and actor["redObject"]==9:return not state.get("trainers",{}).get("silph_rival",false)
 if actor.get("item","")=="CARD_KEY":return not has_key(state)
 return not actor.get("startsHidden",false)
func apply(mid: String,layout: Dictionary,state: Dictionary,actors: Array) -> void:
 for door in doors:
  if door["map"]==mid and door_open(state,door["id"]):
   for p in door["cells"]:layout["solid"][p["cell"][1]][p["cell"][0]] = p["solid"];layout["footTiles"][p["cell"][1]][p["cell"][0]] = p["foot"]
 for a in actors:
  if a["map"]==mid:layout["solid"][a["cell"][1]][a["cell"][0]] = int(visible(a,state))
func transition(store: RefCounted,action: String,value: String) -> String:
 var before: Dictionary = store.state.duplicate(true)
 if action=="take":
  if value!="silph-co-5f":return "这里没有卡片钥匙。"
  if has_key(store.state):return ""
 elif action=="open":
  if not has_key(store.state):return "卡片门锁住了。需要卡片钥匙。"
  var known: bool = false
  for d in doors:
   if d["id"]==value:known = true
  if not known:return "未知卡片门。"
  if door_open(store.state,value):return ""
 else:return "未知剧情操作。"
 if not store.state.has("silph_story"):store.state["silph_story"] = {}
 if action=="take" and store.inventory.receive_error(store.state,"card_key")!="":store.state=before;return "关键物品口袋已满。"
 if action=="take":store.state["silph_story"]["card_key"] = true
 else:
  if not store.state["silph_story"].has("doors"):store.state["silph_story"]["doors"] = {}
  store.state["silph_story"]["doors"][value] = true
 if not store.save_game():store.state = before;return store.error
 return ""

func liberated(state: Dictionary) -> bool:return state.get("trainers",{}).get("silph_giovanni",false)
func nurse(store: RefCounted) -> String:
 if liberated(store.state):return ""
 var before: Dictionary = store.state.duplicate(true)
 store.heal_party()
 if not store.save_game():store.state = before;return store.error
 return ""

func gift(store: RefCounted) -> String:
 if store.state.get("silph_story",{}).get("lapras_received",false):return ""
 if not store.can_receive_capture():return "队伍与全部盒子已满。拉普拉斯仍在这里等你。"
 var before: Dictionary = store.state.duplicate(true)
 var pet: Dictionary = store.create_individual("lapras",-1,25)
 var destination: Dictionary = store.receive_capture(pet)
 if destination.has("error"):store.state = before;return destination["error"]
 if not store.state.has("silph_story"):store.state["silph_story"] = {}
 store.state["silph_story"]["lapras_received"] = true
 if not store.save_game():store.state = before;return store.error
 return ""

func president(store: RefCounted) -> String:
 if not liberated(store.state):return "请先击败坂木，救出公司。"
 if store.state.get("silph_story",{}).get("master_ball_received",false):return ""
 if store.inventory.receive_error(store.state,"master_balls")!="":return "精灵球口袋已满。"
 if int(store.state.get("master_balls",0))>=store.STACK_LIMIT:return "大师球已满，请腾出空间后再领取。"
 var before: Dictionary = store.state.duplicate(true)
 store.state["master_balls"] = int(store.state.get("master_balls",0))+1
 if not store.state.has("silph_story"):store.state["silph_story"] = {}
 store.state["silph_story"]["master_ball_received"] = true
 if not store.save_game():store.state = before;return store.error
 return ""
