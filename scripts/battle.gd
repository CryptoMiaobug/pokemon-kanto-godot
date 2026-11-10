extends Control
const Language = preload("res://scripts/language.gd")
signal finished(won: bool)
signal telemetry(value: Dictionary)
const UI = preload("res://scripts/ui.gd")
var store: RefCounted
var items: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/items.json"))
var rules = preload("res://scripts/rules.gd").new()
var baton_pending: bool = false
var destiny_bonds: Dictionary = {}
var copied_abilities: Dictionary = {}
var grudges:Dictionary={}
var uproars:Dictionary={}
var original_held_items:Dictionary={}
var biding:Dictionary={}
var taunted:Dictionary={}
var tormented:Dictionary={}
var wishes:Dictionary={}
var magic_coats:Dictionary={}
var snatches:Dictionary={}
var substitutes:Dictionary={}
var mimicked:Dictionary={}
var mirror_moves:Dictionary={}
var minimized:Dictionary={}
var rampage_moves:Dictionary={}
var sun_turns:int=0
var recharging:Dictionary={}
var enduring:Dictionary={}
var stockpiles:Dictionary={}
var rollout_moves:Dictionary={}
var rain_turns: int = 0
var hail_turns:int=0
var submerged:Dictionary={}
var infatuated:Dictionary={}
var solar_charges: Dictionary = {}
var sand_turns: int = 0
var transformed: Dictionary = {}
var field_terrain:String="Normal"
var item_terrain:String="plain"
var pursuit_spent: bool = false
var static_id: String = ""
var safari_mode: bool = false
var safari_bait: int = 0
var safari_rock: int = 0
var safari_catch_factor: int = 0
var safari_escape_factor: int = 1
var yawned: Dictionary = {}
var mother_ghost: bool = false
var trainer_id: String = ""
var enemy_party: Array = []
var enemy_index: int = 0
var trainer_before: Dictionary = {}
var trainer_events: Array = []
var waiting_next: bool = false
var trainer_settled: bool = false
var trainer_ai = preload("res://scripts/rival_ai.gd").new()
var trainer_rules = preload("res://scripts/trainer.gd").new()
var participants: Array = []
var growth_events: Array = []
var evolution = preload("res://scripts/evolution.gd").new()
var evolution_queue: Array = []
var evolution_view: Control
var evolution_entry: Dictionary = {}
var learning: Dictionary = {}
var outcome: String = ""
var player_level: Label
var enemy_level: Label
var enemy: Dictionary
var player_stages: Dictionary
var enemy_stages: Dictionary
var identified: Dictionary = {}
var cursed: Dictionary = {}
var nightmares: Dictionary = {}
var trapped: Dictionary = {}
var payday_coins: int = 0
var payday_settled: bool = false
var battle_before: Dictionary = {}
var friendship_fainted:Dictionary={}
var raging: Dictionary = {}
var field_turns: Dictionary = {}
var rampages: Dictionary = {}
var rampage_unable: Dictionary = {}
var fury_cutters: Dictionary = {}
var rollouts: Dictionary = {}
var curled: Dictionary = {}
var rooted: Dictionary = {}
var direct_damage_sources: Dictionary = {}
var direct_damage_amounts: Dictionary = {}
var direct_damage_physical: Dictionary = {}
var future_attacks: Dictionary = {}
var perish_counts: Dictionary = {}
var protected: Dictionary = {}
var protect_uses: Dictionary = {}
var safeguard_turns: Dictionary = {"player":0,"enemy":0}
var lock_ons: Dictionary = {} # target individual -> source individual, two end-turn ticks
var mist_turns: Dictionary = {"player":0,"enemy":0}
var reflect_turns: Dictionary = {"player":0,"enemy":0}
var light_screen_turns: Dictionary = {"player":0,"enemy":0}
var bindings: Dictionary = {} # Battle-local victim ID -> source ID and remaining encoded turns.
var last_moves: Dictionary = {}
var disabled_moves: Dictionary = {}
var mud_sport: Dictionary = {}
var water_sport: Dictionary = {}
var focused: Dictionary = {}
var enemy_items: Array = []
var north_rules: bool = false
var charged: Dictionary = {}
# FireRed 7e3f822: EffectSemiInvulnerable / CancelMultiTurnMoves.
var airborne: Dictionary = {}
var underground: Dictionary = {}
var confused: Dictionary = {}
var encored_moves: Dictionary = {}
var imprisoned_by: Dictionary = {}
var flinched: Dictionary = {}
var item_abilities:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://data/item-abilities.json"))
var knocked_items:Dictionary={}
var consumed_items:Dictionary={}
var kings_rock_moves:Array=JSON.parse_string(FileAccess.get_file_as_string("res://data/kings-rock-moves.json"))["moves"]
var acted: Dictionary = {}
var arena_path: String = "res://assets/pokemon/grass-arena.png"
var seeded_player: bool = false
var seeded_enemy: bool = false
var busy: bool = false
var ended: bool = false
var won: bool = false
var turn: int = 1
var run_tries: int = 0
var bag_page:int=0
var medicine_pending:String=""
var spikes:Dictionary={"player":0,"enemy":0}
const BAG_ITEMS := ["balls","potions","super_potions","master_balls","hyper_potions","max_potions","full_restores","revives","full_heals","great_balls","ultra_balls","x_attacks","x_defends","x_speeds","x_specials","x_accuracies","guard_specs","dire_hits","awakenings","elixirs","max_revives","fresh_water","soda_pop","lemonade","poke_flute","antidotes","paralyze_heals","burn_heals","ice_heals","poke_dolls"]
var dire_hit_used:Dictionary={}
var mode: String = "root"
var canvas: Control
var log_text: String = Language.text("battle.59120bc4bfe0","野生的小拉达出现了！")
var log_label: Label
var menu: Control
var portrait: TextureRect
var enemy_portrait: TextureRect
var hp_label: Label
var enemy_label: Label
var hp_bar: ProgressBar
var enemy_bar: ProgressBar
var presentation:Control
var visual_depth:int=0
var visual_events:Array=[]
var visual_before:Dictionary={}

func _ready() -> void:
	rules.ability_resolver=_item_ability
	battle_before = store.state.duplicate(true)
	for pet in store.state["team"]+enemy_party+[enemy]:
		if pet.has("individual_id"):original_held_items[pet["individual_id"]]=pet.get("held_item","")
	if trainer_id!="":
		trainer_before = store.state.duplicate(true)
		if trainer_rules.definition(trainer_id).get("badge","")!="" or trainer_id.begins_with("league_"):
			for pet in store.state["team"]:store.friendship.adjust(pet,"league",store.state.get("location",{}).get("map_id",""))
		enemy_items = trainer_rules.definition(trainer_id).get("items",[]).duplicate()
		enemy = enemy_party[0]
	elif enemy.is_empty():enemy = store.create_individual("rattata")
	store.pokedex.register(store.state,store.species,enemy["species_id"],false)
	if safari_mode:
		var species: Dictionary = store.species[enemy["species_id"]]
		safari_catch_factor = maxi(1, floori(int(species.get("catch_rate",45))*100.0/1275.0))
		safari_escape_factor = maxi(2, floori(int(species.get("safari_flee_rate",0))*100.0/1275.0))
	participants.append(int(store.state["lead"]))
	log_text = (Language.text("battle.d74da5c327bd","%s派出了%s！") % [trainer_rules.definition(trainer_id)["name"],Language.name(store.species[enemy["species_id"]]["name"])]) if trainer_id!="" else Language.text("battle.7897c13bdda0","野生的%s出现了！") % Language.name(store.species[enemy["species_id"]]["name"])
	player_stages = rules.stages()
	enemy_stages = rules.stages()
	canvas = Control.new()
	canvas.position = Vector2(0,0)
	canvas.scale = Vector2(1,1)
	add_child(canvas)
	_image(arena_path,Rect2(0,0,960,448))
	if trainer_id!="":
		var info: Dictionary = trainer_rules.definition(trainer_id)
		_image(info["portrait"],Rect2(441,15,96,96))
		UI.label(canvas,info.get("title",Language.trainer_name(trainer_id,info["name"])+" · 常青森林"),Rect2(24,4,410,30),19)
	portrait = _image(store.species[active_pet()["species_id"]]["back"],Rect2(96,192,256,256))
	enemy_portrait = _image(store.species[enemy["species_id"]]["sprite"],Rect2(592,40,256,256))
	_image("res://assets/pokemon/healthbox-enemy.png",Rect2(20,40,416,128))
	_image("res://assets/pokemon/healthbox-player.png",Rect2(520,274,416,128))
	hp_label = UI.label(canvas,"",Rect2(568,285,215,36),20)
	enemy_label = UI.label(canvas,"",Rect2(52,51,215,36),20)
	player_level = UI.label(canvas,"",Rect2(800,294,95,30),19)
	enemy_level = UI.label(canvas,"",Rect2(300,60,95,30),19)
	_image("res://assets/pokemon/health-slot.png",Rect2(632,342,216,32))
	_image("res://assets/pokemon/health-slot.png",Rect2(132,108,216,32))
	hp_bar = _bar(Vector2(688,354))
	enemy_bar = _bar(Vector2(188,120))
	UI.panel(canvas,Rect2(0,448,960,192))
	log_label = UI.label(canvas,"",Rect2(30,462,430,150),21)
	log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	menu = Control.new()
	canvas.add_child(menu)
	var entries:Array=[{"pet":active_pet(),"player":true},{"pet":enemy,"player":false}]
	entries.sort_custom(func(a,c):return rules.speed(a["pet"],rules.stages())>rules.speed(c["pet"],rules.stages()))
	for entry in entries:_ability_entry(entry["pet"],entry["player"])
	_sync_weather()
	presentation=preload("res://scripts/battle_presentation.gd").new();canvas.add_child(presentation);presentation.setup(self)
	presentation.presented.connect(func(value:Dictionary):telemetry.emit(value))
	telemetry.connect(func(value:Dictionary):
		if visual_depth>0 and value.get("event","")!="battle_animation":visual_events.append(value.duplicate(true)))
	_update()

func _field_pets() -> Array:
	return [active_pet(),enemy]

func _find_field_pet(id:String)->Dictionary:
	for pet in _field_pets():
		if pet["individual_id"]==id:return pet
	return {"hp":0,"moves":[],"pp":{}}

func _side(pet:Dictionary)->String:
	return "player" if store.state["team"].any(func(p):return p["individual_id"]==pet["individual_id"]) else "enemy"

func _effect_key(pet:Dictionary)->String:
	return _side(pet)

func _effect_pet(key:String)->Dictionary:
	return active_pet() if key=="player" else enemy

func active_pet() -> Dictionary:
	return store.state["team"][int(store.state["lead"])]

func _image(path: String,rect: Rect2) -> TextureRect:
	var image := TextureRect.new()
	image.texture = load(path)
	image.position = rect.position
	image.size = rect.size
	image.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	canvas.add_child(image)
	return image

func _bar(pos: Vector2) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.position = pos
	bar.size = Vector2(144,6)
	bar.show_percentage = false
	bar.add_theme_font_size_override("font_size",1)
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color("50c878")
	fill.content_margin_top = 0
	fill.content_margin_bottom = 0
	var background := StyleBoxFlat.new()
	background.bg_color = Color("c0c0a8")
	background.content_margin_top = 0
	background.content_margin_bottom = 0
	bar.add_theme_stylebox_override("background",background)
	bar.add_theme_stylebox_override("fill",fill)
	canvas.add_child(bar)
	bar.size = Vector2(144,6)
	return bar

func _unhandled_key_input(event: InputEvent) -> void:
	if is_instance_valid(evolution_view):return
	if not event is InputEventKey or not event.pressed or event.echo or busy:
		return
	if not learning.is_empty():
		if event.physical_keycode in [KEY_1,KEY_2,KEY_3,KEY_4,KEY_5]:_learn_choice(event.physical_keycode-KEY_1)
		return
	if ended:
		if event.physical_keycode in [KEY_E,KEY_ENTER,KEY_SPACE]:
			if waiting_next:_advance_enemy()
			else:finished.emit(won)
		elif event.physical_keycode == KEY_R and not waiting_next and trainer_id=="":
			store.heal_and_supply()
			finished.emit(won)
		return
	if baton_pending:
		if event.physical_keycode in [KEY_1,KEY_2,KEY_3,KEY_4,KEY_5,KEY_6]:_complete_baton(event.physical_keycode-KEY_1,true)
		return
	if mode=="bag" and event.physical_keycode in [KEY_LEFT,KEY_RIGHT]:
		bag_page=(bag_page+(1 if event.physical_keycode==KEY_RIGHT else ceili(float(BAG_ITEMS.size())/4.0)-1))%ceili(float(BAG_ITEMS.size())/4.0)
		_update();return
	if event.physical_keycode == KEY_ESCAPE:
		medicine_pending=""
		mode = "root"
		_update()
	elif event.physical_keycode == KEY_C:
		if safari_mode:
			await _safari_throw("ball")
		else:
			await _catch()
	elif event.physical_keycode == KEY_T:
		mode = "team"
		_update()
	elif event.physical_keycode in [KEY_1,KEY_2,KEY_3,KEY_4,KEY_5,KEY_6]:
		_select(event.physical_keycode-KEY_1)

func _select(index: int) -> void:
	if busy or ended:
		return
	match mode:
		"root":
			if safari_mode:
				if index==0:_safari_throw("ball")
				elif index==1:_safari_throw("rock")
				elif index==2:_safari_throw("bait")
				elif index==3:_escape()
				return
			if index==3:
				_escape()
				return
			if index>2:return
			mode = ["moves","bag","team"][index]
			_update()
		"moves":
			if not _has_usable_move(active_pet()):
				_choose("struggle");return
			var ids: Array = active_pet()["moves"]
			if index<ids.size():
				_choose(ids[index])
		"bag":
			var slot:int=bag_page*4+index
			if index>3 or slot>=BAG_ITEMS.size():return
			var item:String=BAG_ITEMS[slot]
			if item in store.BATTLE_ITEMS:_use_battle_item(item)
			elif item in ["balls","master_balls","great_balls","ultra_balls"]:_catch(item)
			elif item=="poke_flute":_use_flute()
			elif item=="poke_dolls":_use_doll()
			else:medicine_pending=item;mode="medicine_target";_update()
		"medicine_target":
			if index<store.state["team"].size():_medicine(index)
		"team":
			_switch(index)

func _disabled(pet: Dictionary, move: String) -> bool:
	if disabled_moves.get(pet["individual_id"],{}).get("move","")==move:return true
	if taunted.has(pet["individual_id"]) and rules.moves[move]["category"]=="Status":return true
	if tormented.has(pet["individual_id"]) and last_moves.get(pet["individual_id"],"")==move and move!="struggle":return true
	var foe: Dictionary = enemy if pet["individual_id"]!=enemy["individual_id"] else active_pet()
	return int(foe["hp"])>0 and imprisoned_by.has(foe["individual_id"]) and move in foe["moves"]

func _has_usable_move(pet: Dictionary) -> bool:
	for move in pet["moves"]:
		if int(pet["pp"].get(move,0))>0 and not _disabled(pet,move):return true
	return false

func _forced_move(pet: Dictionary, selected: String) -> String:
	var key: String = pet["individual_id"]
	if biding.has(key):return "bide"
	if uproars.has(key):return "uproar"
	if solar_charges.has(key):return str(solar_charges[key])
	if airborne.has(key):return str(airborne[key])
	if underground.has(key):return "dig"
	if submerged.has(key):return "dive"
	if rampages.has(key):return rampage_moves.get(key,"thrash")
	if rollouts.has(key):return rollout_moves.get(key,"rollout")
	if not encored_moves.has(key):return selected
	var move: String = encored_moves[key]["move"]
	if move not in pet["moves"] or int(pet["pp"].get(move,0))<=0:
		encored_moves.erase(key);return selected
	return "struggle" if _disabled(pet,move) else move

func _choose(id: String) -> void:
	id = _forced_move(active_pet(),id)
	if _disabled(active_pet(),id) and not airborne.has(active_pet()["individual_id"]) and not underground.has(active_pet()["individual_id"]) and not submerged.has(active_pet()["individual_id"]):return
	if busy or ended or int(active_pet()["hp"])<=0 or (id!="struggle" and not airborne.has(active_pet()["individual_id"]) and not underground.has(active_pet()["individual_id"]) and not submerged.has(active_pet()["individual_id"]) and not solar_charges.has(active_pet()["individual_id"]) and not rollouts.has(active_pet()["individual_id"]) and not rampages.has(active_pet()["individual_id"]) and not biding.has(active_pet()["individual_id"]) and not uproars.has(active_pet()["individual_id"]) and not recharging.has(active_pet()["individual_id"]) and int(active_pet()["pp"].get(id,0))<=0):
		return
	busy = true
	mode = "root"
	acted.clear();flinched.clear();direct_damage_sources.clear();direct_damage_amounts.clear();direct_damage_physical.clear()
	var enemy_move: String = _forced_move(enemy,_enemy_move())
	if id!="rage":raging.erase(active_pet()["individual_id"])
	if enemy_move!="rage":raging.erase(enemy["individual_id"])
	var item_action: String = _trainer_item_choice()
	if item_action!="":
		await _use_trainer_item(item_action)
		if not _terminal():await _move(active_pet(),enemy,id,player_stages,enemy_stages,true)
		await _round_end();return
	var initial_player: String = active_pet()["individual_id"]
	var initial_enemy: String = enemy["individual_id"]
	_sync_weather()
	var player_first: bool = rules.first(active_pet(),enemy,id,enemy_move,player_stages,enemy_stages)
	_update()
	if player_first:
		await _move(active_pet(),enemy,id,player_stages,enemy_stages,true)
		while baton_pending:await get_tree().process_frame
		if not _terminal() and enemy["individual_id"]==initial_enemy:
			await _move(enemy,active_pet(),enemy_move,enemy_stages,player_stages,false)
	else:
		await _move(enemy,active_pet(),enemy_move,enemy_stages,player_stages,false)
		if not _terminal() and int(active_pet()["hp"])>0 and active_pet()["individual_id"]==initial_player:
			await _move(active_pet(),enemy,id,player_stages,enemy_stages,true)
			while baton_pending:await get_tree().process_frame
	await _round_end()

func _move(attacker: Dictionary,defender: Dictionary,id: String,a_stages: Dictionary,d_stages: Dictionary,is_player: bool,called: bool = false) -> void:
	if visual_depth==0:visual_events.clear();visual_before=_visual_snapshot()
	visual_depth+=1
	var result:Dictionary={"succeeded":false}
	await _execute_move(attacker,defender,id,a_stages,d_stages,is_player,called,result)
	# FireRed MOVEEND_MIRROR_MOVE records the chosen move, not a called move.
	visual_depth-=1
	if visual_depth==0:await _visual_finish(is_player,id)
	if not called:_record_mirror_move(attacker,defender,result.get("chosen",id),bool(result["succeeded"]))

func _record_mirror_move(attacker:Dictionary,defender:Dictionary,id:String,succeeded:bool)->void:
	var move:Dictionary=rules.moves[id]
	if succeeded and "FLAG_MIRROR_MOVE_AFFECTED" in move["source_flags"] and move["source_target"]!="MOVE_TARGET_USER" and attacker["individual_id"]!=defender["individual_id"] and int(defender["hp"])>0:
		mirror_moves[defender["individual_id"]]=id

