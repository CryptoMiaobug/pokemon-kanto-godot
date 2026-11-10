extends RefCounted
## Teaching only. Source acquisition and field targets await the actual Sevii maps.
var catalog:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://data/sevii-hms.json"))["machines"]
var move:String="rocksmash"
func valid(s:Dictionary)->bool:
 if not s.has("sevii_hms"):return true
 if not s["sevii_hms"] is Dictionary:return false
 for key in s["sevii_hms"]:
  if not catalog.has(key) or not s["sevii_hms"][key] is bool:return false
 return true
func has_hm(s:Dictionary)->bool:return s.get("sevii_hms",{}).get(move,false)
func learn_error(s:Dictionary,index:int)->String:
 if not has_hm(s):return "还没有HM%02d%s。" % [catalog[move]["hm"],catalog[move]["name"]]
 if index<0 or index>=s["team"].size():return "请选择队伍里的宝可梦。"
 var pet:Dictionary=s["team"][index]
 if pet["species_id"] not in catalog[move]["species"]:return "这只宝可梦不能学习%s。" % catalog[move]["name"]
 if move in pet["moves"]:return "已经学会%s。" % catalog[move]["name"]
 return ""
func teach(store:RefCounted,index:int,slot:int)->String:
 if not store.validate(store.state):return "存档数据无效，未教学。"
 var failure:String=learn_error(store.state,index)
 if failure!="":return failure
 var pet:Dictionary=store.state["team"][index]
 if slot<0 or slot>pet["moves"].size() or slot>=4:return "已取消学习。"
 if slot<pet["moves"].size() and pet["moves"][slot] in store.growth.HM_MOVES:return "秘传招式不能在这里遗忘。"
 var before:Dictionary=store.state.duplicate(true)
 if not store.growth.resolve_learning(pet,move,slot):store.state=before;return "无法学习。"
 store.friendship.adjust(pet,"tmhm",store.state.get("location",{}).get("map_id",""))
 if not store.save_game():store.state=before;return store.error+" 学习已撤销，可以重试。"
 return ""
