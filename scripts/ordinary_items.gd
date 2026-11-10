extends RefCounted
## FireRed item_effects.h: Rare Candy +1 level, no EV; Elixir handled by medicine.
const ITEMS=["rare_candies","escape_ropes"]
var evolution=preload("res://scripts/evolution.gd").new()
func escapable(mid:String)->bool:
 return mid.begins_with("diglett") or mid.begins_with("seafoam-") or mid.begins_with("mtmoon-") or mid.begins_with("rock-tunnel-") or mid.begins_with("pokemon-tower-") or mid.begins_with("pokemon-mansion-") or mid.begins_with("rocket-hideout-") or mid.begins_with("silph-co-") or mid.begins_with("victory-road-")
func candy_preview(store:RefCounted,index:int)->Dictionary:
 if index<0 or index>=store.state["team"].size() or int(store.state.get("rare_candies",0))<=0:return {}
 var pet:Dictionary=store.state["team"][index].duplicate(true)
 if int(pet["level"])>=100:return {}
 var old_max:int=store.growth.stats(pet)["hp"]
 pet["level"]=int(pet["level"])+1;pet["exp"]=store.growth.experience(pet["species_id"],int(pet["level"]))
 if int(pet["hp"])>0:pet["hp"]=int(pet["hp"])+int(store.growth.stats(pet)["hp"])-old_max
 store.friendship.adjust(pet,"level",store.state.get("location",{}).get("map_id",""))
 var learns:Array=[]
 for row in store.species[pet["species_id"]]["learnset"]:
  if int(row["level"])==int(pet["level"]) and row["move"] not in pet["moves"]:learns.append(row["move"])
 var evo:Array=evolution.candidates([pet],[{"kind":"level","index":0}],"victory",store.state)
 return {"pet":pet,"learns":learns,"evolution":evo[0] if not evo.is_empty() else {}}
func commit_candy(store:RefCounted,index:int,preview:Dictionary)->String:
 if preview.is_empty() or index<0 or index>=store.state["team"].size():return "不能使用神奇糖果。"
 var original:Dictionary=store.state["team"][index]
 if int(store.state.get("rare_candies",0))<=0 or preview["pet"]["individual_id"]!=original["individual_id"] or int(preview["pet"]["level"])!=int(original["level"])+1:return "目标已改变，未消耗。"
 var before:Dictionary=store.state.duplicate(true)
 store.state["team"][index]=preview["pet"].duplicate(true);store.state["rare_candies"]-=1
 store.pokedex.register(store.state,store.species,preview["pet"]["species_id"],true)
 if not store.save_game():store.state=before;return store.error
 return ""
func rope(store:RefCounted,mid:String)->String:
 if not escapable(mid):return "这里不能使用离洞绳。"
 if int(store.state.get("ground_inventory",{}).get("escape_ropes",0))<=0:return "没有离洞绳。"
 if not store.state.has("escape_return"):return "尚未记录这处设施的进入位置，请从正常入口进入后使用。"
 var before:Dictionary=store.state.duplicate(true)
 store.state["ground_inventory"]["escape_ropes"]-=1
 store.state["location"]=store.state["escape_return"].duplicate(true)
 store.state["surfing"]=false
 if not store.save_game():store.state=before;return store.error
 return ""