func _execute_move(attacker: Dictionary,defender: Dictionary,id: String,a_stages: Dictionary,d_stages: Dictionary,is_player: bool,called: bool,result:Dictionary) -> void:
	var attacker_id: String = attacker["individual_id"]
	var sketch_before:Dictionary=store.state.duplicate(true) if id=="sketch" and is_player else {}
	if recharging.has(attacker_id) and not called:
		recharging.erase(attacker_id);acted[attacker_id]=true;log_text=Language.text("battle.d9a4454f2a80","正在恢复硬直！");telemetry.emit({"event":"recharge_turn","id":attacker_id});_update();return
	destiny_bonds.erase(attacker_id);grudges.erase(attacker_id)
	if id!="furycutter":fury_cutters.erase(attacker_id)
	acted[attacker_id] = true
	if _item_ability(attacker)=="INNER_FOCUS":flinched.erase(attacker_id)
	if _item_ability(attacker)=="OWN_TEMPO":confused.erase(attacker_id)
	if _item_ability(attacker)=="OBLIVIOUS":infatuated.erase(attacker_id)
	if flinched.has(attacker_id):
		submerged.erase(attacker_id);airborne.erase(attacker_id);underground.erase(attacker_id);solar_charges.erase(attacker_id);fury_cutters.erase(attacker_id);rollouts.erase(attacker_id);rampage_unable[attacker_id] = true
		telemetry.emit({"event":"flinched","individual_id":attacker_id})
		return
	if not called:id = _forced_move(attacker,id)
	result["chosen"]=id
	if not called and infatuated.has(attacker_id) and randf()<0.5:
		submerged.erase(attacker_id);airborne.erase(attacker_id);underground.erase(attacker_id);solar_charges.erase(attacker_id);log_text=Language.text("battle.51b9c44fb485","着迷了，无法行动！");telemetry.emit({"event":"infatuation_blocked"});_update();return
	if not called and attacker.get("status","")=="freeze":
		if id in ["flamewheel","sacredfire"] or randi()%5==0:
			attacker.erase("status");telemetry.emit({"event":"thawed","individual_id":attacker_id})
		else:
			submerged.erase(attacker_id);airborne.erase(attacker_id);underground.erase(attacker_id);solar_charges.erase(attacker_id);fury_cutters.erase(attacker_id);rollouts.erase(attacker_id);rampage_unable[attacker_id] = true
			log_text = Language.text("battle.01fd41a3d79c","冻住了，无法行动！");telemetry.emit({"event":"frozen","individual_id":attacker_id});_update();return
	if not uproars.is_empty() and attacker.get("status","")=="sleep" and _item_ability(attacker)!="SOUNDPROOF":attacker.erase("status");attacker.erase("sleep_turns")
	if not called and attacker.get("status","")=="sleep":
		attacker["sleep_turns"] = maxi(0,int(attacker.get("sleep_turns",1))-(2 if _item_ability(attacker)=="EARLY_BIRD" else 1))
		if int(attacker["sleep_turns"])>0 and id not in ["snore","sleeptalk"]:
			submerged.erase(attacker_id);airborne.erase(attacker_id);underground.erase(attacker_id);solar_charges.erase(attacker_id);fury_cutters.erase(attacker_id);rollouts.erase(attacker_id);rampage_unable[attacker_id] = true
			log_text = Language.text("battle.64727c49bc38","%s还在睡觉！") % Language.display_name(attacker,store.species[attacker["species_id"]]["name"])
			telemetry.emit({"event":"asleep","individual_id":attacker_id})
			_update()
			await get_tree().create_timer(.65).timeout
			return
		if int(attacker.get("sleep_turns",0))<=0:attacker.erase("status");attacker.erase("sleep_turns")
		telemetry.emit({"event":"woke_up","individual_id":attacker_id})
	if _disabled(attacker,id):
		submerged.erase(attacker_id);airborne.erase(attacker_id);underground.erase(attacker_id);solar_charges.erase(attacker_id);fury_cutters.erase(attacker_id);rollouts.erase(attacker_id);rampage_unable[attacker_id] = true
		log_text = Language.text("battle.2264378120f3","招式被封住了！")
		_update()
		await get_tree().create_timer(.65).timeout
		return
	if not called and confused.has(attacker_id):
		confused[attacker_id] = int(confused[attacker_id])-1
		if int(confused[attacker_id])<=0:confused.erase(attacker_id)
		elif randi()%2==0:
			submerged.erase(attacker_id);airborne.erase(attacker_id);underground.erase(attacker_id);solar_charges.erase(attacker_id);fury_cutters.erase(attacker_id);rollouts.erase(attacker_id);rampage_unable[attacker_id] = true
			var stats: Dictionary = rules.pet_stats(attacker)
			var attack: int = rules.staged(int(stats["atk"]),int(a_stages["atk"]))
			var defense: int = rules.staged(int(stats["def"]),int(a_stages["def"]))
			var damage: int = maxi(1,floori(floori((floori(2.0*int(attacker["level"])/5)+2)*40*float(attack)/defense)/50)+2)
			attacker["hp"] = maxi(0,int(attacker["hp"])-damage)
			telemetry.emit({"event":"confusion_self_damage","amount":damage})
			log_text = Language.text("battle.886ab481ad6f","混乱中伤到了自己！");_update()
			await get_tree().create_timer(.65).timeout
			return
	if not called and attacker.get("status","")=="paralysis" and randi()%4==0:
		submerged.erase(attacker_id);airborne.erase(attacker_id);underground.erase(attacker_id);solar_charges.erase(attacker_id);fury_cutters.erase(attacker_id);rollouts.erase(attacker_id);rampage_unable[attacker_id] = true
		log_text = Language.text("battle.92d40735bd58","%s麻痹了，无法行动！") % Language.display_name(attacker,store.species[attacker["species_id"]]["name"])
		_update()
		await get_tree().create_timer(.65).timeout
		return
	_sync_weather()
	var move: Dictionary = rules.moves[id].duplicate(true)
	if move.get("secondary") is Dictionary:
		if _item_ability(attacker)=="SERENE_GRACE":move["secondary"]["chance"]=mini(100,int(move["secondary"].get("chance",0))*2)
	if id=="weatherball" and rules.weather_type!="":
		move=move.duplicate();move["type"]=rules.weather_type;move["category"]="Physical" if rules.weather_type=="Rock" else "Special"
	if id=="hiddenpower":
		move=move.duplicate();move["type"]=rules.hidden_power(attacker)["type"];move["category"]="Physical" if move["type"] in ["Fighting","Flying","Poison","Ground","Rock","Bug","Ghost","Steel"] else "Special"
	if id not in ["protect","detect","endure"]:protect_uses.erase(attacker_id)
	last_moves[attacker_id] = id
	var releasing_solar: bool = id in ["solarbeam","razorwind","skyattack","skullbash"] and solar_charges.has(attacker_id)
	var landing: bool = (id in ["bounce","fly"] and airborne.has(attacker_id)) or (id=="dive" and submerged.has(attacker_id)) or (id=="dig" and underground.has(attacker_id))
	if not called and not landing and not releasing_solar and id!="struggle" and not rollouts.has(attacker_id) and not rampages.has(attacker_id) and not biding.has(attacker_id) and not uproars.has(attacker_id):attacker["pp"][id] = maxi(0,int(attacker["pp"][id])-(2 if _item_ability(defender)=="PRESSURE" and move["target"]!="self" else 1))
	if id=="bide":
		if not biding.has(attacker_id):biding[attacker_id]={"turns":2,"damage":0};log_text=Language.text("battle.60f750f7c97e","开始忍耐！")
		else:
			biding[attacker_id]["turns"]-=1
			if biding[attacker_id]["turns"]<=0:
				var amount:int=int(biding[attacker_id]["damage"])*2;biding.erase(attacker_id)
				amount=_apply_direct(attacker,defender,amount,id);log_text=Language.text("battle.b802eeeedc4d","忍耐释放%d伤害！")%amount
				telemetry.emit({"event":"bide_release","damage":amount})
			else:log_text=Language.text("battle.5a470b4685e1","正在忍耐！")
		_update();return
	if not called and magic_coats.has(defender["individual_id"]) and "FLAG_MAGIC_COAT_AFFECTED" in move["source_flags"]:
		magic_coats.erase(defender["individual_id"]);telemetry.emit({"event":"magic_coat_reflected","move":id});await _move(defender,attacker,id,d_stages,a_stages,not is_player,true);return
	if not called and snatches.has(defender["individual_id"]) and "FLAG_SNATCH_AFFECTED" in move["source_flags"]:
		snatches.erase(defender["individual_id"]);telemetry.emit({"event":"snatched","move":id});await _move(defender,attacker,id,d_stages,a_stages,not is_player,true);return
	if id=="focuspunch" and int(direct_damage_amounts.get(attacker_id,0))>0:
		log_text=Language.text("battle.a36f1af027d6","受到攻击，集中猛击失败！");telemetry.emit({"event":"focus_punch_interrupted"});_update();return
	if id in ["solarbeam","razorwind","skyattack","skullbash"]:
		if not releasing_solar and not (id=="solarbeam" and rules.weather_type=="Fire"):
			if id=="skullbash":a_stages["def"]=mini(6,int(a_stages["def"])+1)
			solar_charges[attacker_id]=id;log_text=Language.text("battle.cad384243b03","正在吸收阳光！") if id=="solarbeam" else Language.text("battle.33a0af894311","正在蓄力！");telemetry.emit({"event":"solar_charge" if id=="solarbeam" else "tm_charge","move":id,"pp":attacker["pp"].get(id,0)});_update();await get_tree().create_timer(.65).timeout;return
		solar_charges.erase(attacker_id);telemetry.emit({"event":"solar_release" if id=="solarbeam" else "tm_release","move":id})
	if id=="dive":
		if not landing:
			submerged[attacker_id]=true;log_text=Language.text("battle.497a0c4fcb40","潜入了水中！");telemetry.emit({"event":"dive_charge","pp":attacker["pp"].get(id,0)});_update();await get_tree().create_timer(.65).timeout;return
		submerged.erase(attacker_id);telemetry.emit({"event":"dive_release","pp":attacker["pp"].get(id,0)})
	if id=="dig":
		if not landing:
			underground[attacker_id]=true;log_text=Language.text("battle.8e232cad5962","挖洞躲进了地下！");telemetry.emit({"event":"dig_charge","individual_id":attacker_id,"pp":attacker["pp"].get(id,0)});_update();await get_tree().create_timer(.65).timeout;return
		underground.erase(attacker_id);telemetry.emit({"event":"dig_release","individual_id":attacker_id,"pp":attacker["pp"].get(id,0)})
	if id in ["bounce","fly"]:
		if not landing:
			airborne[attacker_id] = id
			log_text = Language.text("battle.63515753dce1","%s飞上高空！") % Language.display_name(attacker,store.species[attacker["species_id"]]["name"]) if id=="fly" else Language.text("battle.c99047dbc636","%s高高跳起！") % Language.display_name(attacker,store.species[attacker["species_id"]]["name"])
			telemetry.emit({"event":"fly_charge" if id=="fly" else "bounce_charge","individual_id":attacker_id,"pp":attacker["pp"].get(id,0)})
			_update();await get_tree().create_timer(.65).timeout;return
		airborne.erase(attacker_id)
		telemetry.emit({"event":"fly_land" if id=="fly" else "bounce_land","individual_id":attacker_id,"pp":attacker["pp"].get(id,0)})
	await _dispatch_effect(attacker,defender,id,a_stages,d_stages,is_player,move,result)

func _dispatch_effect(attacker:Dictionary,defender:Dictionary,id:String,a_stages:Dictionary,d_stages:Dictionary,is_player:bool,move:Dictionary,result:Dictionary)->void:
	await _execute_effect(attacker,defender,id,a_stages,d_stages,is_player,move,result)

