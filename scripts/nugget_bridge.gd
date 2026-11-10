extends RefCounted
## Optional v3 held Nugget is saved before invitation/battle, never converted to money.
const FIVE := ["route24_cale","route24_ali","route24_timmy","route24_reli","route24_ethan"]
func ready(state: Dictionary) -> bool:
	if not state.get("trainers",{}) is Dictionary:return false
	for id in FIVE:
		if not state.get("trainers",{}).get(id,false):return false
	return true
func valid(state: Dictionary) -> bool:
	if not state.has("nugget_bridge"):return true
	var v: Variant = state["nugget_bridge"]
	return v is Dictionary and v.size()==2 and v.get("received") is bool and v.get("received")==true and v.get("items") is Dictionary and v["items"].size()==1 and (v["items"].get("nugget")==1 or v["items"].get("nugget")==0) and ready(state)
func award(store: RefCounted) -> String:
	if not ready(store.state):return "先打败金珠桥的五名训练家。"
	if store.state.has("nugget_bridge"):return "金珠已经领取，不能重复领取。"
	var capacity:String=store.inventory.receive_error(store.state,"nuggets")
	if capacity!="":return capacity
	var before: Dictionary = store.state.duplicate(true)
	store.state["nugget_bridge"] = {"received":true,"items":{"nugget":1}}
	if not store.save_game():
		store.state = before
		return store.error+" 金珠尚未领取，可重试。"
	return ""
