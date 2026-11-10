extends RefCounted
## FireRed HM05 field permission and saved Rock Tunnel lighting.
var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/flash.json"))
func has_hm(state: Dictionary) -> bool:
 return state.get("flash_reward",{}).get("hm05",0)==1
func learn_error(state: Dictionary,index: int) -> String:
 if not has_hm(state):return "还没有HM05，请先找2号道路助手领取。"
 if index<0 or index>=state["team"].size():return "请选择队伍里的宝可梦。"
 var pet: Dictionary=state["team"][index]
 if not data["compatibility"].get(pet["species_id"],false):return "这只宝可梦不能学习闪光。"
 if "flash" in pet["moves"]:return "这只宝可梦已经学会闪光。"
 return ""
func teach(store: RefCounted,index: int,slot: int) -> String:
 var failure: String=learn_error(store.state,index)
 if failure!="":return failure
 var pet: Dictionary=store.state["team"][index]
 if slot<0 or slot>pet["moves"].size() or slot>=4:return "已取消学习。"
 if slot<pet["moves"].size() and pet["moves"][slot] in store.growth.HM_MOVES:return "秘传招式不能在这里遗忘。"
 var before: Dictionary=store.state.duplicate(true)
 if not store.growth.resolve_learning(pet,"flash",slot):return "无法学习闪光。"
 store.friendship.adjust(pet,"tmhm",store.state.get("location",{}).get("map_id",""))
 if not store.save_game():store.state=before;return store.error+" 学习已撤销，可以重试。"
 return ""
func user_index(state: Dictionary) -> int:
 for i in range(state["team"].size()):
  if "flash" in state["team"][i]["moves"]:return i
 return -1
func field_permission(state: Dictionary,map_id: String,active: bool=false) -> Dictionary:
 if not state.get("badges",{}).get("boulder",false):return {"allowed":false,"reason":"需要灰色徽章，才能在场外使用闪光。","user_index":-1}
 var index: int=user_index(state)
 if index<0:return {"allowed":false,"reason":"队伍中还没有学会闪光的宝可梦。","user_index":-1}
 if map_id not in data["field_maps"]:return {"allowed":false,"reason":"这里不能使用闪光；只有岩山隧道需要照明。","user_index":index}
 if active:return {"allowed":false,"reason":"闪光已经生效，无需重复使用。","user_index":index}
 return {"allowed":true,"reason":"闪光照亮了岩山隧道。","user_index":index}
