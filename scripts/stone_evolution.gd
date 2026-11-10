extends RefCounted
const ITEMS := ["fire_stones","thunder_stones","water_stones","leaf_stones","moon_stones","sun_stones"]
const SOURCE_ITEMS={"fire_stones":"fire_stone","thunder_stones":"thunder_stone","water_stones":"water_stone","leaf_stones":"leaf_stone","moon_stones":"moon_stone","sun_stones":"sun_stone"}
var evolution=preload("res://scripts/evolution.gd").new()
func target(item:String,pet:Dictionary)->String:
	for row in evolution.data.get(pet.get("species_id",""),[]):
		if row["method"]=="EVO_ITEM" and row["param"]==SOURCE_ITEMS.get(item,""):return row["target"]
	return ""
func preview(store:RefCounted,item:String,index:int)->Dictionary:
	if item not in ITEMS or index<0 or index>=store.state["team"].size() or int(store.state.get(item,0))<=0:return {}
	var original:Dictionary=store.state["team"][index];var next:String=target(item,original)
	if next=="" or not evolution.allowed(original,next,store.state):return {}
	var pet:Dictionary=original.duplicate(true);evolution.change_species(pet,next)
	return {"original":original.duplicate(true),"pet":pet,"item":item,"learns":evolution.learning(pet,index).map(func(e):return e["move"])}
func commit(store:RefCounted,index:int,plan:Dictionary,location:Dictionary)->String:
	if plan.is_empty() or index<0 or index>=store.state["team"].size():return "不能对这个目标使用。"
	var item:String=plan["item"]
	if store.state["team"][index]!=plan["original"] or preview(store,item,index).is_empty():return "进化条件已改变，未消耗道具。"
	var before:Dictionary=store.state.duplicate(true)
	store.pokedex.register(store.state,store.species,plan["original"]["species_id"],true)
	store.state["team"][index]=plan["pet"].duplicate(true)
	store.pokedex.register(store.state,store.species,plan["pet"]["species_id"],true)
	store.state[item]=int(store.state[item])-1;store.state["location"]=location.duplicate(true)
	if not store.save_game():store.state=before;return store.error+" 进化与道具消耗已撤销，可以重试。"
	return ""
func use(store:RefCounted,item:String,index:int,location:Dictionary)->String:
	var plan:Dictionary=preview(store,item,index)
	if plan.is_empty():return "不能进化：检查石头数量、不变之石与全国图鉴条件。"
	# Noninteractive API never silently discards a full-slot move choice. UI uses preview/commit.
	if not plan["learns"].is_empty():return "请从进化石袋确认进化并处理新招式。"
	return commit(store,index,plan,location)
