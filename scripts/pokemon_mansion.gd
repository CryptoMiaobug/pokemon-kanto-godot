extends RefCounted
## Red dynamic blocks drive patches and foot collision together.
var data:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://data/pokemon-mansion-switches.json"))
func valid(s:Dictionary)->bool:
 if s.has("secret_key") and not s["secret_key"] is bool:return false
 return not s.has("mansion_switch") or s["mansion_switch"] is bool
func active(s:Dictionary)->bool:return s.get("mansion_switch",false)
func apply(mid:String,layout:Dictionary,s:Dictionary)->void:
 for door in data["doors"]:
  if door["map"]!=mid:continue
  for c in door["states"][int(active(s))]["cells"]:
   var x:int=int(c["cell"][0]);var y:int=int(c["cell"][1]);layout["solid"][y][x]=c["solid"];layout["footTiles"][y][x]=c["foot"]
 if mid=="pokemon-mansion-b1f" and has_key(s):layout["solid"][13][5]=0
func has_key(s:Dictionary)->bool:return s.get("secret_key",false)
func take_key(store:RefCounted,mid:String,position:Vector2)->String:
 var cell:=Vector2i(floori(position.x/16),floori((position.y-1)/16))
 if mid!="pokemon-mansion-b1f" or absi(cell.x-5)+absi(cell.y-13)!=1:return "此处没有秘密钥匙。"
 if has_key(store.state):return ""
 if store.inventory.receive_error(store.state,"secret_key")!="":return "关键物品口袋已满。"
 var before:Dictionary=store.state.duplicate(true)
 store.state["secret_key"]=true
 store.state["location"]={"map_id":mid,"x":position.x,"y":position.y}
 if not store.save_game():store.state=before;return store.error
 return ""
func toggle(store:RefCounted,mid:String,position:Vector2)->String:
 if not mid.begins_with("pokemon-mansion-"):return "此处没有开关。"
 var before:Dictionary=store.state.duplicate(true)
 store.state["mansion_switch"]=not active(store.state)
 store.state["location"]={"map_id":mid,"x":position.x,"y":position.y}
 if store.save_game():return ""
 store.state=before;return "保存失败，开关保持原状。"
