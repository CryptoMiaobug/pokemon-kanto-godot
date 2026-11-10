extends RefCounted
## One registry for gym receipts, legacy claims and item display. Teaching stays separate.
var data:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://data/gym-tm-rewards.json"))["rewards"]
func item_row(item:String)->Dictionary:
	for row in data.values():
		if row["item"]==item:return row
	return {}
func claimed(s:Dictionary,id:String)->bool:return s.get("gym_tm_claims",{}).get(id,false)
func valid(s:Dictionary)->bool:
	if not s.has("gym_tm_claims"):return true
	if not s["gym_tm_claims"] is Dictionary:return false
	for id in s["gym_tm_claims"]:
		if not data.has(id) or not s["gym_tm_claims"][id] is bool:return false
		if claimed(s,id):
			if not s.get("trainers",{}) is Dictionary or not s.get("badges",{}) is Dictionary:return false
			if not s.get("trainers",{}).get(id,false) or not s.get("badges",{}).get(data[id]["badge"],false):return false
	return true
func grant(s:Dictionary,id:String,inventory:RefCounted)->String:
	if not data.has(id):return "未知道馆奖励。"
	if claimed(s,id):return "已经领取，不能重复获得。"
	if not s.get("trainers",{}).get(id,false) or not s.get("badges",{}).get(data[id]["badge"],false):return "需要已战胜馆主并持有对应徽章。"
	var error:String=inventory.receive_error(s,data[id]["item"])
	if error!="":return error
	inventory.add(s,data[id]["item"],1)
	if not s.has("gym_tm_claims"):s["gym_tm_claims"]={}
	s["gym_tm_claims"][id]=true
	return ""
func claim(store:RefCounted,id:String)->String:
	if not store.validate(store.state):return "存档数据无效，未领取。"
	var before:Dictionary=store.state.duplicate(true)
	var error:String=grant(store.state,id,store.inventory)
	if error!="":return error
	if not store.save_game():store.state=before;return store.error
	return ""
func description(item:String,teaching:RefCounted)->String:
	var row:Dictionary=item_row(item)
	return str(row["name"])+(" · 教学" if teaching.data.has(item) and teaching.data[item]["implemented"] else " · 教学未接入")
