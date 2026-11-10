extends RefCounted
## Source hole events/toggles persist; ordinary stone positions remain map-local.
var data:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://data/seafoam-puzzle.json"))
func valid(s:Dictionary)->bool:
 if not s.has("seafoam"):return true
 var d:Variant=s["seafoam"]
 if not d is Dictionary or d.size()!=2 or not d.get("events") is Array or not d.get("visible") is Array:return false
 if not ([d["events"].size(),d["visible"].size()] in [[6,8],[8,12]]):return false
 for v in d["events"]+d["visible"]:
  if not v is bool:return false
 return true
func ensure(s:Dictionary)->void:
 if not s.has("seafoam"):s["seafoam"]={"events":[false,false,false,false,false,false,false,false],"visible":data["defaults"].duplicate()}
 var d:Dictionary=s["seafoam"]
 if d["events"].size()==6:d["events"] += [false,false]
 if d["visible"].size()==8:d["visible"] += [true,true,false,false]
func visible(a:Dictionary,s:Dictionary)->bool:
 if not a["map"].begins_with("seafoam-islands-"):return not a.get("hidden",false)
 var i:int=data["toggles"].find(a.get("toggle",""))
 var values:Array=s.get("seafoam",{}).get("visible",data["defaults"])
 return (values[i] if i<values.size() else data["defaults"][i]) if i>=0 else not a.get("hidden",false)
func plugged(s:Dictionary)->bool:
 var events:Array=s.get("seafoam",{}).get("events",[false,false,false,false,false,false,false,false])
 return events[4] and events[5]
func edge(mid:String,cell:Vector2i)->Dictionary:
 for row in data["falls"].get(mid,[]):
  if cell==Vector2i(int(row["cell"][0]),int(row["cell"][1])):return row
 return {}
func player_open(mid:String,s:Dictionary)->bool:
 return mid in ["seafoam-islands-1f","seafoam-islands-b1f","seafoam-islands-b2f","seafoam-islands-b3f","seafoam-islands-b4f"]
func pushed(mid:String,cell:Array,s:Dictionary)->bool:
 var row:Dictionary=edge(mid,Vector2i(int(cell[0]),int(cell[1])))
 if row.is_empty() or row["deferred"]:return false
 ensure(s);s["seafoam"]["events"][int(row["event"])]=true
 s["seafoam"]["visible"][data["toggles"].find(row["hide"])]=false
 s["seafoam"]["visible"][data["toggles"].find(row["show"])]=true
 return true
func terminal_plugged(s:Dictionary)->bool:
 var events:Array=s.get("seafoam",{}).get("events",[])
 return events.size()==8 and events[6] and events[7]
func transition(old:String,mid:String,s:Dictionary)->bool:
 if not old.begins_with("seafoam-islands-") or mid!="route20" or not s.has("seafoam"):return false
 ensure(s)
 var before:Array=s["seafoam"]["visible"].duplicate()
 if not plugged(s):
  for i in 8:s["seafoam"]["visible"][i]=data["defaults"][i]
 if not terminal_plugged(s):
  for i in range(8,12):s["seafoam"]["visible"][i]=data["defaults"][i]
 return before!=s["seafoam"]["visible"]
func apply(mid:String,d:Dictionary,s:Dictionary,actors:Array)->void:
 if not mid.begins_with("seafoam-islands-"):return
 # Clear source actor footprints after Surf terrain rebuild; caller reapplies live stones.
 for a in actors:
  if a["map"]==mid:d["solid"][int(a["cell"][1])][int(a["cell"][0])]=0
 for row in data["falls"].get(mid,[]):
  d["solid"][int(row["cell"][1])][int(row["cell"][0])]=0 if player_open(mid,s) else 1
func source_blockers(mid:String,d:Dictionary,s:Dictionary,actors:Array)->void:
 apply(mid,d,s,actors)
 for a in actors:
  if a["map"]==mid and visible(a,s):d["solid"][int(a["cell"][1])][int(a["cell"][0])]=1

func current(mid:String,cell:Vector2i,s:Dictionary,entered:bool=false)->Dictionary:
 var key:String=""
 var land:bool=false
 if mid=="seafoam-islands-b3f" and not plugged(s):
  if cell==Vector2i(15,8):key="b3f_near_steps"
  elif entered and cell in [Vector2i(18,7),Vector2i(19,7)]:key="b3f_left" if cell.x==18 else "b3f_right"
 elif mid=="seafoam-islands-b4f":
  if entered and cell in [Vector2i(4,14),Vector2i(5,14)] and not terminal_plugged(s):key="b4f_left" if cell.x==4 else "b4f_right";land=true
  elif not plugged(s) and cell.x in [20,21] and cell.y in [16,17]:
   return {"steps":[Vector2i.UP,Vector2i.UP] if cell.y==17 else [Vector2i.UP],"land":false}
 if key=="":return {}
 var steps:Array=[]
 for pair in data["currents"][key]:
  var direction:Vector2i={"up":Vector2i.UP,"down":Vector2i.DOWN,"left":Vector2i.LEFT,"right":Vector2i.RIGHT}[pair[0]]
  for i in int(pair[1]):steps.append(direction)
 return {"steps":steps,"land":land}
