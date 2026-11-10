extends RefCounted
## Red geometry; FireRed floor selection 1F-5F. Optional backward-compatible state.
const FLOORS=["celadon-mart-1f","celadon-mart-2f","celadon-mart-3f","celadon-mart-4f","celadon-mart-5f"]
func floor_id(state:Dictionary)->String:return state.get("celadon_lift_floor","celadon-mart-1f")
func valid(state:Dictionary)->bool:return not state.has("celadon_lift_floor") or state["celadon_lift_floor"] in FLOORS
func select_floor(store:RefCounted,value:String,location:Dictionary)->String:
 if value not in FLOORS:return "此楼层没有电梯。"
 var before:Dictionary=store.state.duplicate(true)
 store.state["celadon_lift_floor"]=value
 store.state["location"]=location.duplicate(true)
 if not store.save_game():store.state=before;return store.error
 return ""
