extends RefCounted
## Local-only versioned state. No server authority, backups, or silent corrupt reset.
const PATH := "user://progress.json"
const VERSION := 3
# pret/pokefirered 7e3f822: new_game.c, money.c, item.c, shop.c, items.json.
const INITIAL_MONEY := 3000
const MAX_MONEY := 999999
const STACK_LIMIT := 999
const PURCHASE_LIMIT := 99
const SHOP := {"awakenings":{"name":"解眠药","price":250},"elixirs":{"name":"全招式回复剂","price":3000},"max_revives":{"name":"活力块","price":4000},"moon_stones":{"name":"月之石","price":0},"balls":{"name":"精灵球","price":200},"potions":{"name":"伤药","price":300},"super_potions":{"name":"好伤药","price":700},"hyper_potions":{"name":"厉害伤药","price":1200},"ultra_balls":{"name":"高级球","price":1200},"great_balls":{"name":"超级球","price":600},"full_restores":{"name":"全复药","price":3000},"max_potions":{"name":"全满药","price":2500},"revives":{"name":"活力碎片","price":1500},"full_heals":{"name":"万灵药","price":600},"max_repels":{"name":"黄金喷雾","price":700},"fresh_water":{"name":"清凉水","price":200},"soda_pop":{"name":"苏打汽水","price":300},"lemonade":{"name":"柠檬汽水","price":350},"fire_stones":{"name":"火之石","price":2100},"thunder_stones":{"name":"雷之石","price":2100},"water_stones":{"name":"水之石","price":2100},"leaf_stones":{"name":"叶之石","price":2100},"hp_ups":{"name":"HP增强剂","price":9800},"proteins":{"name":"蛋白药剂","price":9800},"irons":{"name":"防御药剂","price":9800},"calciums":{"name":"特攻药剂","price":9800},"zincs":{"name":"特防药剂","price":9800},"carbos":{"name":"速度药剂","price":9800},"x_attacks":{"name":"力量强化","price":500},"x_defends":{"name":"防御强化","price":550},"x_speeds":{"name":"速度强化","price":350},"x_specials":{"name":"特攻强化","price":350},"x_accuracies":{"name":"命中强化","price":950},"guard_specs":{"name":"防御喷雾","price":700},"dire_hits":{"name":"要害攻击","price":650},"antidotes":{"name":"解毒药","price":100},"paralyze_heals":{"name":"解麻药","price":200},"burn_heals":{"name":"灼伤药","price":250},"ice_heals":{"name":"解冻药","price":250},"repels":{"name":"除虫喷雾","price":350},"super_repels":{"name":"白银喷雾","price":500},"escape_ropes":{"name":"离洞绳","price":550},"poke_dolls":{"name":"皮皮玩偶","price":1000},"retro_mail":{"name":"复古邮件","price":50},"fr_tm05":{"name":"TM05 吼叫","price":1000},"fr_tm15":{"name":"TM15 破坏光线","price":7500},"fr_tm28":{"name":"TM28 挖洞","price":2000},"fr_tm31":{"name":"TM31 劈瓦","price":3000},"fr_tm43":{"name":"TM43 秘密之力","price":3000},"fr_tm45":{"name":"TM45 迷人","price":3000},"fr_tm16":{"name":"TM16 光墙","price":3000},"fr_tm20":{"name":"TM20 神秘守护","price":3000},"fr_tm33":{"name":"TM33 反射壁","price":3000},"nuggets":{"name":"金珠","price":10000},"rare_candies":{"name":"神奇糖果","price":4800},"sun_stones":{"name":"日之石","price":2100},"tm_blizzard":{"name":"TM14 暴风雪","price":5000},"tm_body_slam":{"name":"TM08 泰山压顶","price":4000},"tm_double_edge":{"name":"TM10 舍身冲撞","price":4000},"tm_double_team":{"name":"TM32 影子分身","price":1000},"tm_earthquake":{"name":"TM26 地震","price":4000},"tm_egg_bomb":{"name":"TM37 炸蛋","price":2000},"tm_explosion":{"name":"TM47 大爆炸","price":3000},"tm_horn_drill":{"name":"TM07 角钻","price":2000},"tm_mega_kick":{"name":"TM05 百万吨重踢","price":3000},"tm_pay_day":{"name":"TM16 聚宝功","price":5000},"tm_rage":{"name":"TM20 愤怒","price":2000},"tm_razor_wind":{"name":"TM02 旋风刀","price":2000},"tm_skull_bash":{"name":"TM40 火箭头锤","price":4000},"tm_sky_attack":{"name":"TM43 神鸟猛击","price":5000},"tm_solarbeam":{"name":"TM22 日光束","price":5000},"tm_submission":{"name":"TM17 地狱翻滚","price":3000},"tm_swords_dance":{"name":"TM03 剑舞","price":2000},"tm_take_down":{"name":"TM09 猛撞","price":3000},"tm_dig":{"name":"TM28 挖洞","price":2000},"kingsrock":{"name":"王者之证","price":100},"metalcoat":{"name":"金属膜","price":100},"dragonscale":{"name":"龙之鳞片","price":2100},"upgrade":{"name":"升级数据","price":2100},"everstone":{"name":"不变之石","price":200},"soothebell":{"name":"安抚之铃","price":100}}
const BATTLE_ITEMS := ["x_attacks","x_defends","x_speeds","x_specials","x_accuracies","guard_specs","dire_hits"]
const BATTLE_ITEM_PRICES := {"x_attacks":500,"x_defends":550,"x_speeds":350,"x_specials":350,"x_accuracies":950,"guard_specs":700,"dire_hits":650}
const BATTLE_ITEM_NAMES := {"x_attacks":"力量强化","x_defends":"防御强化","x_speeds":"速度强化","x_specials":"特攻强化","x_accuracies":"命中强化","guard_specs":"防御喷雾","dire_hits":"要害攻击"}
var gym_rewards=preload("res://scripts/gym_rewards.gd").new()
var item_mail=preload("res://scripts/item_mail.gd").new()
var inventory=preload("res://scripts/item_inventory.gd").new()
var evolution_service=preload("res://scripts/evolution_service.gd").new()
var friendship=preload("res://scripts/friendship.gd").new()
var stone_evolution=preload("res://scripts/stone_evolution.gd").new()
var vitamins=preload("res://scripts/vitamins.gd").new()
var roof_drinks=preload("res://scripts/roof_drinks.gd").new()
var counter_tutor=preload("res://scripts/counter_tutor.gd").new()
var celadon_lift=preload("res://scripts/celadon_lift.gd").new()
var pokedex = preload("res://scripts/pokedex.gd").new()
var sevii = preload("res://scripts/sevii.gd").new()
var sevii_hm = preload("res://scripts/sevii_hm.gd").new()
var flash = preload("res://scripts/flash.gd").new()
var flash_reward = preload("res://scripts/flash_reward.gd").new()
var seafoam = preload("res://scripts/seafoam.gd").new()
var travel = preload("res://scripts/travel.gd").new()
var league = preload("res://scripts/league.gd").new()
var hall_of_fame = preload("res://scripts/hall_of_fame.gd").new()
var medicine = preload("res://scripts/medicine.gd").new()
var pokemon_mansion = preload("res://scripts/pokemon_mansion.gd").new()
var league_gate = preload("res://scripts/league_gate.gd").new()
var strength = preload("res://scripts/strength.gd").new()
var surf = preload("res://scripts/surf.gd").new()
var safari_rewards = preload("res://scripts/safari_rewards.gd").new()
var safari = preload("res://scripts/safari.gd").new()
var silph_story = preload("res://scripts/silph_story.gd").new()
var saffron_rules = preload("res://scripts/saffron_rules.gd").new()
var tea_rules = preload("res://scripts/mansion_tea.gd").new()
var ordinary_items = preload("res://scripts/ordinary_items.gd").new()
var ground_items = preload("res://scripts/ground_items.gd").new()
var tower_story = preload("res://scripts/tower_story.gd").new()
var post_b3 = preload("res://scripts/post_b3.gd").new()
var rocket_rules = preload("res://scripts/rocket_entry.gd").new()
var gym_rules = preload("res://scripts/vermilion_puzzle.gd").new()
var cinnabar_gym = preload("res://scripts/cinnabar_gym.gd").new()
var dojo_rules = preload("res://scripts/dojo_rules.gd").new()
var cut_rules = preload("res://scripts/ssanne_cut.gd").new()
var thief_rules = preload("res://scripts/cerulean_thief.gd").new()
var bill_rules = preload("res://scripts/bill.gd").new()
var bridge_rules = preload("res://scripts/nugget_bridge.gd").new()
var fossil_rules = preload("res://scripts/fossil.gd").new()
var storage_rules = preload("res://scripts/storage.gd").new()
var growth = preload("res://scripts/growth.gd").new()
var species: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/pets.json"))
var state: Dictionary = {}
var error: String = ""

