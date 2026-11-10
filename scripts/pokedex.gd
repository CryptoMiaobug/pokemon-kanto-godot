extends RefCounted
## FireRed GetPokedexCount(0): VAR_8006 = GetKantoPokedexCount(FLAG_GET_CAUGHT).
## Optional history; old saves prove only currently held species, never lost history.
const KANTO_COUNT := 151
const NATIONAL_COUNT := 386
func valid(state: Dictionary) -> bool:
	if not state.has("pokedex"):return true
	var dex: Variant = state["pokedex"]
	if not dex is Dictionary or dex.size()!=2:return false
	for field in ["seen","caught"]:
		if not dex.get(field) is Array:return false
		var unique: Array = []
		for num in dex[field]:
			if not (num is int or num is float) or not is_finite(float(num)) or float(num)!=floor(float(num)) or num<1 or num>NATIONAL_COUNT or int(num) in unique:return false
			unique.append(int(num))
	for num in dex["caught"]:
		if num not in dex["seen"]:return false
	return true
func number(species: Dictionary, id: String) -> int:
	return int(species.get(id,{}).get("num",0))
func held(state: Dictionary, species: Dictionary) -> Array:
	var result: Array = []
	var pets: Array = state.get("team",[]).duplicate()
	for box in state.get("storage",{}).get("boxes",[]):
		for pet in box:
			if pet is Dictionary:pets.append(pet)
	for pet in pets:
		var num: int = number(species,pet["species_id"])
		if num>0 and num<=NATIONAL_COUNT and num not in result:result.append(num)
	return result
func caught_numbers(state: Dictionary, species: Dictionary) -> Array:
	var result: Array = []
	for num in state.get("pokedex",{}).get("caught",[]):result.append(int(num))
	for num in held(state,species):
		if num not in result:result.append(num)
	return result
func kanto_caught(state: Dictionary, species: Dictionary) -> int:
	var count: int = 0
	for num in caught_numbers(state,species):
		if num>=1 and num<=KANTO_COUNT:count+=1
	return count
func register(state: Dictionary, species: Dictionary, id: String, owned: bool) -> void:
	var num: int = number(species,id)
	if num<1 or num>NATIONAL_COUNT:return
	if not state.has("pokedex"):
		var existing: Array = held(state,species)
		state["pokedex"]={"seen":existing.duplicate(),"caught":existing.duplicate()}
	# JSON loads numbers as floats: canonicalize before membership tests.
	for field in ["seen","caught"]:
		for i in range(state["pokedex"][field].size()):state["pokedex"][field][i]=int(state["pokedex"][field][i])
	if num not in state["pokedex"]["seen"]:state["pokedex"]["seen"].append(num)
	if owned and num not in state["pokedex"]["caught"]:state["pokedex"]["caught"].append(num)
