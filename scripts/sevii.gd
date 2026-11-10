extends RefCounted
## Pinned FireRed source objects and stages. Transient field changes reset on map exit.
var world:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://data/sevii-world.json"))
var trainers:Array=JSON.parse_string(FileAccess.get_file_as_string("res://data/sevii-trainers.json"))
var removed:Array=[]
var removed_map:String=""
var ice:Array=[]
var ice_map:String=""
const WATER=[16,17,18,19,21,26,27,80,81,82,83]
const BIKERS=["sevii_goon","sevii_goon2","sevii_goon3","sevii_paxton"]
func stage(s:Dictionary)->int:return int(s.get("sevii",{}).get("stage",0))
func valid(s:Dictionary)->bool:
 if not s.has("sevii"):return true
 var v:Variant=s["sevii"]
 if not v is Dictionary:return false
 for key in v:
  if key not in ["stage","departed","meteorite","tri_pass","rescue_asked","hypno_done","rescued","berry_claimed","moon_claimed","ruby","ruby_claimed","rainbow_pass","iapapa_berry"]:return false
  if key=="stage":
   if not (v[key] is int or v[key] is float) or not is_finite(float(v[key])) or float(v[key])!=int(v[key]) or int(v[key])<0 or int(v[key])>5:return false
  elif key=="iapapa_berry":
   if not (v[key] is int or v[key] is float) or not is_finite(float(v[key])) or v[key]<0 or v[key]>999 or v[key]!=floor(v[key]):return false
  elif not v[key] is bool:return false
 return true
func actors(mid:String)->Array:
 if not world.has(mid):return []
 return JSON.parse_string(FileAccess.get_file_as_string("res://data/%s.json" % mid))["actors"]
func boulder_actors()->Array:
 var result:Array=[]
 for mid in world:
  for a in actors(mid):
   if a["script"]=="EventScript_StrengthBoulder":
    var row:Dictionary=a.duplicate(true);row["map"]=mid;row["redObject"]=a["source_index"];row["boulder"]=true;result.append(row)
 return result
func bikers_done(s:Dictionary)->bool:
 for key in BIKERS:
  if not s.get("trainers",{}).get(key,false):return false
 return true
func rockets_done(s:Dictionary)->bool:return s.get("trainers",{}).get("sevii_grunt43",false) and s.get("trainers",{}).get("sevii_grunt44",false)
func visible(a:Dictionary,s:Dictionary)->bool:
 var script:String=a["script"]
 if script=="EventScript_RockSmash" and int(a["source_index"]) in removed:return false
 if script.contains("ItemHM07"):return not s.get("sevii_hms",{}).get("waterfall",false)
 if script=="MtEmber_RubyPath_B5F_EventScript_Ruby":return not s.get("sevii",{}).get("ruby_claimed",false)
 if script.contains("MtEmber_Exterior_EventScript_Grunt"):return not rockets_done(s)
 if script=="ThreeIsland_EventScript_Biker" or script=="ThreeIsland_EventScript_Biker6":return not bikers_done(s)
 if script.contains("Lostelle") and not script.contains("Daddy"):
  return not s.get("sevii",{}).get("rescued",false) if script.contains("BerryForest") else s.get("sevii",{}).get("rescued",false)
 if script=="OneIsland_PokemonCenter_1F_EventScript_Bill":return stage(s)<3
 return script!="0x0"
func apply(mid:String,d:Dictionary,s:Dictionary)->void:
 if not world.has(mid):return
 if removed_map!=mid:removed.clear();removed_map=mid
 if ice_map!=mid:ice.clear();ice_map=mid
 for warp in world[mid]["warps"]:
  if warp.get("door",false) and not warp.get("closed",false):d["solid"][warp["cell"][1]][warp["cell"][0]]=0
 for a in actors(mid):
  if visible(a,s) and a["script"]!="EventScript_StrengthBoulder":d["solid"][a["cell"][1]][a["cell"][0]]=1
 if mid=="sevii-mt-ember-exterior" and stage(s)>=4 and rockets_done(s):d["solid"][39][42]=0
 if mid=="sevii-four-island-icefall-cave-1-f":
  for c in ice:d["behaviors"][c[1]][c[0]]=39
