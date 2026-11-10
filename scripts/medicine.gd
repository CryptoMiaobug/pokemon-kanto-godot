extends RefCounted
## FR pokemon/item_effects.h; same identity and executor in field and battle.
const MEDICINES := ["potions","super_potions","hyper_potions","max_potions","full_restores","full_heals","revives","awakenings","elixirs","max_revives","fresh_water","soda_pop","lemonade","antidotes","paralyze_heals","burn_heals","ice_heals"]
const NEW_ITEMS := ["ultra_balls","great_balls","max_potions","full_restores","full_heals","revives","max_repels","awakenings","elixirs","max_revives"]
func apply(store:RefCounted,item:String,index:int,battle:bool=false,confusion:bool=false)->String:
 if item in ["repels","super_repels","max_repels"]:
  if battle or int(store.state.get("repel_steps",0))>0:return "喷雾尚在生效或当前不能使用。"
  if int(store.state.get(item,0))<=0:return "没有该道具。"
  store.state[item]-=1;store.state["repel_steps"]={"repels":100,"super_repels":200,"max_repels":250}[item];return ""
 if item not in MEDICINES or index<0 or index>=store.state["team"].size():return "不能对这个目标使用。"
 if int(store.state.get(item,0))<=0:return "没有该道具。"
 var p:Dictionary=store.state["team"][index];var hp:int=int(p["hp"]);var maximum:int=int(store.growth.stats(p)["hp"])
 if item=="elixirs":
  var changed:bool=false
  for move in p["moves"]:
   var maximum_pp:int=int(store.growth.moves[move]["pp"])
   if int(p["pp"][move])<maximum_pp:changed=true;p["pp"][move]=mini(maximum_pp,int(p["pp"][move])+10)
  if not changed:return "没有效果，未消耗。"
 elif item in ["antidotes","paralyze_heals","burn_heals","ice_heals"]:
  var cures:Dictionary={"antidotes":["poison","toxic"],"paralyze_heals":["paralysis"],"burn_heals":["burn"],"ice_heals":["freeze"]}
  if hp<=0 or p.get("status","") not in cures[item]:return "没有效果，未消耗。"
  for k in ["status","toxic_counter","status_turns"]:p.erase(k)
 elif item=="awakenings":
  if hp<=0 or p.get("status","")!="sleep":return "没有效果，未消耗。"
  p.erase("status");p.erase("sleep_turns")
 elif item in ["revives","max_revives"]:
  if hp!=0:return "只有倒下的宝可梦才能使用。"
  p["hp"]=maximum if item=="max_revives" else maxi(1,maximum/2)
 else:
  if hp<=0:return "倒下的宝可梦需要活力碎片。"
  var cures:bool=item in ["full_restores","full_heals"]
  var sick:bool=p.get("status","")!="" or (battle and confusion)
  if item=="full_heals" and not sick or item!="full_heals" and hp>=maximum and not(cures and sick):return "没有效果，未消耗。"
  if item!="full_heals":p["hp"]=mini(maximum,hp+int({"potions":20,"super_potions":50,"hyper_potions":200,"fresh_water":50,"soda_pop":60,"lemonade":80}.get(item,maximum)))
  if cures:
   for k in ["status","sleep_turns","toxic_counter","status_turns"]:p.erase(k)
 store.state[item]=int(store.state[item])-1;return ""
func use_field(store:RefCounted,item:String,index:int)->String:
 if not store.validate(store.state):return "存档数据无效。"
 var before:Dictionary=store.state.duplicate(true);var error:String=apply(store,item,index)
 if error!="":return error
 if not store.save_game():store.state=before;return store.error+" 道具和目标保持不变。"
 return ""
func step_repel(state:Dictionary)->bool:
 var steps:int=int(state.get("repel_steps",0))
 if steps<=0:return false
 state["repel_steps"]=steps-1
 return steps==1
func allow_wild(state:Dictionary,level:int)->bool:
 if int(state.get("repel_steps",0))<=0:return true
 for p in state["team"]:
  if int(p["hp"])>0:return level>=int(p["level"])
 return true
