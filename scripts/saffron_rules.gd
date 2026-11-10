extends RefCounted
## FR shared four-gate scene variable; other three gates remain deferred.
func opened(s: Dictionary) -> bool:return s.get("saffron_pass",false)
func valid(s: Dictionary) -> bool:
 if s.has("saffron_pass") and not s["saffron_pass"] is bool:return false
 if opened(s):return s.get("mansion_tea",{}).get("received",false) and s.get("mansion_tea",{}).get("tea",0)==0
 return not s.get("mansion_tea",{}).get("received",false) or s.get("mansion_tea",{}).get("tea",0)==1
func deliver(store: RefCounted,context: String) -> String:
 if context!="route7-gate":return "请到7号道路关卡。"
 if opened(store.state):return ""
 if not store.tea_rules.has_tea(store.state):return "守卫：我渴得受不了！这里不能通过。"
 var before: Dictionary = store.state.duplicate(true)
 store.state["mansion_tea"]["tea"] = 0
 store.state["saffron_pass"] = true
 if not store.save_game():store.state = before;return store.error
 return ""
func visible(a: Dictionary,s: Dictionary) -> bool:
 if a["map"]=="saffron-city":
  if s.get("trainers",{}).get("silph_giovanni",false):return a["redObject"] in [8,9,10,11,12,13]
  if a["redObject"]==14:return not s.get("tower_story",{}).get("rescued",false)
  if a["redObject"]==15:return s.get("tower_story",{}).get("rescued",false)
 return not a.get("startsHidden",false)
func apply(mid: String,layout: Dictionary,s: Dictionary,actors: Array) -> void:
 for a in actors:
  if a["map"]==mid:layout["solid"][a["cell"][1]][a["cell"][0]] = int(visible(a,s))