func _execute_effect(attacker:Dictionary,defender:Dictionary,id:String,a_stages:Dictionary,d_stages:Dictionary,is_player:bool,move:Dictionary,result:Dictionary)->void:
	var called:bool=visual_depth>1
	var attacker_id:String=attacker["individual_id"]
	var sketch_before:Dictionary=store.state.duplicate(true) if id=="sketch" and is_player else {}
	var sure_hit: bool = lock_ons.get(defender["individual_id"],{}).get("source","")==attacker_id
	var accuracy_stage: int = clampi(int(a_stages["accuracy"])-(0 if identified.has(defender["individual_id"]) else int(d_stages["evasion"])), -6,6)
	var accuracy: float = (50 if id=="thunder" and rules.weather_type=="Fire" else int(move["accuracy"] ))*(3.0+maxi(accuracy_stage,0))/(3.0+maxi(-accuracy_stage,0))
	accuracy=_ability_accuracy(attacker,defender,accuracy)
	if id=="thunder" and rules.weather_type=="Water":sure_hit=true
	var name_text: String = Language.display_name(attacker,store.species[attacker["species_id"]]["name"])
	var move_succeeded:bool=true
	var magnitude: Array = rules.magnitude(randi()%65536) if id=="magnitude" else []
	if id in ["selfdestruct","explosion"]:
		if _field_pets().any(func(p):return int(p["hp"])>0 and _item_ability(p)=="DAMP"):
			log_text=Language.text("battle.de83cb4235d8","湿气阻止了爆炸！");telemetry.emit({"event":"explosion_damp_blocked"});_update();return
		attacker["hp"] = 0
	# Start the source 2-3 turn rampage only on a successful damaging hit.
	rampage_unable.erase(attacker_id)
	if id!="rage":raging.erase(attacker_id)
	if id=="substitute":
		var cost:int=maxi(1,int(rules.pet_stats(attacker)["hp"])/4)
		var applied:bool=not substitutes.has(attacker_id) and int(attacker["hp"])>cost
		if applied:attacker["hp"]-=cost;substitutes[attacker_id]=cost;bindings.erase(attacker_id)
		log_text=Language.text("battle.110b940b03f6","制造了替身！") if applied else Language.text("battle.5ffdd8d03e17","替身失败。");telemetry.emit({"event":"substitute","applied":applied,"hp":substitutes.get(attacker_id,0)});_update();return
	if id in ["mirrormove","mimic","sketch","sleeptalk","assist","naturepower"]:
		await _copy_move(attacker,defender,id,a_stages,d_stages,is_player,sketch_before);_update();return
	if substitutes.has(defender["individual_id"]) and move["category"]=="Status" and move["target"]=="normal" and id not in ["perishsong","haze","roar","whirlwind","roleplay","skillswap"]:
		log_text=Language.text("battle.f63e903b19ad","替身挡住了变化招式！");telemetry.emit({"event":"substitute_blocked","move":id});_update();return
	if id=="psychup":
		for stat in d_stages:a_stages[stat]=d_stages[stat]
		log_text=Language.text("battle.e966252a25a8","复制了对手的能力变化！");telemetry.emit({"event":"psychup","stages":a_stages.duplicate()});_update();await get_tree().create_timer(.65).timeout;return
	if protected.has(defender["individual_id"]) and "FLAG_PROTECT_AFFECTED" in move["source_flags"] and id not in ["futuresight","doomdesire"]:
		fury_cutters.erase(attacker_id);log_text = Language.text("battle.fb81e37c5620","对手守住了攻击！");telemetry.emit({"event":"protect_blocked","move":id})
		if id=="spitup":stockpiles.erase(attacker_id)
		if id in ["hijumpkick","jumpkick"]:_jump_kick_crash(attacker,defender,a_stages,d_stages,is_player,"protect",id)
		_update();return
	if underground.has(defender["individual_id"]) and not sure_hit and move["target"] not in ["self","allySide","all"] and id not in ["earthquake","magnitude"]:
		log_text=Language.text("battle.40fc7a3a2750","对手潜入地下，攻击没有命中。");telemetry.emit({"event":"underground_miss","move":id})
		if id in ["hijumpkick","jumpkick"]:_jump_kick_crash(attacker,defender,a_stages,d_stages,is_player,"underground",id)
		_update();return
	if submerged.has(defender["individual_id"]) and not sure_hit and move["target"] not in ["self","allySide","all"] and id not in ["surf","whirlpool"]:
		log_text=Language.text("battle.4c0709078860","对手潜在水中，攻击没有命中。");telemetry.emit({"event":"submerged_miss","move":id})
		if id in ["hijumpkick","jumpkick"]:_jump_kick_crash(attacker,defender,a_stages,d_stages,is_player,"submerged",id)
		_update();return
	if airborne.has(defender["individual_id"]) and not sure_hit and move["target"] not in ["self","allySide","all"] and id not in ["gust","twister","thunder","skyuppercut"]:
		log_text = Language.text("battle.892b37302a29","对手在空中，攻击没有命中。")
		telemetry.emit({"event":"airborne_miss","move":id})
		if id in ["hijumpkick","jumpkick"]:_jump_kick_crash(attacker,defender,a_stages,d_stages,is_player,"airborne",id)
		_update();return
	if _ability_blocks(attacker,defender,move,id):_update();return
	if id=="fakeout" and int(field_turns.get(attacker_id,0))>0:
		log_text = Language.text("battle.80753a303045","击掌奇袭只能在登场后的第一回合使用！");telemetry.emit({"event":"fakeout_failed","id":attacker_id});_update();await get_tree().create_timer(.65).timeout;return
	var rollout_hit: int = int(rollouts.get(attacker_id,0))
	var dynamic_power: int = rules.rollout_power(rollout_hit,curled.has(attacker_id)) if id in ["rollout","iceball"] else int(magnitude[1]) if not magnitude.is_empty() else 120 if id=="revenge" and direct_damage_sources.get(attacker_id,"")==defender["individual_id"] else 0
	if id in ["counter","mirrorcoat"]:
		var countered: bool = direct_damage_sources.get(attacker_id,"")==defender["individual_id"] and bool(direct_damage_physical.get(attacker_id,false))==(id=="counter") and int(direct_damage_amounts.get(attacker_id,0))>0 and int(defender["hp"])>0
		# FireRed checks accuracy and Fighting immunity; resistances do not scale set damage.
		if countered and not sure_hit and randf()*100.0>=accuracy:countered=false
		if rules.move_effectiveness("Fighting" if id=="counter" else "Psychic",defender["species_id"],identified.has(defender["individual_id"]),defender)==0:countered=false
		var counter_damage: int = mini(int(defender["hp"]),int(direct_damage_amounts.get(attacker_id,0))*2) if countered else 0
		counter_damage=_apply_direct(attacker,defender,counter_damage,id)
		log_text=Language.text("battle.418f5f3de55f","双倍奉还造成%d伤害！")%counter_damage if countered else Language.text("battle.88c30005542a","双倍奉还失败！")
		result["succeeded"]=countered
		telemetry.emit({"event":"counter","applied":countered,"damage":counter_damage});_update();await get_tree().create_timer(.65).timeout;return
	if not sure_hit and int(move["accuracy"])>0 and id not in ["hail","guillotine","sheercold","fissure","spikes","softboiled","horndrill","sandstorm","haze","safeguard","aerialace","faintattack","metronome","raindance","transform","shadowpunch","vitalthrow","swift","shockwave","magicalleaf","doubleteam","minimize","recover","synthesis","watersport","teleport","focusenergy","followme","ingrain","reflect","light_screen","lightscreen","curse","calmmind","mist","perishsong","protect","helpinghand","imprison","roleplay","recycle","destinybond","amnesia","barrier","swordsdance","cosmicpower","acidarmor","camouflage","batonpass","rest","yawn"] and randf()*100.0>=accuracy:
		move_succeeded=false
		telemetry.emit({"event":"accuracy_miss","move":id})
		fury_cutters.erase(attacker_id);rollouts.erase(attacker_id)
		log_text = Language.text("battle.489af2954315","%s使用%s！\n但是没有命中。") % [name_text,Language.name(move["name"])]
		if id in ["hijumpkick","jumpkick"]:_jump_kick_crash(attacker,defender,a_stages,d_stages,is_player,"accuracy",id)
	elif id in ["horndrill","guillotine","sheercold","fissure"]:
		var hit: bool = rules.move_effectiveness(move["type"],defender["species_id"],identified.has(defender["individual_id"]),defender)>0 and _item_ability(defender)!="STURDY" and rules.horn_drill_hits(int(attacker["level"]),int(defender["level"]),randi()%100,sure_hit)
		move_succeeded=hit
		if hit:
			_apply_direct(attacker,defender,int(defender["hp"]),id)
			if destiny_bonds.has(defender["individual_id"]):attacker["hp"] = 0
		log_text = Language.text("battle.15922a5a19f1","一击必杀！") if hit else Language.text("battle.3669793820c1","角钻没有效果。")
		telemetry.emit({"event":"horn_drill","hit":hit,"move":id})
	elif id in ["taunt","torment"]:
		var table:Dictionary=taunted if id=="taunt" else tormented
		var applied:bool=not table.has(defender["individual_id"])
		move_succeeded=applied
		if applied:table[defender["individual_id"]]=2
		log_text=Language.text("battle.bea006d04184","对手受到了挑衅！") if id=="taunt" else Language.text("battle.6a1bdea5a42a","对手不能连续使用同一招式！");telemetry.emit({"event":id,"applied":applied})
	elif id in ["magiccoat","snatch"]:
		var applied:bool=not acted.has(defender["individual_id"])
		if applied:(magic_coats if id=="magiccoat" else snatches)[attacker_id]=true
		log_text=Language.text("battle.08d096c041fc","正在等待招式！") if applied else Language.text("battle.b51aaaee4be6","招式失败。");telemetry.emit({"event":id,"applied":applied})
	elif id=="wish":
		var side:String=_effect_key(attacker);var applied:bool=not wishes.has(side)
		if applied:wishes[side]=2
		log_text=Language.text("battle.f528ab600216","许下了愿望！") if applied else Language.text("battle.8c4c1db2a2ea","愿望仍在等待。");telemetry.emit({"event":"wish","applied":applied})
	elif id in ["stockpile","swallow"]:
		var count:int=int(stockpiles.get(attacker_id,0));var applied:bool=count<3 if id=="stockpile" else count>0
		if id=="stockpile" and applied:stockpiles[attacker_id]=count+1
		elif id=="swallow" and applied:attacker["hp"]=mini(int(rules.pet_stats(attacker)["hp"]),int(attacker["hp"])+maxi(1,int(rules.pet_stats(attacker)["hp"])/(1<<(3-count))));stockpiles.erase(attacker_id)
		log_text=Language.text("battle.7dd762c94d9e","储存了力量！") if id=="stockpile" else Language.text("battle.48dd971f1fc2","吞下储存的力量！");telemetry.emit({"event":id,"applied":applied,"count":stockpiles.get(attacker_id,0)})
	elif id in ["flatter","memento"]:
		if id=="flatter":
			move_succeeded=not (int(d_stages["spa"])==6 and confused.has(defender["individual_id"]))
			d_stages["spa"]=mini(6,int(d_stages["spa"])+1)
			if not _safeguarded(defender) and _item_ability(defender)!="OWN_TEMPO" and not confused.has(defender["individual_id"]):confused[defender["individual_id"]]=randi_range(2,5)
		else:
			move_succeeded=int(d_stages["atk"])>-6 or int(d_stages["spa"])>-6
			if move_succeeded:
				for stat in ["atk","spa"]:
					if not _stat_immune(defender,stat):d_stages[stat]=maxi(-6,int(d_stages[stat])-2)
				attacker["hp"]=0
		log_text=Language.text("battle.9cc72d3b4411","吹捧使对手混乱！") if id=="flatter" else Language.text("battle.a84400a99f0c","临别礼物降低了对手能力！");telemetry.emit({"event":id})
	elif id=="bellydrum":
		var cost:int=maxi(1,int(rules.pet_stats(attacker)["hp"])/2);var applied:bool=int(attacker["hp"])>cost and int(a_stages["atk"])<6
		if applied:attacker["hp"]-=cost;a_stages["atk"]=6
		log_text=Language.text("battle.ec5c0ffc39c5","腹鼓最大限度提高了攻击！") if applied else Language.text("battle.db93deef271b","腹鼓失败。");telemetry.emit({"event":"belly_drum","applied":applied})
	elif id=="grudge":
		grudges[attacker_id]=true;log_text=Language.text("battle.5c2c66f8739d","准备以怨念耗尽对手招式PP！");telemetry.emit({"event":"grudge_set"})
	elif id=="splash":
		log_text=Language.text("battle.157b9ed2e9a6","但是，什么也没有发生。");telemetry.emit({"event":"splash"})
	elif id=="trick":
		var applied:bool=_exchange_items(attacker,defender)
		move_succeeded=applied
		log_text=Language.text("battle.ab8f7365d5b8","交换了携带物！") if applied else Language.text("battle.e3f8e5b14934","戏法失败。");telemetry.emit({"event":"trick","applied":applied})
	elif id in ["superfang","endeavor"]:
		var amount:int=maxi(1,int(defender["hp"])/2) if id=="superfang" else maxi(0,int(defender["hp"])-int(attacker["hp"]))
		if rules.move_effectiveness("Normal",defender["species_id"],identified.has(defender["individual_id"]),defender)==0:amount=0
		move_succeeded=amount>0
		amount=_apply_direct(attacker,defender,amount,id);log_text=Language.text("battle.7b453c112c0d","造成%d伤害！")%amount;telemetry.emit({"event":"set_hp_damage","move":id,"damage":amount})
	elif id=="painsplit":
		var average:int=(int(attacker["hp"])+int(defender["hp"]))/2
		attacker["hp"]=mini(int(rules.pet_stats(attacker)["hp"]),average);defender["hp"]=mini(int(rules.pet_stats(defender)["hp"]),average)
		log_text=Language.text("battle.662aa0c7311b","平分了双方的体力！");telemetry.emit({"event":"pain_split","hp":average})
	elif id in ["healbell","aromatherapy"]:
		for pet in (store.state["team"] if is_player else enemy_party):
			if id=="healbell" and _item_ability(pet)=="SOUNDPROOF":continue
			pet.erase("status");pet.erase("sleep_turns");pet.erase("toxic_counter");nightmares.erase(pet["individual_id"])
		log_text=Language.text("battle.d1ca79d6e53d","队伍的异常状态恢复了！");telemetry.emit({"event":"party_status_cured","move":id})
	elif id in ["psywave","present","beatup"]:
		move_succeeded=_special_damage(attacker,defender,id,is_player)
	elif id=="spitup" and not stockpiles.has(attacker_id):
		log_text=Language.text("battle.68e1e8001625","没有储存的力量！");telemetry.emit({"event":"spitup_failed"})
	elif id=="spikes":
		var side:String="enemy" if is_player else "player"
		var added:bool=int(spikes[side])<3
		if added:spikes[side]=int(spikes[side])+1
		log_text=Language.text("battle.8c4db8628f02","对方场地撒下了尖刺！") if added else Language.text("battle.02d4237f8b2d","尖刺已经铺满了。")
		telemetry.emit({"event":"spikes_set","side":side,"layers":spikes[side],"applied":added})
	elif id=="sunnyday":
		var applied:bool=sun_turns==0
		if applied:sun_turns=5;rain_turns=0;sand_turns=0;hail_turns=0
		log_text=Language.text("battle.a622edea41d0","阳光变得强烈！") if applied else Language.text("battle.19bcaf0e0177","阳光仍在持续。");telemetry.emit({"event":"sun_started","applied":applied})
	elif id=="hail":
		if hail_turns==0:hail_turns=5
		rain_turns=0;sand_turns=0;sun_turns=0;log_text=Language.text("battle.62d853ca70a2","下起了冰雹！");telemetry.emit({"event":"hail_started","turns":hail_turns})
	elif id=="attract":
		var applied:bool=_item_ability(defender)!="OBLIVIOUS" and gender(attacker)!="none" and gender(defender)!="none" and gender(attacker)!=gender(defender) and not infatuated.has(defender["individual_id"])
		move_succeeded=applied
		if applied:infatuated[defender["individual_id"]]=attacker_id
		log_text=Language.text("battle.7daf60d46180","对手着迷了！") if applied else Language.text("battle.6accf9110286","迷人没有效果。");telemetry.emit({"event":"attract_used","applied":applied})
	elif id=="sandstorm":
		if sand_turns==0:sand_turns = 5
		rain_turns = 0;hail_turns=0;sun_turns=0;log_text = Language.text("battle.772137ed9f6f","刮起了沙暴！");telemetry.emit({"event":"sandstorm_started","turns":sand_turns})
	elif id=="swagger":
		move_succeeded=not (int(d_stages["atk"])==6 and confused.has(defender["individual_id"]))
		d_stages["atk"] = mini(6,int(d_stages["atk"])+2)
		if not _safeguarded(defender) and _item_ability(defender)!="OWN_TEMPO" and not confused.has(defender["individual_id"]):confused[defender["individual_id"]] = 2+randi()%4
		log_text = Language.text("battle.e39a01baf696","虚张声势提高对手攻击并使其混乱！");telemetry.emit({"event":"swagger","attack_stage":d_stages["atk"],"confused":confused.has(defender["individual_id"])})
	elif id=="raindance":
		if rain_turns==0:rain_turns = 5
		sand_turns = 0;hail_turns=0;sun_turns=0
		log_text = Language.text("battle.ac4b50025644","下起了雨！");telemetry.emit({"event":"rain_started","turns":rain_turns})
	elif id=="transform":
		_transform(attacker,defender,a_stages,d_stages)
	elif id=="metronome":
		var pool: Array = _metronome_pool()
		var next: String = pool[randi()%pool.size()]
		telemetry.emit({"event":"metronome_called","move":next,"scope":"pinned FireRed source exclusions; aliases deduplicated"})
		await _move(attacker,defender,next,a_stages,d_stages,is_player,true)
	elif id=="snore" and attacker.get("status","")!="sleep":
		move_succeeded=false
		log_text = Language.text("battle.af0ace2b1289","打鼾失败：没有睡着。");telemetry.emit({"event":"snore_failed"})
	elif id=="yawn":
		move_succeeded=defender.get("status","")=="" and not yawned.has(defender["individual_id"])
		if move_succeeded:yawned[defender["individual_id"]] = 2
		log_text = Language.text("battle.ea5f32b838bd","哈欠使对手昏昏欲睡。");telemetry.emit({"event":"yawn_set"})
	elif id=="rest":
		var applied:bool=int(attacker["hp"])<int(rules.pet_stats(attacker)["hp"]) and attacker.get("status","")!="sleep" and _item_ability(attacker) not in ["INSOMNIA","VITAL_SPIRIT"]
		if applied:attacker["hp"]=int(rules.pet_stats(attacker)["hp"]);attacker["status"]="sleep";attacker["sleep_turns"]=3;attacker.erase("toxic_counter");nightmares.erase(attacker_id)
		log_text=Language.text("battle.6ded563a723a","睡觉恢复体力并入睡。") if applied else Language.text("battle.7f07bdbba0ab","睡觉失败。");telemetry.emit({"event":"rest_used","applied":applied,"hp":attacker["hp"]})
	elif id in ["futuresight","doomdesire"]:
		var side: String = _effect_key(defender)
		if not future_attacks.has(side):
			var a: int = rules.staged(int(rules.pet_stats(attacker)["spa"]),int(a_stages["spa"]))
			var d: int = rules.staged(int(rules.pet_stats(defender)["spd"]),int(d_stages["spd"]))
			var amount: int = floori(floori((floori(2.0*int(attacker["level"])/5.0)+2)*int(move["power"])*float(a)/d)/50.0)+2
			future_attacks[side] = {"turns":3,"damage":amount}
		log_text = Language.text("battle.5551c1522198","预知了未来的攻击！");telemetry.emit({"event":"future_sight_set","side":side})
	elif id=="dreameater" and defender.get("status","")!="sleep":
		move_succeeded=false
		log_text = Language.text("battle.feedee145e89","食梦失败：对手没有睡着。");telemetry.emit({"event":"dream_eater_failed"})
	elif rules.power(id,defender)>0:
		if id=="brickbreak" and rules.move_effectiveness(move["type"],defender["species_id"],identified.has(defender["individual_id"]),defender)>0:
			var wall_side:String=_side(defender)
			reflect_turns[wall_side]=0
			light_screen_turns[wall_side]=0
			telemetry.emit({"event":"brick_break_wall","side":wall_side})
		if id=="furycutter":
			if rules.effectiveness(move["type"],defender["species_id"],defender)==0:fury_cutters.erase(attacker_id)
			else:
				fury_cutters[attacker_id] = mini(5,int(fury_cutters.get(attacker_id,0))+1)
				dynamic_power = 10*(1<<(int(fury_cutters[attacker_id])-1))
				telemetry.emit({"event":"fury_cutter","power":dynamic_power,"counter":fury_cutters[attacker_id]})
		log_text=Language.text("battle.766701f76d6b","%s使用%s！")%[name_text,Language.name(move["name"])];log_label.text=Language.message(log_text)
		var hits: int = 1
		if id in ["doublekick","bonemerang","twineedle"]:hits = 2
		elif id=="triplekick":hits=3
		elif id in ["spikecannon","rockblast","furyattack","doubleslap","iciclespear","furyswipes","cometpunch","pinmissile","bonerush","armthrust","bulletseed","barrage"]:
			hits = randi()%4
			hits = (randi()%4)+2 if hits>1 else hits+2
		for visual_event in visual_events:
			if visual_event.get("event","") in ["solar_release","tm_release","dive_release","dig_release","fly_land","bounce_land"]:
				await presentation.play("release",is_player,{"text":Language.text("battle.cc3d94550a8c","释放"),"move":id});visual_event["visual_played"]=true
		if rules.move_effectiveness(move["type"],defender["species_id"],identified.has(defender["individual_id"]),defender)==0:
			telemetry.emit({"event":"type_immune","move":id})
		var damage: int = 0
		var real_damage:int=0
		var actual_hits: int = 0
		for i in range(hits):
			if int(defender["hp"])<=0:break
			if id=="triplekick":
				if i>0 and not sure_hit and randf()*100>=accuracy:break
				dynamic_power=10*(i+1)
			var factor: float = (0.5 if not mud_sport.is_empty() else 1.0)*(2.0 if charged.has(attacker_id) else 1.0) if move["type"]=="Electric" else 1.0
			if move["type"]=="Fire" and not water_sport.is_empty():factor *= 0.5
			if airborne.has(defender["individual_id"]) and id in ["gust","twister"]:factor *= 2.0
			if submerged.has(defender["individual_id"]) and id in ["surf","whirlpool"]:factor *= 2.0
			if underground.has(defender["individual_id"]) and id in ["earthquake","magnitude"]:factor *= 2.0
			if id in ["stomp","needlearm","extrasensory"] and minimized.has(defender["individual_id"]):factor*=2.0
			if id=="solarbeam" and rules.weather_type in ["Water","Rock","Ice"]:factor *= 0.5
			var critical: bool = _item_ability(defender) not in ["BATTLE_ARMOR","SHELL_ARMOR"] and id not in ["dragonrage","nightshade","sonicboom","seismictoss"]  and randi()%rules.crit_denominator(id,focused.has(attacker_id))==0
			var weather_factor: float = 1.5 if rules.weather_type=="Water" and move["type"]=="Water" else 0.5 if rules.weather_type=="Water" and move["type"]=="Fire" else 1.5 if rules.weather_type=="Fire" and move["type"]=="Fire" else 0.5 if rules.weather_type=="Fire" and move["type"]=="Water" else 1.0
			var screen_side:String=_side(defender)
			var amount: int = rules.damage(attacker,defender,id,a_stages,d_stages,randi_range(85,100)/100.0,factor*weather_factor*(2.0 if id=="pursuit" and pursuit_spent else 1.0),critical,dynamic_power,identified.has(defender["individual_id"]),int(reflect_turns[screen_side])>0,int(light_screen_turns[screen_side])>0)
			if id=="spitup":amount=rules.damage(attacker,defender,id,a_stages,d_stages,1.0,1.0,false)*int(stockpiles.get(attacker_id,0))
			if critical:telemetry.emit({"event":"critical_hit","move":id})
			var visual_hp:int=int(defender["hp"])
			if substitutes.has(defender["individual_id"]):
				_sync_battler_visuals()
				var absorbed:int=mini(int(substitutes[defender["individual_id"]]),amount)
				damage+=absorbed;substitutes[defender["individual_id"]]-=absorbed
				if substitutes[defender["individual_id"]]<=0:substitutes.erase(defender["individual_id"])
				telemetry.emit({"event":"substitute_hit","move":id,"damage":absorbed})
				if absorbed>0:await presentation.play("substitute",not is_player,{"text":Language.text("battle.094e77a50162","替身 -%d")%absorbed,"move":id,"hit":i+1,"amount":absorbed})
				_sync_battler_visuals()
			else:
				var lost:int=mini(maxi(0,int(defender["hp"])-(1 if enduring.has(defender["individual_id"]) or id=="falseswipe" else 0)),amount)
				damage+=lost;real_damage+=lost;defender["hp"]-=lost
				if lost>0:
					await presentation.play("hit",not is_player,{"text":"-%d"%lost,"move":id,"hit":i+1,"amount":lost,"before_hp":visual_hp,"hp":defender["hp"]})
					visual_before[defender["individual_id"]]["hp"]=defender["hp"]
					_ability_contact(attacker,defender,move)
			actual_hits += 1
		if id=="spitup":stockpiles.erase(attacker_id)
		if damage>0 and id=="uproar" and not uproars.has(attacker_id):uproars[attacker_id]=randi_range(2,5)
		if real_damage>0 and int(defender["hp"])==0 and grudges.has(defender["individual_id"]) and id!="struggle":attacker["pp"][id]=0
		if real_damage>0 and biding.has(defender["individual_id"]):biding[defender["individual_id"]]["damage"]+=real_damage
		if damage>0 and int(defender["hp"])==0 and destiny_bonds.has(defender["individual_id"]):
			attacker["hp"] = 0;telemetry.emit({"event":"destiny_bond_triggered","source":defender["individual_id"]})
		if real_damage>0:direct_damage_sources[defender["individual_id"]] = attacker_id;direct_damage_amounts[defender["individual_id"]]=real_damage;direct_damage_physical[defender["individual_id"]]=move["category"]=="Physical"
		if id=="flail":telemetry.emit({"event":"flail_power","power":rules.flail_power(int(attacker["hp"]),int(rules.pet_stats(attacker)["hp"]))})
		if id=="revenge":telemetry.emit({"event":"revenge_power","power":120 if dynamic_power==120 else 60})
		if hits>1:telemetry.emit({"event":"multi_hit","move":id,"hits":actual_hits,"damage":damage})
		if id in ["thrash","outrage","petaldance"] and damage>0 and not rampages.has(attacker_id):rampages[attacker_id] = (randi()%2)+2;rampage_moves[attacker_id]=id
		if id in ["takedown","submission","doubleedge","volttackle","struggle"] and damage>0 and (id=="struggle" or _item_ability(attacker)!="ROCK_HEAD"):
			var recoil: int = maxi(1,damage/(3 if id in ["doubleedge","volttackle"] else 4));attacker["hp"] = maxi(0,int(attacker["hp"])-recoil);telemetry.emit({"event":"submission_recoil" if id=="submission" else "takedown_recoil","amount":recoil})
		if id=="rage":raging[attacker_id] = true
		if real_damage>0 and raging.has(defender["individual_id"]) and int(defender["hp"])>0:
			d_stages["atk"] = mini(6,int(d_stages["atk"])+1);telemetry.emit({"event":"rage_building","stage":d_stages["atk"]})
		if id=="fakeout" and _item_ability(defender)!="SHIELD_DUST" and real_damage>0 and int(defender["hp"])>0 and not acted.has(defender["individual_id"]):flinched[defender["individual_id"]] = true
		if id in ["rollout","iceball"]:
			rollout_moves[attacker_id]=id
			if damage==0 or rollout_hit==4:rollouts.erase(attacker_id)
			else:rollouts[attacker_id] = rollout_hit+1
			telemetry.emit({"event":"rollout_hit","hit":rollout_hit+1,"power":dynamic_power,"locked":rollouts.has(attacker_id)})
		if id=="magnitude":telemetry.emit({"event":"magnitude","strength":magnitude[0],"power":magnitude[1]})
		if id=="payday" and is_player and real_damage>0:payday_coins = mini(65535,payday_coins+int(attacker["level"])*5)
		if id=="rapidspin" and real_damage>0:
			spikes["player" if is_player else "enemy"]=0
			bindings.erase(attacker_id)
			if is_player:seeded_player = false
			else:seeded_enemy = false
			telemetry.emit({"event":"rapidspin_cleared","individual_id":attacker_id})
		if id in ["waterpulse","confusion","psybeam","dynamicpunch","dizzypunch","signalbeam"] and real_damage>0 and int(defender["hp"])>0 and not _safeguarded(defender) and _item_ability(defender)!="OWN_TEMPO" and not confused.has(defender["individual_id"]) and _secondary(attacker,defender,100 if id in ["dynamicpunch","dizzypunch"] else 20 if id=="waterpulse" else 10):
			confused[defender["individual_id"]] = (randi()%4)+2
			telemetry.emit({"event":"waterpulse_confused" if id=="waterpulse" else "confusion_confused","individual_id":defender["individual_id"]})
		if id in ["dreameater","leechlife","absorb","megadrain","gigadrain"] and real_damage>0:
			var recovered: int = mini(maxi(1,damage/2),int(rules.pet_stats(attacker)["hp"])-int(attacker["hp"]))
			attacker["hp"] = maxi(0,int(attacker["hp"])-maxi(1,damage/2)) if _item_ability(defender)=="LIQUID_OOZE" else int(attacker["hp"])+recovered
			telemetry.emit({"event":"drain_healed","amount":recovered,"damage":damage})
		if id=="poisonfang" and real_damage>0 and int(defender["hp"])>0 and _secondary(attacker,defender,30):telemetry.emit({"event":"toxic_attempt","applied":_inflict_opponent(defender,"toxic")})
		if (id in ["rollingkick","snore","twister","stomp","astonish","hyperfang","boneclub","skyattack"] or north_rules and id in ["headbutt","bite"]) and real_damage>0 and int(defender["hp"])>0 and not acted.has(defender["individual_id"]) and _secondary(attacker,defender,20 if id=="twister" else 10 if id in ["hyperfang","boneclub"] else 30):
			flinched[defender["individual_id"]] = true
			if id=="rollingkick":telemetry.emit({"event":"rolling_kick_flinch","individual_id":defender["individual_id"]})
		var mult: float = rules.move_effectiveness(move["type"],defender["species_id"],identified.has(defender["individual_id"]),defender)
		move_succeeded=mult>0
		if id in ["bind","wrap","firespin","sandtomb","whirlpool","clamp"] and real_damage>0 and mult>0 and int(defender["hp"])>0 and not bindings.has(defender["individual_id"]):
			bindings[defender["individual_id"]] = {"source":attacker["individual_id"],"turns":(randi()%4)+3}
			telemetry.emit({"event":"bind_started","victim":defender["individual_id"]})
		log_text = Language.text("battle.damage","%s使用%s！\n造成 %d 伤害。%s",[Language.display_name(attacker,name_text),Language.name(move["name"]),damage,Language.text("battle.super","效果绝佳！") if mult>1 else Language.text("battle.weak","效果不太好。") if mult<1 else ""])
		if id=="triattack" and real_damage>0 and int(defender["hp"])>0 and _secondary(attacker,defender,20):
			var status: String = ["burn","freeze","paralysis"][randi()%3]
			telemetry.emit({"event":"tri_attack_status","status":status,"applied":_inflict_opponent(defender,status)})
		if real_damage>0 and id in ["sacredfire","blazekick","firepunch","heatwave","powdersnow","iceball"]:
			var secondary:Dictionary=move.get("secondary",{}) if move.get("secondary") is Dictionary else {}
			if randi()%100<int(secondary.get("chance",0)) and _item_ability(defender)!="SHIELD_DUST":_inflict_opponent(defender,"burn" if secondary.get("status","")=="brn" else "freeze")
		if real_damage>0 and id in ["rockslide","needlearm","extrasensory"] and not acted.has(defender["individual_id"]) and randi()%100<int(move["secondary"].get("chance",0)) and _item_ability(defender)!="SHIELD_DUST":flinched[defender["individual_id"]]=true
		if damage>0 and move["source_effect"]=="EFFECT_RECHARGE":recharging[attacker_id]=true
		if damage>0 and move.get("self") is Dictionary:
			for stat in move["self"].get("boosts",{}):a_stages[stat]=clampi(int(a_stages[stat])+int(move["self"]["boosts"][stat]),-6,6)
		if real_damage>0 and id=="smellingsalt" and defender.get("status","")=="paralysis":defender.erase("status")
		if real_damage>0 and id=="secretpower" and int(defender["hp"])>0 and _secondary(attacker,defender,30):_secret_power(defender,d_stages)
		if real_damage>0 and id in ["thief","covet"]:_steal_item(attacker,defender)
		if real_damage>0 and id=="knockoff":_knock_off(defender)
		if real_damage>0 and attacker.get("held_item","")=="kingsrock" and id in kings_rock_moves and int(defender["hp"])>0 and not acted.has(defender["individual_id"]) and _secondary(attacker,defender,10):flinched[defender["individual_id"]]=true
		_sitrus(defender)
		if move["type"]=="Fire" and real_damage>0 and defender.get("status","")=="freeze":defender.erase("status")
		if id=="flamewheel" and attacker.get("status","")=="freeze":attacker.erase("status")
		if id in ["ember","flamewheel","flamethrower","fireblast"] and real_damage>0 and int(defender["hp"])>0 and _secondary(attacker,defender,10):
			var burned: bool = _inflict_opponent(defender,"burn")
			if burned:log_text += Language.text("battle.dabbc2dcf949","\n对手灼伤了！")
			telemetry.emit({"event":"burn_attempt","applied":burned})
		if id in ["icebeam","icepunch","blizzard"] and real_damage>0 and int(defender["hp"])>0 and _secondary(attacker,defender,10):
			telemetry.emit({"event":"ice_freeze_attempt","applied":_inflict_opponent(defender,"freeze")})
		if damage>0 and move["source_effect"] in ["EFFECT_ALL_STATS_UP_HIT","EFFECT_ATTACK_UP_HIT","EFFECT_DEFENSE_UP_HIT"] and randi()%100<int(move.get("secondary",{}).get("chance",10)):
			for stat in (["atk","def","spa","spd","spe"] if move["source_effect"]=="EFFECT_ALL_STATS_UP_HIT" else ["atk"] if move["source_effect"]=="EFFECT_ATTACK_UP_HIT" else ["def"]):a_stages[stat]=mini(6,int(a_stages[stat])+1)
		if mult>0 and real_damage>0 and int(defender["hp"])>0 and move["secondary"] is Dictionary and move["secondary"].has("boosts") and randf()*100<int(move["secondary"].get("chance",0)) and _item_ability(defender)!="SHIELD_DUST":
			for stat in move["secondary"]["boosts"]:
				if int(move["secondary"]["boosts"][stat])>=0 or int(mist_turns[_side(defender)])==0 and not _stat_immune(defender,stat):d_stages[stat] = clampi(int(d_stages[stat])+int(move["secondary"]["boosts"][stat]),-6,6)
		if real_damage>0 and move["secondary"] is Dictionary and move["secondary"].get("status","") in ["psn","par"] and mult>0 and randf()*100<int(move["secondary"].get("chance",0)) and _item_ability(defender)!="SHIELD_DUST":
			if _inflict_opponent(defender,"poison" if move["secondary"]["status"]=="psn" else "paralysis"):log_text += Language.text("battle.b0924cc08dfc","\n对手中毒了！") if move["secondary"]["status"]=="psn" else Language.text("battle.d837d7e075a7","\n对手麻痹了！")
	elif id=="batonpass":
		_begin_baton(is_player)
	elif id=="destinybond":
		destiny_bonds[attacker_id] = true;log_text = Language.text("battle.4490e2683cf2","试图与对手同命！");telemetry.emit({"event":"destiny_bond_set"})
	elif id=="imprison":
		var shared: bool = false
		for shared_move in attacker["moves"]:
			if shared_move in defender["moves"]:shared = true
		var applied: bool = shared and not imprisoned_by.has(attacker_id)
		if applied:imprisoned_by[attacker_id] = true
		log_text = Language.text("battle.d86daf5cc1e5","封印了对手的相同招式！") if applied else Language.text("battle.b892a55fb127","封印失败！")
		telemetry.emit({"event":"imprison_attempt","applied":applied})
	elif id in ["roleplay","skillswap"]:
		var aa:String=_item_ability(attacker);var da:String=_item_ability(defender)
		var applied:bool=da not in ["NONE","WONDER_GUARD"] if id=="roleplay" else (aa!="NONE" or da!="NONE") and aa!="WONDER_GUARD" and da!="WONDER_GUARD"
		move_succeeded=applied
		if applied:
			copied_abilities[attacker_id]=da
			if id=="skillswap":copied_abilities[defender["individual_id"]]=aa
			_ability_cure(attacker);_ability_cure(defender);_sync_weather()
		log_text=Language.text("battle.93a832d7c680","复制了特性！") if id=="roleplay" else Language.text("battle.c598e5cb1e02","交换了特性！");telemetry.emit({"event":id,"applied":applied,"ability":_item_ability(attacker),"scope":"existing single-battle ability effects"})
	elif id=="recycle":
		var recycled:bool=_recycle(attacker)
		log_text = Language.text("battle.1aaa7d6e1295","回收了已消耗的携带物！") if recycled else Language.text("battle.9c750b15f705","没有可回收的携带物。")
		telemetry.emit({"event":"recycle_used" if recycled else "recycle_failed_no_held_item"})
	elif id in ["protect","detect","endure"]:
		var count: int = int(protect_uses.get(attacker_id,0))
		var success: bool = not acted.has(defender["individual_id"]) and (randi()%65536)<=int(65535/pow(2,mini(count,3)))
		if success:
			if id=="endure":enduring[attacker_id]=true
			else:protected[attacker_id]=true
			protect_uses[attacker_id]=mini(count+1,3)
		else:protect_uses.erase(attacker_id)
		log_text = Language.text("battle.28e6498ccbda","守住了！") if success else Language.text("battle.d82df75b0500","守住失败！");telemetry.emit({"event":"protect_attempt","success":success,"count":count})
	elif id=="helpinghand":
		log_text = Language.text("battle.59c5f92f043d","单打没有可帮助的同伴，帮助失败。");telemetry.emit({"event":"helpinghand_failed_single"})
	elif id=="haze":
		for stages in [player_stages,enemy_stages]:
			for stat in stages:stages[stat]=0
		log_text = Language.text("battle.0d737c467a23","黑雾使双方能力变化恢复原状！");telemetry.emit({"event":"haze_reset"})
	elif id in ["lockon","mindreader"]:
		lock_ons[defender["individual_id"]] = {"source":attacker_id,"turns":2}
		log_text = Language.text("battle.5a953a8809f6","锁定了对手！");telemetry.emit({"event":"lock_on","move":id,"target":defender["individual_id"]})
	elif id=="safeguard":
		var side: String = "player" if is_player else "enemy"
		var applied: bool = int(safeguard_turns[side])==0
		if applied:safeguard_turns[side] = 5
		log_text = Language.text("battle.b4e4e3f4384a","神秘守护保护队伍！") if applied else Language.text("battle.22d419abefb2","神秘守护仍在持续。")
		telemetry.emit({"event":"safeguard_started","side":side,"applied":applied})
	elif id=="mist":
		var side: String = "player" if is_player else "enemy"
		if int(mist_turns[side])==0:mist_turns[side] = 5
		log_text = Language.text("battle.2a43f389205d","白雾保护了队伍的能力！");telemetry.emit({"event":"mist_started","side":side})
	elif id=="perishsong":
		for pet in _field_pets():
			if _item_ability(pet)=="SOUNDPROOF":continue
			if not perish_counts.has(pet["individual_id"]):perish_counts[pet["individual_id"]] = 3
		log_text = Language.text("battle.a0625da15464","听到灭亡之歌的宝可梦即将倒下！");telemetry.emit({"event":"perish_song_set"})
	elif id=="spite":
		var previous: String = last_moves.get(defender["individual_id"],"")
		var amount: int = mini(int(defender["pp"].get(previous,0)),randi()%4+2)
		if int(defender["pp"].get(previous,0))<=1:amount = 0
		move_succeeded=amount>0
		if amount>0:defender["pp"][previous] -= amount
		log_text = Language.text("battle.ca0b230c67f8","怨恨减少上次招式%dPP。") % amount
		telemetry.emit({"event":"spite","amount":amount,"move":previous})
	elif id=="curse":
		if "Ghost" in rules.pet_types(attacker):
			if not cursed.has(defender["individual_id"]):
				cursed[defender["individual_id"]] = true
				attacker["hp"] = maxi(0,int(attacker["hp"])-maxi(1,int(rules.pet_stats(attacker)["hp"])/2))
		else:
			for stat in ["atk","def"]:a_stages[stat] = mini(6,int(a_stages[stat])+1)
			a_stages["spe"] = maxi(-6,int(a_stages["spe"])-1)
		log_text = Language.text("battle.b0b5dd4e97df","诅咒！")
		telemetry.emit({"event":"curse","applied":cursed.has(defender["individual_id"])})
	elif id in ["meanlook","spiderweb","block"]:
		move_succeeded=not trapped.has(defender["individual_id"])
		if move_succeeded:trapped[defender["individual_id"]]=attacker_id
		log_text=Language.text("battle.14b72ea17211","黑色目光使对手无法逃走！");telemetry.emit({"event":"mean_look","target":defender["individual_id"]})
	elif id=="nightmare":
		var nightmare_applied:bool=defender.get("status","")=="sleep" and not nightmares.has(defender["individual_id"])
		move_succeeded=nightmare_applied
		if nightmare_applied:nightmares[defender["individual_id"]]=true
		log_text=Language.text("battle.7794cac29c18","对手陷入了恶梦！") if nightmare_applied else Language.text("battle.6167f711d229","恶梦失败！");telemetry.emit({"event":"nightmare","applied":nightmare_applied})
	elif id in ["foresight","odorsleuth"]:
		identified[defender["individual_id"]] = true
		log_text = Language.text("battle.0301334f1c9c","%s识破了对手！") % name_text
	elif id=="followme":
		log_text = Language.text("battle.b1986887c65e","%s成为了注目焦点！单打中没有其他攻击目标。") % name_text
	elif id in ["roar","whirlwind"]:
		move_succeeded=_force_out(attacker,defender,is_player)
	elif id=="teleport":
		if trainer_id!="" or bindings.has(attacker_id):
			log_text = Language.text("battle.3c9d6c0e08e0","瞬间移动失败！")
			telemetry.emit({"event":"teleport_failed","trainer":trainer_id!=""})
		else:
			log_text = Language.text("battle.abee41ff323e","瞬间移动！结束了野生遭遇。")
			telemetry.emit({"event":"teleport_escaped"})
			_finish(false,"escaped")
	elif id=="focusenergy":
		focused[attacker_id] = true
		log_text = Language.text("battle.60b385c4dd80","集中精神！更容易击中要害。")
	elif id=="ingrain":
		rooted[attacker_id] = true
		log_text = Language.text("battle.2080ccf9cca0","扎下根了！每回合恢复，不能换下或被吹走。")
		telemetry.emit({"event":"ingrain_started","id":attacker_id})
	elif id=="reflect":
		var side: String = "player" if is_player else "enemy"
		if int(reflect_turns[side])==0:reflect_turns[side] = 5
		log_text = Language.text("battle.f4bb0651a057","反射壁减弱物理伤害！")
		telemetry.emit({"event":"reflect_started","side":side,"turns":reflect_turns[side]})
	elif id in ["light_screen","lightscreen"]:
		var side:String="player" if is_player else "enemy"
		if int(light_screen_turns[side])==0:light_screen_turns[side]=5
		log_text=Language.text("battle.bc48b9587c60","光墙削弱特殊伤害！")
		telemetry.emit({"event":"light_screen_started","side":side,"turns":light_screen_turns[side]})
	elif id in ["softboiled","recover","synthesis","milkdrink","morningsun","moonlight","slackoff"]:
		var divisor: float = 1.5 if id in ["synthesis","morningsun","moonlight"] and rules.weather_type=="Fire" else 4.0 if id in ["synthesis","morningsun","moonlight"] and rules.weather_type in ["Water","Rock","Ice"] else 2.0
		var amount: int = mini(maxi(1,floori(int(rules.pet_stats(attacker)["hp"])/divisor)),int(rules.pet_stats(attacker)["hp"])-int(attacker["hp"]))
		attacker["hp"] += amount
		log_text = Language.text("battle.ac88a5c51745","%s使用%s！恢复%dHP。") % [name_text,Language.name(move["name"]),amount]
		telemetry.emit({"event":"recover_healed","amount":amount})
	elif id=="refresh":
		if attacker.get("status","") in ["poison","toxic","paralysis","burn"]:
			attacker.erase("status");attacker.erase("toxic_counter");log_text=Language.text("battle.fae5c4cd7398","焕然一新，异常状态恢复了！")
		else:log_text=Language.text("battle.18f0735017d7","没有可以恢复的异常状态。")
	elif id in ["conversion","conversion2"]:
		var choices:Array=[]
		if id=="conversion":
			for known in attacker["moves"]:
				var type:String=rules.moves[known]["type"]
				if type not in rules.pet_types(attacker) and type not in choices:choices.append(type)
		else:
			var previous:String=last_moves.get(defender["individual_id"],"")
			if previous!="":
				for type in rules.types:
					if int(rules.types[type].get(rules.moves[previous]["type"],0)) in [2,3] and type not in rules.pet_types(attacker):choices.append(type)
		if choices.is_empty():log_text=Language.text("battle.954075ec7452","属性变化失败。")
		else:rules.type_overrides[attacker_id]=[choices.pick_random()];log_text=Language.text("battle.2d55c99e5f68","纹理改变了属性！")
	elif id=="camouflage":
		rules.type_overrides[attacker_id]=[field_terrain]
		log_text=Language.text("battle.1a8cd16fa2f3","保护色改变了属性！");telemetry.emit({"event":"camouflage","type":field_terrain,"id":attacker_id})
	elif id=="watersport":
		water_sport[attacker_id] = true
		log_text = Language.text("battle.f189838d2835","玩水减弱了火属性招式！")
	elif id=="mudsport":
		mud_sport[attacker_id] = true
		log_text = Language.text("battle.67adaf0e61c4","泥巴运动减弱了电属性招式！")
	elif id=="charge":
		charged[attacker_id] = 2
		log_text = Language.text("battle.39fe198cfffb","开始充电！")
	elif id in ["supersonic","confuseray","sweetkiss","teeterdance"]:
		var victim: String = defender["individual_id"]
		move_succeeded=not _safeguarded(defender) and _item_ability(defender)!="OWN_TEMPO" and not confused.has(victim)
		if move_succeeded:confused[victim] = (randi()%4)+2
		log_text = Language.text("battle.36f9a4cbaa40","%s！对手陷入混乱。") % Language.name(move["name"])
		telemetry.emit({"event":"confusion_attempt","move":id,"turns":confused.get(victim,0)})
	elif id in ["lovelykiss","sing","sleeppowder","hypnosis","grasswhistle","spore"]:
		var applied: bool = not (id=="sleeppowder" and rules.effectiveness(move["type"],defender["species_id"],defender)==0) and _inflict_opponent(defender,"sleep")
		move_succeeded=applied
		if applied:defender["sleep_turns"] = (randi()%4)+2
		log_text = Language.text("battle.c1d8a6ee812b","%s使用%s！\n%s") % [name_text,Language.name(move["name"]),Language.text("battle.ecc8173e20cc","对手睡着了！") if applied else Language.text("battle.12022c148caf","没有效果。")]
		telemetry.emit({"event":"sleep_attempt","applied":applied})
	elif id=="encore":
		var victim: String = defender["individual_id"]
		var previous: String = last_moves.get(victim,"")
		var applied: bool = not encored_moves.has(victim) and previous in defender["moves"] and previous not in ["struggle","encore","mirrormove"] and int(defender["pp"].get(previous,0))>0
		move_succeeded=applied
		if applied:encored_moves[victim] = {"move":previous,"turns":(randi()%4)+3}
		telemetry.emit({"event":"encore_attempt","applied":applied})
		log_text = Language.text("battle.a780a107a43a","再来一次！") if applied else Language.text("battle.f4ee5139513e","再来一次没有效果。")
	elif id=="disable":
		var victim_id: String = defender["individual_id"]
		var previous: String = last_moves.get(victim_id,"")
		var applied: bool = not disabled_moves.has(victim_id) and previous in defender["moves"] and int(defender["pp"].get(previous,0))>0
		move_succeeded=applied
		if applied:disabled_moves[victim_id] = {"move":previous,"turns":(randi()%4)+2}
		log_text = Language.text("battle.4494b17a2b24","%s使用定身法！\n%s") % [name_text,Language.text("battle.7119468d48c3","对手上一招暂时无法使用！") if applied else Language.text("battle.12022c148caf","没有效果。")]
		telemetry.emit({"event":"disable_attempt","applied":applied,"move":previous})
	elif id=="toxic":
		var applied: bool = _inflict_opponent(defender,"toxic")
		move_succeeded=applied
		log_text = Language.text("battle.821e12ee4d9d","对手中了剧毒！") if applied else Language.text("battle.a6a31e83d70e","剧毒没有效果。")
		telemetry.emit({"event":"toxic_attempt","applied":applied})
	elif id=="willowisp":
		var applied: bool = _inflict_opponent(defender,"burn")
		move_succeeded=applied
		log_text = Language.text("battle.724ba00a51bc","%s使用鬼火！\n%s") % [name_text,Language.text("battle.bebaac76fcaa","对手灼伤了！") if applied else Language.text("battle.12022c148caf","没有效果。")]
		telemetry.emit({"event":"burn_attempt","applied":applied})
	elif id in ["glare","thunderwave","poisonpowder","poisongas","stunspore"]:
		var status: String = "poison" if id in ["poisonpowder","poisongas"] else "paralysis"
		var immune: bool = id=="thunderwave" and rules.effectiveness("Electric",defender["species_id"],defender)==0
		var applied: bool = not immune and _inflict_opponent(defender,status)
		move_succeeded=applied
		log_text = Language.text("battle.c1d8a6ee812b","%s使用%s！\n%s") % [name_text,Language.name(move["name"]),(Language.text("battle.626b3f5fc62e","对手中毒了！") if status=="poison" else Language.text("battle.c82ecda0e0a2","对手麻痹了！")) if applied else Language.text("battle.12022c148caf","没有效果。")]
	elif id=="leechseed":
		move_succeeded="Grass" not in rules.pet_types(defender) and not (seeded_enemy if is_player else seeded_player)
		if move_succeeded:
			if is_player: seeded_enemy = true
			else: seeded_player = true
			log_text = Language.text("battle.9f5c1623f068","%s撒下寄生种子！") % name_text
		else:
			log_text = Language.text("battle.b3eb484c40fc","草属性对手不受寄生种子影响。")
	else:
		if id=="defensecurl":curled[attacker_id] = true
		if id=="minimize":minimized[attacker_id]=true
		var target_stages: Dictionary = a_stages if move["target"]=="self" else d_stages
		var changed: bool = false
		for stat in move["boosts"]:
			if move["target"]!="self" and int(move["boosts"][stat])<0 and int(mist_turns[_side(defender)])>0:continue
			if move["target"]!="self" and int(move["boosts"][stat])<0 and _stat_immune(defender,stat):continue
			var before: int = int(target_stages[stat])
			target_stages[stat] = clampi(int(target_stages[stat])+int(move["boosts"][stat]),-6,6)
			changed = changed or before!=int(target_stages[stat])
		move_succeeded=changed
		log_text = Language.text("battle.c1d8a6ee812b","%s使用%s！\n%s") % [name_text,Language.name(move["name"]),Language.text("battle.1d12037f6993","能力等级发生变化。") if changed else Language.text("battle.bcc66992daeb","能力无法继续变化。")]
	result["succeeded"]=move_succeeded

	telemetry.emit({"event":"player_move" if is_player else "enemy_move","move":id,"pp":attacker["pp"].get(id,0),"hp":attacker["hp"],"enemy_hp":enemy["hp"],"individual_id":attacker["individual_id"]})
	_update()
	await get_tree().create_timer(.65).timeout

