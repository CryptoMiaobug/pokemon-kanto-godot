extends RefCounted
## FireRed Pickup table: cumulative thresholds, independent 10% per eligible party member.
const TABLE = [[15,"oranberry"],[25,"cheriberry"],[35,"chestoberry"],[45,"pechaberry"],[55,"rawstberry"],[65,"aspearberry"],[75,"persimberry"],[80,"fr_tm10"],[85,"pp_ups"],[90,"rare_candies"],[95,"nuggets"],[96,"spelonberry"],[97,"pamtreberry"],[98,"watmelberry"],[99,"durinberry"],[100,"belueberry"]]
var abilities:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://data/item-abilities.json"))
func ability(pet:Dictionary)->String:
 var slots:Array=abilities.get(pet["species_id"],["NONE","NONE"])
 var slot:int=int(pet["individual_id"].right(1).hex_to_int())%2
 return slots[slot] if slots[slot]!="NONE" else slots[0]
func roll_item(roll:int)->String:
 for row in TABLE:
  if roll<int(row[0]):return row[1]
 return ""
func pickup(s:Dictionary,outcome:String,rng:RandomNumberGenerator)->Array:
 var found:Array=[]
 if outcome!="victory":return found
 for pet in s["team"]:
  if ability(pet)!="PICKUP" or pet.get("held_item","")!="" or pet.get("is_egg",false):continue
  if rng.randi()%10!=0:continue
  var item:String=roll_item(rng.randi()%100);pet["held_item"]=item
  found.append({"id":pet["individual_id"],"item":item})
 return found
func gift(store:RefCounted)->String:
 if store.state.get("location",{}).get("map_id","")!="route12-gate-2f":return "请到12号道路门楼二层交谈。"
 if store.state.get("tm27_received",false):return "报恩已经送给你了，亲密度越高威力越大。"
 var failure:String=store.inventory.receive_error(store.state,"fr_tm27")
 if failure!="":return failure
 var before:Dictionary=store.state.duplicate(true)
 store.inventory.add(store.state,"fr_tm27",1);store.state["tm27_received"]=true
 if not store.save_game():store.state=before;return store.error
 return ""
func take_held(store:RefCounted,index:int)->String:
 if index<0 or index>=store.state["team"].size():return "请选择宝可梦。"
 var pet:Dictionary=store.state["team"][index];var item:String=pet.get("held_item","")
 if not TABLE.any(func(row):return row[1]==item):return "没有捡拾携带物。"
 var failure:String=store.inventory.receive_error(store.state,item)
 if failure!="":return failure
 var before:Dictionary=store.state.duplicate(true)
 store.inventory.add(store.state,item,1);pet.erase("held_item")
 if not store.save_game():store.state=before;return store.error
 return ""
