extends RefCounted
## O12 shared one-time dojo reward; all mutations are rolled back on capacity or save failure.
var trainers: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/o12-trainers.json"))
func claim(store: RefCounted, species_id: String) -> String:
	if species_id not in ["hitmonlee", "hitmonchan"]: return "无效的道场奖赏。"
	if store.state.get("trainers", {}).get("o12_koichi", false) == false: return "请先击败道场馆主。"
	if store.state.get("dojo_story", {}).get("gift_received", false): return "已经领取过道场奖赏。"
	if not store.can_receive_capture(): return "队伍与全部盒子已满，奖赏仍保留在这里。"
	var before: Dictionary = store.state.duplicate(true)
	var pet: Dictionary = store.create_individual(species_id, -1, 25)
	pet["moves"] = store.growth.level_moves(species_id, 25)
	pet["pp"] = {}
	for move in pet["moves"]: pet["pp"][move] = int(store.growth.moves[move]["pp"])
	var destination: Dictionary = store.receive_capture(pet)
	if destination.has("error"):
		store.state = before
		return destination["error"]
	if not store.state.has("dojo_story"): store.state["dojo_story"] = {}
	store.state["dojo_story"]["gift_received"] = true
	if not store.save_game():
		store.state = before
		return store.error
	return ""
