extends RefCounted
## Red geometry/landings, FireRed HM02/Thunder Badge and voucher/bicycle rules.
var data:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://data/fly.json"))
const NEW_MAPS=["celadon-mart-3f","celadon-mart-4f","celadon-mart-5f","celadon-mart-roof","celadon-mart-elevator","cinnabar-lab","cinnabar-lab-fossil-room","route2-gate","route2-trade-house","route11","route11-gate-1f","digletts-cave-route11","digletts-cave","digletts-cave-route2","fighting-dojo","seafoam-islands-b4f","seafoam-islands-b2f","seafoam-islands-b3f","seafoam-islands-1f","seafoam-islands-b1f","route19","route20","route16","route16-gate-1f","route16-gate-2f","route16-fly-house","bike-shop","pokemon-fan-club","route17","route18","route18-gate-1f","route18-gate-2f","route5-gate","route6-gate","route8-gate"]
const OUTDOORS=["route11","route19","route20","pallet-town","viridian-city","pewter-city","cerulean-city","lavender-town","vermilion-city","celadon-city","fuchsia-city","cinnabar-island","indigo-plateau","saffron-city","route1","route2","route3","route4-entrance","route4-east","route5","route6","route7","route8","route9","route10-north","route10-south","route12","route13","route14","route15","route16","route17","route18","route21","route22","route23","route24","route25"]
const HM_MOVES=["cut","fly","surf","strength"]
func valid(s:Dictionary)->bool:
 if not s.has("travel"):return true
 var d:Variant=s["travel"]
 if not d is Dictionary or d.size()!=5 or not d.get("hm02") is bool or not d.get("voucher_claimed") is bool or not d.get("bicycle") is bool or not d.get("visited") is Array:return false
 if not (d.get("voucher") is int or d.get("voucher") is float) or d.get("voucher") is bool or (d["voucher"]!=0 and d["voucher"]!=1):return false
 if d["bicycle"] and (not d["voucher_claimed"] or d["voucher"]!=0):return false
 if d["voucher"]==1 and not d["voucher_claimed"]:return false
 if d["voucher_claimed"] and not d["bicycle"] and d["voucher"]!=1:return false
 var seen:Array=[]
 for mid in d["visited"]:
  if not mid is String or destination(mid).is_empty() or mid in seen:return false
  seen.append(mid)
 return true
func ensure(s:Dictionary)->void:
 if not s.has("travel"):s["travel"]={"hm02":false,"voucher_claimed":false,"voucher":0,"bicycle":false,"visited":[]}
func destination(mid:String)->Dictionary:
 for d in data["destinations"]:
  if d["map"]==mid:return d
 return {}
func visit(s:Dictionary,mid:String)->void:
 if destination(mid).is_empty():return
 ensure(s)
 if mid not in s["travel"]["visited"]:s["travel"]["visited"].append(mid)
func has_hm(s:Dictionary)->bool:return s.get("travel",{}).get("hm02",false)
func bicycle(s:Dictionary)->bool:return s.get("travel",{}).get("bicycle",false)
func transaction(store:RefCounted,action:String,context:String)->String:
 var d:Dictionary=store.state.get("travel",{})
 if action=="hm02":
  if context!="route16-fly-house":return "请到16号道路小屋领取。"
  if has_hm(store.state):return "HM02已经领取。"
  if store.safari_rewards.pocket_count(store.state,true)>=58:return "招式口袋已满，请整理后再来。"
 elif action=="voucher":
  if context!="pokemon-fan-club":return "请到枯叶市宝可梦迷俱乐部听会长的故事。"
  if d.get("voucher_claimed",false):return "兑换券已经领取，不能重复领取。"
  if store.safari_rewards.pocket_count(store.state,false)>=30:return "关键物品口袋已满，请整理后再来。"
 elif action=="bicycle":
  if context!="bike-shop":return "请到华蓝市车店兑换。"
  if bicycle(store.state):return "已经获得自行车，不能重复兑换。"
  if d.get("voucher",0)!=1:return "自行车售价100万元，你买不起。需要自行车兑换券。"
 else:return "无此操作。"
 var before:Dictionary=store.state.duplicate(true);ensure(store.state)
 match action:
  "hm02":store.state["travel"]["hm02"]=true
  "voucher":store.state["travel"]["voucher_claimed"]=true;store.state["travel"]["voucher"]=1
  "bicycle":store.state["travel"]["voucher"]=0;store.state["travel"]["bicycle"]=true
 if not store.save_game():store.state=before;return store.error
 return ""
func learn_error(s:Dictionary,index:int)->String:
 if not has_hm(s):return "还没有HM02，请到16号道路小屋领取。"
 if index<0 or index>=s["team"].size():return "请选择队伍里的宝可梦。"
 var pet:Dictionary=s["team"][index]
 if pet["species_id"] not in data["compatible"]:return "这只宝可梦不能学习飞翔。"
 if "fly" in pet["moves"]:return "这只宝可梦已经学会飞翔。"
 return ""
func teach(store:RefCounted,index:int,slot:int)->String:
 var failure:String=learn_error(store.state,index)
 if failure!="":return failure
 var pet:Dictionary=store.state["team"][index]
 if slot<0 or slot>pet["moves"].size() or slot>=4:return "已取消学习。"
 if slot<pet["moves"].size() and pet["moves"][slot] in store.growth.HM_MOVES:return "秘传招式不能在这里遗忘。"
 var before:Dictionary=store.state.duplicate(true)
 if not store.growth.resolve_learning(pet,"fly",slot):return "无法学习飞翔。"
 store.friendship.adjust(pet,"tmhm",store.state.get("location",{}).get("map_id",""))
 if not store.save_game():store.state=before;return store.error
 return ""
func field_error(s:Dictionary,mid:String)->String:
 if mid not in OUTDOORS:return "这里不能使用飞翔。"
 if not s.get("badges",{}).get("thunder",false):return "需要雷电徽章才能在场外使用飞翔。"
 for pet in s["team"]:
  if "fly" in pet["moves"]:return ""
 return "队伍里没有学会飞翔的宝可梦。"
func fly_to(store:RefCounted,mid:String,target:String)->String:
 var failure:String=field_error(store.state,mid)
 if failure!="":return failure
 var dest:Dictionary=destination(target)
 if dest.is_empty() or target not in store.state.get("travel",{}).get("visited",[]):return "尚未到达这个城镇。"
 var before:Dictionary=store.state.duplicate(true)
 store.state["location"]={"map_id":target,"x":int(dest["cell"][0])*16+8,"y":int(dest["cell"][1])*16+9}
 store.state["surfing"]=false
 if not store.save_game():store.state=before;return store.error
 return ""
func ride_error(s:Dictionary,mid:String)->String:
 if not bicycle(s):return "还没有自行车，请持兑换券到华蓝市车店兑换。"
 if mid not in OUTDOORS or s.get("surfing",false):return "这里不能骑自行车。"
 return ""
func cycling(mid:String,pos:Vector2)->bool:return mid=="route17" or mid=="route18" and pos.x<34*16 or mid=="route16" and pos.x<18*16 and pos.y>=8*16
func gate_blocks(s:Dictionary,mid:String,cell:Vector2i)->bool:return cell.x==4 and not bicycle(s) and (mid=="route16-gate-1f" and cell.y in [7,8,9,10] or mid=="route18-gate-1f" and cell.y in [3,4,5,6])