# FireRed 7e3f822: EffectRecoilIfMiss -> damagecalc/typecalc/adjustnormaldamage
# -> DMG_RECOIL_FROM_MISS. No critcalc; cap is TARGET max HP / 2, not current HP.
func _jump_kick_crash(attacker: Dictionary,defender: Dictionary,a_stages: Dictionary,d_stages: Dictionary,is_player: bool,reason: String,move_id: String = "hijumpkick") -> void:
	# Only an ordinary accuracy miss runs CheckWonderGuardAndLevitate before the
	# script's DOESNT_AFFECT_FOE guard. Protect/semi-invulnerable jumps skip it.
	if reason=="accuracy" and rules.move_effectiveness("Fighting",defender["species_id"],identified.has(defender["individual_id"]),defender)==0:
		telemetry.emit({"event":"jump_kick_no_crash","reason":"immune_accuracy_miss"})
		return
	var defending_side:String="enemy" if is_player else "player"
	var prospective: int = rules.damage(attacker,defender,move_id,a_stages,d_stages,randi_range(85,100)/100.0,1.0,false,0,identified.has(defender["individual_id"]),int(reflect_turns[defending_side])>0,int(light_screen_turns[defending_side])>0)
	var amount: int = mini(maxi(1,prospective/2),int(rules.pet_stats(defender)["hp"])/2)
	var lost: int = mini(int(attacker["hp"]),amount)
	attacker["hp"] = maxi(0,int(attacker["hp"])-amount)
	log_text += Language.text("battle.e957214957a1","\n%s失误，撞伤了自己！受到%d伤害。") % [Language.name(rules.moves[move_id]["name"]),lost]
	telemetry.emit({"event":"jump_kick_crash","move":move_id,"individual_id":attacker["individual_id"],"reason":reason,"prospective_damage":prospective,"amount":amount,"lost_hp":lost,"target_max_hp":rules.pet_stats(defender)["hp"]})

