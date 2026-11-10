extends RefCounted
## Red event order, resumable committed stages; no unrelated city or ship flags.
const STAGES := ["waiting","machine","restored","ticket","visited"]
func stage(state: Dictionary) -> String:return state.get("bill",{}).get("stage","waiting")
func valid(state: Dictionary) -> bool:
	if not state.has("bill"):return true
	var v: Variant = state["bill"]
	if not v is Dictionary or v.size()!=2 or v.get("stage") not in STAGES or not v.get("items") is Dictionary:return false
	if v["stage"] in ["ticket","visited"]:return v["items"].size()==1 and (v["items"].get("ss_ticket") is int or v["items"].get("ss_ticket") is float) and not v["items"].get("ss_ticket") is bool and v["items"].get("ss_ticket")==1
	return v["items"].is_empty()
func advance(store: RefCounted,action: String) -> String:
	var current: String = stage(store.state)
	var next: String = {"help":"machine","computer":"restored","ticket":"ticket","leave":"visited"}.get(action,"")
	var required: String = {"help":"waiting","computer":"machine","ticket":"restored","leave":"ticket"}.get(action,"")
	if next=="" or current!=required:return "现在不能这样操作，剧情进度未变更。"
	if action=="ticket" and store.inventory.receive_error(store.state,"ss_ticket")!="":return "关键物品口袋已满。"
	var before: Dictionary = store.state.duplicate(true)
	store.state["bill"] = {"stage":next,"items":{"ss_ticket":1} if next in ["ticket","visited"] else {}}
	if not store.save_game():
		store.state = before
		return store.error+" 正辉事件尚未推进，可以重试。"
	return ""
func actor(state: Dictionary) -> Dictionary:
	match stage(state):
		"waiting":return {"cell":[6,5],"sprite":"monster"}
		"machine":return {}
		"visited":return {"cell":[6,5],"sprite":"human"}
		_:return {"cell":[4,4],"sprite":"human"}