func field_error(s:Dictionary,move:String)->String:
 if not s.get("badges",{}).get("marsh" if move=="rocksmash" else "volcano",false):return "需要金色徽章。" if move=="rocksmash" else "需要深红徽章。"
 for pet in s["team"]:
  if move in pet["moves"]:return ""
 return "队伍中没有学会该秘传招式的宝可梦。"
func claim_hm06(store:RefCounted,mid:String,actor:Dictionary)->String:
 if mid!="sevii-one-island-kindle-road-ember-spa" or actor.get("script","")!="OneIsland_KindleRoad_EmberSpa_EventScript_RockSmashMan":return "请与温泉的原领取人交谈。"
 if store.state.get("sevii_hms",{}).get("rocksmash",false):return "HM06已经领取，不能重复获得。"
 if stage(store.state)<1:return "请先与一岛中心的比尔和锦辉会面。"
 if store.inventory.pocket_count(store.state,"POCKET_TM_CASE")>=58:return "秘传口袋已满。"
 var before:Dictionary=store.state.duplicate(true)
 if not store.state.has("sevii_hms"):store.state["sevii_hms"]={}
 store.state["sevii_hms"]["rocksmash"]=true
 if not store.save_game():store.state=before;return store.error
 return ""
func smash(s:Dictionary,mid:String,index:int)->String:
 if mid!=removed_map:return "目标不在当前地图。"
 var target:Dictionary={}
 for a in actors(mid):
  if int(a["source_index"])==index and a["script"]=="EventScript_RockSmash":target=a
 if target.is_empty() or index in removed:return "这里没有可碎的岩石。"
 var failure:String=field_error(s,"rocksmash")
 if failure!="":return failure
 removed.append(index);return ""
func travel_error(s:Dictionary,dest:String)->String:
 if not s.get("sevii",{}).get("tri_pass",false) and not s.get("sevii",{}).get("rainbow_pass",false):return "需要三岛通行证。"
 if dest=="vermilion-city" and stage(s)<3:return "请先完成救援、交付陨石并随比尔返回红莲。"
 if dest=="sevii-four-island-harbor" and not s.get("sevii",{}).get("rainbow_pass",false):return "需要彩虹通行证。"
 if dest not in ["vermilion-city","sevii-one-island-harbor","sevii-two-island-harbor","sevii-three-island-harbor","sevii-four-island-harbor"]:return "当前航线未开放。"
 return ""