func create_individual(species_id: String, current_hp: int = -1, level: int = 10, explicit_moves: Array = []) -> Dictionary:
	var known: Array = explicit_moves.duplicate() if not explicit_moves.is_empty() else growth.level_moves(species_id,level)
	var pp: Dictionary = {}
	for move in known:pp[move] = int(growth.moves[move]["pp"])
	var pet: Dictionary = {"individual_id":Crypto.new().generate_random_bytes(12).hex_encode(),"species_id":species_id,"level":level,"exp":growth.experience(species_id,level),"ivs":growth.zeros(),"evs":growth.zeros(),"nature":{"up":"","down":""},"moves":known,"pp":pp}
	pet["friendship"]=int(species[species_id].get("base_friendship",70))
	pet["hp"] = int(growth.stats(pet)["hp"]) if current_hp<0 else clampi(current_hp,0,int(growth.stats(pet)["hp"]))
	return pet

func new_game(species_id: String) -> bool:
	state = {"version":VERSION, "team":[create_individual(species_id)], "balls":10, "potions":5, "lead":0, "money":INITIAL_MONEY,"starter":species_id,"trainers":{},"storage":storage_rules.empty()}
	pokedex.register(state,species,species_id,true)
	return save_game()

func validate(value: Variant) -> bool:
	if not value is Dictionary or value.get("version") != VERSION:
		return false
	if value.has("evolution_gifts") and (not value["evolution_gifts"] is Dictionary or value["evolution_gifts"].size()!=1 or not value["evolution_gifts"].get("eevee") is bool):return false
	if value.has("national_dex") and not value["national_dex"] is bool:return false
	if value.has("friendship_steps") and not _integer(value["friendship_steps"],0,127):return false
	if value.has("evolution_inventory"):
		if not value["evolution_inventory"] is Dictionary:return false
		for item in value["evolution_inventory"]:
			if not evolution_service.ITEMS.has(item) or not _integer(value["evolution_inventory"][item],0,STACK_LIMIT):return false
	if value.has("counter_taught") and not value["counter_taught"] is bool:return false
	if value.has("tm27_received") and not value["tm27_received"] is bool:return false
	if not inventory.valid(value) or not ground_items.valid(value):return false
	if not gym_rewards.valid(value) or not sevii_hm.valid(value) or not sevii.valid(value):return false
	if value.has("escape_return"):
		var e:Variant=value["escape_return"]
		if not e is Dictionary or not e.get("map_id") is String or not _integer(e.get("x"),0,20000) or not _integer(e.get("y"),0,20000):return false
	if not celadon_lift.valid(value):return false
	if not pokedex.valid(value) or not flash_reward.valid(value):return false
	if value.has("static_encounters"):
		if not value["static_encounters"] is Dictionary:return false
		for k in value["static_encounters"]:
			if k not in ["route12_snorlax","route16_snorlax"] or not value["static_encounters"][k] is bool:return false
	if not travel.valid(value) or not seafoam.valid(value):return false
	if not league.valid(value) or not hall_of_fame.valid(value):return false
	if not pokemon_mansion.valid(value):return false
	if not strength.valid(value) or not league_gate.valid(value):return false
	if not surf.valid(value):return false
	if not safari_rewards.valid(value):return false
	if not safari.valid(value):return false
	if not silph_story.valid(value):return false
	if value.has("dojo_story") and (not value["dojo_story"] is Dictionary or value["dojo_story"].size()!=1 or not value["dojo_story"].get("gift_received") is bool):return false
	if not post_b3.valid(value) or not tower_story.valid(value) or not tea_rules.valid(value) or not saffron_rules.valid(value):return false
	if not rocket_rules.valid(value):return false
	if not gym_rules.valid(value) or not cut_rules.valid(value) or not cinnabar_gym.valid(value):return false
	if not fossil_rules.valid(value) or not bridge_rules.valid(value) or not bill_rules.valid(value) or not thief_rules.valid(value):return false
	if not value.get("team") is Array or value["team"].size() < 1 or value["team"].size() > 6:
		return false
	if not _integer(value.get("potions"),0,STACK_LIMIT) or not _integer(value.get("balls"), 0, STACK_LIMIT) or not _integer(value.get("lead"), 0, value["team"].size()-1):
		return false
	for item in medicine.NEW_ITEMS:
		if value.has(item) and not _integer(value[item],0,STACK_LIMIT):return false
	for item in stone_evolution.ITEMS:
		if value.has(item) and not _integer(value[item],0,STACK_LIMIT):return false
	for item in vitamins.ITEMS:
		if value.has(item) and not _integer(value[item],0,STACK_LIMIT):return false
	for item in roof_drinks.ITEMS:
		if value.has(item) and not _integer(value[item],0,STACK_LIMIT):return false
	if value.has("roof_exchanges"):
		if not value["roof_exchanges"] is Dictionary:return false
		for item in value["roof_exchanges"]:
			if item not in roof_drinks.ITEMS or not value["roof_exchanges"][item] is bool:return false
	for item in BATTLE_ITEMS:
		if value.has(item) and not _integer(value[item],0,STACK_LIMIT):return false
	if value.has("repel_steps") and not _integer(value["repel_steps"],0,250):return false
	if value.has("flash_active") and not value["flash_active"] is bool:return false
	if value.has("master_balls") and not _integer(value["master_balls"],0,STACK_LIMIT):return false
	if value.has("super_potions") and not _integer(value["super_potions"],0,STACK_LIMIT):return false
	if value.has("hyper_potions") and not _integer(value["hyper_potions"],0,STACK_LIMIT):return false
	if value.has("money") and not _integer(value["money"],0,MAX_MONEY):return false
	if value.has("starter") and value["starter"] not in ["bulbasaur","charmander","squirtle"]:return false
	if value.has("badges"):
		if not value["badges"] is Dictionary:return false
		for badge in value["badges"]:
			if badge not in ["boulder","cascade","thunder","rainbow","marsh","soul","volcano","earth"] or not value["badges"][badge] is bool:return false
	if value.has("trainers"):
		if not value["trainers"] is Dictionary:return false
		for flag in value["trainers"]:
			if not value["trainers"][flag] is bool:return false
	var all_pets: Array = value["team"].duplicate()
	if value.has("storage"):
		var storage: Variant = value["storage"]
		if not storage is Dictionary or not _integer(storage.get("current_box"),0,13) or not _integer(storage.get("send_box"),0,13):return false
		if not storage.get("boxes") is Array or storage["boxes"].size()!=14:return false
		for box in storage["boxes"]:
			if not box is Array or box.size()!=30:return false
			for pet in box:
				if pet!=null:all_pets.append(pet)
	var move_data: Dictionary = growth.moves
	var ids: Array[String] = []
	for pet in all_pets:
		if not pet is Dictionary or not pet.get("individual_id") is String or pet["individual_id"].length() < 8:
			return false
		if pet["individual_id"] in ids or not species.has(pet.get("species_id", "")):
			return false
		if not _integer(pet.get("level"),1,100) or not pet.get("pp") is Dictionary:
			return false
		if pet.has("friendship") and not _integer(pet["friendship"],0,255):return false
		if pet.has("held_item") and not pet["held_item"] is String:return false
		if pet.has("mail_text") and (not pet["mail_text"] is String or pet["mail_text"].length()>120 or pet.get("held_item","")!="retro_mail"):return false
		if not pet.get("moves") is Array or pet["moves"].size()<1 or pet["moves"].size()>4:return false
		if not pet.get("ivs") is Dictionary or not pet.get("evs") is Dictionary or not pet.get("nature") is Dictionary:return false
		var ev_total: int = 0
		for stat in growth.STATS:
			if not _integer(pet["ivs"].get(stat),0,31) or not _integer(pet["evs"].get(stat),0,255):return false
			ev_total += int(pet["evs"][stat])
		if ev_total>510:return false
		if pet["nature"].get("up") not in ["","atk","def","spa","spd","spe"] or pet["nature"].get("down") not in ["","atk","def","spa","spd","spe"]:return false
		if not _integer(pet.get("exp"),growth.experience(pet["species_id"],int(pet["level"])),growth.experience(pet["species_id"],100)):return false
		if int(pet["level"])<100 and int(pet["exp"])>=growth.experience(pet["species_id"],int(pet["level"])+1):return false
		var seen: Array = []
		for move in pet["moves"]:
			if not move_data.has(move) or move in seen:return false
			seen.append(move)
			if not _integer(pet["pp"].get(move),0,int(move_data[move]["pp"])):
				return false
		ids.append(pet["individual_id"])
		if not _integer(pet.get("hp"), 0, int(growth.stats(pet)["hp"])):
			return false
	return true

