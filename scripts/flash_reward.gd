extends RefCounted
## FR Route2_EastBuilding: ten Kanto caught/owned species, HM05 + flag together.
const REQUIRED_CAUGHT := 10
func valid(state: Dictionary) -> bool:
	if not state.has("flash_reward"):return true
	var reward: Variant = state["flash_reward"]
	if not reward is Dictionary or reward.size()!=2 or not reward.get("claimed") is bool:return false
	var qty: Variant = reward.get("hm05")
	return (qty is int or qty is float) and not qty is bool and (qty==0 or qty==1) and (qty==0 or reward["claimed"])
func quantity(state: Dictionary) -> int:return int(state.get("flash_reward",{}).get("hm05",0))
func claimed(state: Dictionary) -> bool:return state.get("flash_reward",{}).get("claimed",false)
func claim(store: RefCounted, context: String) -> String:
	if context!="route2-gate":return "请到2号道路东侧关卡领取。"
	if not store.validate(store.state):return "存档数据无效，未领取。"
	if claimed(store.state):return "HM05已经领取过。"
	if store.pokedex.kanto_caught(store.state,store.species)<REQUIRED_CAUGHT:return "关都捕获或拥有种类不足10种，请继续收集。"
	var capacity: String = store.safari_rewards.capacity_error("hm05",store.safari_rewards.pocket_count(store.state,true))
	if capacity!="":return capacity
	var before: Dictionary = store.state.duplicate(true)
	store.state["flash_reward"]={"claimed":true,"hm05":1}
	if not store.save_game():
		store.state=before
		return store.error
	return ""
