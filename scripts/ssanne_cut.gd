extends RefCounted
## Source FR captain/HM and Red temporary Cut block; no departure or gym battle.
var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/ssanne-cut.json"))
# Generated from each imported map's own tileset cut definition; grass excluded.
var tree_registry: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/cut-trees.json"))
func trees(map: String) -> Array:
	var result: Array = []
	for tree in tree_registry:
		if tree["map"]==map:result.append(tree)
	return result
func has_trees(map: String) -> bool:
	for tree in tree_registry:
		if tree["map"]==map:return true
	return false
func valid(state: Dictionary) -> bool:
	if not state.has("captain"):return true
	var v: Variant = state["captain"]
	return v is Dictionary and v.size()==2 and v.get("received") is bool and v.get("received")==true and v.get("items") is Dictionary and v["items"].size()==1 and (v["items"].get("hm01") is int or v["items"].get("hm01") is float) and not v["items"].get("hm01") is bool and v["items"].get("hm01")==1 and state.get("trainers",{}) is Dictionary and state.get("trainers",{}).get("ssanne_rival",false)==true
func has_hm(state: Dictionary) -> bool:return state.get("captain",{}).get("items",{}).get("hm01",0)==1
func claim(store: RefCounted) -> String:
	if not store.state.get("trainers",{}).get("ssanne_rival",false):return "先完成二层走廊劲敌战。"
	if has_hm(store.state):return "HM01已经领取，不能重复领取。"
	var capacity:String=store.inventory.receive_error(store.state,"hm01")
	if capacity!="":return capacity
	var before: Dictionary = store.state.duplicate(true)
	store.state["captain"] = {"received":true,"items":{"hm01":1}}
	if not store.save_game():
		store.state = before
		return store.error+" HM01尚未领取，可以重试。"
	return ""
func learn_error(state: Dictionary,index: int) -> String:
	if not has_hm(state):return "还没有HM01，请先找船长领取。"
	if index<0 or index>=state["team"].size():return "请选择队伍里的宝可梦。"
	var pet: Dictionary = state["team"][index]
	if pet["species_id"] not in data["compatible"]:return "这只宝可梦不能学习居合斩。"
	if "cut" in pet["moves"]:return "这只宝可梦已经学会居合斩。"
	return ""
func teach(store: RefCounted,index: int,slot: int) -> String:
	var error: String = learn_error(store.state,index)
	if error!="":return error
	var pet: Dictionary = store.state["team"][index]
	if slot<0 or slot>pet["moves"].size() or slot>=4:return "已取消学习，招式未变更。"
	if pet["moves"].size()==4 and pet["moves"][slot] in store.growth.HM_MOVES:return "秘传招式不能在这里遗忘。"
	var before: Dictionary = store.state.duplicate(true)
	if not store.growth.resolve_learning(pet,"cut",slot):return "无法学习居合斩，招式未变更。"
	store.friendship.adjust(pet,"tmhm",store.state.get("location",{}).get("map_id",""))
	if not store.save_game():
		store.state = before
		return store.error+" 学习已撤销，可以重试。"
	return ""
func cutter(state: Dictionary) -> int:
	for i in range(state["team"].size()):
		if "cut" in state["team"][i]["moves"]:return i
	return -1
func field_error(state: Dictionary,tree_present: bool) -> String:
	if not tree_present:return "面前没有本轮可砍的树。"
	if not state.get("badges",{}).get("cascade",false):return "需要蓝色徽章，才能在场外使用居合斩。"
	if cutter(state)<0:return "队伍中还没有学会居合斩的宝可梦。"
	return ""