func _terminal() -> bool:
	if ended:return true
	for pet in store.state["team"]:
		var individual:String=pet["individual_id"]
		if int(pet["hp"])<=0 and not friendship_fainted.has(individual) and battle_before.get("team",[]).any(func(original):return original["individual_id"]==individual and int(original["hp"])>0):
			store.friendship.adjust(pet,"faint_large" if int(enemy["level"])-int(pet["level"])>=30 else "faint")
			friendship_fainted[individual]=true
		elif int(pet["hp"])>0:friendship_fainted.erase(individual)
	if trainer_id!="" and not _any_alive():
		_finish(false)
		return true
	if int(enemy["hp"])<=0:
		_finish(true)
		return true
	if not _any_alive():
		_finish(false)
		return true
	return false

func _rampage_end() -> void:
	for pet in _field_pets():
		var id: String = pet["individual_id"]
		if not rampages.has(id):continue
		if rampage_unable.has(id) or int(pet["hp"])<=0:
			rampages.erase(id);rampage_unable.erase(id);continue
		rampages[id] = int(rampages[id])-1
		if int(rampages[id])<=0:
			rampages.erase(id)
			if _item_ability(pet)!="OWN_TEMPO" and not confused.has(id):confused[id] = (randi()%4)+2
			telemetry.emit({"event":"thrash_ended","individual_id":id,"confusion_turns":confused.get(id,0)})

func _round_end() -> void:
	var residual_before:Dictionary=_visual_snapshot()
	_sync_weather()
	for pet in _field_pets():_ability_end(pet)
	direct_damage_sources.clear();direct_damage_amounts.clear();direct_damage_physical.clear();protected.clear();enduring.clear();magic_coats.clear();snatches.clear()
	for id in uproars.keys():
		uproars[id]-=1
		if uproars[id]<=0:uproars.erase(id)
	for pet in _field_pets():
		if not uproars.is_empty() and pet.get("status","")=="sleep" and _item_ability(pet)!="SOUNDPROOF":pet.erase("status");pet.erase("sleep_turns")
	for id in taunted.keys():
		taunted[id]-=1
		if taunted[id]<=0:taunted.erase(id)
	for side in wishes.keys():
		wishes[side]-=1
		if wishes[side]<=0:
			var pet:Dictionary=_effect_pet(side)
			var amount:int=mini(maxi(1,int(rules.pet_stats(pet)["hp"])/2),int(rules.pet_stats(pet)["hp"])-int(pet["hp"])) if int(pet["hp"])>0 else 0
			pet["hp"]+=amount;wishes.erase(side);telemetry.emit({"event":"wish_healed","amount":amount,"side":side})
	for side in safeguard_turns:safeguard_turns[side] = maxi(0,int(safeguard_turns[side])-1)
	for id in lock_ons.keys():
		lock_ons[id]["turns"] -= 1
		if int(lock_ons[id]["turns"])<=0:lock_ons.erase(id)
	for side in mist_turns:mist_turns[side] = maxi(0,int(mist_turns[side])-1)
	for side in future_attacks.keys():
		future_attacks[side]["turns"] -= 1
		if int(future_attacks[side]["turns"])==0:
			var target: Dictionary = _effect_pet(side)
			var amount: int = maxi(1,floori(int(future_attacks[side]["damage"])*randi_range(85,100)/100.0))
			target["hp"] = maxi(0,int(target["hp"])-amount);future_attacks.erase(side);telemetry.emit({"event":"future_sight_hit","side":side,"damage":amount})
	for pet in _field_pets():
		var id: String = pet["individual_id"]
		if perish_counts.has(id):
			if int(perish_counts[id])==0:pet["hp"] = 0;perish_counts.erase(id)
			else:perish_counts[id] -= 1
	for pet in _field_pets():
		var k: String = pet["individual_id"]
		if yawned.has(k):
			yawned[k] -= 1
			if yawned[k]<=0:
				yawned.erase(k)
				if _inflict_opponent(pet,"sleep"):pet["sleep_turns"] = 2+randi()%4;telemetry.emit({"event":"yawn_asleep","id":k})
	_rampage_end()
	if hail_turns>0:
		for pet in _field_pets():
			if rules.weather_type!="" and int(pet["hp"])>0 and "Ice" not in rules.pet_types(pet) and not submerged.has(pet["individual_id"]) and not underground.has(pet["individual_id"]):
				var amount:int=maxi(1,int(rules.pet_stats(pet)["hp"])/16);pet["hp"]=maxi(0,int(pet["hp"])-amount);telemetry.emit({"event":"hail_damage","amount":amount,"id":pet["individual_id"]})
		hail_turns-=1
	if sand_turns>0:
		sand_turns -= 1
		if sand_turns>0:
			for pet in _field_pets():
				var kinds: Array = rules.pet_types(pet)
				if rules.weather_type!="" and int(pet["hp"])>0 and not ("Rock" in kinds or "Ground" in kinds or "Steel" in kinds or _item_ability(pet)=="SAND_VEIL") and not underground.has(pet["individual_id"]):
					var amount: int = maxi(1,int(rules.pet_stats(pet)["hp"])/16)
					pet["hp"] = maxi(0,int(pet["hp"])-amount);telemetry.emit({"event":"sandstorm_damage","amount":amount,"id":pet["individual_id"]})
	await _visual_deltas(residual_before,"status")
	residual_before=_visual_snapshot()
	if _terminal():return
	for pet in _field_pets():
		if rooted.has(pet["individual_id"]) and int(pet["hp"])>0:
			var amount: int = mini(maxi(1,floori(int(rules.pet_stats(pet)["hp"])/16.0)),int(rules.pet_stats(pet)["hp"])-int(pet["hp"]))
			pet["hp"] += amount
			telemetry.emit({"event":"ingrain_healed","amount":amount})
	for is_enemy in [true,false]:
		var victim: Dictionary = enemy if is_enemy else active_pet()
		var receiver: Dictionary = active_pet() if is_enemy else enemy
		if (seeded_enemy if is_enemy else seeded_player) and int(victim["hp"])>0:
			var amount: int = mini(int(victim["hp"]),maxi(1,floori(int(rules.pet_stats(victim)["hp"])/8.0)))
			victim["hp"] = int(victim["hp"])-amount
			receiver["hp"] = maxi(0,int(receiver["hp"])-amount) if _item_ability(victim)=="LIQUID_OOZE" else mini(int(rules.pet_stats(receiver)["hp"]),int(receiver["hp"])+amount)
	for pet in _field_pets():
		if cursed.has(pet["individual_id"]) and int(pet["hp"])>0:
			pet["hp"] = maxi(0,int(pet["hp"])-maxi(1,int(rules.pet_stats(pet)["hp"])/4))
		if nightmares.has(pet["individual_id"]):
			if pet.get("status","")!="sleep":nightmares.erase(pet["individual_id"])
			elif int(pet["hp"])>0:pet["hp"]=maxi(0,int(pet["hp"])-maxi(1,int(rules.pet_stats(pet)["hp"])/4));telemetry.emit({"event":"nightmare_damage","id":pet["individual_id"]})
		if pet.get("status","")=="toxic" and int(pet["hp"])>0:
			pet["toxic_counter"] = mini(15,int(pet.get("toxic_counter",0))+1)
			var toxic_damage: int = maxi(1,int(rules.pet_stats(pet)["hp"])/16)*int(pet["toxic_counter"])
			pet["hp"] = maxi(0,int(pet["hp"])-toxic_damage)
			telemetry.emit({"event":"toxic_damage","amount":toxic_damage,"counter":pet["toxic_counter"]})
		if pet.get("status","") in ["poison","burn"] and int(pet["hp"])>0:
			var amount: int = maxi(1,floori(int(rules.pet_stats(pet)["hp"])/8.0))
			pet["hp"] = maxi(0,int(pet["hp"])-amount)
			log_text += Language.text("battle.5a94fb9dafc6","\n%s因%s受伤！") % [Language.display_name(pet,store.species[pet["species_id"]]["name"]),Language.text("battle.73d6418dedde","灼伤") if pet.get("status","")=="burn" else Language.text("battle.3af01c498fe4","中毒")]
			if pet.get("status","")=="burn":telemetry.emit({"event":"burn_damage","amount":amount})
	for pet in _field_pets():
		var id: String = pet["individual_id"]
		if bindings.has(id):
			var binding: Dictionary = bindings[id]
			var source: Dictionary = _find_field_pet(binding["source"])
			binding["turns"] = int(binding["turns"])-1
			if int(binding["turns"])<=0 or int(source["hp"])<=0 or int(pet["hp"])<=0:
				bindings.erase(id)
			else:
				var amount: int = maxi(1,floori(int(rules.pet_stats(pet)["hp"])/16.0))
				pet["hp"] = maxi(0,int(pet["hp"])-amount)
				log_text += Language.text("battle.42575965dcd4","\n%s受到绑紧伤害！") % Language.display_name(pet,store.species[pet["species_id"]]["name"])
				telemetry.emit({"event":"bind_damage","victim":id,"amount":amount})
	for pet in _field_pets():_sitrus(pet)
	await _visual_deltas(residual_before,"status")
	residual_before=_visual_snapshot()
	if _terminal():return
	for owner in charged.keys():
		charged[owner] = int(charged[owner])-1
		if int(charged[owner])<=0:charged.erase(owner)
	for victim in encored_moves.keys():
		var pet: Dictionary = _find_field_pet(victim)
		var effect: Dictionary = encored_moves[victim]
		effect["turns"] = int(effect["turns"])-1
		if int(effect["turns"])<=0 or effect["move"] not in pet["moves"] or int(pet["pp"].get(effect["move"],0))<=0:encored_moves.erase(victim)
	for victim in disabled_moves.keys():
		disabled_moves[victim]["turns"] = int(disabled_moves[victim]["turns"])-1
		if int(disabled_moves[victim]["turns"])<=0:disabled_moves.erase(victim)
	rain_turns = maxi(0,rain_turns-1);sun_turns=maxi(0,sun_turns-1)
	for side in reflect_turns:reflect_turns[side] = maxi(0,int(reflect_turns[side])-1)
	for side in light_screen_turns:light_screen_turns[side] = maxi(0,int(light_screen_turns[side])-1)
	for pet in _field_pets():field_turns[pet["individual_id"]] = int(field_turns.get(pet["individual_id"],0))+1
	await _visual_deltas(residual_before,"status")
	turn += 1
	busy = false
	if int(active_pet()["hp"])<=0:
		mode = "team"
		log_text = Language.text("battle.b1a776afeeb5","伙伴倒下了，请换上未倒下队友。")
	_update()

func _any_alive() -> bool:
	for pet in store.state["team"]:
		if int(pet["hp"])>0:return true
	return false

func _enemy_response() -> void:
	if _terminal():return
	if safari_mode:
		var flee_rate: int = safari_escape_factor
		if safari_rock>0:flee_rate = mini(20,safari_escape_factor*2)
		elif safari_bait>0:flee_rate = maxi(1,floori(safari_escape_factor/4.0))
		if randi()%100 < flee_rate*5:
			log_text = Language.text("battle.4b8150346229","%s逃跑了！") % Language.name(store.species[enemy["species_id"]]["name"])
			_finish(false,"safari_fled")
			return
		busy = false
		mode = "root"
		_update()
		return
	if int(active_pet()["hp"])<=0:busy=false;mode="team";_update();return
	var item: String = _trainer_item_choice()
	if item!="":await _use_trainer_item(item)
	else:await _move(enemy,active_pet(),_enemy_move(),enemy_stages,player_stages,false)
	await _round_end()

func _catch(item: String = "balls") -> void:
	if item not in ["balls","master_balls","great_balls","ultra_balls"]:return
	if mother_ghost:
		log_text = Language.text("battle.cf927c43b607","母亲幽灵无法捕获，未消耗精灵球。");telemetry.emit({"event":"mother_capture_blocked","balls":store.state["balls"]});_update();return
	if busy or ended or int(active_pet()["hp"])<=0:return
	if trainer_id!="":
		log_text = Language.text("battle.e3502fbd6602","训练家对战不能捕捉，未消耗精灵球。")
		telemetry.emit({"event":"trainer_capture_blocked","balls":store.state["balls"]})
		_update()
		return
	if not store.can_receive_capture() or int(store.state.get(item,0))<=0:
		log_text = Language.text("battle.b3ed21d32f5c","队伍与盒子已满，或精灵球耗尽。未消耗物品。")
		_update()
		return
	if transformed.has(enemy["individual_id"]):_restore_transform(enemy["individual_id"])
	var catch_before: Dictionary = store.state.duplicate(true)
	busy = true
	store.state[item] = int(store.state.get(item,0))-1
	var capture: Dictionary = {"caught":true,"shakes":4} if item=="master_balls" else rules.capture(int(enemy["hp"]),int(rules.pet_stats(enemy)["hp"]),int(store.species[enemy["species_id"]]["catch_rate"]),[randi()%65536,randi()%65536,randi()%65536,randi()%65536],enemy.get("status",""),20 if item=="ultra_balls" else 15 if item=="great_balls" else 10)
	var ball := _image("res://assets/pokemon/master_ball.png" if item=="master_balls" else "res://assets/pokemon/poke_ball.png",Rect2(600,185,72,72))
	for i in range(mini(3,int(capture["shakes"]))):
		log_text = (Language.text("battle.497a673b8b2c","投出大师球…%s") if item=="master_balls" else Language.text("battle.06de033bf918","投出精灵球…%s")) % Language.text("battle.e26227c21977","摇晃！").repeat(i+1)
		ball.position.x = 650+(-8 if i%2==0 else 8)
		_update()
		await get_tree().create_timer(.35).timeout
	ball.queue_free()
	var caught: bool = capture["caught"]
	telemetry.emit({"event":"catch_attempt","result":"caught" if caught else "failed","balls":store.state["balls"],"item":item,"remaining":store.state.get(item,0)})
	if caught:
		var knocked_before:Dictionary=knocked_items.duplicate(true)
		var enemy_before:Dictionary=enemy.duplicate(true)
		if static_id!="":_mark_static()
		enemy["met_location"]=store.state.get("location",{}).get("map_id","")
		_restore_knocked_items()
		var destination: Dictionary = store.receive_capture(enemy)
		if destination.has("error") or not store.save_game():
			store.state = catch_before
			enemy=enemy_before;knocked_items=knocked_before
			log_text = Language.text("battle.216828d791f0","捕获未保存，已退回本次精灵球，队伍与盒子未变。\n请检查保存目录后重试。")
			busy = false
			telemetry.emit({"event":"capture_save_failed","state":store.state.duplicate(true)})
			_update()
			return
		log_text = Language.text("battle.aed9127eab24","成功收服%s！") % Language.name(store.species[enemy["species_id"]]["name"])
		log_text += Language.text("battle.b0eda08f1821","已送往盒子%d · 位置%d。") % [int(destination["box"])+1,int(destination["slot"])+1] if destination["destination"]=="box" else Language.text("battle.98c4218b55b8","已加入队伍。")
		log_text += Language.text("battle.84bf79504434","\n捕获进度已保存。")
		telemetry.emit({"event":"capture_stored","destination":destination,"state":store.state.duplicate(true)})
		_finish(true,"caught")
	else:
		log_text = Language.text("battle.6f9c81a42747","挣脱了精灵球！")
		await _enemy_response()

func _safari_throw(action: String) -> void:
	if busy or ended or int(store.state.get("safari",{}).get("balls",0))<=0:return
	if action=="rock":
		safari_rock += 1
		safari_bait = 0
		safari_catch_factor = mini(20,safari_catch_factor*2)
		safari_escape_factor = mini(20,safari_escape_factor*2)
		log_text = Language.text("battle.e92e3620fb15","你向%s扔出了石头！它变得警惕了。") % Language.name(store.species[enemy["species_id"]]["name"])
		_enemy_response()
		_update();return
	if action=="bait":
		safari_bait += 1
		safari_rock = 0
		safari_catch_factor = maxi(3,floori(safari_catch_factor/2.0))
		safari_escape_factor = maxi(1,floori(safari_escape_factor/4.0))
		log_text = Language.text("battle.868e81ab347d","你向%s扔出了诱饵！它暂时安心了。") % Language.name(store.species[enemy["species_id"]]["name"])
		_enemy_response();_update();return
	var before: Dictionary = store.state.duplicate(true)
	store.state["safari"]["balls"] = int(store.state["safari"]["balls"])-1
	busy = true
	var effective_rate: int = maxi(1,floori(safari_catch_factor*1275.0/100.0))
	var capture: Dictionary = rules.capture(int(enemy["hp"]),int(rules.pet_stats(enemy)["hp"]),effective_rate,[randi()%65536,randi()%65536,randi()%65536,randi()%65536],"",10)
	if capture["caught"]:
		enemy["met_location"]=store.state.get("location",{}).get("map_id","")
		var destination: Dictionary = store.receive_capture(enemy)
		if destination.has("error") or not store.save_game():
			store.state = before
			log_text = Language.text("battle.0fe443b5809f","捕获未保存，临时球与队伍/盒子均已回滚。")
			busy = false;_update();return
		log_text = Language.text("battle.aed9127eab24","成功收服%s！") % Language.name(store.species[enemy["species_id"]]["name"])
		_finish(true,"caught")
	else:
		log_text = Language.text("battle.ccd1e1dbd797","宝可梦挣脱了临时球！")
		if int(store.state["safari"]["balls"])<=0:
			_finish(false,"safari_no_balls")
			return
		_enemy_response()

func _potion(item: String = "potions") -> void:
	var pet: Dictionary = active_pet()
	var max_hp: int = int(rules.pet_stats(pet)["hp"])
	if busy or ended or int(store.state.get(item,0))<=0 or int(pet["hp"])<=0 or int(pet["hp"])>=max_hp:return
	busy = true
	store.state[item] = int(store.state.get(item,0))-1
	pet["hp"] = mini(max_hp,int(pet["hp"])+(50 if item=="super_potions" else int(items["potion"]["heal"])))
	log_text = Language.text("battle.270cbd704667","使用好伤药！恢复50HP（不超过上限）。") if item=="super_potions" else Language.text("battle.dc4757c6a151","使用伤药！恢复20HP（不超过上限）。")
	telemetry.emit({"event":"potion_used","potions":store.state["potions"],"item":item,"remaining":store.state.get(item,0),"hp":pet["hp"]})
	_update()
	await get_tree().create_timer(.5).timeout
	await _enemy_response()

