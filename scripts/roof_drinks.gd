extends RefCounted
## FireRed Celadon rooftop vending and thirsty-girl reward transactions.
const ITEMS := ["fresh_water", "soda_pop", "lemonade"]
const PRICES := {"fresh_water":200, "soda_pop":300, "lemonade":350}
const HEAL := {"fresh_water":50, "soda_pop":60, "lemonade":80}
const TM := {"fresh_water":"tm16", "soda_pop":"tm20", "lemonade":"tm33"}
const MOVES := {"fresh_water":"light_screen", "soda_pop":"safeguard", "lemonade":"reflect"}
const NAMES := {"fresh_water":"清凉水", "soda_pop":"苏打汽水", "lemonade":"柠檬汽水"}
const TM_NAMES := {"tm16":"TM16 光墙", "tm20":"TM20 神秘守护", "tm33":"TM33 反射壁"}
var COMPATIBLE:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://data/roof-evolution-compatibility.json"))

func buy(store:RefCounted,item:String)->String:
	if item not in ITEMS:return "没有这种饮料。"
	var before:Dictionary=store.state.duplicate(true)
	var failure:String=store.purchase(item,1)
	if failure!="":store.state=before
	return failure

func drink(store:RefCounted,item:String,index:int,location:Dictionary)->String:
	if item not in ITEMS:return "没有这种饮料。"
	if index<0 or index>=store.state["team"].size():return "请选择队伍里的宝可梦。"
	if int(store.state.get(item,0))<=0:return "没有这瓶饮料。"
	var pet:Dictionary=store.state["team"][index]
	var maximum:int=int(store.growth.stats(pet)["hp"])
	if int(pet["hp"])<=0:return "倒下的宝可梦无法使用饮料。"
	if int(pet["hp"])>=maximum:return "HP已满，没有效果。"
	var before:Dictionary=store.state.duplicate(true)
	pet["hp"]=mini(maximum,int(pet["hp"])+int(HEAL[item]));store.state[item]-=1;store.state["location"]=location.duplicate(true)
	if not store.save_game():store.state=before;return store.error+" 饮料和HP均未改变。"
	return ""

func exchange_error(state:Dictionary,item:String,_index:int=-1)->String:
	if item not in ITEMS:return "没有这种饮料。"
	if state.get("roof_exchanges",{}).get(item,false):return "这份饮料的TM已经兑换过了。"
	if int(state.get(item,0))<=0:return "没有这瓶饮料。"
	return ""
func exchange(store:RefCounted,item:String,_index:int=-1,_slot:int=-1,location:Dictionary={})->String:
	var failure:String=exchange_error(store.state,item)
	if failure!="":return failure
	var reward:String="fr_"+TM[item]
	failure=store.inventory.receive_error(store.state,reward)
	if failure!="":return failure
	var before:Dictionary=store.state.duplicate(true)
	store.inventory.add(store.state,reward,1);store.state[item]-=1
	if not store.state.has("roof_exchanges"):store.state["roof_exchanges"]={}
	store.state["roof_exchanges"][item]=true
	if not location.is_empty():store.state["location"]=location.duplicate(true)
	if not store.save_game():store.state=before;return store.error+" 兑换已撤销。"
	return ""
