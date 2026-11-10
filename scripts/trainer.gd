extends RefCounted
## Shared data-driven trainer parties and atomic reward flags.
var gym_rewards=preload("res://scripts/gym_rewards.gd").new()
var sevii:Array=JSON.parse_string(FileAccess.get_file_as_string("res://data/sevii-trainers.json"))
var route16:Array=JSON.parse_string(FileAccess.get_file_as_string("res://data/route16-trainers.json"))
var o05:Array=JSON.parse_string(FileAccess.get_file_as_string("res://data/o05-trainers.json"))
var o04:Array=JSON.parse_string(FileAccess.get_file_as_string("res://data/o04-trainers.json"))
var route17:Array=JSON.parse_string(FileAccess.get_file_as_string("res://data/route17-trainers.json"))
var o12:Array=JSON.parse_string(FileAccess.get_file_as_string("res://data/o12-trainers.json"))
var o13:Array=JSON.parse_string(FileAccess.get_file_as_string("res://data/o13-trainers.json"))
var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/rival-route22.json"))
var forest: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/forest-trainers.json"))
var ship_rival: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/ssanne-rival.json"))
var north_rival: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/cerulean-north-rival.json"))
var thief: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/cerulean-thief.json"))
var ship_rooms: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/ssanne-room-trainers.json"))
var saffron_roads: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/saffron-roads-trainers.json"))
var pokemon_mansion: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/pokemon-mansion-trainers.json"))
var league: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/league-trainers.json"))
var victory: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/kanto51-52-trainers.json"))+JSON.parse_string(FileAccess.get_file_as_string("res://data/kanto53-trainers.json"))
var kanto_final: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/kanto45-46-trainers.json"))
var viridian: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/viridian-gym-trainers.json"))
var cinnabar: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/cinnabar-gym-trainers.json"))
var route21: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/route21-trainers.json"))
var fuchsia: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/fuchsia-trainers-21.json"))+JSON.parse_string(FileAccess.get_file_as_string("res://data/fuchsia-trainers-22.json"))+JSON.parse_string(FileAccess.get_file_as_string("res://data/fuchsia-trainers-24.json"))+JSON.parse_string(FileAccess.get_file_as_string("res://data/fuchsia-trainers-25.json"))
var silph: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/silph-trainers.json"))
var tower: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/tower-trainers.json"))
var post_b3: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/post-b3-trainers.json"))
var rocket_depth: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/rocket-b2-trainers.json"))+JSON.parse_string(FileAccess.get_file_as_string("res://data/rocket-b3-trainers.json"))
var rocket_entry: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/rocket-entry-trainers.json"))
var celadon: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/celadon-trainers.json"))
var route8: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/route8-trainers.json"))
var route10_south: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/route10-south-trainers.json"))
var rock: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/rock-tunnel-trainers.json"))
var roads: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/route9-trainers.json"))
var route6: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/route6-trainers.json"))
var route25: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/route25-trainers.json"))
var route24: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/route24-trainers.json"))
var vermilion: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/vermilion-trainers.json"))
var cerulean: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/cerulean-trainers.json"))
var pewter: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/pewter-trainers.json"))
var route3: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/route3-trainers.json"))
var mtmoon: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/mtmoon-trainers.json"))
var rockets: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/moon-rockets.json"))
var fossil_data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/moon-fossils.json"))
func definition(id: String) -> Dictionary:
	for entry in sevii:
		if entry["id"]==id:return entry
	if id==ship_rival["id"]:return ship_rival
	if id==north_rival["id"]:return north_rival
	if id==fossil_data["trainer"]["id"]:return fossil_data["trainer"]
	if id==data["id"]:return {"id":id,"name":"劲敌","title":"劲敌 · 22号道路首次对战","portrait":"res://assets/route22/trainer.png","reward":data["reward"],"defeat":"啊！你只是运气好！"}
	for entry in o13+route16+route17+o12+o04+o05+league+victory+kanto_final+viridian+cinnabar+pokemon_mansion+route21+fuchsia+saffron_roads+silph+tower+post_b3+rocket_depth+rocket_entry+celadon+route8+route10_south+rock+roads+forest+pewter+vermilion+thief+ship_rooms+route6+cerulean+route25+route24+route3+mtmoon+rockets:
		if entry["id"]==id:return entry
	assert(false,"Unknown trainer ID: "+id)
	return {}