func _integer(value: Variant, low: int, high: int) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and float(value) == floor(float(value)) and value >= low and value <= high

func load_game() -> String:
	if not FileAccess.file_exists(PATH):
		return "missing"
	var file := FileAccess.open(PATH, FileAccess.READ)
	if not file:
		error = "存档无法读取，请检查文件权限。原文件已保留。"
		return "corrupt"
	var parser := JSON.new()
	var parse_error := parser.parse(file.get_as_text())
	var value: Variant = parser.data if parse_error == OK else null
	if value is Dictionary and value.get("version")==1:
		value = migrate_v1(value)
	if value is Dictionary and value.get("version")==2:
		value = migrate_v2(value)
	if not validate(value):
		error = "存档损坏或版本不兼容。原文件未改动；确认新建才会替换。"
		return "corrupt"
	state = value
	if not state.has("gym_tm_claims"):state["gym_tm_claims"]={}
	ground_items.migrate_inventory(state)
	# Loading/migrating is read-only. Persist defaults only on an intentional save.
	if not state.has("money"):
		state["money"] = INITIAL_MONEY
	if not state.has("starter"):
		state["starter"] = preload("res://scripts/trainer.gd").new().infer_starter(state)
	if not state.has("trainers"):
		state["trainers"] = {}
	if not state.has("storage"):
		state["storage"] = storage_rules.empty()
	return "loaded"

