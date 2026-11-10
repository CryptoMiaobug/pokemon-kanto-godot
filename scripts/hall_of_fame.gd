extends RefCounted
## Slice 61: first Hall of Fame registration after the Champion.
## FireRed 7e3f822: PokemonLeague_HallOfFame/scripts.inc (Oak, EventScript_SetDefeatedEliteFourFlagsVars,
## setrespawn HEAL_LOCATION_PALLET_TOWN, special EnterHallOfFame), src/post_battle_event_funcs.c
## (HealPlayerParty, FLAG_SYS_GAME_CLEAR once, continue warp Pallet), src/hall_of_fame.c
## (Task_Hof_InitMonData species/level/tid/personality snapshot, HALL_OF_FAME_MAX_TEAMS 50, oldest dropped).
## Red ee2a8ccb kanto6_ending.js continuePositionAfterHallOfFame: Pallet Town fly spot (5,6).
## individual_id stands in for tid+personality. No money is paid here; the Champion reward was settled in slice 60.
const MAX_TEAMS := 50
const MAP := "hall-of-fame"
const CONTINUE := {"map_id": "pallet-town", "x": 88, "y": 105}
const LEAGUE_IDS := ["league_lorelei", "league_bruno", "league_agatha", "league_lance", "league_champion"]

func valid(s: Dictionary) -> bool:
	if not s.has("hall_of_fame"):
		return true
	var v: Variant = s["hall_of_fame"]
	if not v is Dictionary or v.size() != 2 or not v.get("game_clear") is bool or not v.get("teams") is Array:
		return false
	if v["teams"].size() > MAX_TEAMS or (v["game_clear"] != (v["teams"].size() > 0)):
		return false
	for team in v["teams"]:
		if not team is Array or team.size() < 1 or team.size() > 6:
			return false
		var ids: Array = []
		for mon in team:
			if not mon is Dictionary or mon.size() != 3 or not mon.get("individual_id") is String or not mon.get("species_id") is String:
				return false
			if mon["individual_id"] in ids or mon["individual_id"].length() < 8 or mon["species_id"] == "":
				return false
			var level: Variant = mon.get("level")
			if not (level is int or level is float) or float(level) != floor(float(level)) or level < 1 or level > 100:
				return false
			ids.append(mon["individual_id"])
	return true

func cleared(s: Dictionary) -> bool:
	return s.get("hall_of_fame", {}).get("game_clear", false)

func teams(s: Dictionary) -> Array:
	return s.get("hall_of_fame", {}).get("teams", [])

## Champion beaten in the current run and not yet registered (stage 5 only exists until registration).
func pending(s: Dictionary) -> bool:
	var league: Dictionary = s.get("league", {})
	return league.get("active", false) and int(league.get("stage", 0)) == 5 and s.get("trainers", {}).get("league_champion", false)

func snapshot(s: Dictionary) -> Array:
	var team: Array = []
	for pet in s["team"]:
		team.append({"individual_id": pet["individual_id"], "species_id": pet["species_id"], "level": int(pet["level"])})
	return team

## One atomic commit: heal, snapshot, game clear, E4 reset, Pallet continue position. Returns "" or a refusal.
func register(store: RefCounted) -> String:
	if not pending(store.state):
		return "名人堂已经登记，不能重复登记。" if cleared(store.state) else "尚未击败冠军，不能登记名人堂。"
	var before: Dictionary = store.state.duplicate(true)
	store.heal_party()
	var record: Dictionary = store.state.get("hall_of_fame", {"game_clear": false, "teams": []}).duplicate(true)
	record["teams"].append(snapshot(store.state))
	while record["teams"].size() > MAX_TEAMS:
		record["teams"].pop_front()
	record["game_clear"] = true
	store.state["hall_of_fame"] = record
	store.state["league"] = {"active": false, "stage": 0}
	for id in LEAGUE_IDS:
		store.state["trainers"].erase(id)
	store.state["surfing"] = false
	store.state["location"] = CONTINUE.duplicate(true)
	if not store.save_game():
		store.state = before
		return store.error + " 名人堂未登记，进度保持冠军胜利后。"
	return ""
