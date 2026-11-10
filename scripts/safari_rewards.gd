extends RefCounted
## FR separate pockets: key30 / TMHM58; independent reward flags and quantities.
func valid(state: Dictionary) -> bool:
 if not state.has("safari_rewards"):return true
 var d:Variant=state["safari_rewards"]
 if not d is Dictionary or d.size()!=2 or not d.get("items") is Dictionary or not d.get("claimed") is Dictionary:return false
 for key in d["items"]:
  if key not in ["gold_teeth","hm03"] or not d["items"][key] is float and not d["items"][key] is int or (d["items"][key]!=0 and d["items"][key]!=1):return false
 for key in d["claimed"]:
  if key not in ["gold_teeth","hm03"] or not d["claimed"][key] is bool:return false
 for key in ["gold_teeth","hm03"]:
  if quantity(state,key)>0 and not claimed(state,key):return false
 return true
func quantity(state:Dictionary,key:String)->int:return int(state.get("safari_rewards",{}).get("items",{}).get(key,0))
func claimed(state:Dictionary,key:String)->bool:return state.get("safari_rewards",{}).get("claimed",{}).get(key,false)
func pocket_count(state:Dictionary,hm:bool)->int:
 return preload("res://scripts/item_inventory.gd").new().pocket_count(state,"POCKET_TM_CASE" if hm else "POCKET_KEY_ITEMS")
func capacity_error(key:String,occupied:int)->String:
 return "背包对应口袋已满，可以整理后重试。" if occupied>=(58 if key in ["hm03","hm05"] else 30) else ""
func claim(store:RefCounted,key:String,context:String)->String:
 if key not in ["gold_teeth","hm03"]:return "无此奖励。"
 if not store.safari.active(store.state) or context!=("safari-zone-west" if key=="gold_teeth" else "safari-zone-secret-house"):return "请到原奖励位置领取。"
 if claimed(store.state,key):return "已经领取，不能重复获得。"
 var failure:String=capacity_error(key,pocket_count(store.state,key=="hm03"))
 if failure!="":return failure
 var before:Dictionary=store.state.duplicate(true)
 if not store.state.has("safari_rewards"):store.state["safari_rewards"]={"items":{},"claimed":{}}
 store.state["safari_rewards"]["items"][key]=1;store.state["safari_rewards"]["claimed"][key]=true
 if not store.save_game():store.state=before;return store.error
 return ""
func apply(mid:String,data:Dictionary,state:Dictionary)->void:
 if mid=="safari-zone-west" and claimed(state,"gold_teeth"):
  # Original item actor disappears; restore the underlying source terrain.
  data["solid"][7][19]=0
