extends RefCounted
## FireRed 7e3f822: pokemon_storage_system.h, pokemon.c, storage data/tasks.
const BOXES := 14
const SLOTS := 30
func empty() -> Dictionary:
	var boxes: Array = []
	for _b in range(BOXES):
		var slots: Array = []
		slots.resize(SLOTS)
		boxes.append(slots)
	return {"current_box":0,"send_box":0,"boxes":boxes}

func first_space(state: Dictionary) -> Dictionary:
	var storage: Dictionary = state["storage"]
	# Original SendMonToPC starts at StorageGetCurrentBox, wraps, and keeps slot order.
	for offset in range(BOXES):
		var box: int = (int(storage["current_box"])+offset)%BOXES
		for slot in range(SLOTS):
			if storage["boxes"][box][slot]==null:return {"box":box,"slot":slot}
	return {}

func restored(store, pet: Dictionary) -> Dictionary:
	# BoxPokemon has no HP/status. Normalize those here; original conversion heals on withdrawal.
	var result: Dictionary = pet.duplicate(true)
	result["hp"] = int(store.growth.stats(result)["hp"])
	for move in result["moves"]:result["pp"][move] = int(store.growth.moves[move]["pp"])
	for field in ["status","status1","primary_status"]:
		if result.has(field):result[field] = "" if result[field] is String else 0
	for field in ["sleep_turns","toxic_counter","status_turns"]:
		if result.has(field):result[field] = 0
	return result

func receive(store, pet: Dictionary) -> Dictionary:
	if store.state["team"].size()<6:
		store.state["team"].append(pet.duplicate(true))
		return {"destination":"party"}
	var space: Dictionary = first_space(store.state)
	if space.is_empty():return {"error":"队伍与全部盒子已满。"}
	store.state["storage"]["boxes"][space["box"]][space["slot"]] = restored(store,pet)
	store.state["storage"]["send_box"] = space["box"]
	return {"destination":"box","box":space["box"],"slot":space["slot"]}

func apply(store, action: String, box: int, slot: int, party: int) -> String:
	if not store.validate(store.state) or not store.state.has("storage"):return "存档数据无效，未操作。"
	if box<0 or box>=BOXES:return "盒子无效。"
	if action=="select":
		if int(store.state["storage"]["current_box"])!=box:store.state["storage"]["send_box"] = box
		store.state["storage"]["current_box"] = box
		return ""
	if slot<0 or slot>=SLOTS:return "位置无效。"
	var team: Array = store.state["team"]
	var slots: Array = store.state["storage"]["boxes"][box]
	if action=="withdraw":
		if slots[slot]==null:return "这个位置是空的。"
		if team.size()>=6:return "队伍已有6只，请先寄存或选择交换。"
		team.append(restored(store,slots[slot]))
		slots[slot] = null
	elif action in ["deposit","exchange"]:
		if party<0 or party>=team.size():return "请选择队伍成员。"
		if action=="deposit":
			if team.size()<=1:return "最后一只伙伴不能寄存。"
			if slots[slot]!=null:return "此位置已有伙伴，请选择交换。"
			# Like the original PC, keep a usable party member outside the box.
			var usable: int = 0
			for i in range(team.size()):
				if i!=party and int(team[i]["hp"])>0:usable+=1
			if usable==0:return "请保留一只能够战斗的伙伴。"
			slots[slot] = restored(store,team[party])
			team.remove_at(party)
			var lead: int = int(store.state["lead"])
			store.state["lead"] = maxi(0,lead-1) if party<=lead else lead
		else:
			if slots[slot]==null:return "交换需要选择盒内伙伴。"
			var outgoing: Dictionary = restored(store,team[party])
			team[party] = restored(store,slots[slot])
			slots[slot] = outgoing
	else:return "未知操作。"
	return ""
