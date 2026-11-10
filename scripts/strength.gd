extends RefCounted
var data:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://data/strength.json"))
func valid(s:Dictionary)->bool:
 if not s.has("warden"):return true
 var v:Variant=s["warden"]
 return v is Dictionary and v.size()==2 and v.get("delivered") is bool and v.get("claimed") is bool and (not v["claimed"] or v["delivered"]) and (not v["delivered"] or s.get("safari_rewards",{}).get("items",{}).get("gold_teeth",0)==0)
func has_hm(s:Dictionary)->bool:return s.get("warden",{}).get("claimed",false)
func action(s:Dictionary)->String:return "done" if has_hm(s) else "claim" if s.get("warden",{}).get("delivered",false) else "deliver"
func transact(store:RefCounted,context:String)->String:
 if context!="wardens-house":return "请到园长家交谈。"
 var a:String=action(store.state)
 if a=="done":return "HM04已经领取，不能重复获得。"
 if a=="deliver" and store.safari_rewards.quantity(store.state,"gold_teeth")!=1:return "园长没有金牙，暂时听不清他说什么。"
 if a=="claim" and store.safari_rewards.pocket_count(store.state,true)>=58:return "秘传口袋已满，HM04待领取。"
 var before:Dictionary=store.state.duplicate(true)
 if a=="deliver":
  store.state["safari_rewards"]["items"]["gold_teeth"]=0;store.state["warden"]={"delivered":true,"claimed":false}
 else:store.state["warden"]["claimed"]=true
 if not store.save_game():store.state=before;return store.error
 return ""
func learn_error(s:Dictionary,index:int)->String:
 if not has_hm(s):return "还没有HM04，请先找园长领取。"
 if index<0 or index>=s["team"].size():return "请选择队伍里的宝可梦。"
 var pet:Dictionary=s["team"][index]
 if pet["species_id"] not in data["compatible"]:return "这只宝可梦不能学习怪力。"
 if "strength" in pet["moves"]:return "已经学会怪力。"
 return ""
func teach(store:RefCounted,index:int,slot:int)->String:
 var error:String=learn_error(store.state,index)
 if error!="":return error
 var pet:Dictionary=store.state["team"][index]
 if slot<0 or slot>pet["moves"].size() or slot>=4:return "已取消学习。"
 if slot<pet["moves"].size() and pet["moves"][slot] in store.growth.HM_MOVES:return "秘传招式不能在这里遗忘。"
 var before:Dictionary=store.state.duplicate(true)
 if not store.growth.resolve_learning(pet,"strength",slot):return "无法学习怪力。"
 store.friendship.adjust(pet,"tmhm",store.state.get("location",{}).get("map_id",""))
 if not store.save_game():store.state=before;return store.error
 return ""
func field_error(s:Dictionary)->String:
 if not s.get("badges",{}).get("rainbow",false):return "需要彩虹徽章，才能推动石头。"
 for pet in s["team"]:
  if "strength" in pet["moves"]:return ""
 return "队伍中还没有学会怪力的宝可梦。"
