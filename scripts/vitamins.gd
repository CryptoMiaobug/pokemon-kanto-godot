extends RefCounted
## FireRed vitamin rules: +10 EV, per-stat cap 100 and total cap 510.
const ITEMS := ["hp_ups", "proteins", "irons", "calciums", "zincs", "carbos"]
const STATS := {"hp_ups":"hp", "proteins":"atk", "irons":"def", "calciums":"spa", "zincs":"spd", "carbos":"spe"}
func use(store:RefCounted, item:String, index:int, location:Dictionary)->String:
 if item not in ITEMS or index<0 or index>=store.state["team"].size():return "不能对这个目标使用。"
 if int(store.state.get(item,0))<=0:return "没有该营养药。"
 var pet:Dictionary=store.state["team"][index]
 var stat:String=STATS[item];var evs:Dictionary=pet.get("evs",store.growth.zeros())
 var total:int=0
 for key in store.growth.STATS:total+=int(evs.get(key,0))
 if int(evs.get(stat,0))>=100:return "该能力的培养上限已到100，未消耗。"
 if total>=510:return "努力值总上限已到510，未消耗。"
 var before:Dictionary=store.state.duplicate(true)
 var old_max:int=int(store.growth.stats(pet)["hp"])
 var gain:int=mini(10,mini(100-int(evs.get(stat,0)),510-total))
 evs[stat]=int(evs.get(stat,0))+gain;pet["evs"]=evs
 if int(pet["hp"])>0:pet["hp"]=int(pet["hp"])+int(store.growth.stats(pet)["hp"])-old_max
 store.friendship.adjust(pet,"vitamin",store.state.get("location",{}).get("map_id",""))
 store.state[item]=int(store.state[item])-1;store.state["location"]=location.duplicate(true)
 if not store.save_game():store.state=before;return store.error+" 营养药和培养值已撤销，可以重试。"
 return ""
