extends RefCounted
## FR pokemon.c sFriendshipEventDeltas. Missing old fields use base, never historical gains.
const DELTAS={"level":[5,3,2],"vitamin":[5,3,2],"battle_item":[1,1,0],"league":[3,2,1],"tmhm":[1,1,0],"walking":[1,1,1],"faint":[-1,-1,-1],"faint_large":[-5,-5,-10]}
var species:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://data/pets.json"))
func value(pet:Dictionary)->int:return int(pet.get("friendship",species[pet["species_id"]].get("base_friendship",70)))
func adjust(pet:Dictionary,event:String,section:String="")->void:
	var current:int=value(pet)
	var band:int=2 if current>=200 else 1 if current>=100 else 0
	var delta:int=DELTAS[event][band]
	if delta>0:
		if pet.get("held_item","")=="soothebell":delta=delta*150/100
		if pet.get("pokeball","")=="luxuryball":delta+=1
		if section!="" and pet.get("met_location","")==section:delta+=1
	pet["friendship"]=clampi(current+delta,0,255)
func step(state:Dictionary,section:String)->void:
	state["friendship_steps"]=(int(state.get("friendship_steps",0))+1)%128
	if int(state["friendship_steps"])!=0:return
	for pet in state["team"]:
		if randi()&1==0:adjust(pet,"walking",section)