func transact(store:RefCounted,action:String,location:Dictionary={})->String:
 if not store.validate(store.state):return "存档状态无效。"
 var before:Dictionary=store.state.duplicate(true)
 var v:Dictionary=store.state.get("sevii",{}).duplicate(true)
 var failure:String=""
 match action:
  "depart":
   if not store.state.get("badges",{}).get("volcano",false) or v.get("departed",false):return "先取得深红徽章，再与比尔出航。"
   v["departed"]=true
  "meet":
   if not v.get("departed",false) or stage(store.state)!=0:return "已经与锦辉会面。"
   if store.inventory.pocket_count(store.state,"POCKET_KEY_ITEMS")>28:return "关键物品口袋需要两个空位。"
   v["stage"]=1;v["meteorite"]=true;v["tri_pass"]=true
  "ask_rescue":
   if stage(store.state)!=1:return "这项委托已结束。"
   v["rescue_asked"]=true
  "rescue":
   if not v.get("hypno_done",false) or v.get("rescued",false):return "先处理吓到迷失女孩的催眠貘。"
   v["rescued"]=true
   if not v.get("berry_claimed",false) and store.inventory.pocket_count(store.state,"POCKET_BERRY_POUCH")<43:
    v["iapapa_berry"]=int(v.get("iapapa_berry",0))+1;v["berry_claimed"]=true
  "deliver":
   if not v.get("rescued",false) or not v.get("meteorite",false):return "请先救回迷失女孩，再交付陨石。"
   v["meteorite"]=false;v["stage"]=2
  "moon":
   if stage(store.state)<2 or v.get("moon_claimed",false):return "月之石已经领取或尚未交付陨石。"
   failure=store.inventory.receive_error(store.state,"moon_stones")
   if failure!="":return failure
   store.inventory.add(store.state,"moon_stones",1);v["moon_claimed"]=true
  "return":
   if stage(store.state)!=2:return "请先完成迷失女孩救援与陨石交付。"
   v["stage"]=3
  "ruby_request":
   if stage(store.state)!=3 or not store.state.get("national_dex",false):return "需要全国图鉴，锦辉才能委托寻找红宝石。"
   v["stage"]=4
  "ruby":
   if stage(store.state)!=4 or not rockets_done(store.state) or v.get("ruby_claimed",false):return "尚不能领取红宝石。"
   if store.inventory.pocket_count(store.state,"POCKET_KEY_ITEMS")>=30:return "关键物品口袋已满。"
   v["ruby"]=true;v["ruby_claimed"]=true
  "rainbow":
   if not v.get("ruby",false) or stage(store.state)!=4:return "请带回红宝石。"
   v["ruby"]=false;v["tri_pass"]=false;v["rainbow_pass"]=true;v["stage"]=5
  "hm07":
   if stage(store.state)!=5 or store.state.get("sevii_hms",{}).get("waterfall",false):return "尚不能领取或已经领取HM07。"
   if store.inventory.pocket_count(store.state,"POCKET_TM_CASE")>=58:return "秘传口袋已满。"
   if not store.state.has("sevii_hms"):store.state["sevii_hms"]={}
   store.state["sevii_hms"]["waterfall"]=true
  "heal":store.heal_party()
  _ :return "未知七岛事件。"
 store.state["sevii"]=v
 if not location.is_empty():store.state["location"]=location.duplicate(true);store.state["surfing"]=false
 if not store.save_game():store.state=before;return store.error
 return ""
func ferry(store:RefCounted,dest:String,location:Dictionary)->String:
 var failure:String=travel_error(store.state,dest)
 if failure!="":return failure
 var before:Dictionary=store.state.duplicate(true)
 store.state["location"]=location.duplicate(true);store.state["surfing"]=false
 if not store.save_game():store.state=before;return store.error
 return ""
func waterfall(d:Dictionary,s:Dictionary,cell:Vector2i,step:Vector2i)->Dictionary:
 if not s.get("surfing",false) or step.x!=0 or step.y==0:return {}
 var target:Vector2i=cell+step
 if target.x<0 or target.y<0 or target.x>=int(d["width"]) or target.y>=int(d["height"]):return {}
 if int(d["behaviors"][target.y][target.x])!=19:return {}
 if step.y<0:
  var failure:String=field_error(s,"waterfall")
  if failure!="":return {"error":failure}
 var cells:Array=[]
 while target.y>=0 and target.y<int(d["height"]) and int(d["behaviors"][target.y][target.x])==19:
  cells.append([target.x,target.y]);target+=step
 if target.y<0 or target.y>=int(d["height"]) or int(d["behaviors"][target.y][target.x]) not in WATER or int(d["solid"][target.y][target.x])!=0:return {"error":"瀑布终点不可安全停靠。"}
 cells.append([target.x,target.y]);return {"cells":cells,"end":[target.x,target.y]}

static func edge_blocked(d:Dictionary,a:Vector2i,b:Vector2i)->bool:
 var step:Vector2i=b-a
 var north:Array=[50,52,53];var south:Array=[51,54,55];var east:Array=[48,52,54];var west:Array=[49,53,55]
 var origin:Array=north if step.y<0 else south if step.y>0 else east if step.x>0 else west
 var destination:Array=south if step.y<0 else north if step.y>0 else west if step.x>0 else east
 if int(d["behaviors"][a.y][a.x]) in origin or int(d["behaviors"][b.y][b.x]) in destination:return true
 var first:int=int(d["elevations"][a.y][a.x]);var second:int=int(d["elevations"][b.y][b.x])
 return first not in [0,15] and second not in [0,15] and first!=second
