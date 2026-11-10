extends RefCounted
## FireRed wild_encounter.c walking land path, no repel/flutes/items/abilities/roamers.
var table: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/encounters.json"))
var tables: Dictionary = {"route1":table,"route2":JSON.parse_string(FileAccess.get_file_as_string("res://data/encounters-route2.json")),"viridian-forest":JSON.parse_string(FileAccess.get_file_as_string("res://data/encounters-viridian-forest.json")),"route11":JSON.parse_string(FileAccess.get_file_as_string("res://data/encounters-route11.json")),"digletts-cave":JSON.parse_string(FileAccess.get_file_as_string("res://data/encounters-digletts-cave.json"))}
var safari: Dictionary = {}
func _init() -> void:
	for id in ["seafoam-islands-b4f","seafoam-islands-b2f","seafoam-islands-b3f","seafoam-islands-1f","seafoam-islands-b1f","route16","route17","route18","victory-road-3f","victory-road-1f","victory-road-2f","pokemon-mansion-2f","pokemon-mansion-1f","route15","route14","route13","route12","pokemon-tower-6f","pokemon-tower-5f","pokemon-tower-4f","pokemon-tower-3f","route7","route8","route10-south","rock-tunnel-1f","rock-tunnel-b1f","route9","route10-north","route6","route5","route25","route24","route3","route4-entrance","route4-east","mtmoon-1f","mtmoon-b1f","mtmoon-b2f"]:tables[id] = JSON.parse_string(FileAccess.get_file_as_string("res://data/encounters-%s.json" % id))
	for id in ["safari-zone-entry","safari-zone-east","safari-zone-north","safari-zone-west"]:safari[id] = JSON.parse_string(FileAccess.get_file_as_string("res://data/encounters-%s.json" % id))

var sea:Dictionary={"route19":JSON.parse_string(FileAccess.get_file_as_string("res://data/encounters-route19.json")),"route20":JSON.parse_string(FileAccess.get_file_as_string("res://data/encounters-route20.json"))}
var route21:Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/encounters-route21.json"))
var route23:Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/encounters-route23.json"))
var active_map: String = "route1"
var steps: int = 0
var buff: int = 0
var previous_grass: bool = false
func step(grass: bool, map: String = "route1", water: bool = false) -> Dictionary:
	# O13 map-only phase; no Route1 placeholder encounters.
	if map in ["cinnabar-lab","cinnabar-lab-fossil-room","route2-gate","route2-trade-house","route11-gate-1f","digletts-cave-route11","digletts-cave-route2"]:return {}
	if map!=active_map:
		active_map = map
		steps = 0
		buff = 0
		previous_grass = false
	table = (route23 if map=="route23" else route21)["water" if water else "land"] if map in ["route21","route23"] else tables.get(map,tables["route1"])
	if map in ["route11","digletts-cave"]:table=tables[map]
	if map in ["seafoam-islands-b3f","seafoam-islands-b4f"] and water:table=tables[map]["water"]
	if map in sea:
		table=sea[map]
		if not water:grass=false
	if map in safari:table=safari[map]
	if not grass:
		previous_grass = false
		return {}
	var cooldown: int = 8-floori(int(table["encounter_rate"])/10.0)
	var ready: bool = steps>=cooldown
	if not ready:
		steps += 1
		ready = randi()%100<5
	var previous: bool = previous_grass
	previous_grass = true
	if not ready:return {}
	if not previous and randi()%100>=60:return {}
	var rate: int = mini(1600,int(table["encounter_rate"])*16+floori(buff*16/200.0))
	if randi()%1600>=rate:
		buff = (buff+int(table["encounter_rate"]))%65536
		return {}
	steps = 0
	buff = 0
	var roll: int = randi()%100
	for slot in table["slots"]:
		roll -= int(slot["weight"])
		if roll<0:return {"species_id":slot["species_id"],"level":randi_range(int(slot["min_level"]),int(slot["max_level"]))}
	return {}
