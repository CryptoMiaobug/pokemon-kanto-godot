extends RefCounted
## FireRed success-only one-time tutor; Red 3F geometry retained.
var data:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://data/counter-tutor.json"))
func learn_error(state:Dictionary,index:int)->String:
 if state.get("counter_taught",false):return "双倍奉还已经教过一次，不能重复教学。"
 if index<0 or index>=state["team"].size():return "请选择队伍里的宝可梦。"
 var pet:Dictionary=state["team"][index]
 if not data["compatibility"].get(pet["species_id"],false):return "这只宝可梦不能学习双倍奉还。"
 if "counter" in pet["moves"]:return "这只宝可梦已经学会双倍奉还。"
 return ""
func teach(store:RefCounted,index:int,slot:int,location:Dictionary)->String:
 var error:String=learn_error(store.state,index)
 if error!="":return error
 if location.get("map_id","")!="celadon-mart-3f":return "请在玉虹百货3楼接受教学。"
 var pet:Dictionary=store.state["team"][index]
 if slot<0 or slot>pet["moves"].size() or slot>=4:return "已取消学习。"
 if slot<pet["moves"].size() and pet["moves"][slot] in store.growth.HM_MOVES:return "秘传招式不能在这里遗忘。"
 var before:Dictionary=store.state.duplicate(true)
 if not store.growth.resolve_learning(pet,"counter",slot):return "无法学习双倍奉还。"
 store.state["counter_taught"]=true
 store.state["location"]=location.duplicate(true)
 if not store.save_game():store.state=before;return store.error+" 学习已撤销，可以重试。"
 return ""
