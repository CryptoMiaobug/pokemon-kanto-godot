extends RefCounted
## FireRed species_info, experience_tables, level_up_learnsets; no trade/item bonuses.
var friendship=preload("res://scripts/friendship.gd").new()
var species: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/pets.json"))
var moves: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/moves.json"))
# FireRed HM01–07; Dive has no normal FireRed HM acquisition.
const HM_MOVES = ["cut","fly","surf","strength","flash","rocksmash","waterfall"]
const STATS = ["hp","atk","def","spe","spa","spd"]
func zeros() -> Dictionary:
	return {"hp":0,"atk":0,"def":0,"spe":0,"spa":0,"spd":0}
func experience(id: String, level: int) -> int:
	if level<=1:return 1
	var cube: int = level*level*level
	if species[id]["growth"]=="MEDIUM_SLOW":return maxi(0,floori(6.0*cube/5)-15*level*level+100*level-140)
	return cube
func stats(pet: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for stat in STATS:
		var value: int = floori((2*int(species[pet["species_id"]]["base_stats"][stat])+int(pet.get("ivs",zeros())[stat])+floori(int(pet.get("evs",zeros())[stat])/4.0))*int(pet["level"])/100.0)
		result[stat] = value+int(pet["level"])+10 if stat=="hp" else value+5
	# Persisted nature uses stat names; neutral default Hardy.
	var nature: Dictionary = pet.get("nature",{"up":"","down":""})
	if nature["up"]!=nature["down"]:
		if result.has(nature["up"]):result[nature["up"]] = floori(result[nature["up"]]*1.1)
		if result.has(nature["down"]):result[nature["down"]] = floori(result[nature["down"]]*0.9)
	return result
func level_moves(id: String, level: int) -> Array:
	var known: Array = []
	for entry in species[id]["learnset"]:
		if int(entry["level"])<=level and entry["move"] not in known:
			known.append(entry["move"])
			if known.size()>4:known.pop_front()
	return known
func resolve_learning(pet: Dictionary, move: String, slot: int) -> bool:
	if move in pet["moves"]:return false
	if slot<0:return false
	if pet["moves"].size()<4:pet["moves"].append(move)
	elif slot<4:
		if pet["moves"][slot] in HM_MOVES:return false
		pet["pp"].erase(pet["moves"][slot])
		pet["moves"][slot] = move
	else:return false
	pet["pp"][move] = int(moves[move]["pp"])
	return true
func award(party: Array, participants: Array, enemy: Dictionary, outcome: String, trainer: bool = false, section:String="") -> Array:
	var events: Array = []
	if outcome!="victory":return events
	var eligible: Array = []
	for index in participants:
		if int(party[index]["hp"])>0 and index not in eligible:eligible.append(index)
	if eligible.is_empty():return events
	var amount: int = maxi(1,floori(floori(int(species[enemy["species_id"]]["exp_yield"])*int(enemy["level"])/7.0)/eligible.size()))
	if trainer:amount = floori(amount*150.0/100.0)
	for index in eligible:
		var pet: Dictionary = party[index]
		if int(pet["level"])>=100:continue
		var before: int = stats(pet)["hp"]
		var total: int = 0
		for stat in STATS:total += int(pet["evs"][stat])
		for stat in STATS:
			var gain: int = mini(int(species[enemy["species_id"]]["ev_yield"][stat]),mini(255-int(pet["evs"][stat]),510-total))
			pet["evs"][stat] = int(pet["evs"][stat])+gain
			total += gain
		pet["exp"] = mini(experience(pet["species_id"],100),int(pet["exp"])+amount)
		events.append({"kind":"xp","index":index,"amount":amount})
		while int(pet["level"])<100 and int(pet["exp"])>=experience(pet["species_id"],int(pet["level"])+1):
			pet["level"] = int(pet["level"])+1
			friendship.adjust(pet,"level",section)
			events.append({"kind":"level","index":index,"level":pet["level"]})
			for entry in species[pet["species_id"]]["learnset"]:
				if int(entry["level"])==int(pet["level"]) and entry["move"] not in pet["moves"]:
					events.append({"kind":"learn","index":index,"move":entry["move"]})
		if int(pet["hp"])>0:pet["hp"] = int(pet["hp"])+int(stats(pet)["hp"])-before
	return events
