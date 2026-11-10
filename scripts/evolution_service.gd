extends RefCounted
## Explicit offline adaptation: local trade return, source held-item conditions; atomic commit.
const ITEMS={"sun_stones":{"name":"日之石","price":2100},"kingsrock":{"name":"王者之证","price":10000},"metalcoat":{"name":"金属膜","price":10000},"dragonscale":{"name":"龙之鳞片","price":10000},"upgrade":{"name":"升级数据","price":10000},"everstone":{"name":"不变之石","price":3000},"soothebell":{"name":"安抚之铃","price":3000}}
const SOURCE_ITEMS={"kings_rock":"kingsrock","metal_coat":"metalcoat","dragon_scale":"dragonscale","up_grade":"upgrade"}
var evolution=preload("res://scripts/evolution.gd").new()
func trade_target(pet:Dictionary,state:Dictionary)->String:
	for row in evolution.data.get(pet["species_id"],[]):
		if row["method"]=="EVO_TRADE" or row["method"]=="EVO_TRADE_ITEM" and pet.get("held_item","")==SOURCE_ITEMS.get(row["param"],row["param"]):
			if evolution.allowed(pet,row["target"],state):return row["target"]
	return ""
func unlock(store:RefCounted)->String:
	if store.state.get("national_dex",false):return "全国图鉴已解锁。"
	if not store.hall_of_fame.cleared(store.state) or store.pokedex.kanto_caught(store.state,store.species)<60:return "大木：名人堂登记并拥有过60种关都宝可梦后，可升级全国图鉴。"
	var before:Dictionary=store.state.duplicate(true);store.state["national_dex"]=true
	if not store.save_game():store.state=before;return store.error
	return ""
func purchase(store:RefCounted,item:String)->String:
	if not ITEMS.has(item):return "没有该道具。"
	if not store.state.get("national_dex",false):return "先解锁全国图鉴，才能使用进化服务物资。"
	var price:int=ITEMS[item]["price"]
	if int(store.state["money"])<price:return "余额不足。"
	if (int(store.state.get(item,0)) if item=="sun_stones" else int(store.state.get("evolution_inventory",{}).get(item,0)))>=999:return "携带数量已满。"
	var capacity:String=store.inventory.receive_error(store.state,item)
	if capacity!="":return capacity
	var before:Dictionary=store.state.duplicate(true)
	if item=="sun_stones":store.state[item]=int(store.state.get(item,0))+1
	else:
		if not store.state.has("evolution_inventory"):store.state["evolution_inventory"]={}
		store.state["evolution_inventory"][item]=int(store.state["evolution_inventory"].get(item,0))+1
	store.state["money"]-=price
	if not store.save_game():store.state=before;return store.error
	return ""
func hold(store:RefCounted,index:int,item:String)->String:
	if index<0 or index>=store.state["team"].size() or item!="" and (not ITEMS.has(item) or item=="sun_stones"):return "不能携带该道具。"
	var pet:Dictionary=store.state["team"][index];var old:String=pet.get("held_item","")
	if old!="" and not ITEMS.has(old):return "请先处理原有携带物。"
	var bag:Dictionary=store.state.get("evolution_inventory",{})
	if item!="" and int(bag.get(item,0))<=0:return "没有该携带物。"
	if old!="" and int(bag.get(old,0))>=999:return "背包已满。"
	if old!="" and store.inventory.receive_error(store.state,old)!="":return "这个口袋已满。"
	var before:Dictionary=store.state.duplicate(true)
	if not store.state.has("evolution_inventory"):store.state["evolution_inventory"]={}
	bag=store.state["evolution_inventory"]
	if old!="":bag[old]=int(bag.get(old,0))+1
	if item!="":bag[item]=int(bag.get(item,0))-1;pet["held_item"]=item
	else:pet.erase("held_item")
	if not store.save_game():store.state=before;return store.error
	return ""
func trade_preview(store:RefCounted,index:int)->Dictionary:
	if index<0 or index>=store.state["team"].size():return {}
	var pet:Dictionary=store.state["team"][index].duplicate(true);var target:String=trade_target(pet,store.state)
	if target=="":return {}
	var original:Dictionary=pet.duplicate(true)
	evolution.change_species(pet,target)
	for row in evolution.data.get(original["species_id"],[]):
		if row["method"]=="EVO_TRADE_ITEM" and row["target"]==target:pet.erase("held_item")
	return {"original":original,"pet":pet,"learns":evolution.learning(pet,index).map(func(e):return e["move"])}
func commit(store:RefCounted,index:int,preview:Dictionary)->String:
	if index<0 or index>=store.state["team"].size() or preview.is_empty():return "不能进化。"
	if store.state["team"][index]!=preview["original"]:return "目标已改变，已取消。"
	var target:String=trade_target(store.state["team"][index],store.state)
	if target=="" or target!=preview["pet"]["species_id"]:return "通信条件不满足。"
	var before:Dictionary=store.state.duplicate(true)
	store.pokedex.register(store.state,store.species,preview["original"]["species_id"],true)
	store.state["team"][index]=preview["pet"].duplicate(true)
	store.pokedex.register(store.state,store.species,target,true)
	if not store.save_game():store.state=before;return store.error+" 进化及携带物消耗已撤销。"
	return ""

## Source gifts/prizes made reachable without adding unrelated maps or gambling.
## FR RoofRoom Eevee25 once; PrizeRoom FR Dratini18/2800 coins, Porygon26/9999 coins.
## Coins cost 20 currency each in FR. Direct conversion is an explicit single-player adaptation.
const STARTERS={"eevee":{"level":25,"price":0},"dratini":{"level":18,"price":56000},"porygon":{"level":26,"price":199980}}
func acquire(store:RefCounted,sid:String,map_id:String)->String:
	if not STARTERS.has(sid) or map_id!="celadon-city":return "请在玉虹市联系领取服务。"
	if sid=="eevee" and store.state.get("evolution_gifts",{}).get(sid,false):return "伊布已经领取。"
	if not store.can_receive_capture():return "队伍与盒子已满。"
	var row:Dictionary=STARTERS[sid]
	if int(store.state["money"])<int(row["price"]):return "余额不足。"
	var before:Dictionary=store.state.duplicate(true)
	var pet:Dictionary=store.create_individual(sid,-1,int(row["level"]));pet["met_location"]=map_id
	var destination:Dictionary=store.receive_capture(pet)
	if destination.has("error"):store.state=before;return destination["error"]
	store.state["money"]-=int(row["price"])
	if sid=="eevee":store.state["evolution_gifts"]={"eevee":true}
	if not store.save_game():store.state=before;return store.error
	return ""