func save_game() -> bool:
	if not validate(state):
		error = "存档数据校验失败，未写入。"
		return false
	var temp := PATH + ".tmp"
	var file := FileAccess.open(temp, FileAccess.WRITE)
	if not file:
		error = "保存失败：无法写入本地目录。请检查权限后重试。"
		return false
	var payload: PackedByteArray = JSON.stringify(state).to_utf8_buffer()
	file.store_buffer(payload)
	file.flush()
	var write_error := file.get_error()
	file.close()
	# Some file backends return OK after a short buffered write (e.g. EFBIG).
	# Verify the closed temporary file before atomically replacing valid progress.
	if write_error != OK or FileAccess.get_file_as_bytes(temp) != payload:
		error = "保存失败：写入异常，旧存档保留。"
		return false
	var rename_error := DirAccess.rename_absolute(ProjectSettings.globalize_path(temp), ProjectSettings.globalize_path(PATH))
	if rename_error != OK:
		error = "保存失败：无法替换存档，旧进度保留。"
		return false
	error = ""
	return true

func heal_party() -> void:
	# Existing battle has no primary-status engine. Clear only present compatible fields.
	for pet in state["team"]:
		pet["hp"] = int(growth.stats(pet)["hp"])
		for move in pet["moves"]:pet["pp"][move] = int(growth.moves[move]["pp"])
		for field in ["status","status1","primary_status"]:
			if pet.has(field):pet[field] = "" if pet[field] is String else 0
		for field in ["sleep_turns","toxic_counter","status_turns"]:
			if pet.has(field):pet[field] = 0

