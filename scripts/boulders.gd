extends RefCounted
## Map-local positions/activation deliberately never serialized.
var map:String=""
var active:bool=false
var cells:Array=[]
var originals:Array=[]
var clock:float=0.0
var changed:Callable
var object_ids:Array=[]
var visibility:Callable
var immovable:Array=[]
var puzzle:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://data/victory-road-puzzle.json"))
func enter(mid:String,actors:Array)->void:
 if mid==map:return
 map=mid;active=false;cells=[];originals=[];object_ids=[];immovable=[];clock=0
 for a in actors:
  if a["map"]==mid and (not visibility.is_valid() or visibility.call(a)) and (a.get("boulder",false) or a.get("redObject",0)==3 and mid=="wardens-house"):
   cells.append([int(a["cell"][0]),int(a["cell"][1])]);object_ids.append(int(a["redObject"]));immovable.append(a.get("immovable",false))
 originals=cells.duplicate(true)
func displaced()->bool:return cells!=originals
func refresh(actors:Array)->void:
 var previous:Dictionary={}
 for i in object_ids.size():previous[object_ids[i]]=cells[i].duplicate()
 var mid:String=map;var enabled:bool=active
 map="";enter(mid,actors)
 for i in object_ids.size():
  if previous.has(object_ids[i]):cells[i]=previous[object_ids[i]]
 active=enabled
func index(cell:Vector2i)->int:return cells.find([cell.x,cell.y])
func apply(d:Dictionary)->void:
 for c in originals:d["solid"][c[1]][c[0]]=0
 for c in cells:
  if c[0]>=0:d["solid"][c[1]][c[0]]=1
func push(i:int,step:Vector2i,d:Dictionary)->bool:
 if not active or i<0 or i>=cells.size() or absi(step.x)+absi(step.y)!=1:return false
 if immovable[i]:return false
 var old:=Vector2i(cells[i][0],cells[i][1]);var target:Vector2i=old+step
 if target.x<0 or target.y<0 or target.x>=int(d["width"]) or target.y>=int(d["height"]):return false
 var seafoam_hole:bool=map in ["seafoam-islands-1f","seafoam-islands-b1f","seafoam-islands-b2f","seafoam-islands-b3f"] and int(d["footTiles"][target.y][target.x])==34
 if (d["solid"][target.y][target.x]!=0 and not seafoam_hole) or index(target)>=0:return false
 if map.begins_with("sevii-") and preload("res://scripts/sevii.gd").edge_blocked(d,old,target):return false
 if map.begins_with("victory-road-") and int(d["footTiles"][target.y][target.x])==21:return false
 for p in d.get("pairCollisionsLand",[]):
  var a:int=d["footTiles"][old.y][old.x];var b:int=d["footTiles"][target.y][target.x]
  if a==int(p[0]) and b==int(p[1]) or a==int(p[1]) and b==int(p[0]):return false
 cells[i]=[target.x,target.y]
 if changed.is_valid():changed.call(map,cells.duplicate(true))
 return true
func safe_position(position:Vector2)->Vector2:
 # Original stone may reappear on the player's transient square after reload.
 if displaced():
  if map=="seafoam-islands-1f":return Vector2(72,265)
  if map=="seafoam-islands-b1f":return Vector2(120,89)
  if map=="seafoam-islands-b2f":return Vector2(88,57)
  if map=="seafoam-islands-b3f":return Vector2(88,201)
  if map=="victory-road-2f":return Vector2(8,137)
  if map=="victory-road-3f":return Vector2(376,121)
  if map=="victory-road-1f":return Vector2(136,265)
  if map=="wardens-house":return Vector2(72,105)
 return position
