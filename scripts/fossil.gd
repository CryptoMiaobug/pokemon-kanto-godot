extends RefCounted
const Language = preload("res://scripts/language.gd")
## Optional v3 event + held item are one mutually exclusive atomic payload.
const TRAINER := "mtmoonb2f_miguel"
const REVIVED := {"dome_fossil":"kabuto","helix_fossil":"omanyte"}
var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/moon-fossils.json"))
func valid(state: Dictionary) -> bool:
	if state.has("fossil_lab"):
		var lab: Variant = state["fossil_lab"]
		if not lab is Dictionary or lab.size()!=2 or lab.get("stage") not in ["reviving","ready","claimed"] or lab.get("item") not in ["dome_fossil","helix_fossil"]:return false
		if not state.has("moon_fossil"):return false
	if not state.has("moon_fossil"):return true
	var event: Variant = state["moon_fossil"]
	if not event is Dictionary or event.size()!=4 or event.get("complete")!=true:return false
	if not state.get("trainers",{}) is Dictionary:return false
	var choice: Variant = event.get("choice")
	if choice not in ["dome_fossil","helix_fossil"]:return false
	var other: String = "helix_fossil" if choice=="dome_fossil" else "dome_fossil"
	var delivered: bool = state.has("fossil_lab")
	if delivered and state["fossil_lab"]["item"]!=choice:return false
	var quantity: Variant = event.get("items",{}).get(choice) if event.get("items") is Dictionary else null
	return event.get("scientist")==other and event.get("items") is Dictionary and event["items"].size()==1 and (quantity is int or quantity is float) and quantity==(0 if delivered else 1) and state.get("trainers",{}).get(TRAINER,false)
func select(store: RefCounted, choice: String) -> String:
	if choice not in ["dome_fossil","helix_fossil"]:return "化石选择无效。"
	if not store.state.get("trainers",{}).get(TRAINER,false):return "先与化石学者对战；现在不能拿走化石。"
	if store.state.has("moon_fossil"):return "已经分好化石，不能重复领取。"
	var capacity:String=store.inventory.receive_error(store.state,choice)
	if capacity!="":return capacity
	var before: Dictionary = store.state.duplicate(true)
	store.state["moon_fossil"] = {"choice":choice,"scientist":"helix_fossil" if choice=="dome_fossil" else "dome_fossil","items":{choice:1},"complete":true}
	if not store.save_game():
		store.state = before
		return store.error+" 化石尚未领取，请重试。"
	return ""
# O15-2 uses the existing Moon event inventory; no Amber acquisition exists.
func available(state: Dictionary) -> Array[String]:
	var result: Array[String] = []
	if not valid(state) or state.has("fossil_lab"):return result
	var event: Dictionary = state.get("moon_fossil",{})
	for item in data["items"]:
		if event.get("items",{}).get(item["id"],0)==1:result.append(item["id"])
	return result
func deliver(store: RefCounted, choice: String, location: Dictionary) -> String:
	if not store.validate(store.state):return "存档数据无效，未交付。"
	if store.state.has("fossil_lab"):return "已经交付化石，不能重复提交。"
	if choice not in available(store.state):return "没有这块化石，未收取物品。"
	if location.get("map_id")!="cinnabar-lab-fossil-room":return "请在化石研究室交付。"
	var before: Dictionary = store.state.duplicate(true)
	store.state["moon_fossil"]["items"][choice] = 0
	store.state["fossil_lab"] = {"item":choice,"stage":"reviving"}
	store.state["location"] = location.duplicate(true)
	if not store.save_game():
		store.state = before
		return store.error+" 化石未交付，请重试。"
	return ""
func advance_on_entry(store: RefCounted, map_id: String, location: Dictionary) -> bool:
	if map_id!="cinnabar-lab" or not store.state.has("fossil_lab") or store.state["fossil_lab"].get("stage")!="reviving":return true
	var before: Dictionary = store.state.duplicate(true)
	store.state["fossil_lab"]["stage"]="ready"
	store.state["location"]=location.duplicate(true)
	if store.save_game():return true
	store.state=before
	return false
func claim(store: RefCounted, location: Dictionary) -> String:
	if not store.validate(store.state):return "存档数据无效，未领取。"
	if not store.state.has("fossil_lab") or store.state["fossil_lab"].get("stage")!="ready":return "没有可领取的复活宝可梦。"
	if location.get("map_id")!="cinnabar-lab-fossil-room":return "请在化石研究室领取。"
	if not store.state.has("storage"):return "存档数据无效，未领取。"
	if not store.can_receive_capture():return "队伍与全部盒子已满，复活宝可梦仍可领取。"
	var before: Dictionary=store.state.duplicate(true)
	var pet: Dictionary=store.create_individual(REVIVED[store.state["fossil_lab"]["item"]],-1,5)
	var destination: Dictionary=store.receive_capture(pet)
	if destination.has("error"):
		store.state=before
		return destination["error"]
	store.state["location"]=location.duplicate(true)
	var failure: String=mark_claimed(store)
	if failure!="":store.state=before
	return failure
func mark_claimed(store: RefCounted) -> String:
	# O15-4 calls this only after receiving the individual; one save commits both.
	if not store.state.has("fossil_lab") or store.state["fossil_lab"].get("stage")!="ready":return "没有可领取的复活宝可梦。"
	var before: Dictionary=store.state.duplicate(true)
	store.state["fossil_lab"]["stage"]="claimed"
	if not store.save_game():
		store.state=before
		return store.error+" 领取状态未改变。"
	return ""
func scientist_cell(state: Dictionary) -> Array:
	for item in data["items"]:
		if item["id"]==state.get("moon_fossil",{}).get("choice",""):return item["scientist_cell"]
	return data["trainer"]["cell"]
func summary(state: Dictionary) -> String:
	for item in data["items"]:
		if item["id"]==state.get("moon_fossil",{}).get("choice",""):
			if state.has("fossil_lab"):
				var stage:String=state["fossil_lab"].get("stage","")
				return Language.story("复活完成：%s · 可在研究室领取") % Language.name(item["name"]) if stage=="ready" else Language.story("已领取：%s · 不可重复领取") % Language.name(item["name"]) if stage=="claimed" else Language.story("研究所已收取：%s · 离开研究所后完成复活") % Language.name(item["name"])
			return Language.story("持有：%s ×1 · 另一块归学者") % Language.name(item["name"])
	return Language.story("持有化石：无")