func _switch(index: int) -> void:
	if busy or index<0 or index>=store.state["team"].size() or index==int(store.state["lead"]) or int(store.state["team"][index]["hp"])<=0:return
	var forced: bool = int(active_pet()["hp"])<=0
	if not forced and (submerged.has(active_pet()["individual_id"]) or airborne.has(active_pet()["individual_id"]) or underground.has(active_pet()["individual_id"]) or rollouts.has(active_pet()["individual_id"]) or rampages.has(active_pet()["individual_id"])):return
	if not forced and _ability_trapped(active_pet(),enemy):log_text=Language.text("battle.05d0502f33cd","对手的特性阻止换下！");_update();return
	if not forced and rooted.has(active_pet()["individual_id"]):
		log_text = Language.text("battle.b0fd6d400f86","伙伴已扎根，不能换下！");_update();return
	if not forced and bindings.has(active_pet()["individual_id"]):
		log_text = Language.text("battle.421fb8bc35d6","伙伴被绑紧，暂时不能换下！")
		telemetry.emit({"event":"bind_switch_blocked"})
		_update()
		return
	if not forced and trapped.has(active_pet()["individual_id"]):
		log_text = Language.text("battle.5640b035bbc0","伙伴被黑色目光困住，不能换下！")
		telemetry.emit({"event":"mean_look_switch_blocked"})
		_update()
		return
	if not forced and "pursuit" in enemy["moves"] and int(enemy["pp"].get("pursuit",0))>0 and _enemy_move()=="pursuit":
		busy = true;pursuit_spent = true;await _move(enemy,active_pet(),"pursuit",enemy_stages,player_stages,false);pursuit_spent = false
		if _terminal():return
		forced = int(active_pet()["hp"])<=0
		_release_bindings(active_pet()["individual_id"]);store.state["lead"] = index;_spikes_entry(active_pet(),true);player_stages = rules.stages();seeded_player = false;_ability_entry(active_pet(),true)
		if index not in participants:participants.append(index)
		await _round_end();return
	_release_bindings(active_pet()["individual_id"])
	store.state["lead"] = index
	_spikes_entry(active_pet(),true)
	if index not in participants:participants.append(index)
	player_stages = rules.stages()
	_ability_entry(active_pet(),true)
	seeded_player = false
	busy = true
	mode = "root"
	telemetry.emit({"event":"switched","lead":index})
	if forced:
		busy = false
		if not _terminal():
			if int(active_pet()["hp"])<=0:mode="team"
			_update()
	else:await _enemy_response()

func _finish(victory: bool, result: String = "") -> void:
	if ended:return
	for id in mimicked.keys():_restore_mimic(id)
	for id in transformed.keys():_restore_transform(id)
	substitutes.clear();mirror_moves.clear();minimized.clear();recharging.clear();enduring.clear();rampage_moves.clear();stockpiles.clear();grudges.clear();uproars.clear();biding.clear();taunted.clear();tormented.clear();magic_coats.clear();snatches.clear();wishes.clear()
	rules.type_overrides.clear()
	submerged.clear();infatuated.clear()
	airborne.clear()
	underground.clear()
	solar_charges.clear()
	ended = true
	busy = false
	won = victory
	outcome = result if result!="" else "victory" if victory else "defeat"
	growth_events = [] if safari_mode else store.growth.award(store.state["team"],participants,enemy,outcome,trainer_id!="",store.state.get("location",{}).get("map_id",""))
	if trainer_id!="":
		trainer_events.append_array(growth_events.duplicate(true))
		waiting_next = victory and enemy_party.any(func(pet: Dictionary) -> bool:return int(pet["hp"])>0)
		evolution_queue = [] if waiting_next else evolution.candidates(store.state["team"],trainer_events,outcome,store.state)
	else:evolution_queue = evolution.candidates(store.state["team"],growth_events,outcome,store.state)
	if not waiting_next:
		_restore_knocked_items()
		player_stages=rules.stages();enemy_stages=rules.stages();mist_turns={"player":0,"enemy":0};focused.clear();dire_hit_used.clear()
	telemetry.emit({"event":"battle_ended","won":won,"outcome":outcome,"growth":growth_events.duplicate(true),"state":store.state.duplicate(true)})
	_next_growth_event()

func _next_growth_event() -> void:
	learning = {}
	while not growth_events.is_empty():
		var entry: Dictionary = growth_events.pop_front()
		var pet: Dictionary = store.state["team"][entry["index"]]
		var name_text: String = Language.display_name(pet,store.species[pet["species_id"]]["name"])
		if entry["kind"]=="xp":log_text += Language.text("battle.377b2c5cf5f9","\n%s获得%d经验！") % [name_text,entry["amount"]]
		elif entry["kind"]=="level":log_text += Language.text("battle.17d8e1cf3442","\n%s升到Lv%d！") % [name_text,entry["level"]]
		elif entry["kind"]=="learn" and entry["move"] not in pet["moves"]:
			if pet["moves"].size()<4:
				store.growth.resolve_learning(pet,entry["move"],pet["moves"].size())
				log_text += Language.text("battle.d8381a62dc9d","\n学会了%s！") % Language.name(rules.moves[entry["move"]]["name"])
				telemetry.emit({"event":"move_learned","index":entry["index"],"move":entry["move"]})
			else:
				learning = entry
				log_text = Language.text("battle.21ff249bbce9","%s升到Lv%d！\n想学%s：选择遗忘招式，或5放弃。") % [name_text,pet["level"],Language.name(rules.moves[entry["move"]]["name"])]
				_update()
				return
	if not evolution_queue.is_empty():
		_start_evolution()
		return
	if waiting_next:
		log_text += Language.text("battle.b9b20fb358b6","\nEnter：训练家派出下一只。")
	elif trainer_id!="":
		_settle_trainer()
		log_text += Language.text("battle.02f36cea6019","\nEnter 返回地图。")
	else:
		_settle_payday()
		log_text += Language.text("battle.01199a94438c","\nEnter 返回 · R 免费恢复返回。")
	_update()

func _start_evolution() -> void:
	evolution_entry = evolution_queue.pop_front()
	canvas.hide()
	evolution_view = preload("res://scripts/evolution_view.gd").new()
	evolution_view.before = evolution_entry["from"]
	evolution_view.after = evolution_entry["target"]
	evolution_view.species = store.species
	evolution_view.completed.connect(_evolution_completed)
	evolution_view.resolved.connect(_evolution_resolved)
	add_child(evolution_view)
	telemetry.emit({"event":"evolution_started","entry":evolution_entry.duplicate(true),"state":store.state.duplicate(true)})

func _evolution_completed(cancelled: bool) -> void:
	var pet: Dictionary = store.state["team"][evolution_entry["index"]]
	if not cancelled:
		# Preserve proven pre-evolution ownership before mutating an old-save individual.
		store.pokedex.register(store.state,store.species,pet["species_id"],true)
		growth_events = evolution.apply(pet,evolution_entry,store.state)
		store.pokedex.register(store.state,store.species,pet["species_id"],true)
	telemetry.emit({"event":"evolution_cancelled" if cancelled else "evolution_completed","entry":evolution_entry.duplicate(true),"state":store.state.duplicate(true)})

func _evolution_resolved(_cancelled: bool) -> void:
	evolution_view.queue_free()
	evolution_view = null
	evolution_entry = {}
	canvas.show()
	log_text = Language.text("battle.38da3d74f5c6","进化流程结束。")
	_next_growth_event()

func _learn_choice(slot: int) -> void:
	if learning.is_empty():return
	var entry: Dictionary = learning.duplicate()
	var pet: Dictionary = store.state["team"][entry["index"]]
	if slot>=0 and slot<pet["moves"].size() and pet["moves"][slot] in store.growth.HM_MOVES:
		log_text = Language.text("battle.463f784dd732","秘传招式不能在这里遗忘，请选择其他招式或放弃。")
		_update()
		return
	var learned: bool = store.growth.resolve_learning(pet,entry["move"],slot if slot<4 else -1)
	telemetry.emit({"event":"learning_resolved","index":entry["index"],"move":entry["move"],"learned":learned,"slot":slot,"state":store.state.duplicate(true)})
	log_text = Language.text("battle.677fd4d1b204","学会了%s！") % Language.name(rules.moves[entry["move"]]["name"]) if learned else Language.text("battle.d5d89ecb3f75","放弃学习%s。") % Language.name(rules.moves[entry["move"]]["name"])
	_next_growth_event()

func _release_bindings(id: String) -> void:
	for pet in store.state["team"]+enemy_party+[enemy]:
		if pet.get("individual_id","")==id and _item_ability(pet)=="NATURAL_CURE":_clear_status(pet)
	rules.flash_fire.erase(id)
	_restore_mimic(id)
	grudges.erase(id);uproars.erase(id)
	biding.erase(id);taunted.erase(id);tormented.erase(id);magic_coats.erase(id);snatches.erase(id)
	substitutes.erase(id);mirror_moves.erase(id);minimized.erase(id);rampage_moves.erase(id)
	recharging.erase(id);enduring.erase(id);stockpiles.erase(id);rollout_moves.erase(id)
	rules.type_overrides.erase(id)
	for pet in store.state["team"]+enemy_party:
		if pet["individual_id"]==id:pet.erase("toxic_counter")
	lock_ons.erase(id)
	for target in lock_ons.keys():
		if lock_ons[target]["source"]==id:lock_ons.erase(target)
	_restore_transform(id)
	yawned.erase(id);perish_counts.erase(id);protected.erase(id);protect_uses.erase(id)
	rampages.erase(id);rampage_unable.erase(id)
	raging.erase(id)
	field_turns.erase(id)
	fury_cutters.erase(id)
	rollouts.erase(id)
	rooted.erase(id)
	curled.erase(id)
	identified.erase(id)
	disabled_moves.erase(id)
	imprisoned_by.erase(id)
	mud_sport.erase(id)
	water_sport.erase(id)
	destiny_bonds.erase(id)
	copied_abilities.erase(id)
	focused.erase(id)
	dire_hit_used.erase(id)
	submerged.erase(id);infatuated.erase(id)
	for victim in infatuated.keys():
		if infatuated[victim]==id:infatuated.erase(victim)
	airborne.erase(id)
	underground.erase(id)
	solar_charges.erase(id)
	charged.erase(id)
	confused.erase(id)
	cursed.erase(id)
	nightmares.erase(id);trapped.erase(id)
	for victim in trapped.keys():
		if trapped[victim]==id:trapped.erase(victim)
	encored_moves.erase(id)
	flinched.erase(id)
	acted.erase(id)
	last_moves.erase(id)
	for victim in bindings.keys():
		if victim==id or bindings[victim]["source"]==id:bindings.erase(victim)

func _advance_enemy() -> void:
	if not waiting_next:return
	_release_bindings(enemy["individual_id"])
	# FireRed resets Toxic's escalating counter when a battler leaves the active slot.
	# A trainer's next opponent is the same battler-transition boundary for the player.
	active_pet().erase("toxic_counter")
	for i in range(enemy_party.size()):
		if int(enemy_party[i]["hp"])>0:enemy_index = i;break
	enemy = enemy_party[enemy_index]
	store.pokedex.register(store.state,store.species,enemy["species_id"],false)
	_spikes_entry(enemy,false)
	enemy_stages = rules.stages()
	_ability_entry(enemy,false)
	seeded_enemy = false
	participants = [int(store.state["lead"])] if int(active_pet()["hp"])>0 else []
	waiting_next = false
	ended = false
	busy = false
	mode = "root" if int(active_pet()["hp"])>0 else "team"
	log_text = Language.text("battle.d74da5c327bd","%s派出了%s！") % [trainer_rules.definition(trainer_id)["name"],Language.name(store.species[enemy["species_id"]]["name"])]
	telemetry.emit({"event":"trainer_next_enemy","index":enemy_index,"enemy":enemy.duplicate(true)})
	if _terminal():return
	_update()

var pickup_rewards:Dictionary={}
func _pickup_rewards(pickup_rng:RandomNumberGenerator=null)->void:
	if pickup_rng==null:pickup_rng=RandomNumberGenerator.new();pickup_rng.randomize()
	var found:Array=preload("res://scripts/tm_acquisition.gd").new().pickup(store.state,outcome,pickup_rng)
	for reward in found:pickup_rewards[reward["id"]]=reward["item"]
	if not found.is_empty():telemetry.emit({"event":"pickup_found","items":found})

func _settle_trainer() -> void:
	if trainer_settled:return
	trainer_settled = true
	store.state = store.league.result_state(store.state,won,trainer_id,store.growth) if trainer_id.begins_with("league_") else trainer_rules.result_state(store.state,won,trainer_id)
	var reward_failed:bool=store.state.is_empty()
	if reward_failed:store.error=Language.text("battle.8224bb7092c2","道馆奖励无法放入背包，本场未结算。")
	if won and not reward_failed:store.state["money"] = mini(999999,int(store.state["money"])+payday_coins)
	if not reward_failed:_pickup_rewards()
	if reward_failed or not store.save_game():
		store.state = trainer_before.duplicate(true)
		won = false
		outcome = "save_failed"
		log_text = store.error+Language.text("battle.ad052f5c54b2","\n本场结算已撤销，战前进度保留，可重试。")
	else:
		var info: Dictionary = trainer_rules.definition(trainer_id)
		log_text = Language.text("battle.02458bef37e6","%s：%s（原文译意）\n胜利！奖金%d已保存 · 余额%d。") % [Language.trainer_name(trainer_id,info["name"]),Language.story(info["defeat"]),info["reward"],store.state["money"]] if won else Language.text("battle.3f1aa3c46314","本场落败，无奖金；可治疗后重试。")
		if won and info.get("badge","")=="earth":log_text += Language.text("battle.7aa483ece881","\n获得绿色徽章！八枚徽章已经集齐。")
		if won and info.get("badge","")=="soul":log_text += Language.text("battle.a44a528ade8b","\n获得粉红徽章！")
		if won and info.get("badge","")=="marsh":log_text += Language.text("battle.60507eded60b","\n获得金色徽章！")
		if won and info.get("badge","")=="boulder":
			log_text += Language.text("battle.196166a4bfea","\n获得灰色徽章！")
			var badge := _image("res://assets/pewter-gym/boulder-badge.png",Rect2(844,20,64,64))
			badge.name = "BoulderBadge"
		if won and info.get("badge","")=="cascade":
			log_text += Language.text("battle.97ad55ecf36e","\n获得蓝色徽章！")
			var badge := _image("res://assets/cerulean-gym/cascade-badge.png",Rect2(844,20,64,64))
			badge.name = "CascadeBadge"
		if won and info.get("badge","")=="rainbow":
			log_text += Language.text("battle.76b6452a4ba7","\n获得彩虹徽章！")
			var badge := _image("res://assets/celadon-gym/rainbow-badge.png",Rect2(844,20,64,64))
			badge.name = "RainbowBadge"
		if won and info.get("badge","")=="thunder":
			log_text += Language.text("battle.492d535eb572","\n获得雷电徽章！")
			var badge := _image("res://assets/vermilion-gym/thunder-badge.png",Rect2(844,20,64,64))
			badge.name = "ThunderBadge"
		if won and info.get("badge","")=="volcano":log_text += Language.text("battle.27867ac1f58c","\n获得深红徽章！")
		if won and store.gym_rewards.data.has(trainer_id):log_text += Language.text("battle.6b2b37d64b0c","\n获得TM%02d ×1，已入包并保存。") % int(store.gym_rewards.data[trainer_id]["tm"])
	telemetry.emit({"event":"trainer_settled","won":won,"outcome":outcome,"state":store.state.duplicate(true)})

func _enemy_move() -> String:
	if underground.has(enemy["individual_id"]):return "dig"
	if airborne.has(enemy["individual_id"]):return str(airborne[enemy["individual_id"]])
	if rampages.has(enemy["individual_id"]):return rampage_moves.get(enemy["individual_id"],"thrash")
	if rollouts.has(enemy["individual_id"]):return rollout_moves.get(enemy["individual_id"],"rollout")
	if trainer_id!="":
		var candidate: Dictionary = enemy.duplicate(true)
		for id in candidate["moves"]:
			if _disabled(enemy,id):candidate["pp"][id] = 0
		if trainer_id=="fuchsia_koga":return trainer_ai.choose_koga(candidate,active_pet(),enemy_stages,player_stages,{"last":last_moves.get(active_pet()["individual_id"],""),"seeded":seeded_player,"rooted":rooted.has(enemy["individual_id"]),"cursed":cursed.has(active_pet()["individual_id"]),"user_reserves":enemy_party.filter(func(p):return p["individual_id"]!=enemy["individual_id"] and int(p["hp"])>0).size(),"target_reserves":store.state["team"].filter(func(p):return p["individual_id"]!=active_pet()["individual_id"] and int(p["hp"])>0).size()})
		if trainer_id=="saffron_sabrina":return trainer_ai.choose_sabrina(candidate,active_pet(),enemy_stages,player_stages,{"reflect":int(reflect_turns["enemy"]),"future":future_attacks.has("player"),"confused":confused.has(active_pet()["individual_id"]),"reserves":enemy_party.filter(func(p):return p["individual_id"]!=enemy["individual_id"] and int(p["hp"])>0).size()})
		if trainer_id.begins_with("vermilion_"):return trainer_ai.choose_gym(candidate,active_pet(),enemy_stages,player_stages,trainer_id=="vermilion_surge",seeded_player,confused.has(active_pet()["individual_id"]))
		return trainer_ai.choose(candidate,active_pet(),enemy_stages,player_stages,seeded_player,trainer_id not in ["route22_early","pewter_brock","cerulean_misty","ssanne_rival"],trainer_id=="cerulean_misty", {"target_disabled":disabled_moves.has(active_pet()["individual_id"]),"target_last":last_moves.get(active_pet()["individual_id"],"struggle")} if trainer_id=="ssanne_rival" else {})
	for id in enemy["moves"]:
		if int(enemy["pp"][id])>0 and not _disabled(enemy,id) and rules.power(id,active_pet())>0:return id
	for id in enemy["moves"]:
		if int(enemy["pp"][id])>0 and not _disabled(enemy,id):return id
	return "struggle"

# Rendering derives exclusively from the battle-local individual HP registry.
func _battler_texture(pet:Dictionary,player:bool)->Texture2D:
	var doll:bool=not ended and int(pet.get("hp",0))>0 and int(substitutes.get(pet.get("individual_id",""),0))>0
	var path:String=store.species[pet["species_id"]]["back" if player else "sprite"]
	if doll:path="res://assets/battle-substitute/"+("substitute_back.png" if player else "substitute.png")
	return load(path)

func _sync_battler_visuals()->void:
	if not is_instance_valid(portrait):return
	_set_battler_visual(portrait,active_pet(),true)
	_set_battler_visual(enemy_portrait,enemy,false)

func _set_battler_visual(sprite:TextureRect,pet:Dictionary,player:bool)->void:
	sprite.texture=_battler_texture(pet,player)
	sprite.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED if sprite.texture.resource_path.contains("battle-substitute/") else TextureRect.STRETCH_SCALE