func heal_and_supply() -> void:
	for pet in state["team"]:
		pet["hp"] = int(growth.stats(pet)["hp"])
		for move in pet["moves"]:pet["pp"][move] = int(growth.moves[move]["pp"])
	state["balls"] = 10
	state["potions"] = 5

func migrate_v1(old: Dictionary) -> Variant:
	if not old.get("team") is Array or not _integer(old.get("balls"),0,99) or not _integer(old.get("lead"),0,old["team"].size()-1):
		return null
	var migrated: Dictionary = old.duplicate(true)
	for index in range(migrated["team"].size()):
		var pet: Variant = migrated["team"][index]
		if not pet is Dictionary or not pet.get("individual_id") is String:
			return null
		var id: String = pet.get("species_id","")
		var target: String = {"moss_turtle":"squirtle","camp_fox":"rattata"}.get(id,id)
		if not species.has(target):
			return null
		var old_max: int = 36 if id=="moss_turtle" else 38 if id=="camp_fox" else int(species[target]["max_hp"])
		if not _integer(pet.get("hp"),0,old_max):
			return null
		var new_pet := create_individual(target,ceili(float(pet["hp"])*int(species[target]["max_hp"])/old_max))
		new_pet["individual_id"] = pet["individual_id"]
		migrated["team"][index] = new_pet
	migrated["version"] = VERSION
	migrated["potions"] = 5
	return migrated

