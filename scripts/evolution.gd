extends RefCounted
## FR battle_main.c: won-battle level bitmap; one evolution per member. RTC branches disabled.
var growth=preload("res://scripts/growth.gd").new()
var friendship=preload("res://scripts/friendship.gd").new()
var data:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://data/evolutions.json"))["rules"]
func allowed(pet:Dictionary,target:String,state:Dictionary)->bool:
	return pet.get("held_item","")!="everstone" and (int(growth.species[target]["num"])<=151 or state.get("national_dex",false))
func candidates(party:Array,events:Array,outcome:String,state:Dictionary={})->Array:
	var result:Array=[]
	if outcome!="victory":return result
	for index in party.size():
		if not events.any(func(e):return e["kind"]=="level" and int(e["index"])==index):continue
		var pet:Dictionary=party[index]
		for row in data.get(pet["species_id"],[]):
			if row["method"]=="EVO_LEVEL" and int(pet["level"])>=int(row["param"]) or row["method"]=="EVO_FRIENDSHIP" and friendship.value(pet)>=220:
				if allowed(pet,row["target"],state):result.append({"index":index,"individual_id":pet["individual_id"],"from":pet["species_id"],"target":row["target"]})
				break
	return result
func change_species(pet:Dictionary,target:String)->void:
	var old_max:int=growth.stats(pet)["hp"]
	pet["species_id"]=target
	if int(pet["hp"])>0:pet["hp"]=int(pet["hp"])+int(growth.stats(pet)["hp"])-old_max
func apply(pet:Dictionary,entry:Dictionary,state:Dictionary={})->Array:
	if pet["individual_id"]!=entry["individual_id"] or pet["species_id"]!=entry["from"]:return []
	var valid:Array=candidates([pet],[{"kind":"level","index":0}],"victory",state)
	if valid.is_empty() or valid[0]["target"]!=entry["target"]:return []
	change_species(pet,entry["target"])
	return learning(pet,int(entry["index"]))
func learning(pet:Dictionary,index:int)->Array:
	var result:Array=[]
	for move in growth.species[pet["species_id"]]["learnset"]:
		if int(move["level"])==int(pet["level"]) and move["move"] not in pet["moves"]:result.append({"kind":"learn","index":index,"move":move["move"]})
	return result