func _update() -> void:
	var pet: Dictionary = active_pet()
	var data: Dictionary = store.species[pet["species_id"]]
	_sync_battler_visuals()
	portrait.visible = not underground.has(pet["individual_id"])
	hp_label.text = "%s%s" % [Language.display_name(pet,data["name"]),Language.text("battle.aa40341c4038"," · 中毒") if pet.get("status","")in ["poison","toxic"] else Language.text("battle.c5a4525ab133"," · 麻痹") if pet.get("status","")=="paralysis" else Language.text("battle.d9febb870dae"," · 灼伤") if pet.get("status","")=="burn" else Language.text("battle.38af319f950e"," · 冰冻") if pet.get("status","")=="freeze" else Language.text("battle.94d4d4e75cf3"," · 睡眠") if pet.get("status","")=="sleep" else ""]
	enemy_label.text = Language.name(store.species[enemy["species_id"]]["name"])+(Language.text("battle.aa40341c4038"," · 中毒") if enemy.get("status","")in ["poison","toxic"] else Language.text("battle.c5a4525ab133"," · 麻痹") if enemy.get("status","")=="paralysis" else Language.text("battle.d9febb870dae"," · 灼伤") if enemy.get("status","")=="burn" else Language.text("battle.38af319f950e"," · 冰冻") if enemy.get("status","")=="freeze" else Language.text("battle.94d4d4e75cf3"," · 睡眠") if enemy.get("status","")=="sleep" else "")
	enemy_portrait.visible = not underground.has(enemy["individual_id"])
	player_level.text = "Lv%d" % pet["level"]
	enemy_level.text = "Lv%d" % enemy["level"]
	hp_bar.max_value = int(rules.pet_stats(pet)["hp"])
	if visual_depth==0:hp_bar.value = int(pet["hp"])
	enemy_bar.max_value = int(rules.pet_stats(enemy)["hp"])
	if visual_depth==0:enemy_bar.value = int(enemy["hp"])
	log_label.text = Language.message(log_text)
	for child in menu.get_children():
		child.queue_free()
	if not learning.is_empty():
		var learner: Dictionary = store.state["team"][learning["index"]]
		for i in range(5):
			var text: String = Language.text("battle.079ed4bfd53c","%d 遗忘%s") % [i+1,Language.name(rules.moves[learner["moves"][i]]["name"])] if i<4 else Language.text("battle.e1cc3f1b1c93","5 放弃学习")
			UI.button(menu,text,Rect2(478+(i%2)*237,461+floori(i/2.0)*54,230,49),_learn_choice.bind(i))
		return
	if ended:return
	var labels: Array[String] = []
	match mode:
		"root": labels.assign([Language.text("battle.caad95d2f492","投临时球 ×%d") % int(store.state.get("safari",{}).get("balls",0)),Language.text("battle.9258af87f163","扔石头"),Language.text("battle.cf5b3f07af64","投诱饵"),Language.text("battle.2f6b0db7ddab","逃跑")]) if safari_mode else labels.assign([Language.text("battle.a642a31e1182","战斗"),Language.text("battle.015845346aa9","背包"),Language.text("battle.ffc69a048286","宝可梦"),Language.text("battle.2f6b0db7ddab","逃跑")])
		"moves":
			for id in pet["moves"]:
				var move: Dictionary = rules.moves[id]
				labels.append("%s  PP %d/%d\n%s / %s" % [Language.name(move["name"]),pet["pp"][id],move["pp"],move["type"],Language.text("battle.a454f17872a1","物理") if move["category"]=="Physical" else Language.text("battle.c32b61e9bdf8","特殊") if move["category"]=="Special" else Language.text("battle.e329c44530ee","变化")])
			if not _has_usable_move(pet):labels.assign([Language.text("battle.95edca9aff5d","挣扎")])
		"bag":
			for slot in range(bag_page*4,mini(bag_page*4+4,BAG_ITEMS.size())):
				var id:String=BAG_ITEMS[slot]
				labels.append((Language.text("battle.61e13ab991f5","宝可梦笛") if id=="poke_flute" else Language.text("battle.f09283456818","大师球") if id=="master_balls" else store.SHOP[id]["name"])+Language.text("battle.9796ac4eb284"," ×%d\n← / → 翻页 %d/%d")%[int(store.tower_story.flute(store.state)) if id=="poke_flute" else store.state.get(id,0),bag_page+1,ceili(float(BAG_ITEMS.size())/4.0)])
		"medicine_target":
			for member in store.state["team"]:labels.append("%s HP%d"%[Language.display_name(member,store.species[member["species_id"]]["name"]),member["hp"]])
		"team":
			for member in store.state["team"]:
				labels.append("%s HP %d" % [Language.display_name(member,store.species[member["species_id"]]["name"]),member["hp"]])
	for i in range(labels.size()):
		var button := UI.button(menu,"%d %s" % [i+1,labels[i]],Rect2(478+(i%2)*237,461+floori(i/2.0)*(54 if mode in ["team","medicine_target"] else 80),230,49 if mode in ["team","medicine_target"] else 73),_select.bind(i))
		button.add_theme_font_size_override("font_size",17)
		button.disabled = busy

		if mode=="moves":button.disabled = busy or (int(pet["pp"][pet["moves"][i]])<=0 and not airborne.has(pet["individual_id"]) and not underground.has(pet["individual_id"]) and not solar_charges.has(pet["individual_id"]) and not rollouts.has(pet["individual_id"]) and not rampages.has(pet["individual_id"]) and not biding.has(pet["individual_id"]) and not uproars.has(pet["individual_id"]) and not recharging.has(pet["individual_id"]) or (_disabled(pet,pet["moves"][i]) and not airborne.has(pet["individual_id"]) and not underground.has(pet["individual_id"])) or _forced_move(pet,pet["moves"][i])!=pet["moves"][i]) or int(pet["hp"])<=0
		if mode=="moves" and not _has_usable_move(pet):button.disabled = busy or int(pet["hp"])<=0
		if mode=="bag":button.disabled=busy or (not store.tower_story.flute(store.state) if BAG_ITEMS[bag_page*4+i]=="poke_flute" else int(store.state.get(BAG_ITEMS[bag_page*4+i],0))<=0)

func _escape() -> void:
	if busy or ended:return
	if trainer_id!="":
		log_text = Language.text("battle.96b2651d1bb6","训练家对战不能逃跑。")
		telemetry.emit({"event":"trainer_escape_blocked"})
		_update()
		return
	var success: bool = _item_ability(active_pet())=="RUN_AWAY" or not _ability_trapped(active_pet(),enemy) and rules.escape(rules.pet_stats(active_pet())["spe"],rules.pet_stats(enemy)["spe"],run_tries,randi()%256)
	run_tries += 1
	telemetry.emit({"event":"escape_attempt","success":success,"tries":run_tries})
	if success:
		log_text = Language.text("battle.991e6549311a","成功逃离！")
		_finish(false,"escaped")
	else:
		busy = true
		log_text = Language.text("battle.859caff2d1c7","没能逃走！")
		await _enemy_response()

func _trainer_item_choice() -> String:
	if (trainer_id not in ["league_lorelei","league_bruno","league_agatha","league_lance","league_champion","vermilion_surge","saffron_sabrina","fuchsia_koga","cinnabar_blaine"] and not trainer_id.begins_with("viridian_") and not trainer_id.begins_with("victory_")) or int(enemy["hp"])<=0:return ""
	var alive: int = 0
	for pet in enemy_party:
		if int(pet["hp"])>0:alive += 1
	for i in range(enemy_items.size()):
		if i>0 and alive>enemy_items.size()-i+1:continue
		var item: String = enemy_items[i]
		var maximum: int = rules.pet_stats(enemy)["hp"]
		if item=="fullrestore" and (int(enemy["hp"])<maximum/4):return item
		if item in ["superpotion","hyperpotion"] and (int(enemy["hp"])<maximum/4 or maximum-int(enemy["hp"])>(200 if item=="hyperpotion" else 50)):return item
		if item=="fullheal" and (enemy.get("status","")!="" or confused.has(enemy["individual_id"])):return item
	return ""

func _use_trainer_item(item: String) -> void:
	var index: int = enemy_items.find(item)
	if index<0:return
	enemy_items[index] = ""
	if item=="fullrestore":
		enemy["hp"]=int(rules.pet_stats(enemy)["hp"]);enemy.erase("status");enemy.erase("sleep_turns");enemy.erase("toxic_counter");confused.erase(enemy["individual_id"])
	elif item in ["superpotion","hyperpotion"]:enemy["hp"] = mini(int(rules.pet_stats(enemy)["hp"]),int(enemy["hp"])+(200 if item=="hyperpotion" else 50))
	else:
		enemy["status"] = "";enemy.erase("sleep_turns");enemy.erase("toxic_counter");confused.erase(enemy["individual_id"])
	log_text = Language.text("battle.fff06169dd82","%s使用了%s！") % [trainer_rules.definition(trainer_id)["name"],Language.text("battle.ecb2aa988353","全复药") if item=="fullrestore" else Language.text("battle.41d9fd088595","厉害伤药") if item=="hyperpotion" else Language.text("battle.4e0b2cf894ab","好伤药") if item=="superpotion" else Language.text("battle.c7e3b59a9107","万灵药")]
	telemetry.emit({"event":"trainer_item_used","item":item,"enemy_hp":enemy["hp"]})
	_update();await get_tree().create_timer(.65).timeout

func _force_out(attacker: Dictionary,defender: Dictionary,is_player: bool) -> bool:
	if _item_ability(defender)=="SUCTION_CUPS" or rooted.has(defender["individual_id"]):
		log_text = Language.text("battle.8a4ae7aeb521","对手扎根了，不能被吹走！");telemetry.emit({"event":"ingrain_roar_blocked"});return false
	var candidates: Array = []
	var party: Array = enemy_party if is_player else store.state["team"]
	var current: int = enemy_index if is_player else int(store.state["lead"])
	if trainer_id!="":
		for i in range(party.size()):
			if i!=current and int(party[i]["hp"])>0:candidates.append(i)
	if (trainer_id!="" and candidates.is_empty()) or not rules.roar_succeeds(int(attacker["level"]),int(defender["level"]),randi()%65536):
		log_text = Language.text("battle.5946b6ac34e0","吼叫失败！");return false
	if trainer_id=="":
		log_text = Language.text("battle.5ab72c467871","吼叫结束了野生遭遇！")
		_finish(false,"forced_out");return true
	_release_bindings(defender["individual_id"])
	var next: int = int(candidates[randi()%candidates.size()])
	if is_player:
		enemy_index = next;enemy = enemy_party[next];enemy_stages = rules.stages();seeded_enemy = false
	else:
		store.state["lead"] = next;player_stages = rules.stages();seeded_player = false;_ability_entry(active_pet(),true)
		if next not in participants:participants.append(next)
	_spikes_entry(party[next],not is_player);_ability_entry(party[next],not is_player)
	log_text = Language.text("battle.3d541fc1c722","吼叫！%s被拖上场！") % Language.name(store.species[party[next]["species_id"]]["name"])
	telemetry.emit({"event":"roar_switched","enemy":is_player,"index":next})

	return true

func _settle_payday() -> void:
	if static_id=="sevii_hypno":
		if payday_settled:return
		payday_settled=true
		if outcome in ["victory","caught","escaped","forced_out"]:
			var v:Dictionary=store.state.get("sevii",{}).duplicate(true);v["hypno_done"]=true;store.state["sevii"]=v
			if outcome=="victory":store.state["money"]=mini(999999,int(store.state["money"])+payday_coins);_pickup_rewards()
			if not store.save_game():store.state=battle_before.duplicate(true);won=false;outcome="save_failed";log_text=store.error
		telemetry.emit({"event":"sevii_hypno_settled","outcome":outcome,"state":store.state.duplicate(true)});return
	if static_id!="":
		if payday_settled:return
		payday_settled = true;_mark_static()
		if outcome=="victory":store.state["money"] = mini(999999,int(store.state["money"])+payday_coins);_pickup_rewards()
		if not store.save_game():store.state = battle_before.duplicate(true);won = false;outcome = "save_failed";log_text = store.error+Language.text("battle.0f40a6e13a47","\n静态事件结算已撤销。")
		telemetry.emit({"event":"static_settled","id":static_id,"outcome":outcome,"state":store.state.duplicate(true)});return
	if mother_ghost:
		if payday_settled:return
		payday_settled = true
		if won:
			store.state["trainers"]["tower_mother_released"] = true
			if not store.save_game():
				store.state = battle_before.duplicate(true);won = false;outcome = "save_failed";log_text = store.error
			else:log_text = Language.text("battle.12ce21723744","幽灵是卡拉卡拉的母亲。母亲的灵魂安息了！")
		else:
			store.state = battle_before.duplicate(true)
		telemetry.emit({"event":"mother_settled","won":won,"outcome":outcome,"state":store.state.duplicate(true)});return
	if payday_settled:return
	payday_settled = true
	# Source only BattleWon reaches givepaydaymoney; capture/run/teleport/loss do not.
	if outcome!="victory":return
	store.state["money"] = mini(999999,int(store.state["money"])+payday_coins)
	_pickup_rewards()
	if not store.save_game():
		store.state = battle_before.duplicate(true)
		won = false;outcome = "save_failed"
		log_text = store.error+Language.text("battle.33aa780ff29d","\n聚宝功与本场成长结算已撤销。")
	elif payday_coins>0:log_text += Language.text("battle.7890c42e2371","\n拾取了%d元！") % payday_coins

# Gen3 Baton Pass: retain stage and only the supported passable volatile set.
func _begin_baton(is_player: bool) -> void:
	var party: Array = store.state["team"] if is_player else enemy_party
	var current: int = int(store.state["lead"]) if is_player else enemy_index
	var next: int = -1
	for i in range(party.size()):
		if i!=current and int(party[i]["hp"])>0:next = i;break
	if next<0:log_text = Language.text("battle.5d1d59bdb48e","没有可接棒的队友！");telemetry.emit({"event":"baton_pass_failed"});return
	if is_player:
		baton_pending = true;busy = true;mode = "team";log_text = Language.text("battle.66f1bffcadab","选择接棒队友（数字键）。");_update()
	else:_complete_baton(next,false)
func _complete_baton(index: int,is_player: bool) -> void:
	var party: Array = store.state["team"] if is_player else enemy_party
	var current: int = int(store.state["lead"]) if is_player else enemy_index
	if index<0 or index>=party.size() or index==current or int(party[index]["hp"])<=0:return
	var old: String = party[current]["individual_id"]
	var target: String = party[index]["individual_id"]
	var carry: Array = []
	for values in [confused,focused,cursed,perish_counts,rooted,mud_sport,water_sport,substitutes]:
		carry.append(values.get(old,null))
	_release_bindings(old)
	var sets: Array = [confused,focused,cursed,perish_counts,rooted,mud_sport,water_sport,substitutes]
	for i in range(sets.size()):
		if carry[i]!=null:sets[i][target] = carry[i]
	if is_player:
		store.state["lead"] = index
		if index not in participants:participants.append(index)
	else:enemy_index = index;enemy = party[index]
	_spikes_entry(party[index],is_player);_ability_entry(party[index],is_player)
	baton_pending = false;busy = true;mode = "root"
	log_text = Language.text("battle.93fc68c97542","接棒！能力变化由队友继承。");telemetry.emit({"event":"baton_pass","player":is_player,"from":old,"to":target,"index":index});_update()

func _mark_static() -> void:
	if static_id=="sevii_hypno":
		var v:Dictionary=store.state.get("sevii",{}).duplicate(true);v["hypno_done"]=true;store.state["sevii"]=v;return
	var flags: Dictionary = store.state.get("static_encounters",{}).duplicate()
	flags[static_id] = true;store.state["static_encounters"] = flags

func _metronome_pool() -> Array:
	var result:Array=[];var seen:Dictionary={}
	var forbidden:Array=["metronome","struggle","sketch","mimic","counter","mirrorcoat","protect","detect","endure","destinybond","sleeptalk","thief","followme","snatch","helpinghand","covet","trick","focuspunch"]
	for id in rules.moves:
		var canonical:String=str(id).replace("_","")
		if canonical not in forbidden and not seen.has(canonical):result.append(id);seen[canonical]=true
	return result
func _transform(a: Dictionary,d: Dictionary,ast: Dictionary,dst: Dictionary) -> void:
	var id: String = a["individual_id"]
	if transformed.has(id) or transformed.has(d["individual_id"]):log_text = Language.text("battle.2b08fc84f1fb","变身失败！");return
	transformed[id] = {"species_id":a["species_id"],"moves":a["moves"].duplicate(),"pp":a["pp"].duplicate()}
	var stats: Dictionary = rules.pet_stats(d).duplicate();stats["hp"] = rules.pet_stats(a)["hp"];rules.transformed_stats[id] = stats
	copied_abilities[id]=_item_ability(d)
	a["species_id"] = d["species_id"];a["moves"] = d["moves"].duplicate();a["pp"] = {}
	for move in a["moves"]:a["pp"][move] = mini(5,int(rules.moves[move]["pp"]))
	ast.merge(dst,true);log_text = Language.text("battle.8f3c195c8989","变身！保留自身HP，复制对手形态、五项数值、招式与能力等级。");telemetry.emit({"event":"transformed","id":id,"target":d["species_id"]})
func _restore_transform(id: String) -> void:
	if not transformed.has(id):return
	var pet: Dictionary = active_pet() if active_pet()["individual_id"]==id else enemy
	for p in enemy_party+store.state["team"]:
		if p["individual_id"]==id:pet = p;break
	for key in transformed[id]:pet[key] = transformed[id][key]
	transformed.erase(id);rules.transformed_stats.erase(id);copied_abilities.erase(id)

func _safeguarded(pet: Dictionary) -> bool:
	return int(safeguard_turns[_side(pet)])>0

func _inflict_opponent(pet: Dictionary,status: String) -> bool:
	var applied:bool=not _safeguarded(pet) and not (status=="sleep" and not uproars.is_empty() and _item_ability(pet)!="SOUNDPROOF") and rules.inflict(pet,status)
	if applied and _item_ability(pet)=="SYNCHRONIZE" and status in ["poison","toxic","paralysis","burn"]:rules.inflict(enemy if pet["individual_id"]==active_pet()["individual_id"] else active_pet(),"poison" if status=="toxic" else status)
	return applied

func _medicine(index:int)->void:
	var item:String=medicine_pending
	var pet:Dictionary=store.state["team"][index]
	var failure:String=store.medicine.apply(store,item,index,true,confused.has(pet["individual_id"]))
	if failure!="":log_text=failure;_update();return
	if item in ["full_restores","full_heals"]:confused.erase(pet["individual_id"])
	medicine_pending="";mode="root";busy=true;log_text=store.SHOP[item]["name"]+Language.text("battle.78f44f5ecd04","使用成功！")
	telemetry.emit({"event":"medicine_used","item":item,"target":index,"remaining":store.state.get(item,0),"hp":pet["hp"]})
	_update();await get_tree().create_timer(.5).timeout;await _enemy_response()

func _battle_item_failure(item:String)->String:
	if safari_mode:return Language.text("battle.9358f8bdf978","野生保护区对战不能使用战斗道具。")
	if int(active_pet()["hp"])<=0:return Language.text("battle.864a6ba325d8","倒下的伙伴不能使用战斗道具。")
	var stages:Dictionary=player_stages
	if item in ["x_attacks"] and int(stages["atk"])>=6:return Language.text("battle.ad253e94eafc","攻击等级已达上限。")
	if item in ["x_defends"] and int(stages["def"])>=6:return Language.text("battle.f1d98e3dbca3","防御等级已达上限。")
	if item in ["x_speeds"] and int(stages["spe"])>=6:return Language.text("battle.ac8da4a8f2e8","速度等级已达上限。")
	if item in ["x_specials"] and int(stages["spa"])>=6:return Language.text("battle.f795a3ca9a06","特攻等级已达上限。")
	if item in ["x_accuracies"] and int(stages["accuracy"])>=6:return Language.text("battle.126cd8c98567","命中等级已达上限。")
	if item=="guard_specs" and int(mist_turns["player"])>0:return Language.text("battle.bda47b264c69","防御喷雾效果仍在持续。")
	if item=="dire_hits" and focused.has(active_pet()["individual_id"]):return Language.text("battle.32d634129db9","要害攻击效果已生效。")
	return ""

func _use_battle_item(item:String)->void:
	if busy or ended or item not in store.BATTLE_ITEMS or (mode!="bag" and not store.BATTLE_ITEMS.has(item)):return
	var count:int=int(store.state.get(item,0));var failure:String=Language.text("battle.b0f020491a29","背包中没有该道具。") if count<=0 else _battle_item_failure(item)
	if failure!="":log_text=failure;_update();return
	var before:Dictionary=store.state.duplicate(true);store.state[item]=count-1
	if not save_canonical():store.state=before;log_text=store.error+Language.text("battle.701285212915"," 道具未消耗，本回合未使用。");_update();return
	var id:String=active_pet()["individual_id"];var stat:String=str({"x_attacks":"atk","x_defends":"def","x_speeds":"spe","x_specials":"spa","x_accuracies":"accuracy"}.get(item,""))
	if stat!="":player_stages[stat]=mini(6,int(player_stages[stat])+1)
	elif item=="guard_specs":mist_turns["player"]=5
	else:focused[id]=true;dire_hit_used[id]=true
	log_text=Language.text("battle.fff06169dd82","%s使用了%s！")%[Language.name(store.species[active_pet()["species_id"]]["name"]),store.BATTLE_ITEM_NAMES[item]]
	store.friendship.adjust(active_pet(),"battle_item",store.state.get("location",{}).get("map_id",""))
	telemetry.emit({"event":"battle_item_used","item":item,"stage":player_stages.duplicate(true),"mist_turns":mist_turns["player"],"dire_hit":focused.has(id)})
	mode="root";medicine_pending="";busy=true;_update();await get_tree().create_timer(.5).timeout;await _enemy_response()
func _spikes_entry(pet:Dictionary,is_player:bool)->void:
	var side:String="player" if is_player else "enemy";var layers:int=int(spikes[side])
	# Narrow default-ability immunity for supported species; no general ability engine.
	if layers==0 or int(pet["hp"])<=0 or "Flying" in rules.pet_types(pet) or _item_ability(pet)=="LEVITATE":return
	var amount:int=maxi(1,int(rules.pet_stats(pet)["hp"])/((5-layers)*2))
	pet["hp"]=maxi(0,int(pet["hp"])-amount)
	telemetry.emit({"event":"spikes_damage","side":side,"layers":layers,"amount":amount,"hp":pet["hp"]})

func gender(pet:Dictionary)->String:
	if pet.has("gender"):return pet["gender"]
	var ratio:int=int(store.species[pet["species_id"]].get("gender_ratio",127))
	if ratio==255:return "none"
	if ratio==254:return "female"
	return "female" if int(pet["individual_id"].substr(0,2).hex_to_int())<ratio else "male"
