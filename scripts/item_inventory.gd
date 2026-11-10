extends RefCounted
## Source FR pocket limits. Legacy over-capacity saves remain readable; new receipts are checked.
var catalog:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://data/item-catalog.json"))
var tms:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://data/ground-tms.json"))["items"]
var gym_rewards=preload("res://scripts/gym_rewards.gd").new()
const LIMITS={"POCKET_ITEMS":42,"POCKET_KEY_ITEMS":30,"POCKET_POKE_BALLS":13,"POCKET_TM_CASE":58,"POCKET_BERRY_POUCH":43}
func pocket(item:String)->String:
 if item in ["meteorite","tri_pass","ruby","rainbow_pass"]:return "POCKET_KEY_ITEMS"
 if item=="iapapa_berry" or item.ends_with("berry"):return "POCKET_BERRY_POUCH"
 if item.begins_with("hm") or item in tms or not gym_rewards.item_row(item).is_empty():return "POCKET_TM_CASE"
 if item in ["gold_teeth","voucher","bicycle","ss_ticket","poke_flute","silph_scope","lift_key","card_key","tea","secret_key"]:return "POCKET_KEY_ITEMS"
 if item.ends_with("balls") or item=="balls":return "POCKET_POKE_BALLS"
 return catalog["items"].get(item,{}).get("pocket","POCKET_ITEMS")
func quantity(s:Dictionary,item:String)->int:
 if item.begins_with("fr_tm"):return int(s.get("tm_inventory",{}).get(item,0))
 if item=="tm_dig":return int(s.get("stolen_tm",{}).get("items",{}).get("tm28",0))
 if item in ["escape_ropes","nuggets"] or item in tms:return int(s.get("ground_inventory",{}).get(item,0))
 if item in ["gold_teeth","hm03"]:return int(s.get("safari_rewards",{}).get("items",{}).get(item,0))
 if item=="bridge_nugget":return int(s.get("nugget_bridge",{}).get("items",{}).get("nugget",0))
 if item in ["dome_fossil","helix_fossil"]:return int(s.get("moon_fossil",{}).get("items",{}).get(item,0))
 if item in ["kingsrock","metalcoat","dragonscale","upgrade","everstone","soothebell"]:return int(s.get("evolution_inventory",{}).get(item,0))
 return int(s.get(item,0))
func add(s:Dictionary,item:String,delta:int)->void:
 var field:String="tm_inventory" if item.begins_with("fr_tm") else "ground_inventory" if item in ["escape_ropes","nuggets"] or item in tms else "evolution_inventory" if item in ["kingsrock","metalcoat","dragonscale","upgrade","everstone","soothebell"] else ""
 if item=="bridge_nugget":s["nugget_bridge"]["items"]["nugget"]+=delta;return
 if item=="tm_dig":s["stolen_tm"]["items"]["tm28"]+=delta;return
 if field=="":s[item]=int(s.get(item,0))+delta
 else:
  if not s.has(field):s[field]={}
  s[field][item]=int(s[field].get(item,0))+delta
func receive_error(s:Dictionary,item:String,count:int=1)->String:
 if quantity(s,item)+count>999:return "同类库存上限999。"
 if quantity(s,item)>0:return ""
 var used:int=pocket_count(s,pocket(item))
 return "这个口袋已满。" if used>=int(LIMITS.get(pocket(item),42)) else ""
func valid(s:Dictionary)->bool:
 if s.has("tm_inventory"):
  if not s["tm_inventory"] is Dictionary:return false
  for key in s["tm_inventory"]:
   var v:Variant=s["tm_inventory"][key]
   if not key.begins_with("fr_tm") or (not tms.has(key) and gym_rewards.item_row(key).is_empty()) or not (v is int or v is float) or not is_finite(float(v)) or v<0 or v>999 or v!=floor(v):return false
 for key in catalog["items"]:
  if s.has(key):
   var v:Variant=s[key]
   if not (v is int or v is float) or v<0 or v>999 or v!=floor(v):return false
 return true

func pocket_count(s:Dictionary,target:String)->int:
 var occupied:Dictionary={}
 for key in s:
  if (s[key] is int or s[key] is float) and int(s[key])>0 and (catalog["items"].has(key) or key in ["rare_candies","moon_stones","max_revives","elixirs","master_balls","sun_stones"]):occupied[key]=true
 for field in ["ground_inventory","tm_inventory","evolution_inventory"]:
  for key in s.get(field,{}):
   if int(s[field][key])>0:occupied[key]=true
 if quantity(s,"tm_dig")>0:occupied["tm_dig"]=true
 for key in ["dome_fossil","helix_fossil"]:
  if quantity(s,key)>0:occupied[key]=true
 if int(s.get("nugget_bridge",{}).get("items",{}).get("nugget",0))>0:occupied["nuggets"]=true
 var hm:Dictionary={"hm01":s.get("captain",{}).get("items",{}).get("hm01",0),"hm02":int(s.get("travel",{}).get("hm02",false)),"hm03":quantity(s,"hm03"),"hm04":int(s.get("warden",{}).get("claimed",false)),"hm05":s.get("flash_reward",{}).get("hm05",0)}
 for key in hm:
  if int(hm[key])>0:occupied[key]=true
 for move in ["rocksmash","waterfall"]:
  if s.get("sevii_hms",{}).get(move,false):occupied["hm06" if move=="rocksmash" else "hm07"]=true
 var keys:Dictionary={"gold_teeth":quantity(s,"gold_teeth"),"voucher":s.get("travel",{}).get("voucher",0),"bicycle":int(s.get("travel",{}).get("bicycle",false)),"ss_ticket":s.get("bill",{}).get("items",{}).get("ss_ticket",0),"poke_flute":int(s.get("tower_story",{}).get("poke_flute",false)),"silph_scope":s.get("rocket_story",{}).get("items",{}).get("silph_scope",0),"lift_key":s.get("rocket_story",{}).get("items",{}).get("lift_key",0),"card_key":int(s.get("silph_story",{}).get("card_key",false)),"tea":s.get("mansion_tea",{}).get("tea",0),"secret_key":int(s.get("secret_key",false))}
 for key in keys:
  if int(keys[key])>0:occupied[key]=true
 for key in ["meteorite","tri_pass","ruby","rainbow_pass","iapapa_berry"]:
  if int(s.get("sevii",{}).get(key,0))>0:occupied[key]=true
 var count:int=0
 for key in occupied:
  if pocket(key)==target:count+=1
 return count
