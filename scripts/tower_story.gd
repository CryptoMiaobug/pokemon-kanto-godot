extends RefCounted
func rescued(s: Dictionary) -> bool:return s.get("tower_story",{}).get("rescued",false)
func flute(s: Dictionary) -> bool:return s.get("tower_story",{}).get("poke_flute",false)
func ready(s: Dictionary) -> bool:
 for flag in ["tower_mother_released","tower7_1","tower7_2","tower7_3"]:
  if not s.get("trainers",{}).get(flag,false):return false
 return true
func candy_claimed(s: Dictionary) -> bool:return s.get("tower_pickups",{}).get("tower6_rare_candy",false)
func take_candy(store: RefCounted) -> String:
 if store.state.get("location",{}).get("map_id","")!="pokemon-tower-6f":return "请到原道具位置领取。"
 if candy_claimed(store.state):return "已经领取，不能重复获得。"
 if int(store.state.get("rare_candies",0))>=store.STACK_LIMIT:return "神奇糖果已达到持有上限。"
 var capacity:String=store.inventory.receive_error(store.state,"rare_candies")
 if capacity!="":return capacity
 var before: Dictionary = store.state.duplicate(true)
 store.state["rare_candies"] = int(store.state.get("rare_candies",0))+1
 if not store.state.has("tower_pickups"):store.state["tower_pickups"]={}
 store.state["tower_pickups"]["tower6_rare_candy"]=true
 if not store.save_game():store.state=before;return store.error
 return ""
func valid(s: Dictionary) -> bool:
 if s.has("rare_candies") and (not (s["rare_candies"] is int or s["rare_candies"] is float) or s["rare_candies"]!=floor(s["rare_candies"]) or s["rare_candies"]<0 or s["rare_candies"]>999):return false
 if s.has("tower_pickups"):
  if not s["tower_pickups"] is Dictionary:return false
  for key in s["tower_pickups"]:
   if key!="tower6_rare_candy" or not s["tower_pickups"][key] is bool:return false
 if not s.has("tower_story"):return true
 if not s["tower_story"] is Dictionary:return false
 for k in s["tower_story"]:
  if k not in ["rescued","poke_flute"] or not s["tower_story"][k] is bool:return false
 return not flute(s) or rescued(s)
func visible(a: Dictionary,s: Dictionary) -> bool:
 if a["map"]=="pokemon-tower-6f" and a.get("item","")=="RARE_CANDY":return not candy_claimed(s)
 if a["map"]=="pokemon-tower-7f":
  if a["redObject"]==4:return not rescued(s)
  return not s.get("trainers",{}).get("tower7_%d" % int(a["redObject"]),false)
 if a["map"]=="mr-fujis-house" and a["redObject"]==5:return rescued(s)
 return not a.get("startsHidden",false)
func apply(mid: String,layout: Dictionary,s: Dictionary,actors: Array) -> void:
 if mid=="pokemon-tower-6f" and candy_claimed(s):layout["solid"][8][6]=0
 for a in actors:
  if a["map"]==mid and mid in ["pokemon-tower-7f","mr-fujis-house"]:
   layout["solid"][a["cell"][1]][a["cell"][0]] = int(visible(a,s))
func transition(store: RefCounted,action: String) -> String:
 var before: Dictionary = store.state.duplicate(true)
 var story: Dictionary = store.state.get("tower_story",{}).duplicate(true)
 if action=="rescue":
  if not ready(store.state):return "先解放母亲幽灵并击败三名火箭队员。"
  if rescued(store.state):return ""
  story["rescued"] = true
  store.state["location"] = {"map_id":"mr-fujis-house","x":56,"y":41}
 elif action=="flute":
  if not rescued(store.state):return "富士老人还未获救。"
  if flute(store.state):return ""
  if store.inventory.receive_error(store.state,"poke_flute")!="":return "关键物品口袋已满。"
  story["poke_flute"] = true
 else:return "未知操作。"
 store.state["tower_story"] = story
 if not store.save_game():store.state = before;return store.error
 return ""

func play_flute(store:RefCounted)->String:
 if not flute(store.state):return "尚未获得宝可梦笛。"
 var before:Dictionary=store.state.duplicate(true)
 for pet in store.state["team"]:
  if int(pet["hp"])>0 and pet.get("status","")=="sleep":pet.erase("status");pet.erase("sleep_turns")
 if not store.save_game():store.state=before;return store.error
 return ""