func migrate_v2(old: Dictionary) -> Variant:
	if not old.get("team") is Array:return null
	var migrated: Dictionary = old.duplicate(true)
	for pet in migrated["team"]:
		if not pet is Dictionary or not species.has(pet.get("species_id","")) or not _integer(pet.get("level"),10,10) or not pet.get("pp") is Dictionary:return null
		pet["moves"] = pet.get("moves",species[pet["species_id"]]["moves"]).duplicate()
		pet["exp"] = growth.experience(pet["species_id"],int(pet["level"]))
		pet["ivs"] = pet.get("ivs",growth.zeros())
		pet["evs"] = pet.get("evs",growth.zeros())
		pet["nature"] = pet.get("nature",{"up":"","down":""})
	migrated["version"] = VERSION
	return migrated

func purchase(item: String, quantity: int) -> String:
	if not SHOP.has(item) or int(SHOP[item]["price"])<=0 or quantity<1 or quantity>PURCHASE_LIMIT:return "购买数量无效。"
	if not validate(state) or not state.has("money"):return "存档数据无效，未交易。"
	var total: int = int(SHOP[item]["price"])*quantity
	if int(state["money"])<total:return "余额不足，未扣款、未发货。"
	var capacity:String=inventory.receive_error(state,item,quantity)
	if capacity!="":return capacity
	var before: Dictionary = state.duplicate(true)
	state["money"] = int(state["money"])-total
	inventory.add(state,item,quantity)
	if not save_game():
		state = before
		return error+" 本次交易已取消，余额与库存未变。"
	return ""

func pc_action(action: String, box: int, slot: int = -1, party: int = -1) -> String:
	var before: Dictionary = state.duplicate(true)
	var failure: String = storage_rules.apply(self,action,box,slot,party)
	if failure!="":return failure
	if not save_game():
		state = before
		return error+" 操作已取消，队伍与盒子未变。"
	return ""

func receive_capture(pet: Dictionary) -> Dictionary:
	var destination: Dictionary = storage_rules.receive(self,pet)
	if not destination.has("error"):pokedex.register(state,species,pet["species_id"],true)
	return destination

func can_receive_capture() -> bool:
	return state["team"].size()<6 or not storage_rules.first_space(state).is_empty()

func sell(item:String,quantity:int)->String:
	if not validate(state):return "存档数据无效。"
	if not SHOP.has(item) or int(SHOP[item]["price"])<=0 or quantity<1 or quantity>PURCHASE_LIMIT:return "不能出售该道具。"
	if inventory.quantity(state,item)<quantity:return "道具数量不足。"
	var total:int=int(SHOP[item]["price"])/2*quantity
	if int(state["money"])+total>MAX_MONEY:return "金额达到上限。"
	var before:Dictionary=state.duplicate(true)
	inventory.add(state,item,-quantity);state["money"]+=total
	if not save_game():state=before;return error
	return ""
