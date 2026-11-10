extends RefCounted
## FR ITEM_TEA / FLAG_GOT_TEA mapped onto Red mansion Granny.
## Source has no Yes/No; the project adds confirmation/cancel.
func has_tea(state: Dictionary) -> bool:return state.get("mansion_tea",{}).get("tea",0)==1
func valid(state: Dictionary) -> bool:
 if not state.has("mansion_tea"):return true
 var story: Variant = state["mansion_tea"]
 if not story is Dictionary:return false
 for key in story:
  if key not in ["tea","received"]:return false
 if story.has("received") and not story["received"] is bool:return false
 var count: Variant = story.get("tea",0)
 if not (count is int or count is float) or (count!=0 and count!=1):return false
 return bool(story.get("received",false))==(count==1 or state.get("saffron_pass",false))
func claim(store: RefCounted,context: String) -> String:
 if context!="celadon-mansion-1f":return "请到玉虹公寓1F与老奶奶交谈。"
 if store.state.get("mansion_tea",{}).get("received",false):return ""
 if store.inventory.receive_error(store.state,"tea")!="":return "关键物品口袋已满。"
 var before: Dictionary = store.state.duplicate(true)
 store.state["mansion_tea"] = {"tea":1,"received":true}
 if not store.save_game():store.state = before;return store.error
 return ""
