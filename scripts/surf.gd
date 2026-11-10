extends RefCounted
var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/surf.json"))
var world: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/surf-world.json"))
func valid(state: Dictionary) -> bool:return not state.has("surfing") or state["surfing"] is bool
func has_hm(state: Dictionary) -> bool:return state.get("safari_rewards",{}).get("items",{}).get("hm03",0)==1
func learn_error(state: Dictionary,index: int) -> String:
 if not has_hm(state):return "还没有HM03，请先到秘密小屋领取。"
 if index<0 or index>=state["team"].size():return "请选择队伍里的宝可梦。"
 var pet:Dictionary=state["team"][index]
 if pet["species_id"] not in data["compatible"]:return "这只宝可梦不能学习冲浪。"
 if "surf" in pet["moves"]:return "已经学会冲浪。"
 return ""
func teach(store: RefCounted,index: int,slot: int) -> String:
 var failure:String=learn_error(store.state,index)
 if failure!="":return failure
 var pet:Dictionary=store.state["team"][index]
 if slot<0 or slot>pet["moves"].size() or slot>=4:return "已取消学习。"
 if pet["moves"].size()==4 and pet["moves"][slot] in store.growth.HM_MOVES:return "秘传招式不能在这里遗忘。"
 var before:Dictionary=store.state.duplicate(true)
 if not store.growth.resolve_learning(pet,"surf",slot):return "无法学习冲浪。"
 store.friendship.adjust(pet,"tmhm",store.state.get("location",{}).get("map_id",""))
 if not store.save_game():store.state=before;return store.error
 return ""
func field_error(state:Dictionary)->String:
 if not state.get("badges",{}).get("soul",false):return "需要粉红徽章，才能在场外冲浪。"
 for pet in state["team"]:
  if "surf" in pet["moves"]:return ""
 return "队伍中还没有学会冲浪的宝可梦。"
func water(mid:String,d:Dictionary,cell:Vector2i)->bool:
 if d.has("behaviors") and mid.begins_with("sevii-"):
  if cell.x<0 or cell.y<0 or cell.x>=int(d["width"]) or cell.y>=int(d["height"]):return false
  return int(d["behaviors"][cell.y][cell.x]) in [16,17,18,19,21,26,27,80,81,82,83]
 if not world.has(mid) or not world[mid]["isWaterTileset"]:return false
 if cell.x<0 or cell.y<0 or cell.x>=int(d["width"]) or cell.y>=int(d["height"]):return false
 for tile in world[mid]["surfTiles"]:
  if int(d["footTiles"][cell.y][cell.x])==int(tile) and int(tile) in [20,50,72]:return true
 return false
func pair_blocked(mid:String,d:Dictionary,a:Vector2i,b:Vector2i)->bool:
 if d.has("behaviors") and mid.begins_with("sevii-"):return int(d["behaviors"][b.y][b.x]) in [17,19]
 if not world.has(mid):return true
 var first:int=d["footTiles"][a.y][a.x];var second:int=d["footTiles"][b.y][b.x]
 for pair in world[mid]["pairCollisionsWater"]:
  if first==int(pair[0]) and second==int(pair[1]) or first==int(pair[1]) and second==int(pair[0]):return true
 return false
func apply(mid:String,d:Dictionary,state:Dictionary)->void:
 if d.has("behaviors") and mid.begins_with("sevii-"):
  for y in range(int(d["height"])):
   for x in range(int(d["width"])):
    if water(mid,d,Vector2i(x,y)):d["solid"][y][x]=0 if state.get("surfing",false) and int(d["behaviors"][y][x]) not in [17,19] else 1
  return
 if not state.get("surfing",false) or not world.has(mid):return
 for y in range(int(d["height"])):
  for x in range(int(d["width"])):
   if water(mid,d,Vector2i(x,y)):d["solid"][y][x]=0
 d["pairCollisionsLand"]=world[mid]["pairCollisionsWater"]