const FAMILIES := {"bulbasaur":"bulbasaur","ivysaur":"bulbasaur","venusaur":"bulbasaur","charmander":"charmander","charmeleon":"charmander","charizard":"charmander","squirtle":"squirtle","wartortle":"squirtle","blastoise":"squirtle"}
func infer_starter(state: Dictionary) -> String:
	# The original first member is never reordered/removed by current game controls.
	# Never infer from current lead. Unknown legacy party uses documented Squirtle default.
	return FAMILIES.get(state["team"][0]["species_id"],"squirtle")
func party(store: RefCounted, id: String = "route22_early") -> Array:
	var row: Dictionary = definition(id)
	var entries: Array = row.get("party",[])
	if id=="league_champion":entries = row.get("teams",{}).get(store.state.get("starter",infer_starter(store.state)),[])
	if id==data["id"]:entries = data["teams"][data["rival_for"][store.state["starter"]]]
	if id==north_rival["id"]:entries = north_rival["teams"][north_rival["rival_for"][store.state["starter"]]]
	if id==ship_rival["id"]:entries = ship_rival["teams"][ship_rival["rival_for"][store.state["starter"]]]
	if id in ["route22_late","silph_rival","tower_rival"]:entries = definition(id)["teams"][definition(id)["rival_for"][store.state["starter"]]]
	var result: Array = []
	for entry in entries:
		var pet: Dictionary = store.create_individual(entry["species_id"],-1,int(entry["level"]),entry["moves"])
		for stat in store.growth.STATS:pet["ivs"][stat] = int(entry["ivs"])
		if entry.has("held_item"):pet["held_item"] = entry["held_item"]
		if entry.has("gender"):pet["gender"]=entry["gender"]
		pet["nature"] = entry["nature"].duplicate(true)
		pet["moves"] = entry["moves"].duplicate()
		pet["pp"] = {}
		for move in pet["moves"]:pet["pp"][move] = int(store.growth.moves[move]["pp"])
		pet["hp"] = int(store.growth.stats(pet)["hp"])
		result.append(pet)
	return result
func result_state(candidate: Dictionary, victory: bool, id: String = "route22_early") -> Dictionary:
	var entry: Dictionary = definition(id)
	var result: Dictionary = candidate.duplicate(true)
	if victory and not result.get("trainers",{}).get(id,false):
		result["money"] = mini(999999,int(result["money"])+int(entry["reward"]))
		result["trainers"][id] = true
		if entry.get("badge","")!="":
			if not result.has("badges"):result["badges"] = {}
			result["badges"][entry["badge"]] = true
		if id=="viridian_giovanni":
			for other in viridian:result["trainers"][other["id"]] = true
		if id=="fuchsia_koga":
			for other in fuchsia:
				if other["map"]=="fuchsia-gym":result["trainers"][other["id"]] = true
		if id=="celadon_erika":
			for other in celadon:result["trainers"][other["id"]] = true
		if id=="vermilion_surge":
			for other in vermilion:result["trainers"][other["id"]] = true
		if id.begins_with("cinnabar_"):
			var index: int = {"cinnabar_quinn":1,"cinnabar_avery":2,"cinnabar_ramon":3,"cinnabar_derek":4,"cinnabar_dusty":5,"cinnabar_zac":6}.get(id,0)
			if index>0:
				var flags: Array = result.get("cinnabar_quiz",[false,false,false,false,false,false]).duplicate()
				flags[index-1] = true;result["cinnabar_quiz"] = flags
			if id=="cinnabar_blaine":
				result["cinnabar_quiz"] = [true,true,true,true,true,true]
				for other in cinnabar:result["trainers"][other["id"]] = true
		if gym_rewards.data.has(id) and not gym_rewards.claimed(result,id):
			var inventory=preload("res://scripts/item_inventory.gd").new()
			var error:String=gym_rewards.grant(result,id,inventory)
			if error!="":return {}
	return result