func _sitrus(pet:Dictionary)->void:
	if pet.get("held_item","")!="sitrusberry" or int(pet["hp"])<=0:return
	var maximum:int=int(rules.pet_stats(pet)["hp"])
	if int(pet["hp"])>maximum/2:return
	consumed_items[pet["individual_id"]]="sitrusberry"
	var amount:int=mini(30,maximum-int(pet["hp"]));pet["hp"]+=amount;pet.erase("held_item");telemetry.emit({"event":"sitrus_used","amount":amount,"id":pet["individual_id"]})

func _knock_off(pet:Dictionary)->bool:
	var ability:String=_item_ability(pet)
	if ability.to_upper()=="STICKY_HOLD" or pet.get("held_item","")=="":return false
	knocked_items[pet["individual_id"]]=pet["held_item"];pet.erase("held_item")
	telemetry.emit({"event":"knock_off","id":pet["individual_id"]});return true
func _recycle(pet:Dictionary)->bool:
	var id:String=pet["individual_id"]
	if pet.get("held_item","")!="" or not consumed_items.has(id):return false
	pet["held_item"]=consumed_items[id];consumed_items.erase(id);return true
func _restore_knocked_items()->void:
	for pet in store.state["team"]+enemy_party+[enemy]:
		if knocked_items.has(pet.get("individual_id","")):pet["held_item"]=knocked_items[pet["individual_id"]]
	knocked_items.clear()
	for pet in store.state["team"]+enemy_party:
		if original_held_items.has(pet["individual_id"]):
			var item:String=original_held_items[pet["individual_id"]]
			if item!="" and not consumed_items.has(pet["individual_id"]):pet["held_item"]=item
			elif item=="":pet.erase("held_item")
func _use_flute()->void:
	if not store.tower_story.flute(store.state):return
	for pet in store.state["team"]+enemy_party+[enemy]:
		if not pet.is_empty() and _item_ability(pet)!="SOUNDPROOF" and pet.get("status","")=="sleep":pet.erase("status");pet.erase("sleep_turns");nightmares.erase(pet["individual_id"])
	mode="root";busy=true;log_text=Language.text("battle.3dc513143b48","吹响了宝可梦笛！");_update()
	telemetry.emit({"event":"poke_flute_used"})
	await get_tree().create_timer(.5).timeout
	await _enemy_response()

func _use_doll()->void:
	if trainer_id!="" or int(store.state.get("poke_dolls",0))<=0:
		log_text=Language.text("battle.8775148b37fc","这里不能使用皮皮玩偶。");_update();return
	store.state["poke_dolls"]-=1;_finish(false,"escaped")
func _secret_power(defender:Dictionary,stages:Dictionary)->void:
	match item_terrain:
		"grass":_inflict_opponent(defender,"poison")
		"long_grass":_inflict_opponent(defender,"sleep")
		"sand":stages["accuracy"]=maxi(-6,int(stages["accuracy"])-1)
		"underwater":stages["def"]=maxi(-6,int(stages["def"])-1)
		"water":stages["atk"]=maxi(-6,int(stages["atk"])-1)
		"pond":stages["spe"]=maxi(-6,int(stages["spe"])-1)
		"mountain":
			if not _safeguarded(defender):confused[defender["individual_id"]]=(randi()%4)+2
		"cave":
			if not acted.has(defender["individual_id"]):flinched[defender["individual_id"]]=true
		_:_inflict_opponent(defender,"paralysis")

func _item_ability(pet:Dictionary)->String:
	if copied_abilities.has(pet["individual_id"]):return copied_abilities[pet["individual_id"]]
	var abilities:Array=item_abilities.get(pet["species_id"],["NONE","NONE"])
	# No source personality field exists in old saves: stable individual-ID parity is the local adapter.
	var slot:int=int(pet["individual_id"].right(1).hex_to_int())%2
	return abilities[slot] if abilities[slot]!="NONE" else abilities[0]

func _same_move(a:String,b:String)->bool:return a.replace("_","")==b.replace("_","")
func _knows(pet:Dictionary,id:String)->bool:
	for known in pet["moves"]:
		if _same_move(known,id):return true
	return false
func _restore_mimic(id:String)->void:
	if not mimicked.has(id):return
	for pet in store.state["team"]+enemy_party:
		if pet["individual_id"]==id:
			var entry:Dictionary=mimicked[id];pet["moves"][entry["slot"]]="mimic";pet["pp"].erase(entry["move"]);pet["pp"]["mimic"]=entry["pp"]
	mimicked.erase(id)
func _copy_move(a:Dictionary,d:Dictionary,id:String,ast:Dictionary,dst:Dictionary,player:bool,before:Dictionary)->void:
	var key:String=a["individual_id"];var previous:String=last_moves.get(d["individual_id"],"");var next:String="";var pool:Array=[]
	if id=="mirrormove":next=mirror_moves.get(key,"")
	elif id=="naturepower":next={"grass":"stunspore","long_grass":"razorleaf","sand":"earthquake","underwater":"hydropump","water":"surf","pond":"bubblebeam","mountain":"rockslide","cave":"shadowball","building":"swift","plain":"swift"}.get(item_terrain,"swift")
	elif id=="sleeptalk":
		if a.get("status","")=="sleep":
			for known in a["moves"]:
				if known not in ["assist","mirrormove","metronome","mimic","sketch","sleeptalk","focuspunch","uproar","bide"] and rules.moves[known]["source_effect"] not in ["EFFECT_SKULL_BASH","EFFECT_RAZOR_WIND","EFFECT_SKY_ATTACK","EFFECT_SOLAR_BEAM","EFFECT_SEMI_INVULNERABLE"] and not _disabled(a,known):pool.append(known)
	elif id=="assist":
		for pet in (store.state["team"] if player else enemy_party):
			if pet["individual_id"]==key:continue
			for known in pet["moves"]:
				if known not in ["assist","mirrormove","metronome","struggle","sketch","mimic","counter","mirrorcoat","protect","detect","endure","destinybond","sleeptalk","thief","followme","snatch","helpinghand","covet","trick","focuspunch"]:pool.append(known)
	elif id in ["mimic","sketch"]:
		var slot:int=a["moves"].find(id)
		var allowed:bool=slot>=0 and rules.moves.has(previous) and not _knows(a,previous) and not transformed.has(key) and previous not in (["struggle","sketch"] if id=="sketch" else ["metronome","struggle","sketch","mimic"])
		if allowed:
			if id=="mimic":mimicked[key]={"slot":slot,"move":previous,"pp":a["pp"][id]}
			a["moves"][slot]=previous;a["pp"].erase(id);a["pp"][previous]=int(rules.moves[previous]["pp"]) if id=="sketch" else mini(5,int(rules.moves[previous]["pp"]))
			if id=="sketch" and player:
				if not save_canonical():
					store.state=before.duplicate(true);log_text=store.error;telemetry.emit({"event":"sketch_save_failed","error":store.error});return
			log_text=Language.text("battle.966d09fbc3d6","写生永久学会了招式！") if id=="sketch" else Language.text("battle.5507082ba840","模仿暂时复制了招式！")
		else:log_text=Language.text("battle.8deeb4fe6175","复制招式失败。")
		telemetry.emit({"event":id,"applied":allowed,"move":previous});return
	if next in ["mirrormove","metronome","assist","sleeptalk"]:next=""
	if not pool.is_empty():next=pool.pick_random()
	if next=="" or not rules.moves.has(next):log_text=Language.text("battle.4023b8457916","没有可调用的招式。");telemetry.emit({"event":"called_move_failed","move":id});return
	telemetry.emit({"event":"called_move","caller":id,"move":next});await _move(a,d,next,ast,dst,player,true)

# Fixed damage follows substitute/Endure but bypasses ordinary damage modifiers.
func _apply_direct(a:Dictionary,d:Dictionary,amount:int,id:String)->int:
	var key:String=d["individual_id"];var lost:int=0
	if substitutes.has(key):
		lost=mini(int(substitutes[key]),amount);substitutes[key]-=lost
		if substitutes[key]<=0:substitutes.erase(key)
		_sync_battler_visuals()
	else:
		lost=mini(maxi(0,int(d["hp"])-(1 if enduring.has(key) else 0)),amount);d["hp"]-=lost
		if lost>0:
			_ability_contact(a,d,rules.moves[id])
			direct_damage_sources[key]=a["individual_id"];direct_damage_amounts[key]=lost;direct_damage_physical[key]=rules.moves[id]["category"]=="Physical"
			if biding.has(key):biding[key]["damage"]+=lost
			if d["hp"]==0 and destiny_bonds.has(key):a["hp"]=0
	return lost
func _special_damage(a:Dictionary,d:Dictionary,id:String,player:bool)->bool:
	var total:int=0
	if id=="psywave":
		if rules.move_effectiveness("Psychic",d["species_id"],false,d)>0:total=_apply_direct(a,d,maxi(1,int(a["level"])*(50+10*(randi()%11))/100),id)
	elif id=="present":
		var roll:int=randi()%256
		if roll>=204:
			var healed:int=mini(maxi(1,int(rules.pet_stats(d)["hp"])/4),int(rules.pet_stats(d)["hp"])-int(d["hp"]));d["hp"]+=healed;log_text=Language.text("battle.d6167e77e1c4","礼物恢复了%dHP！")%healed;telemetry.emit({"event":"present_healed","amount":healed});return healed>0
		total=_apply_direct(a,d,rules.damage(a,d,id,player_stages if player else enemy_stages,enemy_stages if player else player_stages,randi_range(85,100)/100.0,1.0,randi()%16==0,40 if roll<102 else 80 if roll<178 else 120),id)
	elif id=="beatup":
		for pet in (store.state["team"] if player else enemy_party):
			if int(pet["hp"])<=0 or pet.get("status","")!="" or int(d["hp"])<=0:continue
			var power:int=(int(pet["level"])*2/5+2)*int(store.species[pet["species_id"]]["base_stats"]["atk"])*10/int(store.species[d["species_id"]]["base_stats"]["def"])/50+2
			if randi()%16==0:power*=2
			total+=_apply_direct(a,d,power,id)
	log_text=Language.text("battle.dd1411041bc7","%s造成%d伤害！")%[Language.name(rules.moves[id]["name"]),total];telemetry.emit({"event":"special_damage","move":id,"damage":total})
	return total>0

func _exchange_items(a:Dictionary,d:Dictionary)->bool:
	if a.get("held_item","")=="retro_mail" or d.get("held_item","")=="retro_mail" or _item_ability(d)=="STICKY_HOLD":return false
	if a.get("held_item","")=="" and d.get("held_item","")=="":return false
	for pet in [a,d]:
		if not original_held_items.has(pet["individual_id"]):original_held_items[pet["individual_id"]]=pet.get("held_item","")
	var item:String=a.get("held_item","");var other:String=d.get("held_item","")
	a.erase("held_item");d.erase("held_item")
	if other!="":a["held_item"]=other
	if item!="":d["held_item"]=item
	return true
func _steal_item(a:Dictionary,d:Dictionary)->bool:
	if a.get("held_item","")!="" or d.get("held_item","") in ["","retro_mail"] or _item_ability(d)=="STICKY_HOLD":return false
	for pet in [a,d]:
		if not original_held_items.has(pet["individual_id"]):original_held_items[pet["individual_id"]]=pet.get("held_item","")
	a["held_item"]=d["held_item"];d.erase("held_item");telemetry.emit({"event":"item_stolen","item":a["held_item"]});return true

func save_canonical()->bool:
	var live:Dictionary=store.state;var canonical:Dictionary=live.duplicate(true)
	for pet in canonical["team"]:
		var pid:String=pet["individual_id"]
		if transformed.has(pid):
			for field in transformed[pid]:pet[field]=transformed[pid][field].duplicate(true) if transformed[pid][field] is Dictionary or transformed[pid][field] is Array else transformed[pid][field]
		if mimicked.has(pid):
			var entry:Dictionary=mimicked[pid];pet["moves"][entry["slot"]]="mimic";pet["pp"].erase(entry["move"]);pet["pp"]["mimic"]=entry["pp"]
		if original_held_items.has(pid):
			var item:String=pickup_rewards[pid] if pickup_rewards.has(pid) and outcome=="victory" and (trainer_settled or payday_settled) else original_held_items[pid]
			if item!="" and not consumed_items.has(pid):pet["held_item"]=item
			elif item=="":pet.erase("held_item")
	store.state=canonical;var ok:bool=store.save_game();store.state=live;return ok

# FireRed single-battler ability hooks; state is scoped to this battle node.
func _clear_status(pet:Dictionary)->void:
	for field in ["status","sleep_turns","toxic_counter"]:pet.erase(field)
	nightmares.erase(pet["individual_id"])
func _sync_weather()->void:
	rules.weather_type="" if _field_pets().any(func(p):return int(p["hp"])>0 and _item_ability(p) in ["CLOUD_NINE","AIR_LOCK"]) else "Fire" if sun_turns>0 else "Water" if rain_turns>0 else "Rock" if sand_turns>0 else "Ice" if hail_turns>0 else ""
func _stat_immune(pet:Dictionary,stat:String)->bool:
	return _item_ability(pet) in ["CLEAR_BODY","WHITE_SMOKE"] or stat=="atk" and _item_ability(pet)=="HYPER_CUTTER" or stat=="accuracy" and _item_ability(pet)=="KEEN_EYE"
func _ability_entry(pet:Dictionary,player:bool)->void:
	if safari_mode or int(pet["hp"])<=0:return
	var other:Dictionary=enemy if player else active_pet()
	var stages:Dictionary=enemy_stages if player else player_stages
	if _item_ability(pet)=="TRACE" and _item_ability(other) not in ["NONE","TRACE"]:copied_abilities[pet["individual_id"]]=_item_ability(other)
	if _item_ability(pet)=="INTIMIDATE" and not substitutes.has(other["individual_id"]) and not _stat_immune(other,"atk"):stages["atk"]=maxi(-6,int(stages["atk"])-1)
	telemetry.emit({"event":"ability_entry","ability":_item_ability(pet),"id":pet["individual_id"]})
	_sync_weather()
func _ability_blocks(a:Dictionary,d:Dictionary,m:Dictionary,id:String)->bool:
	var ability:String=_item_ability(d);var blocked:bool=false
	if m["target"]=="self":return false
	if ability=="SOUNDPROOF" and id in ["growl","roar","sing","supersonic","screech","snore","uproar","metal_sound","metalsound","grasswhistle","hypervoice"]:blocked=true
	if ability=="LEVITATE" and m["type"]=="Ground" and int(m["power"])>0:blocked=true
	if ability in ["VOLT_ABSORB","WATER_ABSORB"] and int(m["power"])>0 and m["type"]==("Electric" if ability=="VOLT_ABSORB" else "Water"):
		d["hp"]=mini(int(rules.pet_stats(d)["hp"]),int(d["hp"])+maxi(1,int(rules.pet_stats(d)["hp"])/4));blocked=true
	if ability=="FLASH_FIRE" and m["type"]=="Fire" and d.get("status","")!="freeze":rules.flash_fire[d["individual_id"]]=true;blocked=true
	if blocked:log_text=Language.text("battle.d2841cbdaef6","特性使招式无效！");telemetry.emit({"event":"ability_block","ability":ability,"move":id})
	return blocked
func _ability_trapped(pet:Dictionary,other:Dictionary)->bool:
	return _item_ability(other)=="MAGNET_PULL" and "Steel" in rules.pet_types(pet) or _item_ability(other)=="ARENA_TRAP" and "Flying" not in rules.pet_types(pet) and _item_ability(pet)!="LEVITATE"
func _ability_contact(a:Dictionary,d:Dictionary,m:Dictionary)->void:
	if int(a["hp"])<=0 or "FLAG_MAKES_CONTACT" not in m["source_flags"]:return
	var ability:String=_item_ability(d)
	if ability in ["STATIC","POISON_POINT"] and randi()%3==0:_ability_status(a,d,"paralysis" if ability=="STATIC" else "poison")
	if ability=="EFFECT_SPORE" and randi()%10==0:
		var status:String=["sleep","poison","paralysis"][randi()%3]
		if _ability_status(a,d,status) and status=="sleep":a["sleep_turns"]=randi_range(2,5)
	if ability=="CUTE_CHARM" and int(d["hp"])>0 and _item_ability(a)!="OBLIVIOUS" and gender(a)!="none" and gender(d)!="none" and gender(a)!=gender(d) and randi()%3==0:infatuated[a["individual_id"]]=d["individual_id"]
func _ability_end(pet:Dictionary)->void:
	if int(pet["hp"])<=0:return
	if _item_ability(pet)=="SHED_SKIN" and pet.get("status","")!="" and randi()%3==0:_clear_status(pet)
	_ability_cure(pet)
func _ability_cure(pet:Dictionary)->void:
	if _item_ability(pet) in ["IMMUNITY","LIMBER","WATER_VEIL","INSOMNIA","VITAL_SPIRIT"]:
		var status:String=pet.get("status","")
		if status in ["poison","toxic"] and _item_ability(pet)=="IMMUNITY" or status=="paralysis" and _item_ability(pet)=="LIMBER" or status=="burn" and _item_ability(pet)=="WATER_VEIL" or status=="sleep" and _item_ability(pet) in ["INSOMNIA","VITAL_SPIRIT"]:_clear_status(pet)
	if _item_ability(pet)=="OWN_TEMPO":confused.erase(pet["individual_id"])
	if _item_ability(pet)=="OBLIVIOUS":infatuated.erase(pet["individual_id"])

func _secondary(a:Dictionary,d:Dictionary,chance:int)->bool:
	return _item_ability(d)!="SHIELD_DUST" and randi()%100<mini(100,chance*(2 if _item_ability(a)=="SERENE_GRACE" else 1))

func _ability_status(pet:Dictionary,source:Dictionary,status:String)->bool:
	var applied:bool=rules.inflict(pet,status)
	if applied and _item_ability(pet)=="SYNCHRONIZE" and status in ["poison","toxic","burn","paralysis"]:rules.inflict(source,"poison" if status=="toxic" else status)
	return applied

func _ability_accuracy(a:Dictionary,d:Dictionary,value:float)->float:
	return value*(1.3 if _item_ability(a)=="COMPOUND_EYES" else 1.0)*(0.8 if _item_ability(d)=="SAND_VEIL" and rules.weather_type=="Rock" else 1.0)

func _visual_snapshot()->Dictionary:
	var snapshot:Dictionary={}
	for pet in _field_pets():
		snapshot[pet["individual_id"]]={"hp":int(pet["hp"]),"status":pet.get("status","")}
	return snapshot

func _visual_deltas(before:Dictionary,damage_kind:String,recoil_id:String="")->void:
	if not is_instance_valid(presentation):return
	for pet in _field_pets():
		var pid:String=pet["individual_id"]
		if not before.has(pid):continue
		var player:bool=pid==active_pet()["individual_id"]
		var previous:Dictionary=before[pid]
		var delta:int=int(pet["hp"])-int(previous["hp"])
		if delta!=0:
			await presentation.play("heal" if delta>0 else "recoil" if pid==recoil_id else damage_kind,player,{"text":"+%d"%delta if delta>0 else str(delta),"amount":absi(delta),"before_hp":previous["hp"],"hp":pet["hp"]})
		if pet.get("status","")!=previous["status"]:
			var names:Dictionary={"poison":Language.text("battle.3af01c498fe4","中毒"),"toxic":Language.text("battle.e198edea3456","剧毒"),"burn":Language.text("battle.73d6418dedde","灼伤"),"paralysis":Language.text("battle.f6f37d69c057","麻痹"),"freeze":Language.text("battle.e8399f36630b","冰冻"),"sleep":Language.text("battle.01324e540d05","睡眠"),"":Language.text("battle.a38b9c01e753","状态恢复")}
			await presentation.play("status",player,{"text":names.get(pet.get("status",""),Language.text("battle.6be7330d116a","状态变化")),"status":pet.get("status","")})

func _visual_finish(is_player:bool,move_id:String)->void:
	if not is_instance_valid(presentation):return
	var marker:String=""
	for event in visual_events:
		var name:String=event.get("event","")
		if name.ends_with("_charge"):marker="charge"
		elif name in ["solar_release","tm_release","dive_release","dig_release","fly_land","bounce_land"] and not event.get("visual_played",false):marker="release"
		elif name in ["ability_block","type_immune"]:marker="immune"
		elif name.ends_with("_miss") or name=="protect_blocked":marker="miss"
	if marker!="":await presentation.play(marker,is_player if marker in ["charge","release"] else not is_player,{"text":{"charge":Language.text("battle.d7051102e956","蓄力"),"release":Language.text("battle.cc3d94550a8c","释放"),"immune":Language.text("battle.2c1bdb2ae6a3","无效"),"miss":Language.text("battle.f3a76d896853","未命中")}[marker],"move":move_id})

	await _visual_deltas(visual_before,"hit",active_pet()["individual_id"] if is_player else enemy["individual_id"])
	_update()
