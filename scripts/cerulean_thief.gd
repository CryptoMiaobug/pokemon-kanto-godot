extends RefCounted
const TRAINER := "cerulean_rocket_thief"
func released(state: Dictionary) -> bool:return state.get("bill",{}).get("stage","") in ["ticket","visited"] or state.has("stolen_tm")
func valid(state: Dictionary) -> bool:
	if not state.has("stolen_tm"):return true
	var v: Variant = state["stolen_tm"]
	if not v is Dictionary or v.size()!=2 or v.get("received") is not bool or v.get("received")!=true or not v.get("items") is Dictionary:return false
	var n: Variant = v["items"].get("tm28")
	return v["items"].size()==1 and (n is int or n is float) and not n is bool and (n==0 or n==1) and state.get("trainers",{}) is Dictionary and state["trainers"].get(TRAINER,false) is bool and state["trainers"].get(TRAINER,false)
func award(store: RefCounted) -> String:
	if not store.state.get("trainers",{}).get(TRAINER,false):return "先击败屋后的火箭队。"
	if store.state.has("stolen_tm"):return "TM28已经收回，不能重复领取。"
	var capacity:String=store.inventory.receive_error(store.state,"tm_dig")
	if capacity!="":return capacity
	var before: Dictionary = store.state.duplicate(true)
	store.state["stolen_tm"] = {"received":true,"items":{"tm28":1}}
	if not store.save_game():
		store.state = before
		return store.error+" TM28尚未领取，可以重试。"
	return ""
