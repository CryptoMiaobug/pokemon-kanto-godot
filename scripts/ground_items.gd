extends RefCounted
## Source-pinned ordinary ground pickups. Existing story/key-item transactions stay separate.
var entries: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/ground-items.json"))
const NAMES := {"escape_ropes":"离洞绳","elixirs":"全招式回复剂","awakenings":"解眠药","nuggets":"金珠","moon_stones":"月之石","max_revives":"活力块","rare_candies":"神奇糖果"}
func definition(a: Dictionary) -> Dictionary:
 for entry in entries:
  if entry["map"]==a.get("map","") and int(entry["object"])==int(a.get("redObject",-1)) and entry["cell"]==a.get("cell",[]):return entry
 return {}
func claimed(s: Dictionary,entry: Dictionary) -> bool:return s.get("ground_pickups",{}).get(entry["key"],false)
func visible(a: Dictionary,s: Dictionary) -> bool:
 var entry: Dictionary=definition(a)
 return entry.is_empty() or not claimed(s,entry)
func quantity(s: Dictionary,entry: Dictionary) -> int:
 var item: String=entry["inventory"]
 if item.begins_with("fr_tm"):return int(s.get("tm_inventory",{}).get(item,0))
 return int(s.get(item,0)) if item in ["awakenings","elixirs","max_revives","moon_stones","rare_candies","carbos","calciums","max_potions","irons","full_restores","hp_ups","x_accuracies","hyper_potions","super_potions","proteins","full_heals","guard_specs","revives"] else int(s.get("ground_inventory",{}).get(item,0))
func display_name(store: RefCounted,entry: Dictionary) -> String:
 var item: String=entry["inventory"]
 if item.begins_with("fr_tm"):return load("res://scripts/ground_tms.gd").new().display_name(item)
 if store.SHOP.has(item):return store.SHOP[item]["name"]
 return NAMES.get(item,entry["item"])
func take(store: RefCounted,entry: Dictionary) -> String:
 if entry not in entries:return "未知地面道具。"
 if store.state.get("location",{}).get("map_id","")!=entry["map"]:return "请到原道具位置领取。"
 if claimed(store.state,entry):return "已经领取，不能重复获得。"
 var capacity:String=store.inventory.receive_error(store.state,entry["inventory"])
 if capacity!="":return capacity
 if quantity(store.state,entry)>=store.STACK_LIMIT:return "道具已达到持有上限。"
 var before: Dictionary=store.state.duplicate(true)
 var item: String=entry["inventory"]
 var amount: int=quantity(store.state,entry)+1
 if item.begins_with("fr_tm"):store.inventory.add(store.state,item,1)
 elif item in ["awakenings","elixirs","max_revives","moon_stones","rare_candies","carbos","calciums","max_potions","irons","full_restores","hp_ups","x_accuracies","hyper_potions","super_potions","proteins","full_heals","guard_specs","revives"]:store.state[item]=amount
 else:
  if not store.state.has("ground_inventory"):store.state["ground_inventory"]={}
  store.state["ground_inventory"][item]=amount
 if not store.state.has("ground_pickups"):store.state["ground_pickups"]={}
 store.state["ground_pickups"][entry["key"]]=true
 if not store.save_game():store.state=before;return store.error
 return ""
func apply(mid: String,d: Dictionary,s: Dictionary) -> void:
 for entry in entries:
  if entry["map"]==mid and (claimed(s,entry) or entry.get("tm_acquisition",false)):
   var c: Array=entry["cell"]
   d["solid"][c[1]][c[0]]=1 if entry.get("tm_acquisition",false) and not claimed(s,entry) else entry["underlying_floor"]["solid"]
   d["footTiles"][c[1]][c[0]]=entry["underlying_floor"]["foot"]
func valid(s: Dictionary) -> bool:
 var keys: Array=[];var items: Array=[]
 for entry in entries:keys.append(entry["key"]);items.append(entry["inventory"])
 if s.has("ground_pickups"):
  if not s["ground_pickups"] is Dictionary:return false
  for key in s["ground_pickups"]:
   if key not in keys or not s["ground_pickups"][key] is bool:return false
 if s.has("ground_inventory"):
  if not s["ground_inventory"] is Dictionary:return false
  for key in s["ground_inventory"]:
   var v: Variant=s["ground_inventory"][key]
   if key not in items or not (v is int or v is float) or not is_finite(float(v)) or v!=floor(v) or v<0 or v>999:return false
   if key in ["awakenings","elixirs","max_revives","moon_stones"] and int(s.get(key,0))+int(v)>999:return false
 return true

func migrate_inventory(s:Dictionary)->void:
 # Previous pickup-only saves stored these in ground_inventory. Move, never replenish.
 for item in ["awakenings","elixirs","max_revives","moon_stones"]:
  if s.get("ground_inventory",{}).has(item):
   s[item]=int(s.get(item,0))+int(s["ground_inventory"][item])
   s["ground_inventory"].erase(item)
