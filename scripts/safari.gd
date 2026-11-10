extends RefCounted
## FR entry script fee/party capacity and safari_zone.c30/600. No Safari battle.
const GATE_LOCATION := {"map_id":"safari-zone-gate","x":56,"y":73}
const ENTRY_LOCATION := {"map_id":"safari-zone-entry","x":232,"y":393}
func is_zone(mid: String) -> bool:return mid in ["safari-zone-west","safari-zone-secret-house","safari-zone-north","safari-zone-entry","safari-zone-east"]
func active(state: Dictionary) -> bool:return state.get("safari",{}).get("active",false)
func valid(state: Dictionary) -> bool:
 if not state.has("safari"):return true
 var d:Variant=state["safari"]
 if not d is Dictionary or not d.get("active") is bool:return false
 for k in ["steps","balls"]:
  var v:Variant=d.get(k)
  if not (v is int or v is float) or not is_finite(float(v)) or v!=floor(float(v)) or v<0 or v>(600 if k=="steps" else 30):return false
 return (d["steps"]>0 and d["balls"]>0) if d["active"] else (d["steps"]==0 and d["balls"]==0)
func enter(store: RefCounted,context: String) -> String:
 if context!="safari-zone-gate":return "请到狩猎区入口办理。"
 if active(store.state):return "已经入园，不会重复收费。"
 if store.state["team"].size()==6 and store.storage_rules.first_space(store.state).is_empty():return "队伍与盒子已满，无法入园。"
 if int(store.state["money"])<500:return "入园需要500，资金不足。"
 var before:Dictionary=store.state.duplicate(true)
 store.state["money"]-=500;store.state["safari"]={"active":true,"steps":600,"balls":30};store.state["location"]=ENTRY_LOCATION.duplicate()
 if not store.save_game():store.state=before;return store.error
 return ""
func leave(store: RefCounted) -> String:
 if not active(store.state):return "尚未入园。"
 var before:Dictionary=store.state.duplicate(true)
 store.state["safari"]={"active":false,"steps":0,"balls":0};store.state["location"]=GATE_LOCATION.duplicate();store.state["surfing"]=false
 if not store.save_game():store.state=before;return store.error
 return ""
func step(store: RefCounted,location: Dictionary) -> String:
 if not active(store.state):return ""
 var before:Dictionary=store.state.duplicate(true)
 store.state["safari"]["steps"]-=1;store.state["location"]=location.duplicate()
 var expired:bool=int(store.state["safari"]["steps"])==0
 if expired:store.state["safari"]={"active":false,"steps":0,"balls":0};store.state["location"]=GATE_LOCATION.duplicate();store.state["surfing"]=false
 # Local adaptation: each accepted grid step and its location commit together.
 if not store.save_game():store.state=before;return store.error
 return "expired" if expired else ""
