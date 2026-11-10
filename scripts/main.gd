extends Node2D
const UI = preload("res://scripts/ui.gd")
const Player = preload("res://scripts/player.gd")
const BATTLE_SCENE = preload("res://scenes/battle.tscn")
var sevii_teaching:String=""
var sevii_action:String=""
var sevii_actor:Dictionary={}
var sevii_warp_latch:String=""
var sevii_motion:Array=[]
var sevii_motion_clock:float=0.0
var sevii_motion_origin:=Vector2.ZERO
var sevii_boulders:Array=[]
var flash_teaching:bool=false
var fly_teaching:bool=false
var travel_action:String=""
var travel_target:String=""
var riding:bool=false
var travel_actors:Array=JSON.parse_string(FileAccess.get_file_as_string("res://data/o01-o02-actors.json"))
var o03_actors:Array=JSON.parse_string(FileAccess.get_file_as_string("res://data/route17-actors.json"))
var o04_actors:Array=JSON.parse_string(FileAccess.get_file_as_string("res://data/route18-actors.json"))+JSON.parse_string(FileAccess.get_file_as_string("res://data/route18-gate-1f-actors.json"))+JSON.parse_string(FileAccess.get_file_as_string("res://data/route18-gate-2f-actors.json"))
var map_id: String = "pallet-town"
var tm_acquisition=preload("res://scripts/tm_acquisition.gd").new()
var tm_acquisition_actors:Array=JSON.parse_string(FileAccess.get_file_as_string("res://data/tm-acquisition-actors.json"))
var moon_warps: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/moon-warps.json"))
var rock_warps: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/rock-tunnel-warps.json"))
var lift_pending: bool = false
var tower_actors: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/tower-actors.json"))
var purified_latch: bool = false
var tower_trigger_latch: String = ""
var post_b3_actors: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/post-b3-actors.json"))
var viridian_gym = preload("res://scripts/viridian_gym.gd").new()
var rocket_spin = preload("res://scripts/rocket_spin.gd").new()
var rocket_depth_actors: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/rocket-b2-actors.json"))+JSON.parse_string(FileAccess.get_file_as_string("res://data/rocket-b3-actors.json"))
var rocket_actors: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/rocket-entry-actors.json"))
var tm_rules=preload("res://scripts/ground_tms.gd").new()
var mail_phase:String=""
var mail_editor:LineEdit
var teaching_item:String=""
var teaching_phase:String=""
var teaching_index:int=-1
var teaching_slot:int=-1
var counter_phase:String=""
var counter_index:int=-1
var counter_slot:int=-1
var celadon_lift_pending:bool=false
var o16_actors:Array=JSON.parse_string(FileAccess.get_file_as_string("res://data/o16-actors.json"))
var celadon_actors: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/celadon-actors.json"))
var celadon_stock: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/celadon-stock.json"))
var west_path_actors: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/west-path-actors.json"))
var lavender_actors: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/lavender-actors.json"))
var lavender_stock: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/lavender-stock.json"))
var cinnabar_stock: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/cinnabar-stock.json"))
var rock_actors: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/rock-tunnel-actors.json"))
var moon_warp_latch: String = ""
var ship_warps: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/ssanne-warps.json"))
var ship_actors: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/ssanne-actors.json"))
var upper_actors: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/ssanne-2f-actors.json"))
var ship_rival_revealed: bool = false
var ship_rival_latch: bool = false
var room_actors: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/ssanne-room-actors.json"))
var ship_pass: bool = false
var ship_dialog: bool = false
var service_actors: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/vermilion-service-actors.json"))
var service_stock: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/vermilion-stock.json"))
var south_actors: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/route6-actors.json"))
var layout: Dictionary
var map_title: Label
var encounter = preload("res://scripts/encounter.gd").new()
var last_cell := Vector2i(-1,-1)
var player: CharacterBody2D
var world: Node2D
var overlay: Control
var prompt: Label
var status: Label
var battle: Control
var in_battle: bool = false
var interaction_ready_at: int = 0
var last_reported_position := Vector2(-1000, -1000)
var telemetry_path: String = ""
var telemetry_seq: int = 0
var telemetry_run_id: String = "%s-%s-%s" % [OS.get_process_id(),Time.get_unix_time_from_system(),Time.get_ticks_usec()]
var last_input_state: Dictionary = {}
const INPUT_TELEMETRY = preload("res://scripts/input_telemetry.gd")
var store = preload("res://scripts/save_store.gd").new()
var gym_phase: bool = false
var boulders=preload("res://scripts/boulders.gd").new()
var league_actors:Array=JSON.parse_string(FileAccess.get_file_as_string("res://data/kanto47-48-actors.json"))+JSON.parse_string(FileAccess.get_file_as_string("res://data/kanto49-50-actors.json"))
var victory_road=preload("res://scripts/victory_road.gd").new()
var league_gate=preload("res://scripts/league_gate.gd").new()
var boulder_pending:bool=false
var strength_teaching: bool = false
var warden_pending: bool = false
var o06_actors:Array=JSON.parse_string(FileAccess.get_file_as_string("res://data/o06-actors.json"))
var o07_actors:Array=JSON.parse_string(FileAccess.get_file_as_string("res://data/o07-actors.json"))
var o05_actors:Array=JSON.parse_string(FileAccess.get_file_as_string("res://data/o05-actors.json"))
var flash_pending: bool = false
var flash_active: bool = false
var flash_mask: ColorRect
var flash_layer: CanvasLayer
var o15_actors:Array=JSON.parse_string(FileAccess.get_file_as_string("res://data/o15-actors.json"))
var o14_actors:Array=JSON.parse_string(FileAccess.get_file_as_string("res://data/o14-actors.json"))
var o13_actors:Array=JSON.parse_string(FileAccess.get_file_as_string("res://data/o13-actors.json"))
var route21_actors:Array=JSON.parse_string(FileAccess.get_file_as_string("res://data/route21-actors.json"))
var pokemon_mansion_actors:Array=JSON.parse_string(FileAccess.get_file_as_string("res://data/pokemon-mansion-actors.json"))
var mansion_key_pending:bool=false
var mansion_pending:bool=false
var cinnabar_actors:Array=JSON.parse_string(FileAccess.get_file_as_string("res://data/cinnabar-actors.json"))
var cinnabar_quiz_pending: int = 0
var strength_actors:Array=JSON.parse_string(FileAccess.get_file_as_string("res://data/safari-actors-31.json"))
var surf_teaching: bool = false
var surf_target := Vector2i.ZERO
var surf_pending: bool = false
var cut_phase: String = ""
var cut_learner: int = -1
var cut_slot: int = -1
var cut_tree: Dictionary = {}
var cut_removed: Array = []
var modal: Control
var load_status: String = ""
var field_item:String=""
var candy_pending:Dictionary={}
var candy_index:int=-1
var field_bag_open:bool=false
var stone_item:String=""
var evolution_menu_open:bool=false
var evolution_plan:Dictionary={}
var evolution_index:int=-1
var evolution_kind:String=""
var evolution_phase:String=""
var evolution_hold_item:String=""
var stone_bag_open:bool=false
var indigo_stock:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://data/indigo-stock.json"))
var elite_actors:Array=JSON.parse_string(FileAccess.get_file_as_string("res://data/league-actors.json"))
var indigo_actors:Array=JSON.parse_string(FileAccess.get_file_as_string("res://data/indigo-lobby-actors.json"))
var shop_phase: String = ""
var shop_item: String = "balls"
var shop_quantity: int = 1
var shop_ready_at: int = 0
var shop_message: String = ""
var shop_stock_kind:String="vitamins"
var roof_phase:String=""
var roof_item:String=""
var roof_index:int=-1
var roof_slot:int=-1
var trainer_rules = preload("res://scripts/trainer.gd").new()
var pc: Control
var badge_label: Label
var cascade_label: Label
var cascade_icon: TextureRect
var badge_icon: TextureRect
var gate_latch: bool = false
var safari_reward: String = ""
var safari_action: String = ""
var safari_actors: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/safari-actors-27.json"))+JSON.parse_string(FileAccess.get_file_as_string("res://data/safari-actors-28.json"))+JSON.parse_string(FileAccess.get_file_as_string("res://data/safari-actors-29.json"))
var snorlax_pending: bool = false
var saffron_roads_actors: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/saffron-roads-actors.json"))
var fuchsia_actors: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/fuchsia-actors-21.json"))+JSON.parse_string(FileAccess.get_file_as_string("res://data/fuchsia-actors-22.json"))+JSON.parse_string(FileAccess.get_file_as_string("res://data/fuchsia-actors-23.json"))+JSON.parse_string(FileAccess.get_file_as_string("res://data/fuchsia-actors-24.json"))+JSON.parse_string(FileAccess.get_file_as_string("res://data/fuchsia-actors-26.json"))
var silph_actors: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/silph-actors.json"))
var silph_lift_pending: bool = false
var silph_action: String = ""
var silph_value: String = ""
var saffron_actors: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/saffron-actors.json"))
var o11_actors: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/o11-actors.json"))
var o12_actors: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/o12-actors.json"))
var dojo_choice_pending: bool = false
var tea_pending: bool = false
var mansion_actors: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/mansion-actors.json"))
var fuji_action: String = ""
var pending_mother: bool = false
var pending_trainer: String = ""
var hall_phase: String = ""
var hall_ready_at: int = 0
var hall_actors:Array=JSON.parse_string(FileAccess.get_file_as_string("res://data/hall-of-fame-actors.json"))
var trainer_ready_at: int = 0
var tm_pending: bool = false
var bill_pending: String = ""
var bridge_pending: bool = false
var fossil_pending: String = ""
var lab_fossil_phase: String = ""
var lab_fossil_item: String = ""
var fossil_label: Label
var fossil_actors: Node2D
var nurse_phase: String = ""
var nurse_ready_at: int = 0
var seafoam_current:Array=[]
var seafoam_current_index:int=0
var seafoam_current_clock:float=0.0
var seafoam_current_land:bool=false
var seafoam_current_end:Vector2=Vector2.ZERO
var seafoam_current_fault:bool=false
var field_visuals: Node2D
var visual_transition: bool = false
var visual_deadline: int = 0
var visual_generation: int = 0
var visual_cover: ColorRect
var visual_door: Node2D
var visual_source_map: String = ""
var visual_source_position := Vector2.ZERO
var visual_pending: Dictionary = {}
var visual_committing: bool = false


func _ready() -> void:
	moon_warps.merge(rock_warps)
	telemetry_path = OS.get_environment("TURTLE_TELEMETRY")
	_setup_inputs()
	_build_map("pallet-town",Vector2(88,108))
	var canvas := CanvasLayer.new()
	add_child(canvas)
	canvas.layer = 2
	overlay = Control.new()
	overlay.theme = UI.setup_theme()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(overlay)
	flash_layer = CanvasLayer.new()
	flash_layer.layer = 1
	add_child(flash_layer)
	UI.panel(overlay, Rect2(4, 2, 952, 36))
	map_title = UI.label(overlay, "真新镇 · Red 地图复现", Rect2(18, 2, 420, 32), 22)
	badge_icon = TextureRect.new()
	badge_icon.texture = preload("res://assets/pewter-gym/boulder-badge.png")
	badge_icon.position = Vector2(780,42)
	badge_icon.size = Vector2(32,32)
	badge_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	overlay.add_child(badge_icon)
	badge_label = UI.label(overlay,"灰色徽章 · 已获得",Rect2(816,44,140,30),16)
	cascade_icon = TextureRect.new()
	cascade_icon.texture = preload("res://assets/cerulean-gym/cascade-badge.png")
	cascade_icon.position = Vector2(600,42)
	cascade_icon.size = Vector2(32,32)
	cascade_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	overlay.add_child(cascade_icon)
	cascade_label = UI.label(overlay,"蓝色徽章 · 已获得",Rect2(636,44,140,30),16)
	fossil_label = UI.label(overlay,"",Rect2(18,76,600,25),16)
	for hud in [badge_label,cascade_label,fossil_label]:
		hud.add_theme_color_override("font_color",Color.WHITE)
		hud.add_theme_color_override("font_outline_color",Color("303840"))
		hud.add_theme_constant_override("outline_size",3)
	status = UI.label(overlay, "向北通往1号道路 · 房门关闭", Rect2(470, 7, 480, 24), 16)
	UI.panel(overlay, Rect2(4, 604, 952, 34))
	prompt = UI.label(overlay, "WASD移动 · E交谈 · F6碎岩/F7攀瀑 · M/N/L教学 · F飞翔/V骑车 · B背包 · P队伍 · F5存档/F10退出", Rect2(18, 608, 930, 26), 16)
	if map_id in ["rock-tunnel-1f","rock-tunnel-b1f"]:
		_build_map(map_id,player.position)
	_trace({"event":"map_ready", "position":[player.position.x, player.position.y]})
	get_tree().auto_accept_quit = false
	load_status = store.load_game()
	if load_status == "loaded":
		_restore_location()
		if store.error!="":status.text = store.error
		_state_trace("loaded")
	elif load_status == "missing":
		_starter_menu()
	else:
		_corrupt_menu()

func _setup_inputs() -> void:
	var bindings := {"walk_left":[KEY_A, KEY_LEFT], "walk_right":[KEY_D, KEY_RIGHT], "walk_up":[KEY_W, KEY_UP], "walk_down":[KEY_S, KEY_DOWN], "interact":[KEY_E, KEY_ENTER, KEY_SPACE]}
	for action in bindings:
		InputMap.add_action(action)
		for key in bindings[action]:
			var event := InputEventKey.new()
			event.physical_keycode = key
			InputMap.action_add_event(action, event)

func _add_solid(parent: Node, rect: Rect2) -> void:
	var body := StaticBody2D.new()
	body.position = rect.get_center()
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	var collision := CollisionShape2D.new()
	collision.shape = shape
	body.add_child(collision)
	parent.add_child(body)

func _process(_delta: float) -> void:
	if not sevii_motion.is_empty():_sevii_motion_tick(_delta);_camera();return
	if visual_transition:
		if Time.get_ticks_msec()>=visual_deadline:_visual_recover()
		else:return
	# Schedule after this frame's state changes, including all early-return paths.
	if telemetry_path!="":call_deferred("_input_state_trace")
	if is_instance_valid(flash_mask):
		_flash_update_center()
	if not seafoam_current.is_empty():
		_seafoam_tick(_delta);_camera();return
	if is_instance_valid(player) and not in_battle and not is_instance_valid(modal) and not is_instance_valid(pc):
		var current_cell:=Vector2i(floori(player.position.x/16),floori((player.position.y-1)/16))
		if _seafoam_begin(current_cell,false):return
	if is_instance_valid(player) and not in_battle and not is_instance_valid(modal) and not is_instance_valid(pc):
		if store.travel.cycling(map_id,player.position) and store.travel.bicycle(store.state):riding=true;player.cycling=true
		var gate_cell:=Vector2i(floori(player.position.x/16),floori((player.position.y-1)/16))
		if store.travel.gate_blocks(store.state,map_id,gate_cell):
			player.position=Vector2(88,73 if map_id=="route18-gate-1f" else 121);player.velocity=Vector2.ZERO;status.text="等一下！自行车道禁止行人，请先取得自行车。";_state_trace("bicycle_gate_refused")
	if is_instance_valid(player) and not in_battle and not is_instance_valid(modal) and not is_instance_valid(pc):
		if rocket_spin.active:
			if rocket_spin.tick(player,_delta):_trace({"event":"spin_stopped","map":map_id,"position":[player.position.x,player.position.y]})
			_camera();return
		var spin_cell := Vector2i(floori(player.position.x/16),floori((player.position.y-1)/16))
		if rocket_spin.begin(map_id,spin_cell):
			player.position = Vector2(spin_cell.x*16+8,spin_cell.y*16+9);player.active = false;player.velocity = Vector2.ZERO
			_trace({"event":"spin_started","map":map_id,"cell":[spin_cell.x,spin_cell.y],"steps":rocket_spin.route.size()});return
	if is_instance_valid(fossil_label):
		fossil_label.text = store.fossil_rules.summary(store.state)
		if store.state.has("nugget_bridge"):fossil_label.text += " · 金珠 ×%d"%int(store.state["nugget_bridge"]["items"]["nugget"])
		if store.bill_rules.stage(store.state) in ["ticket","visited"]:fossil_label.text += " · 船票 ×1"
		if store.state.has("stolen_tm"):fossil_label.text += " · TM28 ×%d"%tm_rules.quantity(store.state,"tm_dig")
		if store.state.get("badges",{}).get("soul",false):fossil_label.text += " · 粉红徽章已获得"
		if store.state.get("badges",{}).get("marsh",false):fossil_label.text += " · 金色徽章已获得"
		if store.state.get("badges",{}).get("rainbow",false):fossil_label.text += " · 彩虹徽章已获得"
		if store.state.get("badges",{}).get("thunder",false):fossil_label.text += " · 雷电徽章已获得"
		if store.state.get("badges",{}).get("volcano",false):fossil_label.text += " · 深红徽章已获得"
		if store.state.get("badges",{}).get("earth",false):fossil_label.text = store.fossil_rules.summary(store.state)+" · 八枚徽章已集齐（含绿色徽章）"
		fossil_label.visible = store.state.get("badges",{}).get("volcano",false) or store.state.get("badges",{}).get("rainbow",false) or store.state.get("badges",{}).get("thunder",false) or store.state.has("moon_fossil") or store.state.has("nugget_bridge") or store.state.has("bill") or store.state.has("stolen_tm") or map_id=="mtmoon-b2f"
	if is_instance_valid(badge_label):
		var earned: bool = store.state.get("badges",{}).get("boulder",false)
		badge_label.visible = earned
		badge_icon.visible = earned
	if is_instance_valid(cascade_label):
		var earned: bool = store.state.get("badges",{}).get("cascade",false)
		cascade_label.visible = earned
		cascade_icon.visible = earned
	if not is_instance_valid(player):
		return
	if player.ledge_jumping:
		_camera()
		return
	if not in_battle and not is_instance_valid(modal) and not is_instance_valid(pc):
		var cell := Vector2i(floori(player.position.x/16),floori((player.position.y-1)/16))

		boulders.clock=maxf(0,boulders.clock-_delta)
		if boulders.active and boulders.clock<=0 and Input.get_vector("walk_left","walk_right","walk_up","walk_down")!=Vector2.ZERO:
			var direction:=Input.get_vector("walk_left","walk_right","walk_up","walk_down")
			var step:=Vector2i(signi(int(direction.x)),0) if absf(direction.x)>absf(direction.y) else Vector2i(0,signi(int(direction.y)))
			player.facing=Vector2(step)
			var bi:int=boulders.index(cell+step)
			if bi>=0:
				var before_push:Dictionary=store.state.duplicate(true)
				var old_stones:Array=boulders.cells.duplicate(true)
				boulders.clock=.22;var moved:bool=boulders.push(bi,step,layout)
				if moved:
					if map_id.begins_with("seafoam-islands-") and store.seafoam.pushed(map_id,boulders.cells[bi],store.state):
						var safe:Array=layout["safe"]
						store.state["location"]={"map_id":map_id,"x":safe[0],"y":safe[1]}
						if not store.save_game():
							store.state=before_push;boulders.cells=old_stones;status.text=store.error;_state_trace("seafoam_fall_failed");return
						boulders.refresh(strength_actors+league_actors+o06_actors+o07_actors);_state_trace("seafoam_fall_committed")
						player.position=Vector2((cell.x+step.x)*16+8,(cell.y+step.y)*16+9);_build_map(map_id,player.position);return
					if map_id=="victory-road-1f" and not store.state.get("victory_road_1f_open",false) and boulders.index(Vector2i(17,13))>=0:
						if not _commit_victory_switch():
							boulders.cells[bi]=[cell.x+step.x,cell.y+step.y];return
					if victory_road.pushed(map_id,boulders.cells[bi],store.state):
						store.state["location"]={"map_id":map_id,"x":8 if map_id=="victory-road-2f" else 376,"y":137 if map_id=="victory-road-2f" else 121}
						if not store.save_game():
							store.state=before_push;boulders.cells=old_stones;status.text=store.error;_state_trace("victory_upper_failed");return
						if map_id=="victory-road-3f" and boulders.cells[bi]==[23,15]:boulders.cells[bi]=[-1,-1]
						_state_trace("victory_upper_committed")
					player.position=Vector2((cell.x+step.x)*16+8,(cell.y+step.y)*16+9);_build_map(map_id,player.position)
				_trace({"event":"boulder_pushed" if moved else "boulder_blocked","cells":boulders.cells.duplicate(true)});return
		if store.state.get("surfing",false) and not store.surf.water(map_id,layout,cell):
			var before: Dictionary = store.state.duplicate(true)
			store.state["surfing"] = false
			store.state["location"] = {"map_id":map_id,"x":player.position.x,"y":player.position.y}
			var result: String = store.safari.step(store,store.state["location"]) if store.safari.is_zone(map_id) and store.safari.active(store.state) else ("" if store.save_game() else store.error)
			if result=="expired":_restore_location();status.text = "时间到！已返回入口。";_state_trace("safari_expired")
			elif result=="":_build_map(map_id,player.position);_state_trace("surf_landed")
			else:store.state = before;_restore_location();status.text = result;_state_trace("surf_failed")
			return
		if map_id=="pallet-town" and store.state.get("surfing",false) and player.position.y>=281 and player.velocity.y>0 and cell.x in [4,5,6,7]:
			_build_map("route21",Vector2(player.position.x,9));_trace({"event":"map_changed","map":map_id});return
		if map_id=="route21" and store.state.get("surfing",false) and player.position.y<=9 and player.velocity.y<0 and cell.x in [4,5,6,7]:
			_build_map("pallet-town",Vector2(player.position.x,281));_trace({"event":"map_changed","map":map_id});return
		if map_id=="route21" and store.state.get("surfing",false) and player.position.y>=1433 and player.velocity.y>0 and cell.x in [1,2,3]:
			_change_map("cinnabar-island",Vector2(player.position.x,9));return
		if map_id=="cinnabar-island" and store.state.get("surfing",false) and player.position.y<=9 and player.velocity.y<0 and cell.x in [1,2,3]:
			_change_map("route21",Vector2(player.position.x,1433));return
		if map_id=="pallet-town" and player.position.y<8 and player.velocity.y<0 and Time.get_ticks_msec()>=interaction_ready_at and cell.x in [10,11]:
			_build_map("route1",Vector2(player.position.x,570))
			map_title.text = "1号道路 · Red地图 / FireRed遇敌"
			_trace({"event":"map_changed","map":map_id})
			return
		if map_id=="route1" and player.position.y>569 and player.velocity.y>0 and Time.get_ticks_msec()>=interaction_ready_at and cell.x in [10,11]:
			_build_map("pallet-town",Vector2(player.position.x,9))
			map_title.text = "真新镇 · Red 地图复现"
			_trace({"event":"map_changed","map":map_id})
			return
		if Time.get_ticks_msec()>=interaction_ready_at:
			if _league_gate_trigger(cell):return
			if _late_rival_trigger(cell):return
			if _viridian_gym_trigger(cell):return
			if _saffron_gate_trigger(cell):return
			if _tower_purified(cell):return
			if _tower_trigger(cell):return
			if _ship_rival_trigger(cell):return
			if _forest_transition(cell):return
			if map_id=="viridian-city" and player.position.x<8 and player.velocity.x<0 and cell.y in [14,15,16,17]:
				_change_map("route22",Vector2(631,player.position.y-128))
				return
			if map_id=="route22" and player.position.x>631 and player.velocity.x>0 and cell.y in [6,7,8,9]:
				_change_map("viridian-city",Vector2(9,player.position.y+128))
				return
			if map_id=="route1" and player.position.y<8 and player.velocity.y<0 and cell.x in [10,11]:
				_change_map("viridian-city",Vector2(player.position.x+160,570))
				return
			if map_id=="viridian-city" and player.position.y>569 and player.velocity.y>0 and cell.x in [20,21]:
				_change_map("route1",Vector2(player.position.x-160,9))
				return
			if map_id=="viridian-city" and cell==Vector2i(23,25) and player.velocity.y<0:
				_change_map("viridian-center",Vector2(56,105))
				return
			if map_id=="viridian-city" and cell==Vector2i(29,19) and player.velocity.y<0:
				_change_map("viridian-mart",Vector2(56,105))
				return
			if map_id=="viridian-mart" and cell.y==7 and cell.x in [3,4] and player.velocity.y>0:
				_change_map("viridian-city",Vector2(472,329))
				return
			if map_id=="viridian-center" and cell.y==7 and cell.x in [3,4] and player.velocity.y>0:
				_change_map("viridian-city",Vector2(376,425))
				return
		_camera()
		if cell!=last_cell and player.velocity.length()>0:
			last_cell = cell
			store.friendship.step(store.state,map_id)
			if store.safari.is_zone(map_id) and store.safari.active(store.state):
				var result: String = store.safari.step(store,{"map_id":map_id,"x":player.position.x,"y":player.position.y})
				_state_trace("safari_step")
				if result!="":
					_restore_location();status.text = "时间到！已返回入口。" if result=="expired" else result;_state_trace("safari_"+result);return
				status.text = "剩余%d步 · 临时球%d · R退出 · 捕获延期" % [store.state["safari"]["steps"],store.state["safari"]["balls"]]
			var water_encounter: bool = map_id in ["seafoam-islands-b4f","seafoam-islands-b3f","route19","route20","route21","route23"] and store.state.get("surfing",false) and store.surf.water(map_id,layout,cell)
			var safari_grass: bool = store.safari.is_zone(map_id) and cell.y>=0 and cell.y<int(layout["height"]) and cell.x>=0 and cell.x<int(layout["width"]) and int(layout["grass"][cell.y][cell.x])==1
			var grass: bool = water_encounter or safari_grass or (map_id in ["seafoam-islands-b4f","seafoam-islands-b2f","seafoam-islands-b3f","seafoam-islands-1f","seafoam-islands-b1f","victory-road-3f","victory-road-1f","victory-road-2f","pokemon-mansion-b1f","pokemon-mansion-3f","pokemon-mansion-2f","pokemon-mansion-1f","pokemon-tower-6f","pokemon-tower-5f","pokemon-tower-4f","pokemon-tower-3f","rock-tunnel-1f","rock-tunnel-b1f","mtmoon-1f","mtmoon-b1f","mtmoon-b2f","digletts-cave"] and cell.y>=0 and cell.y<int(layout["height"]) and cell.x>=0 and cell.x<int(layout["width"]) and int(layout["solid"][cell.y][cell.x])==0) or map_id in ["route16","route17","route18","route23","route21","route15","route14","route13","route12","route7","route8","route10-south","route9","route10-north","route1","route2","route11","viridian-forest","route3","route4-entrance","route4-east","route24","route25","route5","route6"] and cell.y>=0 and cell.y<int(layout["height"]) and cell.x>=0 and cell.x<int(layout["width"]) and int(layout["grass"][cell.y][cell.x])==1
			if map_id=="mtmoon-b2f" and store.state.get("trainers",{}).get("mtmoonb2f_miguel",false) and cell.x in [11,12,13,14] and cell.y in [5,6,7,8]:grass = false
			if map_id=="pokemon-tower-5f" and cell in [Vector2i(10,8),Vector2i(11,8),Vector2i(10,9),Vector2i(11,9)]:grass = false
			var repel_expired:bool=store.medicine.step_repel(store.state)
			if repel_expired:status.text="喷雾效果消失了。";_trace({"event":"repel_expired"})
			var wild: Dictionary = encounter.step(grass,map_id,water_encounter) if not repel_expired and Time.get_ticks_msec()>=interaction_ready_at else {}
			if not wild.is_empty() and not store.medicine.allow_wild(store.state,int(wild["level"])):wild={}
			_trace({"event":"step","map":map_id,"cell":[cell.x,cell.y],"grass":grass,"water":water_encounter,"encounter":not wild.is_empty()})
			if not wild.is_empty():_start_battle(wild)
	if telemetry_path != "" and player.position.distance_to(last_reported_position) > (0.05 if player.velocity==Vector2.ZERO else 1.0):
		last_reported_position = player.position
		_trace({"event":"position", "x":snappedf(player.position.x, 0.01), "y":snappedf(player.position.y, 0.01), "blocked":player.get_slide_collision_count() > 0,"map":map_id})

func _start_battle(wild: Dictionary) -> void:
	var safari_battle: bool = store.safari.active(store.state) and store.safari.is_zone(map_id)
	if map_id.begins_with("pokemon-tower-") and not store.post_b3.has_item(store.state,"silph_scope"):
		status.text = "幽灵无法辨认！没有检视镜，宝可梦无法对战。";_trace({"event":"tower_ghost_refused"});return
	if not store.validate(store.state):
		return
	if int(store.state["team"][int(store.state["lead"])]["hp"]) <= 0:
		status.text = "首发倒下，请 P 换首发或 H 免费恢复。"
		return
	in_battle = true
	player.active = false
	overlay.hide()
	battle = BATTLE_SCENE.instantiate()
	battle.theme = UI.setup_theme()
	battle.store = store
	battle.item_terrain=_item_battle_terrain()
	battle.safari_mode = safari_battle
	if map_id in ["route19","route20"]:battle.field_terrain="Water" if store.state.get("surfing",false) else "Ground"
	if map_id in ["rock-tunnel-1f","rock-tunnel-b1f","mtmoon-1f","mtmoon-b1f","mtmoon-b2f"]:battle.arena_path = "res://assets/mtmoon-1f/cave-arena.png"
	battle.north_rules = map_id.begins_with("sevii-") or map_id.begins_with("pokemon-mansion-") or map_id.begins_with("pokemon-tower-") or map_id in ["route14","route15","route7","route8","rock-tunnel-1f","rock-tunnel-b1f","route9","route10-north","route24","route25","route5","route6"]
	battle.enemy = store.create_individual(wild["species_id"],-1,int(wild["level"]))
	overlay.get_parent().add_child(battle)
	battle.finished.connect(_return_to_map)
	battle.telemetry.connect(_trace)
	_trace({"event":"battle_started","enemy":wild})

func _return_to_map(won: bool) -> void:
	var completed_league:bool=battle.trainer_id.begins_with("league_")
	var completed_cinnabar: bool = battle.trainer_id.begins_with("cinnabar_") and won
	var completed_rocket: bool = battle.trainer_id in ["rocket_poster","rocket_b1_5"] and won
	var completed_thief: bool = battle.trainer_id=="cerulean_rocket_thief" and won
	var completed_ship: bool = battle.trainer_id=="ssanne_rival" and won
	var completed_north: bool = battle.trainer_id=="cerulean_north_rival" and won
	var completed_dojo_boss: bool = battle.trainer_id=="o12_koichi" and won
	var trainer_message: String = battle.log_text if battle.trainer_id!="" else ""
	battle.queue_free()
	interaction_ready_at = Time.get_ticks_msec() + 250
	in_battle = false
	player.active = true
	overlay.show()
	if completed_league and battle.outcome!="save_failed":
		if won:_change_map(map_id,player.position)
		else:_restore_location()
	_save()
	status.text = "本场结束 · HP / 球数已保留 · H 免费恢复补球" if store.error == "" else store.error
	if trainer_message!="":status.text = "训练家战已结算 · 余额%d · 可前往商店" % int(store.state["money"]) if store.error=="" else store.error
	if battle.trainer_id.begins_with("sevii_"):_change_map(map_id,player.position)
	if battle.static_id!="":_change_map(map_id,player.position)
	if battle.static_id=="sevii_hypno" and store.state.get("sevii",{}).get("hypno_done",false):
		_sevii_prompt("rescue","迷失女孩 · 获救","谢谢你！请带我回二岛游戏厅。")
	if completed_cinnabar or battle.trainer_id.begins_with("silph") or battle.trainer_id.begins_with("tower7_") or completed_rocket or completed_north or completed_ship or battle.trainer_id.begins_with("rocket_b4_") or battle.trainer_id in ["rocket_giovanni","tower_rival"]:_change_map(map_id,player.position)
	if battle.trainer_id=="route22_late" or battle.trainer_id=="viridian_giovanni":
		_change_map(map_id,player.position)
		if won:status.text=trainer_rules.definition(battle.trainer_id)["after"]
	if completed_ship:status.text = trainer_rules.ship_rival["after"]
	_state_trace("map_state")
	_trace({"event":"returned_to_map", "won":won})
	if completed_thief:_tm_dialog()
	if completed_dojo_boss:
		dojo_choice_pending=true;trainer_ready_at=Time.get_ticks_msec()+250;_new_modal("格斗道场 · 馆主奖励")
		UI.label(modal,"道场馆主已败北。选择一只宝可梦作为奖赏：\n1 飞腿郎 Hitmonlee　　2 快拳郎 Hitmonchan\nEsc 暂不领取",Rect2(95,190,770,170),22);_state_trace("dojo_gift_prompt")

func _trace(value: Dictionary) -> void:
	if telemetry_path == "":
		return
	var file := FileAccess.open(telemetry_path, FileAccess.READ_WRITE) if FileAccess.file_exists(telemetry_path) else FileAccess.open(telemetry_path, FileAccess.WRITE)
	if file:
		file.seek_end()
		telemetry_seq += 1
		var output: Dictionary = value.duplicate(true)
		output["seq"] = telemetry_seq
		output["run_id"] = telemetry_run_id
		file.store_line(JSON.stringify(output))

func _input_state_trace() -> void:
	if telemetry_path=="":return
	var snapshot: Dictionary = INPUT_TELEMETRY.state(self)
	if snapshot!=last_input_state:
		last_input_state = snapshot.duplicate(true)
		_trace(snapshot)

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo or in_battle:
		return
	if not sevii_motion.is_empty():return
	if sevii_action!="":_sevii_input(event.physical_keycode);return
	if is_instance_valid(pc) or rocket_spin.active or not seafoam_current.is_empty() or player.ledge_jumping or visual_transition:return
	if mail_phase!="":
		if event.physical_keycode==KEY_ESCAPE:mail_phase="";_close_modal()
		return
	if travel_action!="":_travel_input(event.physical_keycode);return
	if teaching_phase!="":_teaching_input(event.physical_keycode);return
	if counter_phase!="":_counter_input(event.physical_keycode);return
	if roof_phase!="":_roof_input(event.physical_keycode);return
	if lab_fossil_phase!="":_lab_fossil_input(event.physical_keycode);return
	if not is_instance_valid(modal):
		if event.physical_keycode in [KEY_F6,KEY_F7]:
			sevii_teaching="rocksmash" if event.physical_keycode==KEY_F6 else "waterfall"
			store.sevii_hm.move=sevii_teaching;_hm_menu();return
		sevii_teaching=""
		if event.physical_keycode==KEY_I:fly_teaching=false;strength_teaching=false;surf_teaching=false;flash_teaching=true;_hm_menu();return
		if event.physical_keycode==KEY_U:_flash_field();return
		if event.physical_keycode==KEY_L:flash_teaching=false;fly_teaching=true;strength_teaching=false;surf_teaching=false;_hm_menu();return
		if event.physical_keycode==KEY_F:_fly_menu();return
		if event.physical_keycode==KEY_V:_bicycle_toggle();return
	if mansion_key_pending:
		if Time.get_ticks_msec()<trainer_ready_at:return
		if event.physical_keycode in [KEY_ESCAPE,KEY_B]:mansion_key_pending=false;_close_modal();_state_trace("mansion_key_cancelled")
		elif event.physical_keycode in [KEY_E,KEY_ENTER,KEY_SPACE]:
			var failure:String=store.pokemon_mansion.take_key(store,map_id,player.position)
			mansion_key_pending=false;_close_modal();_change_map(map_id,player.position)
			status.text=failure if failure!="" else "获得秘密钥匙！可在关键物品查看。"
			_state_trace("mansion_key_taken" if failure=="" else "mansion_key_failed")
		return
	if mansion_pending:
		if Time.get_ticks_msec()<trainer_ready_at:return
		if event.physical_keycode in [KEY_ESCAPE,KEY_B]:mansion_pending=false;_close_modal();_state_trace("mansion_cancelled")
		elif event.physical_keycode in [KEY_E,KEY_ENTER,KEY_SPACE]:
			var failure:String=store.pokemon_mansion.toggle(store,map_id,player.position)
			mansion_pending=false;_close_modal()
			if failure=="":_change_map(map_id,player.position)
			status.text=failure if failure!="" else "开关已按下，全楼的门随之变化。"
			_state_trace("mansion_toggle" if failure=="" else "mansion_toggle_failed")
		return
	if snorlax_pending:
		if Time.get_ticks_msec()<trainer_ready_at:return
		if event.physical_keycode in [KEY_ESCAPE,KEY_B]:snorlax_pending = false;_close_modal();_state_trace("snorlax_cancelled")
		elif event.physical_keycode in [KEY_E,KEY_ENTER,KEY_SPACE]:snorlax_pending = false;_close_modal();_start_snorlax()
		return
	if silph_action!="":
		if Time.get_ticks_msec()<trainer_ready_at:return
		if event.physical_keycode in [KEY_ESCAPE,KEY_B]:silph_action = "";_close_modal();_state_trace("silph_action_cancelled")
		elif event.physical_keycode in [KEY_E,KEY_ENTER,KEY_SPACE]:
			var action: String = silph_action
			var failure: String = store.silph_story.president(store) if action=="president" else store.silph_story.gift(store) if action=="gift" else store.silph_story.transition(store,action,silph_value)
			silph_action = "";_close_modal()
			if failure!="":status.text = failure;_state_trace("silph_action_failed");return
			_change_map(map_id,player.position);status.text = "获得大师球 ×1！可在野生战斗背包中使用。已保存。" if action=="president" else "拉普拉斯已加入队伍或送往盒子！已保存。" if action=="gift" else "获得卡片钥匙！已保存。" if action=="take" else "卡片门已打开！钥匙可以反复使用。";_state_trace("silph_master_ball_received" if action=="president" else "silph_lapras_received" if action=="gift" else "silph_key_taken" if action=="take" else "silph_door_opened")
		return
	if celadon_lift_pending:
		if Time.get_ticks_msec()<trainer_ready_at:return
		if event.physical_keycode in [KEY_ESCAPE,KEY_B]:celadon_lift_pending=false;_close_modal();_state_trace("celadon_lift_cancelled")
		elif event.physical_keycode in [KEY_1,KEY_2,KEY_3,KEY_4,KEY_5]:
			var floor:String="celadon-mart-%df"%(event.physical_keycode-KEY_1+1)
			var failure:String=store.celadon_lift.select_floor(store,floor,{"map_id":map_id,"x":player.position.x,"y":player.position.y})
			celadon_lift_pending=false;_close_modal();status.text=failure if failure!="" else "电梯已抵达 "+floor;_state_trace("celadon_lift_selected")
		return
	if silph_lift_pending:
		if Time.get_ticks_msec()<trainer_ready_at:return
		if event.physical_keycode in [KEY_ESCAPE,KEY_B]:silph_lift_pending = false;_close_modal();_state_trace("silph_lift_cancelled")
		elif event.physical_keycode in [KEY_1,KEY_2,KEY_3,KEY_4,KEY_5,KEY_6,KEY_7,KEY_8,KEY_9,KEY_0,KEY_MINUS]:
			var floor: String = "silph-co-%df" % (10 if event.physical_keycode==KEY_0 else 11 if event.physical_keycode==KEY_MINUS else event.physical_keycode-KEY_1+1)
			var failure: String = store.silph_story.select_floor(store,floor)
			silph_lift_pending = false;_close_modal();status.text = failure if failure!="" else "电梯已抵达 "+floor;_state_trace("silph_lift_selected")
		return
	if lift_pending:
		if Time.get_ticks_msec()<trainer_ready_at:return
		if event.physical_keycode in [KEY_ESCAPE,KEY_B]:lift_pending = false;_close_modal();_state_trace("lift_cancelled")
		elif event.physical_keycode in [KEY_1,KEY_2,KEY_3]:
			var floor: String = ["rocket-hideout-b1f","rocket-hideout-b2f","rocket-hideout-b4f"][event.physical_keycode-KEY_1]
			var failure: String = store.post_b3.transition(store,"select_floor",floor)
			lift_pending = false;_close_modal();status.text = failure if failure!="" else "电梯已抵达 "+floor;_state_trace("lift_selected")
		return
	if gym_phase:
		if Time.get_ticks_msec()>=trainer_ready_at and event.physical_keycode in [KEY_E,KEY_ENTER,KEY_SPACE,KEY_ESCAPE]:gym_phase = false;_close_modal()
		return
	if cinnabar_quiz_pending>0:
		if Time.get_ticks_msec()<trainer_ready_at:return
		if event.physical_keycode in [KEY_ESCAPE,KEY_B]:cinnabar_quiz_pending=0;_close_modal();_state_trace("cinnabar_quiz_cancelled")
		elif event.physical_keycode in [KEY_1,KEY_2,KEY_E,KEY_ENTER,KEY_SPACE]:
			var index: int=cinnabar_quiz_pending;var yes: bool=event.physical_keycode in [KEY_1,KEY_E,KEY_ENTER,KEY_SPACE];cinnabar_quiz_pending=0;_close_modal()
			var answer:Dictionary=store.cinnabar_gym.answer(store.state,index,yes)
			if answer["correct"]:
				var before: Dictionary=store.state.duplicate(true);store.cinnabar_gym.mark_correct(store.state,index)
				if not store.save_game():store.state=before;status.text=store.error
				else:_change_map(map_id,player.position);status.text="回答正确，门打开了！"
			else:status.text="回答错误，训练家向你发起挑战！";_forest_trainer_interact(store.cinnabar_gym.definition(answer["trainer"]))
		return
	if cut_phase!="":
		_cut_input(event.physical_keycode)
		return
	if ship_dialog:
		if Time.get_ticks_msec()>=interaction_ready_at and event.physical_keycode in [KEY_E,KEY_ENTER,KEY_SPACE,KEY_ESCAPE]:
			ship_dialog = false;_close_modal()
		return
	if tm_pending:
		if Time.get_ticks_msec()<trainer_ready_at:return
		if event.physical_keycode in [KEY_ESCAPE,KEY_B]:
			tm_pending = false;_close_modal();_trace({"event":"tm28_cancelled"})
		elif event.physical_keycode in [KEY_E,KEY_ENTER,KEY_SPACE,KEY_1]:_tm_take()
		return
	if bill_pending!="":
		if Time.get_ticks_msec()<trainer_ready_at:return
		if event.physical_keycode in [KEY_ESCAPE,KEY_B]:
			bill_pending = "";_close_modal();_trace({"event":"bill_cancelled"})
		elif event.physical_keycode in [KEY_E,KEY_ENTER,KEY_SPACE,KEY_1]:_bill_confirm()
		elif event.physical_keycode==KEY_2 and bill_pending=="help":
			_bill_dialog("help","不？拜托，帮帮遇到麻烦的人吧！\n当我进入传送器后，请在电脑上运行细胞分离系统。")
		return
	if bridge_pending:
		if Time.get_ticks_msec()<trainer_ready_at:return
		if event.physical_keycode in [KEY_E,KEY_ENTER,KEY_SPACE,KEY_1]:_bridge_take()
		elif event.physical_keycode in [KEY_ESCAPE,KEY_B]:
			bridge_pending = false;_close_modal();_trace({"event":"bridge_reward_cancelled"})
		return
	if fossil_pending!="":
		if Time.get_ticks_msec()<trainer_ready_at:return
		if event.physical_keycode in [KEY_1,KEY_E,KEY_ENTER,KEY_SPACE]:_fossil_take()
		elif event.physical_keycode in [KEY_2,KEY_ESCAPE,KEY_B]:
			fossil_pending = "";_close_modal();_trace({"event":"fossil_cancelled"})
		return
	if not candy_pending.is_empty():
		_candy_key(event.physical_keycode);return
	if field_bag_open:
		if event.physical_keycode==KEY_ESCAPE:field_bag_open=false;field_item="";_close_modal()
		elif event.physical_keycode in [KEY_1,KEY_2,KEY_3,KEY_4,KEY_5,KEY_6,KEY_7,KEY_8]:_field_bag_select(event.physical_keycode-KEY_1)
		return
	if evolution_menu_open:
		_evolution_key(event.physical_keycode);return
	if stone_bag_open:
		if event.physical_keycode in [KEY_ESCAPE,KEY_B]:stone_bag_open=false;stone_item="";_close_modal()
		elif event.physical_keycode>=KEY_1 and event.physical_keycode<=KEY_6:_stone_bag_select(event.physical_keycode-KEY_1)
		return
	if shop_phase!="":
		_shop_input(event.physical_keycode)
		return
	if tea_pending:
		if event.physical_keycode==KEY_ESCAPE:
			tea_pending = false;_close_modal();_state_trace("tea_cancelled")
		elif event.physical_keycode in [KEY_E,KEY_ENTER,KEY_SPACE]:
			tea_pending = false;_close_modal()
			var failure: String = store.tea_rules.claim(store,map_id)
			status.text = "获得茶 ×1！已保存。K 查看关键物品。" if failure=="" else failure
			_state_trace("tea_received" if failure=="" else "tea_failed")
		return
	if fuji_action!="":
		if event.physical_keycode==KEY_ESCAPE:fuji_action = "";_close_modal()
		elif event.physical_keycode in [KEY_E,KEY_ENTER,KEY_SPACE]:
			var action: String = fuji_action;fuji_action = "";_close_modal()
			var failure: String = store.tower_story.transition(store,action)
			if failure!="":status.text = failure;_state_trace("fuji_failed")
			else:
				if action=="rescue":_change_map("mr-fujis-house",Vector2(56,41));player.facing = Vector2.UP
				status.text = "已回到富士之家，请另与老人交谈。" if action=="rescue" else "获得宝可梦笛！K 查看关键物品。"
				_state_trace("fuji_"+action)
		return
	if pending_mother:
		if event.physical_keycode==KEY_ESCAPE:pending_mother = false;_close_modal()
		elif event.physical_keycode in [KEY_E,KEY_ENTER,KEY_SPACE]:
			pending_mother = false;_close_modal();_start_mother()
		return
	if boulder_pending:
		if event.physical_keycode==KEY_ESCAPE:boulder_pending=false;_close_modal();_state_trace("strength_cancelled")
		elif event.physical_keycode in [KEY_E,KEY_ENTER,KEY_SPACE]:
			boulder_pending=false;_close_modal();var failure:String=store.strength.field_error(store.state)
			if failure=="":boulders.active=true;status.text="怪力已启用！方向键单格推石；离图复位。";_state_trace("strength_activated")
			else:status.text=failure;_state_trace("strength_rejected")
		return
	if warden_pending:
		if event.physical_keycode==KEY_ESCAPE:warden_pending=false;_close_modal();_state_trace("warden_cancelled")
		elif event.physical_keycode in [KEY_E,KEY_ENTER,KEY_SPACE]:
			var a:String=store.strength.action(store.state);warden_pending=false;_close_modal();var error:String=store.strength.transact(store,map_id);status.text=error if error!="" else "已交还金牙！请再次交谈领取HM04。" if a=="deliver" else "获得HM04怪力！J教学。已保存。";_state_trace("warden_"+a if error=="" else "warden_failed")
		return
	if surf_pending:
		if event.physical_keycode==KEY_ESCAPE:surf_pending = false;_close_modal();_state_trace("surf_cancelled")
		elif event.physical_keycode in [KEY_E,KEY_ENTER,KEY_SPACE]:
			surf_pending = false;_close_modal();var before: Dictionary = store.state.duplicate(true)
			store.state["surfing"] = true
			store.state["location"] = {"map_id":map_id,"x":surf_target.x*16+8,"y":surf_target.y*16+9}
			var result: String = store.safari.step(store,store.state["location"]) if store.safari.active(store.state) else ("" if store.save_game() else store.error)
			if result=="expired":_restore_location();_state_trace("safari_expired")
			elif result=="":_build_map(map_id,Vector2(surf_target.x*16+8,surf_target.y*16+9));_state_trace("surf_started")
			else:store.state = before;status.text = store.error;_state_trace("surf_failed")
		return
	if safari_reward!="":
		if event.physical_keycode==KEY_ESCAPE:safari_reward = "";_close_modal();_state_trace("safari_reward_cancelled")
		elif event.physical_keycode in [KEY_E,KEY_ENTER,KEY_SPACE]:
			var key: String = safari_reward;safari_reward = "";_close_modal()
			var failure: String = store.safari_rewards.claim(store,key,map_id)
			status.text = "已获得金牙，园长事件留后片。" if key=="gold_teeth" and failure=="" else "已获得HM03冲浪，按N教学。" if failure=="" else failure
			if failure=="":_build_map(map_id,player.position)
			_state_trace("safari_reward_"+key if failure=="" else "safari_reward_failed")
		return
	if safari_action!="":
		if event.physical_keycode==KEY_ESCAPE:safari_action = "";_close_modal();_state_trace("safari_cancelled")
		elif event.physical_keycode in [KEY_E,KEY_ENTER,KEY_SPACE]:
			var action: String = safari_action;safari_action = "";_close_modal()
			var failure: String = store.safari.enter(store,map_id) if action=="enter" else store.safari.leave(store)
			if failure!="":status.text = failure;_state_trace("safari_failed")
			else:_restore_location();status.text = "入园成功：30临时球 / 600步，普通球不变。" if action=="enter" else "已退出，临时球已归还。";_state_trace("safari_"+action)
		return
	if event.physical_keycode==KEY_J and not in_battle and not is_instance_valid(modal):flash_teaching=false;fly_teaching=false;strength_teaching=true;surf_teaching=false;_hm_menu();return
	if event.physical_keycode==KEY_R and store.safari.active(store.state) and not in_battle:_safari_prompt("leave");return
	if hall_phase!="":
		if Time.get_ticks_msec()<hall_ready_at:return
		if hall_phase=="oak" and event.physical_keycode in [KEY_E,KEY_ENTER,KEY_SPACE]:_hall_dialog("record")
		elif hall_phase=="record" and event.physical_keycode in [KEY_E,KEY_ENTER,KEY_SPACE]:_hall_register()
		elif hall_phase=="done" and event.physical_keycode in [KEY_E,KEY_ENTER,KEY_SPACE]:
			hall_phase="";_close_modal();_change_map("pallet-town",Vector2(store.hall_of_fame.CONTINUE["x"],store.hall_of_fame.CONTINUE["y"]))
			status.text="名人堂已登记 · 已在真新镇继续 · 可读档继续冒险";_state_trace("hall_of_fame_continue")
		elif hall_phase in ["oak","record","failed"] and event.physical_keycode in [KEY_ESCAPE,KEY_B]:
			hall_phase="";_close_modal();status.text="面向大木博士按 E 登记名人堂。";_state_trace("hall_of_fame_cancelled")
		elif hall_phase=="failed" and event.physical_keycode in [KEY_E,KEY_ENTER,KEY_SPACE]:_hall_dialog("record")
		return
	if flash_pending:
		if event.physical_keycode in [KEY_ESCAPE,KEY_B,KEY_2]:
			flash_pending=false;_close_modal();status.text="下次收集好资料再来吧。";_state_trace("flash_declined")
		elif event.physical_keycode in [KEY_E,KEY_ENTER,KEY_SPACE,KEY_1]:
			flash_pending=false;_close_modal()
			var count: int = store.pokedex.kanto_caught(store.state,store.species)
			var failure: String = store.flash_reward.claim(store,map_id)
			status.text="关都捕获或拥有%d种：获得HM05闪光！K查看；I教学；U在岩山隧道使用。" % count if failure=="" else "关都捕获或拥有%d种。%s" % [count,failure]
			_state_trace("flash_claimed" if failure=="" else "flash_failed")
		return
	if dojo_choice_pending:
		if Time.get_ticks_msec()<trainer_ready_at:return
		if event.physical_keycode in [KEY_ESCAPE,KEY_B]:dojo_choice_pending=false;_close_modal();_state_trace("dojo_choice_cancelled")
		elif event.physical_keycode in [KEY_1,KEY_2,KEY_E,KEY_ENTER,KEY_SPACE]:
			var species_id:String="hitmonlee" if event.physical_keycode==KEY_1 else "hitmonchan" if event.physical_keycode==KEY_2 else ""
			if species_id=="":status.text="请选择 1 飞腿郎或 2 快拳郎。";return
			var failure:String=store.dojo_rules.claim(store,species_id)
			if failure!="":status.text=failure;_state_trace("dojo_gift_failed");return
			dojo_choice_pending=false;_close_modal();_change_map(map_id,player.position);status.text="已选择%s并保存。" % ("飞腿郎" if species_id=="hitmonlee" else "快拳郎");_state_trace("dojo_gift_claimed")
		return
	if pending_trainer!="":
		if Time.get_ticks_msec()<trainer_ready_at:return
		if event.physical_keycode in [KEY_E,KEY_ENTER,KEY_SPACE,KEY_1]:
			var selected: String = pending_trainer
			pending_trainer = ""
			_close_modal()
			_start_trainer(selected)
		elif event.physical_keycode in [KEY_ESCAPE,KEY_B]:
			pending_trainer = ""
			_close_modal()
		return
	if nurse_phase!="":
		if Time.get_ticks_msec()<nurse_ready_at:return
		if nurse_phase=="welcome" and event.physical_keycode in [KEY_E,KEY_ENTER,KEY_SPACE,KEY_1]:_nurse_dialog("choice")
		elif nurse_phase=="choice":
			if event.physical_keycode in [KEY_1,KEY_E,KEY_ENTER,KEY_SPACE]:_nurse_heal()
			elif event.physical_keycode in [KEY_2,KEY_ESCAPE,KEY_B]:_nurse_dialog("farewell")
		elif event.physical_keycode in [KEY_E,KEY_ENTER,KEY_SPACE,KEY_ESCAPE,KEY_B]:
			nurse_phase = ""
			_close_modal()
		return
	if is_instance_valid(modal):
		if load_status == "missing" and event.physical_keycode in [KEY_1,KEY_2,KEY_3]:
			_pick_starter(["bulbasaur","charmander","squirtle"][event.physical_keycode-KEY_1])
		elif load_status == "loaded" and event.physical_keycode in [KEY_1,KEY_2,KEY_3,KEY_4,KEY_5,KEY_6]:
			_set_lead(event.physical_keycode-KEY_1)
		elif load_status == "loaded" and event.physical_keycode in [KEY_ESCAPE,KEY_P]:
			_close_modal()
		return
	match event.physical_keycode:
		KEY_T:
			_evolution_service_menu()
		KEY_G:
			_ground_item_bag()
		KEY_K:
			_new_modal("背包 · 关键物品")
			UI.label(modal,"宝可梦笛 ×1 · 点击吹奏可唤醒队伍。" if store.tower_story.flute(store.state) else "尚未获得宝可梦笛。",Rect2(100,200,755,150),22)
			if store.tower_story.flute(store.state):UI.button(modal,"吹奏宝可梦笛",Rect2(100,245,755,45),_field_flute)
			UI.label(modal,"卡片钥匙 ×1 · 可反复打开公司卡片门。" if store.silph_story.has_key(store.state) else "尚未获得卡片钥匙。",Rect2(100,450,755,36),20)
			UI.label(modal,"茶 ×1 · 可交给7号道路关卡守卫。" if store.tea_rules.has_tea(store.state) else "茶已交给守卫，四关卡共享通行。" if store.saffron_rules.opened(store.state) else "尚未获得茶。",Rect2(100,365,755,90),22)
			UI.label(modal,"金牙 ×%d · HM03冲浪 ×%d；N 教学冲浪。" % [store.safari_rewards.quantity(store.state,"gold_teeth"),store.safari_rewards.quantity(store.state,"hm03")],Rect2(100,300,755,50),20)
			UI.label(modal,"秘密钥匙 ×1 · 红莲道馆入馆凭证（馆内后续开放）。" if store.pokemon_mansion.has_key(store.state) else "尚未获得秘密钥匙。",Rect2(100,485,755,32),20)
			UI.label(modal,"HM02 ×%d · 兑换券 ×%d · 自行车 ×%d · L教学 / F飞翔 / V骑乘" % [int(store.travel.has_hm(store.state)),int(store.state.get("travel",{}).get("voucher",0)),int(store.travel.bicycle(store.state))],Rect2(100,155,755,36),18)
			UI.label(modal,"HM05闪光 ×%d · I教学；U在岩山隧道使用。" % store.flash_reward.quantity(store.state),Rect2(100,520,755,30),18)
			_state_trace("key_items_open")
		KEY_M:
			flash_teaching=false;fly_teaching=false;strength_teaching = false;surf_teaching = false;_hm_menu()
		KEY_N:
			flash_teaching=false;fly_teaching=false;strength_teaching = false;surf_teaching = true;_hm_menu()
		KEY_E,KEY_ENTER,KEY_SPACE:
			var cell := Vector2i(floori(player.position.x/16),floori((player.position.y-1)/16))
			if Time.get_ticks_msec()>=interaction_ready_at and _sevii_interact(cell):return
			if Time.get_ticks_msec()>=interaction_ready_at and _tm_gift_interact(cell):return
			if Time.get_ticks_msec()>=interaction_ready_at and _ground_item_interact(cell):return
			if Time.get_ticks_msec()>=interaction_ready_at and boulders.index(cell+Vector2i(player.facing))>=0:
				var failure:String=store.strength.field_error(store.state)
				if failure!="":status.text=failure;_state_trace("strength_rejected");return
				boulder_pending=true;_new_modal("使用怪力？");UI.label(modal,"E确认 · Esc取消。离开地图后石头复位。",Rect2(100,220,755,180),24);_state_trace("strength_prompt");return
			if Time.get_ticks_msec()>=interaction_ready_at and map_id=="wardens-house" and cell==Vector2i(2,4) and player.facing.y<0:
				if store.strength.action(store.state)=="done":status.text="怪力能推动石头。HM04已经领取。";_state_trace("warden_repeat");return
				warden_pending=true;_new_modal("园长 · 金牙与怪力");UI.label(modal,"交还金牙，或领取待领HM04。
E确认 · Esc取消。",Rect2(100,220,755,180),24);_state_trace("warden_prompt");return
			if Time.get_ticks_msec()>=interaction_ready_at:
				for entry in trainer_rules.victory:
					if entry["map"]==map_id and cell+Vector2i(player.facing)==Vector2i(entry["cell"][0],entry["cell"][1]):
						_forest_trainer_interact(entry);return
				for actor in league_actors:
					if actor["map"]==map_id and not actor.get("boulder",false) and cell+Vector2i(player.facing)==Vector2i(actor["cell"][0],actor["cell"][1]):
						status.text="火焰鸟目前仅展示，捕获未开放。" if actor.get("legendary",false) else "可见物品拾取延期。";_state_trace("victory_deferred");return
			if map_id=="route21" and Time.get_ticks_msec()>=interaction_ready_at:
				for tr in trainer_rules.route21:
					var tc:=Vector2i(tr["cell"][0],tr["cell"][1]);var dd:=tc-cell
					if absi(dd.x)+absi(dd.y)==1 and Vector2(dd).normalized().dot(player.facing)>0.9:_forest_trainer_interact(tr);return
			if Time.get_ticks_msec()>=interaction_ready_at and _surf_interact(cell):return
			if Time.get_ticks_msec()>=interaction_ready_at and _safari_interact(cell):return
			if Time.get_ticks_msec()>=interaction_ready_at and _tower_interact(cell):return
			if Time.get_ticks_msec()>=interaction_ready_at and _rocket_interact(cell):return
			if Time.get_ticks_msec()>=interaction_ready_at and _travel_interact(cell):return
			if Time.get_ticks_msec()>=interaction_ready_at and _cut_interact(cell):return
			if Time.get_ticks_msec()>=interaction_ready_at and _o15_interact(cell):return
			if Time.get_ticks_msec()>=interaction_ready_at and _o14_interact(cell):return
			if Time.get_ticks_msec()>=interaction_ready_at:
				for actor in o13_actors:
					if actor["map"]==map_id and absi(cell.x-int(actor["cell"][0]))+absi(cell.y-int(actor["cell"][1]))==1 and player.facing.dot(Vector2(int(actor["cell"][0])-cell.x,int(actor["cell"][1])-cell.y))>0.5:
						if map_id=="route11":
							for entry in trainer_rules.o13:
								if entry["redObject"]==actor["redObject"]:_forest_trainer_interact(entry);return
						status.text="2F与服务尚未开放。" if map_id=="route11-gate-1f" else "地鼠挖出了这条洞穴。" if map_id=="digletts-cave-route11" else "南方关卡的助手会检查关都捕获或拥有种类，达10种可领取HM05。"
						return
			if map_id=="vermilion-gym" and Time.get_ticks_msec()>=interaction_ready_at and _gym_interact(cell):return
			if map_id=="ssanne-2f" and cell.x in [36,37] and cell.y==8 and Time.get_ticks_msec()>=interaction_ready_at:
				_forest_trainer_interact(trainer_rules.ship_rival);return
			if map_id=="vermilion-city" and cell==Vector2i(18,30) and player.facing.y>0 and Time.get_ticks_msec()>=interaction_ready_at:
				_ship_ticket_dialog(true);return
			if map_id in ["ssanne-1f","ssanne-1f-rooms","ssanne-2f","ssanne-captain"] and Time.get_ticks_msec()>=interaction_ready_at:
				for actor in ship_actors+room_actors+upper_actors:
					if actor.get("hidden",false):continue
					var target := Vector2i(int(actor["cell"][0]),int(actor["cell"][1]))
					if actor["map"]==map_id and absi(cell.x-target.x)+absi(cell.y-target.y)==1 and player.facing.dot(Vector2(target-cell))>0.5:
						if map_id=="ssanne-1f-rooms" and int(actor["redObject"]) in [2,3,4]:
							for entry in trainer_rules.ship_rooms:
								if entry["redObject"]==actor["redObject"]:_forest_trainer_interact(entry);return
						status.text = actor.get("text","1F客房开放；其他船层未开放。")
						_trace({"event":"ship_actor_dialog","object":actor["redObject"],"text":status.text});return
			if map_id in ["underground-route5","underground-route6","vermilion-city"] and Time.get_ticks_msec()>=interaction_ready_at:
				for actor in south_actors:
					var target := Vector2i(int(actor["cell"][0]),int(actor["cell"][1]))
					if actor["map"]==map_id and absi(cell.x-target.x)+absi(cell.y-target.y)==1 and player.facing.dot(Vector2(target-cell))>0.5:
						if map_id=="vermilion-city" and actor["redObject"]==3:
							_ship_ticket_dialog(cell==Vector2i(18,30) and player.facing.y>0);return
						status.text = "这里是通往华蓝市与枯叶市的地下通道；交换功能未开放。" if map_id=="underground-route5" else "地下通道通往5号道路，地面南方是枯叶市。" if map_id=="underground-route6" else "中心、商店与船1F开放；其他建筑未开放。"
						return
			if map_id in ["cerulean-city","cerulean-trashed-house"] and Time.get_ticks_msec()>=interaction_ready_at and _thief_interact(cell):return
			if map_id=="bills-house" and Time.get_ticks_msec()>=interaction_ready_at and _bill_interact(cell):return
			if map_id=="cerulean-city" and not store.state.get("trainers",{}).get("cerulean_north_rival",false) and cell==Vector2i(20,6) and player.facing.y<0 and Time.get_ticks_msec()>=interaction_ready_at:
				_forest_trainer_interact(trainer_rules.north_rival);return
			if Time.get_ticks_msec()>=interaction_ready_at and map_id in ["rock-tunnel-1f","rock-tunnel-b1f"]:
				for entry in trainer_rules.rock:
					if entry["map"]!=map_id:continue
					var target := Vector2i(entry["cell"][0],entry["cell"][1])
					if absi(cell.x-target.x)+absi(cell.y-target.y)==1 and player.facing.dot(Vector2(target-cell))>0.5:
						_forest_trainer_interact(entry);return
			if map_id in ["celadon-gym","route8","route10-south"] and Time.get_ticks_msec()>=interaction_ready_at:
				for entry in trainer_rules.celadon+trainer_rules.route8+trainer_rules.route10_south:
					if entry["map"]!=map_id:continue
					var target := Vector2i(entry["cell"][0],entry["cell"][1])
					if absi(cell.x-target.x)+absi(cell.y-target.y)==1 and player.facing.dot(Vector2(target-cell))>0.5:
						_forest_trainer_interact(entry);return
			if map_id in ["viridian-city","viridian-gym"] and Time.get_ticks_msec()>=interaction_ready_at and _viridian_gym_interact(cell):return
			if map_id.begins_with("pokemon-mansion-") and Time.get_ticks_msec()>=interaction_ready_at and _pokemon_mansion_interact(cell):return
			if map_id in ["cinnabar-island","cinnabar-center","cinnabar-mart"] and Time.get_ticks_msec()>=interaction_ready_at:
				for actor in cinnabar_actors:
					var target := Vector2i(actor["cell"][0],actor["cell"][1])
					if actor["map"]==map_id and actor["role"] in ["visitor","link"] and absi(cell.x-target.x)+absi(cell.y-target.y)==1 and player.facing.dot(Vector2(target-cell))>0.5:
						status.text = "通信功能未开放。" if actor["role"]=="link" else "红莲岛中心与商店开放；大宅、研究所和七岛延期。";return
			if map_id=="cinnabar-gym" and Time.get_ticks_msec()>=interaction_ready_at and _cinnabar_gym_interact(cell):return
			if map_id=="fighting-dojo" and Time.get_ticks_msec()>=interaction_ready_at and _dojo_interact(cell):return
			if map_id in ["safari-zone-west","safari-zone-secret-house","safari-zone-north","safari-zone-east","safari-zone-gate","safari-zone-entry","fuchsia-gym","route14","route15","route15-gate-1f","fuchsia-city","fuchsia-center","fuchsia-mart"] and Time.get_ticks_msec()>=interaction_ready_at and _fuchsia_interact(cell):return
			if map_id in ["saffron-gym","route13","route12","route12-gate-1f"] and Time.get_ticks_msec()>=interaction_ready_at and _saffron_roads_interact(cell):return
			if map_id.begins_with("silph-co-") and Time.get_ticks_msec()>=interaction_ready_at and _silph_interact(cell):return
			if map_id in ["saffron-city","saffron-center","saffron-mart","route7-gate"] and Time.get_ticks_msec()>=interaction_ready_at and _saffron_interact(cell):return
			if map_id=="celadon-mansion-1f" and Time.get_ticks_msec()>=interaction_ready_at and _tea_interact(cell):return
			if map_id.begins_with("celadon-mart-") and Time.get_ticks_msec()>=interaction_ready_at and _celadon_mart_interact(cell):return
			if map_id in ["celadon-city","celadon-center","celadon-mart-1f","celadon-mart-2f"] and Time.get_ticks_msec()>=interaction_ready_at:
				if map_id=="celadon-mart-2f" and cell==Vector2i(5,5) and player.facing.y<0:_shop_dialog("list");return
				if map_id=="celadon-mart-2f" and cell==Vector2i(6,5) and player.facing.y<0:_shop_dialog("list");return
				for actor in celadon_actors:
					var target := Vector2i(actor["cell"][0],actor["cell"][1])
					if actor["map"]==map_id and not (map_id=="celadon-center" and actor["redObject"]==1) and absi(cell.x-target.x)+absi(cell.y-target.y)==1 and player.facing.dot(Vector2(target-cell))>0.5:status.text = "玉虹百货1至5F与屋顶可达；新楼层服务尚未开放。";return
			if map_id in ["lavender-town","lavender-center","lavender-mart"] and Time.get_ticks_msec()>=interaction_ready_at:
				for actor in lavender_actors:
					var target := Vector2i(actor["cell"][0],actor["cell"][1])
					if actor["map"]==map_id and actor["role"] in ["visitor","link"] and absi(cell.x-target.x)+absi(cell.y-target.y)==1 and player.facing.dot(Vector2(target-cell))>0.5:
						status.text = "通信功能未开放。" if actor["role"]=="link" else "紫苑镇中心与商店开放；宝可梦塔、富士与笛子剧情未开放。";return
			if map_id=="mtmoon-b2f" and Time.get_ticks_msec()>=interaction_ready_at and _fossil_interact(cell):return
			if map_id in ["route9","route10-north","route6","viridian-forest","pewter-gym","cerulean-gym","route25","route24","route3","mtmoon-1f","mtmoon-b2f"] and Time.get_ticks_msec()>=interaction_ready_at:
				for entry in (trainer_rules.roads.filter(func(v):return v["map"]==map_id) if map_id in ["route9","route10-north"] else trainer_rules.route6 if map_id=="route6" else trainer_rules.route25 if map_id=="route25" else trainer_rules.route24 if map_id=="route24" else trainer_rules.cerulean if map_id=="cerulean-gym" else trainer_rules.rockets if map_id=="mtmoon-b2f" else trainer_rules.mtmoon if map_id=="mtmoon-1f" else trainer_rules.forest if map_id=="viridian-forest" else trainer_rules.route3 if map_id=="route3" else trainer_rules.pewter):
					var target := Vector2i(int(entry["cell"][0]),int(entry["cell"][1]))
					if absi(cell.x-target.x)+absi(cell.y-target.y)==1 and player.facing.dot(Vector2(target- cell))>0.5:
						_forest_trainer_interact(entry)
						return
			if map_id in ["vermilion-center","vermilion-mart"]:
				for actor in service_actors:
					var target := Vector2i(actor["cell"][0],actor["cell"][1])
					if actor["map"]==map_id and actor["role"] in ["visitor","link"] and absi(cell.x-target.x)+absi(cell.y-target.y)==1 and player.facing.dot(Vector2(target-cell))>0.5:
						status.text = "通信与交换功能未开放。" if actor["role"]=="link" else "中心提供治疗与PC；商店仅出售已实现的货单子集。";return
			if map_id=="hall-of-fame" and Time.get_ticks_msec()>=interaction_ready_at:
				for a in hall_actors:
					var delta:=Vector2i(a["cell"][0],a["cell"][1])-cell
					if absi(delta.x)+absi(delta.y)==1 and player.facing.dot(Vector2(delta))>0.5:
						if store.hall_of_fame.pending(store.state):_hall_dialog("oak")
						else:status.text="名人堂已经登记。";_state_trace("hall_of_fame_repeat_rejected")
						return
			if map_id in store.league.ROOMS and Time.get_ticks_msec()>=interaction_ready_at:
				for a in elite_actors:
					var target:=Vector2i(a["cell"][0],a["cell"][1]);var delta:=target-cell
					if a["map"]==map_id and absi(delta.x)+absi(delta.y)==1 and player.facing.dot(Vector2(delta))>0.5:
						if map_id in ["league-lorelei","league-bruno","league-agatha","league-lance","league-champion"]:_forest_trainer_interact(trainer_rules.definition({"league-lorelei":"league_lorelei","league-bruno":"league_bruno","league-agatha":"league_agatha","league-lance":"league_lance","league-champion":"league_champion"}[map_id]))
						else:status.text="联盟挑战尚未开放。";_state_trace("league_deferred")
						return
			if map_id=="indigo-lobby" and Time.get_ticks_msec()>=interaction_ready_at:
				if cell==Vector2i(7,7) and player.facing.y<0:_nurse_dialog("welcome");return
				if cell==Vector2i(15,8) and player.facing.y<0:_pc_open();return
				if cell==Vector2i(2,5) and player.facing.x<0:_shop_dialog("list");return
				for a in indigo_actors:
					var t:=Vector2i(a["cell"][0],a["cell"][1])
					if absi(t.x-cell.x)+absi(t.y-cell.y)==1 and player.facing.dot(Vector2(t-cell))>0.5:status.text="通信功能未开放。" if a["role"]=="link" else "先治疗并补足道具，再挑战四天王。北门可以挑战科拿。";return
			if map_id=="route22" and absi(cell.x-25)+absi(cell.y-5)==1 and Time.get_ticks_msec()>=interaction_ready_at:
				var direction := Vector2(25-cell.x,5-cell.y)
				if player.facing.dot(direction)>0.5:_rival_interact()
			if map_id in ["cinnabar-mart","fuchsia-mart","saffron-mart","viridian-mart","vermilion-mart","lavender-mart"] and cell==Vector2i(2,5) and player.facing.x<0 and Time.get_ticks_msec()>=interaction_ready_at:_shop_dialog("list")
			if map_id in ["cinnabar-center","fuchsia-center","saffron-center","viridian-center","mtmoon-center","cerulean-center","vermilion-center","lavender-center","celadon-center"] and cell==Vector2i(13,4) and player.facing.y<0 and Time.get_ticks_msec()>=interaction_ready_at:_pc_open()
			if map_id=="fuchsia-center" and cell==Vector2i(3,3) and player.facing.y<0 and Time.get_ticks_msec()>=interaction_ready_at:_nurse_dialog("welcome")
			if map_id in ["cinnabar-center","saffron-center","viridian-center","pewter-center","mtmoon-center","cerulean-center","vermilion-center","lavender-center","celadon-center"] and cell==Vector2i(3,3) and player.facing.y<0 and Time.get_ticks_msec()>=interaction_ready_at:_nurse_dialog("welcome")
		KEY_B:
			if map_id=="route17":return
			field_item="";_field_bag()
		KEY_O:
			stone_item="";_stone_bag()
		KEY_P:
			_team_menu()
		KEY_H:
			if store.league.active(store.state):status.text="联盟连战中不能使用免费营地，请使用背包道具。";return
			store.heal_and_supply()
			if _save():
				status.text = "免费营地补给：全队恢复，捕捉球补至 10。"
			_state_trace("supply")
		KEY_F5:
			_save()
		KEY_F10:
			if _save():
				get_tree().quit()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if load_status != "loaded" or _save():
			get_tree().quit()

func _save() -> bool:
	# Closing mid-trainer battle commits only its complete pre-battle snapshot.
	if in_battle and is_instance_valid(battle) and battle.trainer_id!="" and not battle.trainer_settled:
		var pending: Dictionary = store.state
		store.state = battle.trainer_before.duplicate(true)
		var safe: bool = store.save_game()
		store.state = pending
		return safe
	var saved_position: Vector2 = sevii_motion_origin if not sevii_motion.is_empty() else visual_source_position if visual_transition and not visual_committing and map_id==visual_source_map else seafoam_current_end if not seafoam_current.is_empty() else rocket_spin.destination() if rocket_spin.active else boulders.safe_position(player.safe_position())
	var before_save:Dictionary=store.state.duplicate(true)
	store.state["location"] = {"map_id":map_id,"x":saved_position.x,"y":saved_position.y}
	var ok: bool = battle.save_canonical() if in_battle and is_instance_valid(battle) else store.save_game()
	if not ok:store.state=before_save
	status.text = "已保存 · 余额 %d · 球 %d · 药 %d" % [store.state.get("money",0),store.state.get("balls",0),store.state.get("potions",0)] if ok else store.error
	_trace({"event":"saved" if ok else "save_failed","path":ProjectSettings.globalize_path(store.PATH)})
	return ok

func _state_trace(event: String) -> void:
	_trace({"event":event,"state":store.state.duplicate(true),"path":ProjectSettings.globalize_path(store.PATH)})

func _new_modal(title: String) -> void:
	if is_instance_valid(modal):
		modal.queue_free()
	modal = Control.new()
	modal.theme = UI.setup_theme()
	overlay.get_parent().add_child(modal)
	player.active = false
	UI.panel(modal,Rect2(74,100,812,460),Color("18343c"))
	UI.label(modal,title,Rect2(99,116,760,42),27)

func _close_modal() -> void:
	shop_phase = ""
	nurse_phase = ""
	mail_phase = ""
	if is_instance_valid(modal):
		modal.queue_free()
		modal = null
	player.active = true
	interaction_ready_at = Time.get_ticks_msec()+250

func _starter_menu() -> void:
	load_status = "missing"
	_new_modal("首次出发 · 选择一只初始伙伴")
	UI.label(modal,"仅无存档时选择。伙伴、HP、球和首发会保存在本机。",Rect2(100,170,755,40),19)
	for i in range(3):
		var id: String = ["bulbasaur","charmander","squirtle"][i]
		var texture := TextureRect.new()
		texture.texture = load(store.species[id]["sprite"])
		texture.position = Vector2(135+i*245,230)
		texture.size = Vector2(192,192)
		texture.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		modal.add_child(texture)
		UI.button(modal,"%d 选择%s" % [i+1,store.species[id]["name"]],Rect2(105+i*250,430,245,65),_pick_starter.bind(id))

func _pick_starter(id: String) -> void:
	if load_status != "missing":
		return
	if not store.new_game(id):
		status.text = store.error
		UI.label(modal,store.error,Rect2(100,470,750,60),18)
		return
	load_status = "loaded"
	_close_modal()
	_state_trace("starter_selected")
	_save()

func _corrupt_menu() -> void:
	_new_modal("存档需要处理 · 原文件已保留")
	UI.label(modal,store.error,Rect2(100,180,760,70),20)
	UI.button(modal,"保留文件并退出",Rect2(110,300,735,65),func():get_tree().quit())
	UI.button(modal,"我要放弃旧进度并新建…",Rect2(110,390,735,65),_confirm_reset)

func _confirm_reset() -> void:
	_new_modal("再次确认：放弃原本地存档？")
	UI.label(modal,"选择伙伴并保存后会替换旧文件。没有自动备份。",Rect2(105,180,750,60),21)
	UI.button(modal,"取消，保留原文件退出",Rect2(110,290,735,65),func():get_tree().quit())
	UI.button(modal,"确认新建，前往选择伙伴",Rect2(110,390,735,65),_starter_menu)

func _team_menu() -> void:
	_new_modal("队伍 · 精灵球 %d · 伤药 %d" % [int(store.state["balls"]),int(store.state["potions"])])
	var move_data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/moves.json"))
	for i in range(store.state["team"].size()):
		var pet: Dictionary = store.state["team"][i]
		var data: Dictionary = store.species[pet["species_id"]]
		var lead: bool = i==int(store.state["lead"])
		var y: float = 164+i*52
		var card := Panel.new()
		card.position=Vector2(96,y);card.size=Vector2(768,50);card.mouse_filter=Control.MOUSE_FILTER_IGNORE
		var style:=StyleBoxFlat.new()
		style.bg_color=Color("e5ead2") if lead else Color("d6dfd3")
		style.border_color=Color("548867") if lead else Color("a7b8af")
		style.set_border_width_all(2 if lead else 1);style.set_corner_radius_all(4)
		card.add_theme_stylebox_override("panel",style);modal.add_child(card)
		var icon := TextureRect.new()
		var icon_path: String = "res://assets/pokemon/%s-icon.png" % pet["species_id"]
		if ResourceLoader.exists(icon_path):icon.texture=load(icon_path)
		icon.position=Vector2(103,y+1);icon.size=Vector2(48,48)
		icon.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;icon.mouse_filter=Control.MOUSE_FILTER_IGNORE;modal.add_child(icon)
		UI.label(modal,"%d %s Lv%d %s" % [i+1,data["name"],int(pet["level"]),"首发" if lead else ""],Rect2(155,y+1,260,22),16)
		var maximum: int = int(store.growth.stats(pet)["hp"])
		var ratio: float = clampf(float(pet["hp"])/maximum,0,1)
		var bar:=ColorRect.new();bar.position=Vector2(424,y+8);bar.size=Vector2(110,8);bar.color=Color("65776c");bar.mouse_filter=Control.MOUSE_FILTER_IGNORE
		var fill:=ColorRect.new();fill.position=Vector2(1,1);fill.size=Vector2(108*ratio,6)
		fill.color=Color("5a9e70") if ratio>0.5 else Color("d3a64e") if ratio>0.2 else Color("c86b62")
		fill.mouse_filter=Control.MOUSE_FILTER_IGNORE;bar.add_child(fill);modal.add_child(bar)
		UI.label(modal,"HP %d/%d" % [int(pet["hp"]),maximum],Rect2(541,y+1,126,22),14)
		var skills: Array[String] = []
		for id in pet["moves"]:skills.append("%s %d/%d" % [move_data[id]["name"],int(pet["pp"][id]),int(move_data[id]["pp"])])
		UI.label(modal,"EXP %s · %s" % [str(pet["exp"])," / ".join(skills)],Rect2(155,y+25,600,23),12)
		var button := UI.button(modal,"%d 首发" % [i+1],Rect2(762,y+5,94,38),_set_lead.bind(i))
		button.disabled=int(pet["hp"])<=0 or lead
	UI.button(modal,"P / Esc 返回地图",Rect2(105,484,745,54),_close_modal)
	_state_trace("team_view")

func _set_lead(index: int) -> void:
	if index<0 or index>=store.state["team"].size() or int(store.state["team"][index]["hp"])<=0:
		return
	store.state["lead"] = index
	_save()
	_team_menu()

func _build_map(id: String, arrival: Vector2) -> void:
	seafoam_current=[];seafoam_current_index=0;seafoam_current_clock=0.0
	if id not in ["rock-tunnel-1f","rock-tunnel-b1f"]:
		flash_active=false
		if store.state.has("flash_active"):store.state["flash_active"]=false
	if is_instance_valid(flash_mask):
		flash_mask.get_parent().remove_child(flash_mask)
		flash_mask.queue_free()
		flash_mask=null
	rocket_spin.reset()
	if id!=map_id:
		cut_removed.clear()
		if id=="vermilion-gym":store.gym_rules.enter(store.state)
	if is_instance_valid(world):
		remove_child(world)
		world.queue_free()
	map_id = id
	layout = JSON.parse_string(FileAccess.get_file_as_string("res://data/%s.json" % id))
	if id=="cinnabar-island" and store.state.has("mansion_switch"):store.state["mansion_switch"]=false
	if id=="fighting-dojo":
		for actor in o12_actors:layout["solid"][actor["cell"][1]][actor["cell"][0]]=1
	viridian_gym.geometry(id,layout)
	if id=="route22":layout["solid"][5][8]=0
	if id=="route22" and store.state.get("trainers",{}).get("route22_late",false):layout["solid"][5][25]=0
	store.pokemon_mansion.apply(id,layout,store.state)
	if id=="cinnabar-gym":store.cinnabar_gym.geometry(layout,store.state)
	store.league.apply(id,layout,store.state)
	victory_road.apply(id,layout,store.state,league_actors)
	boulders.visibility=func(a:Dictionary)->bool:return store.seafoam.visible(a,store.state) and victory_road.visible(a,store.state)
	if sevii_boulders.is_empty():sevii_boulders=store.sevii.boulder_actors()
	boulders.enter(id,strength_actors+league_actors+o06_actors+o07_actors+sevii_boulders)
	if id=="victory-road-1f" and store.state.get("victory_road_1f_open",false):
		for patch in boulders.puzzle["openCells"]:
			layout["solid"][patch["cell"][1]][patch["cell"][0]]=patch["solid"];layout["footTiles"][patch["cell"][1]][patch["cell"][0]]=patch["foot"]
	boulders.apply(layout)
	store.post_b3.apply(id,layout,store.state)
	store.tower_story.apply(id,layout,store.state,tower_actors)
	store.ground_items.apply(id,layout,store.state)
	boulders.apply(layout)
	store.saffron_rules.apply(id,layout,store.state,saffron_actors)
	store.silph_story.apply(id,layout,store.state,silph_actors)
	_apply_snorlax(id,layout)
	store.safari_rewards.apply(id,layout,store.state)
	if store.state.get("surfing",false) and not store.surf.water(id,layout,Vector2i(floori(arrival.x/16),floori((arrival.y-1)/16))):store.state["surfing"] = false
	store.surf.apply(id,layout,store.state)
	store.sevii.apply(id,layout,store.state)
	boulders.apply(layout)
	if id.begins_with("seafoam-islands-"):
		store.seafoam.apply(id,layout,store.state,o06_actors+o07_actors)
		boulders.apply(layout)
	if id in ["route19","route20"]:layout["o05SeaExit"]="left" if id=="route19" else "right"
	for actor in o05_actors:
		if actor["map"]==id:layout["solid"][actor["cell"][1]][actor["cell"][0]]=1
	if id in ["game-corner","rocket-hideout-b1f"]:store.rocket_rules.apply(id,layout,store.state)
	if store.cut_rules.has_trees(id):
		for tree in store.cut_rules.trees(id):
			if tree["cell"] in cut_removed:
				for patch in tree["cells"]:
					layout["solid"][patch["cell"][1]][patch["cell"][0]] = patch["solid"]
					layout["footTiles"][patch["cell"][1]][patch["cell"][0]] = patch["foot"]
	if id=="vermilion-gym" and store.gym_rules.opened(store.state):
		for patch in store.gym_rules.data["door"]["openCells"]:
			layout["solid"][patch["cell"][1]][patch["cell"][0]] = patch["solid"]
			layout["footTiles"][patch["cell"][1]][patch["cell"][0]] = patch["foot"]
	if id=="viridian-forest":
		for entry in trainer_rules.forest:layout["solid"][int(entry["cell"][1])][int(entry["cell"][0])] = 1
	world = Node2D.new()
	world.position = Vector2(160,40)
	world.scale = Vector2(2,2)
	world.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(world)
	if id in ["rock-tunnel-1f","rock-tunnel-b1f"] and is_instance_valid(overlay):
		flash_mask = ColorRect.new()
		flash_mask.name = "RockTunnelDarkness"
		flash_mask.color = Color(0.015,0.02,0.03,0.94)
		flash_mask.position = Vector2(0,40)
		flash_mask.size = Vector2(960,576)
		flash_mask.mouse_filter = Control.MOUSE_FILTER_IGNORE
		flash_mask.z_index = 50
		flash_mask.material = _flash_mask_material()
		flash_mask.material.set_shader_parameter("enabled", flash_active)
		flash_mask.material.set_shader_parameter("light_center", (arrival * 2.0 + world.position - Vector2(0,40)) / Vector2(960,576))
		flash_layer.add_child(flash_mask)
	var ground := Sprite2D.new()
	ground.texture = load("res://assets/%s/ground.png" % id)
	ground.centered = false
	ground.name = "Ground"
	world.add_child(ground)
	if id=="victory-road-1f" and store.state.get("victory_road_1f_open",false):
		var patch:=Sprite2D.new();patch.texture=load(boulders.puzzle["patch"]);patch.centered=false;patch.position=Vector2(128,192);world.add_child(patch)
	if id in ["league-lorelei","league-bruno","league-agatha"] and store.league.stage(store.state)>store.league.ROOMS.find(id):
		var doors:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://data/league-doors.json"));var door:=Sprite2D.new();door.texture=load(doors[id]["patch"]);door.centered=false;door.position=Vector2(64,0);world.add_child(door)
	for opened_patch in victory_road.patches(id,store.state):
		var patch:=Sprite2D.new();patch.texture=load(opened_patch["patch"]);patch.centered=false;patch.position=Vector2(opened_patch["block"][0]*32,opened_patch["block"][1]*32);world.add_child(patch)
	if id=="cinnabar-gym":
		var opened:Array=store.cinnabar_gym.gates(store.state)
		for gate in store.cinnabar_gym.quiz["gates"]:
			if opened[int(gate["id"])-1]:
				var patch:=Sprite2D.new();patch.texture=load("res://assets/cinnabar-gym/gate-%d-open.png"%int(gate["id"]));patch.centered=false;patch.position=Vector2(gate["block"][0]*32,gate["block"][1]*32);world.add_child(patch)
	for door in store.pokemon_mansion.data["doors"]:
		if door["map"]==id:
			var patch:=Sprite2D.new();patch.texture=load(door["states"][int(store.pokemon_mansion.active(store.state))]["patch"]);patch.centered=false;patch.position=Vector2(door["block_cell"][0]*32,door["block_cell"][1]*32);world.add_child(patch)
	for door in store.silph_story.doors:
		if door["map"]==id and store.silph_story.door_open(store.state,door["id"]):
			var patch := Sprite2D.new();patch.texture = load(door["patch"]);patch.centered = false;patch.position = Vector2(door["block_cell"][0]*32,door["block_cell"][1]*32);world.add_child(patch)
	if id=="rocket-hideout-b4f" and store.post_b3.door_open(store.state):
		var door_patch := Sprite2D.new();door_patch.texture = load(store.post_b3.door["patch"]);door_patch.centered = false;door_patch.position = Vector2(384,160);world.add_child(door_patch)
	if id in ["game-corner","rocket-hideout-b1f"]:
		for block in store.rocket_rules.blocks:
			if block["map"]==id and store.rocket_rules.active(id,store.state):
				var patch := Sprite2D.new();patch.texture = load(block["patch"]);patch.centered = false;patch.position = Vector2(block["block_cell"][0]*32,block["block_cell"][1]*32);world.add_child(patch)
	if id=="vermilion-gym":
		if store.gym_rules.opened(store.state):
			var door := Sprite2D.new();door.texture = load("res://assets/vermilion-gym/door-open.png");door.centered = false;door.position = Vector2(64,64);world.add_child(door)
		elif store.gym_rules.found:
			var light := Line2D.new();light.add_point(Vector2(65,80));light.add_point(Vector2(95,80));light.default_color = Color("d7b54d");light.width = 1;world.add_child(light)
	if store.cut_rules.has_trees(id):
		for tree in store.cut_rules.trees(id):
			if tree["cell"] in cut_removed:
				var patch := Sprite2D.new();patch.texture = load(tree["patch"]);patch.centered = false;patch.position = Vector2(tree["block_cell"][0]*32,tree["block_cell"][1]*32);world.add_child(patch)
	for y in range(int(layout["height"])):
		for x in range(int(layout["width"])):
			if int(layout["solid"][y][x])==1:_add_solid(world,Rect2(x*16,y*16,16,16))
	# Original Forest directional tile-pair collision becomes thin native edge colliders.
	for pair in layout.get("pairCollisionsLand",[]):
		for y in range(int(layout["height"])):
			for x in range(int(layout["width"])):
				var a: int = int(layout["footTiles"][y][x])
				for delta in [Vector2i(1,0),Vector2i(0,1)]:
					var next: Vector2i = Vector2i(x,y)+delta
					if next.x>=int(layout["width"]) or next.y>=int(layout["height"]):continue
					var b: int = int(layout["footTiles"][next.y][next.x])
					if (a==int(pair[0]) and b==int(pair[1])) or (a==int(pair[1]) and b==int(pair[0])):
						_add_solid(world,Rect2((x+1)*16-.5,y*16,1,16) if delta.x==1 else Rect2(x*16,(y+1)*16-.5,16,1))
	var width: int = int(layout["width"])*16
	var height: int = int(layout["height"])*16
	var north_gate: bool = id in ["route19","route17","route18","route23","cinnabar-island","route21","route13","route12","lavender-town","pallet-town","route1","viridian-city","route2","route3","route5","cerulean-city","cerulean-trashed-house","vermilion-city"]
	if north_gate:
		var start: int = 96 if id=="route19" else 0 if id in ["route17","route18"] else 144 if id=="route23" else 16 if id=="cinnabar-island" else 64 if id=="route21" else 640 if id=="route13" else 0 if id=="lavender-town" else 160 if id=="vermilion-city" else 48 if id=="cerulean-trashed-house" else 0 if id=="route5" else 160 if id=="cerulean-city" else 800 if id=="route3" else 272 if id=="viridian-city" else 0 if id=="route2" else 160
		var end: int = 224 if id=="route19" else 320 if id in ["route17","route18"] else 176 if id=="route23" else 64 if id=="cinnabar-island" else 128 if id=="route21" else width if id in ["route13","lavender-town"] else 480 if id=="vermilion-city" else 64 if id=="cerulean-trashed-house" else width if id=="route5" else 480 if id=="cerulean-city" else width if id=="route3" else 320 if id=="viridian-city" else width if id=="route2" else 192
		_add_solid(world,Rect2(-16,-16,start+16,16))
		_add_solid(world,Rect2(end,-16,width-end+16,16))
	elif not store.sevii.world.has(id):_add_solid(world,Rect2(-16,-16,width+32,16))
	if id=="cerulean-city":
		_add_solid(world,Rect2(-16,0,16,128))
		_add_solid(world,Rect2(-16,416,16,height-416))
	elif id=="route19":
		_add_solid(world,Rect2(-16,0,16,576))
	elif id=="fuchsia-city":
		_add_solid(world,Rect2(-16,0,16,128));_add_solid(world,Rect2(-16,416,16,height-416))
	elif id=="saffron-city":
		_add_solid(world,Rect2(-16,0,16,272))
		_add_solid(world,Rect2(-16,304,16,height-304))
	elif id=="route14":
		_add_solid(world,Rect2(-16,0,16,576))
	elif id=="celadon-city":
		_add_solid(world,Rect2(-16,0,16,128));_add_solid(world,Rect2(-16,416,16,height-416))
	elif id=="route12":
		_o13_edge_colliders(world,id,false)
	elif id=="route11":_o13_edge_colliders(world,id,false)
	elif id in ["route13","route15","route7","lavender-town","route25","route9"]:pass
	elif id=="route10-north":
		_add_solid(world,Rect2(-16,288,16,height-288))
	elif id=="route3":
		_add_solid(world,Rect2(-16,0,16,96))
		_add_solid(world,Rect2(-16,160,16,height-160))
	elif id=="viridian-city":
		_add_solid(world,Rect2(-16,0,16,224))
		_add_solid(world,Rect2(-16,288,16,height-288))
	elif not store.sevii.world.has(id):_add_solid(world,Rect2(-16,0,16,height))
	if id=="cerulean-city":
		_add_solid(world,Rect2(width,0,16,128))
		_add_solid(world,Rect2(width,416,16,height-416))
	elif id=="route14":
		_add_solid(world,Rect2(width,288,16,height-288))
	elif id in ["route16","fuchsia-city","route15","route7","route8","route9"]:pass
	elif id=="vermilion-city":
		_o13_edge_colliders(world,id,true)
	elif id=="route11":_o13_edge_colliders(world,id,true)
	elif id in ["route18","route20"]:pass
	elif id=="celadon-city":
		_add_solid(world,Rect2(width,0,16,128))
		_add_solid(world,Rect2(width,416,16,height-416))
	elif id=="pewter-city":
		_add_solid(world,Rect2(width,0,16,224))
		_add_solid(world,Rect2(width,288,16,height-288))
	elif id in ["route4-east","route24"]:pass
	elif id=="route22":
		_add_solid(world,Rect2(width,0,16,96))
		_add_solid(world,Rect2(width,160,16,height-160))
	elif not store.sevii.world.has(id):_add_solid(world,Rect2(width,0,16,height))
	if id in ["indigo-plateau","route12","route6","route10-south","lavender-town","route17"]:pass
	elif id=="fuchsia-city":
		_add_solid(world,Rect2(-16,height,272,16));_add_solid(world,Rect2(384,height,width-368,16))
	elif id=="route18":_add_solid(world,Rect2(-16,height,width+32,16))
	elif id=="pallet-town":
		_add_solid(world,Rect2(0,height,64,16));_add_solid(world,Rect2(128,height,width-128,16))
	elif id in ["route1","viridian-city","route2","pewter-city","route4-entrance","route24","cerulean-city"]:
		var gate: int = 160 if id=="cerulean-city" else 0 if id=="route24" else 0 if id=="route4-entrance" else 112 if id=="route2" else 160 if id in ["route1","pewter-city"] else 320
		_add_solid(world,Rect2(0,height,gate,16))
		_add_solid(world,Rect2(gate+(320 if id=="cerulean-city" else width if id in ["route24","route4-entrance"] else 320 if id=="pewter-city" else 48 if id=="route2" else 32),height,width-gate-(320 if id=="cerulean-city" else width if id in ["route24","route4-entrance"] else 320 if id=="pewter-city" else 48 if id=="route2" else 32),16))
	elif not store.sevii.world.has(id):_add_solid(world,Rect2(-16,height,width+32,16))
	var objects := Node2D.new()
	objects.y_sort_enabled = true
	world.add_child(objects)
	if id=="viridian-forest":
		for entry in trainer_rules.forest:
			var npc := Sprite2D.new()
			npc.texture = load("res://assets/forest-trainers/youngster-left.png")
			npc.position = Vector2(int(entry["cell"][0])*16+8,int(entry["cell"][1])*16+8)
			objects.add_child(npc)
			if id=="mtmoon-1f":_add_solid(world,Rect2(int(entry["cell"][0])*16,int(entry["cell"][1])*16,16,16))
	if id=="route22" and not store.state.get("trainers",{}).get("route22_late",false):
		var rival := Sprite2D.new()
		rival.texture = load("res://assets/route22/rival.png")
		rival.position = Vector2(408,88)
		objects.add_child(rival)
	if id=="viridian-mart":
		var clerk := Sprite2D.new()
		clerk.texture = load("res://assets/viridian-mart/clerk.png")
		clerk.position = Vector2(8,88)
		objects.add_child(clerk)
	if id in ["route9","route10-north","pewter-gym","cerulean-gym","route25","route24","route3","mtmoon-1f","mtmoon-b2f"]:
		for entry in (trainer_rules.roads.filter(func(v):return v["map"]==id) if id in ["route9","route10-north"] else trainer_rules.route25 if id=="route25" else trainer_rules.route24 if id=="route24" else trainer_rules.cerulean if id=="cerulean-gym" else trainer_rules.rockets if id=="mtmoon-b2f" else trainer_rules.mtmoon if id=="mtmoon-1f" else trainer_rules.route3 if id=="route3" else trainer_rules.pewter):
			var npc := Sprite2D.new()
			npc.texture = load(entry["sprite"])
			npc.position = Vector2(int(entry["cell"][0])*16+8,int(entry["cell"][1])*16+8)
			objects.add_child(npc)
			if id in ["mtmoon-1f","mtmoon-b2f"]:_add_solid(world,Rect2(int(entry["cell"][0])*16,int(entry["cell"][1])*16,16,16))
	if id=="vermilion-gym":
		for entry in store.gym_rules.data["actors"]:
			var npc := Sprite2D.new();npc.texture = load(entry["sprite"]);npc.position = Vector2(entry["cell"][0]*16+8,entry["cell"][1]*16+8);objects.add_child(npc)
	if id=="cerulean-city" and not store.state.get("trainers",{}).get("cerulean_north_rival",false):
		var rival := Sprite2D.new()
		rival.texture = load(trainer_rules.north_rival["sprite"])
		rival.position = Vector2(328,88)
		objects.add_child(rival)
		_add_solid(world,Rect2(320,80,16,16))
	if id=="cerulean-city":
		var guard_cell := Vector2i(28 if store.thief_rules.released(store.state) else 27,12)
		_add_story_actor(objects,"guard",guard_cell)
		_add_solid(world,Rect2(guard_cell.x*16,guard_cell.y*16,16,16))
		if not store.state.has("stolen_tm"):
			_add_story_actor(objects,"rocket",Vector2i(30,8));_add_solid(world,Rect2(480,128,16,16))
	if id=="cerulean-trashed-house":
		_add_story_actor(objects,"owner",Vector2i(2,1));_add_story_actor(objects,"girl",Vector2i(5,6))
	if id=="bills-house":
		var actor: Dictionary = store.bill_rules.actor(store.state)
		if not actor.is_empty():
			var npc := Sprite2D.new();npc.texture = load("res://assets/bills-house/%s.png" % actor["sprite"])
			npc.position = Vector2(int(actor["cell"][0])*16+8,int(actor["cell"][1])*16+8);objects.add_child(npc)
			_add_solid(world,Rect2(int(actor["cell"][0])*16,int(actor["cell"][1])*16,16,16))
	if id=="cerulean-gym":
		var guide := Sprite2D.new()
		guide.texture = load("res://assets/cerulean-gym/guide.png")
		guide.position = Vector2(120,168)
		objects.add_child(guide)
	if id=="cinnabar-gym":
		for entry in store.cinnabar_gym.all_trainers():
			var npc:=Sprite2D.new();npc.texture=load(entry["sprite"]);npc.position=Vector2(entry["cell"][0]*16+8,entry["cell"][1]*16+8);objects.add_child(npc)
		var cinnabar_guide:=Sprite2D.new();cinnabar_guide.texture=load("res://assets/cinnabar-gym/guide.png");cinnabar_guide.position=Vector2(16*16+8,13*16+8);objects.add_child(cinnabar_guide)
	if id in ["rock-tunnel-1f","rock-tunnel-b1f"]:
		for entry in rock_actors:
			if entry["map"]!=id:continue
			var npc := Sprite2D.new();npc.texture = load(entry["sprite"]);npc.position = Vector2(entry["cell"][0]*16+8,entry["cell"][1]*16+8);objects.add_child(npc)
	if id in ["celadon-gym","route8","route10-south"]:
		for entry in trainer_rules.celadon+trainer_rules.route8+trainer_rules.route10_south:
			if entry["map"]!=id:continue
			var npc := Sprite2D.new();npc.texture = load(entry["sprite"]);npc.position = Vector2(entry["cell"][0]*16+8,entry["cell"][1]*16+8);objects.add_child(npc)
	if id=="mtmoon-b2f":_build_fossil_actors()
	if id in ["viridian-center","pewter-center","mtmoon-center","cerulean-center"]:
		var nurse := Sprite2D.new()
		nurse.texture = load("res://assets/viridian-center/nurse.png")
		nurse.position = Vector2(56,24)
		objects.add_child(nurse)
	for actor in tm_acquisition_actors+o16_actors+o15_actors+o14_actors+o13_actors+o07_actors+o06_actors+travel_actors+o03_actors+o04_actors+o05_actors+o11_actors+o12_actors+hall_actors+elite_actors+indigo_actors+league_actors+viridian_gym.actors+pokemon_mansion_actors+cinnabar_actors+route21_actors+strength_actors+safari_actors+fuchsia_actors+saffron_roads_actors+silph_actors+tower_actors+post_b3_actors+rocket_depth_actors+rocket_actors+south_actors+service_actors+ship_actors+room_actors+upper_actors+lavender_actors+west_path_actors+celadon_actors+mansion_actors+saffron_actors:
		if actor["map"]==id:
			if not store.ground_items.visible(actor,store.state):continue
			if id=="fighting-dojo" and actor["redObject"] in [6,7]:continue
			if id=="route16" and actor["redObject"]==7 and store.state.get("static_encounters",{}).get("route16_snorlax",false):continue
			if not store.seafoam.visible(actor,store.state) or not victory_road.visible(actor,store.state):continue
			if actor in pokemon_mansion_actors and actor.get("item","")=="SECRET_KEY" and store.pokemon_mansion.has_key(store.state):continue
			if id=="safari-zone-entry" and actor in fuchsia_actors:continue
			if id=="safari-zone-west" and actor.get("item","")=="GOLD_TEETH" and store.safari_rewards.claimed(store.state,"gold_teeth"):continue
			if id=="route12" and actor["redObject"]==1 and store.state.get("static_encounters",{}).get("route12_snorlax",false):continue
			if actor in silph_actors and not store.silph_story.visible(actor,store.state):continue
			if actor in saffron_actors and not store.saffron_rules.visible(actor,store.state):continue
			if actor in tower_actors and not store.tower_story.visible(actor,store.state):continue
			if actor in post_b3_actors and not store.post_b3.visible(actor,store.state):continue
			if actor.get("id","")=="rocket_poster" and store.rocket_rules.guard_gone(store.state):continue
			if id=="ssanne-2f" and actor.get("hidden",false):continue
			if id=="ssanne-1f-rooms" and (int(actor["cell"][0])/10!=floori(arrival.x/160) or int(actor["cell"][1])/10!=floori(arrival.y/160)):continue
			var actor_cell:Array=actor["cell"]
			if actor.get("boulder",false):
				actor_cell=boulders.cells[boulders.object_ids.find(int(actor["redObject"]))]
				if actor_cell[0]<0:continue
			if id=="wardens-house" and actor["redObject"]==3:actor_cell=boulders.cells[0]
			var npc := Sprite2D.new();npc.texture = load(actor["sprite"]);npc.position = Vector2(int(actor_cell[0])*16+8,int(actor_cell[1])*16+8);objects.add_child(npc)
	if id=="ssanne-2f" and ship_rival_revealed and not store.state.get("trainers",{}).get("ssanne_rival",false):
		var rival := Sprite2D.new();rival.texture = load(trainer_rules.ship_rival["sprite"]);rival.position = Vector2(584,120);objects.add_child(rival)
	if id=="ssanne-captain":
		var captain := Sprite2D.new();captain.texture = load(store.cut_rules.data["captain"]["sprite"]);captain.position = Vector2(72,40);objects.add_child(captain)
	_sevii_draw(objects,id)
	var foreground_path: String = "res://assets/%s/foreground.png" % id
	if ResourceLoader.exists(foreground_path):
		var foreground := Sprite2D.new()
		foreground.texture = load(foreground_path)
		foreground.centered = false
		foreground.z_index = 20
		world.add_child(foreground)
	player = Player.new()
	player.surfing = store.state.get("surfing",false)
	if id not in store.travel.OUTDOORS:riding=false
	if store.travel.cycling(id,arrival) and store.travel.bicycle(store.state):riding=true
	player.cycling=riding
	player.cycling_road=id=="route17"
	player.position = arrival
	player.layout = layout
	objects.add_child(player)
	field_visuals = preload("res://scripts/field_visuals.gd").new()
	world.add_child(field_visuals)
	field_visuals.setup(id,layout,player,ground.texture)
	field_visuals.attach_environment(world)
	_seafoam_begin(Vector2i(floori(arrival.x/16),floori((arrival.y-1)/16)),true)
	last_cell = Vector2i(floori(arrival.x/16),floori((arrival.y-1)/16))
	interaction_ready_at = Time.get_ticks_msec()+250

	_camera()

func _camera() -> void:
	var extent := Vector2(int(layout["width"])*16,int(layout["height"])*16)
	if map_id=="ssanne-1f-rooms":
		var origin := Vector2(floori(player.position.x/160)*160,160 if player.position.y>=160 else 0)
		var cabin_size := Vector2(64,96)
		var ground: Sprite2D = world.get_node("Ground")
		ground.region_enabled = true
		ground.region_rect = Rect2(origin,cabin_size)
		ground.position = origin
		world.position = Vector2(0,40)+(Vector2(480,288)-cabin_size)*1.0-origin*2
		return
	var view := Vector2(480,288)
	var offset := Vector2.ZERO
	for axis in range(2):
		offset[axis] = (view[axis]-extent[axis])/2 if extent[axis]<view[axis] else -clampf(player.position[axis]-view[axis]/2,0,extent[axis]-view[axis])
	world.position = Vector2(offset.x*2,40+offset.y*2)
	_flash_update_center()

func _change_map(id: String, arrival: Vector2) -> void:
	if visual_transition and not visual_committing:return
	if not visual_committing and id!=map_id and is_instance_valid(overlay) and is_instance_valid(player) and _visual_kind(map_id,id)!="road":
		_visual_begin(id,arrival)
		return
	if is_instance_valid(player) and store.ordinary_items.escapable(id) and not store.ordinary_items.escapable(map_id):
		store.state["escape_return"]={"map_id":map_id,"x":roundi(player.position.x),"y":roundi(player.position.y)}
	var leaving_cave: bool = map_id in ["rock-tunnel-1f","rock-tunnel-b1f"] and id not in ["rock-tunnel-1f","rock-tunnel-b1f"]
	if leaving_cave:
		flash_active=false
		store.state["flash_active"]=false
	store.travel.visit(store.state,id)
	if id!=map_id:
		var before:Dictionary=store.state.duplicate(true)
		if store.seafoam.transition(map_id,id,store.state) or victory_road.transition(id,store.state):
			store.state["location"]={"map_id":id,"x":arrival.x,"y":arrival.y}
			if not store.save_game():store.state=before;status.text=store.error;_state_trace("victory_transition_failed");return
	if id=="hall-of-fame" and not store.hall_of_fame.pending(store.state):
		id="pallet-town";arrival=Vector2(store.hall_of_fame.CONTINUE["x"],store.hall_of_fame.CONTINUE["y"])
	if id=="cinnabar-lab" and map_id!="cinnabar-lab":
		if not store.fossil_rules.advance_on_entry(store,"cinnabar-lab",{"map_id":id,"x":arrival.x,"y":arrival.y}):
			status.text=store.error;_state_trace("fossil_progress_failed");return
	_build_map(id,arrival)
	ship_pass = false
	if id=="hall-of-fame":_hall_dialog("oak")
	moon_warp_latch = "%s:%d:%d" % [id,floori(arrival.x/16),floori((arrival.y-1)/16)] if id in moon_warps or id in ship_warps else ""
	if store.sevii.world.has(id):
		sevii_warp_latch="%s:%d:%d" % [id,floori(arrival.x/16),floori((arrival.y-1)/16)]
		map_title.text=store.sevii.world[id]["source"]+" · FireRed"
		status.text="E交谈/场外秘传 · F6碎岩教学 · F7攀瀑教学"
		_trace({"event":"map_changed","map":id,"position":[arrival.x,arrival.y]});return
	map_title.text = {"celadon-mart-3f":"玉虹百货 · 3F","celadon-mart-4f":"玉虹百货 · 4F","celadon-mart-5f":"玉虹百货 · 5F · 营养药","celadon-mart-roof":"玉虹百货 · 屋顶","celadon-mart-elevator":"玉虹百货 · 电梯","cinnabar-lab":"红莲岛 · 研究所入口","cinnabar-lab-fossil-room":"红莲研究所 · 化石研究室","route2-gate":"2号道路 · 东侧关卡","route2-trade-house":"2号道路 · 民居","route11":"11号道路 · Red地图","route11-gate-1f":"11号道路关卡 · 1F","digletts-cave-route11":"地鼠洞 · 南入口","digletts-cave":"地鼠洞 · 洞内","digletts-cave-route2":"地鼠洞 · 北入口","fighting-dojo":"金黄市 · 格斗道场","route5-gate":"5号道路关卡 · 茶通行","route6-gate":"6号道路关卡 · 茶通行","route8-gate":"8号道路关卡 · 茶通行", "seafoam-islands-b2f":"双子岛 · B2F","seafoam-islands-b3f":"双子岛 · B3F","seafoam-islands-b4f":"双子岛 · B4F","seafoam-islands-1f":"双子岛 · 1F","seafoam-islands-b1f":"双子岛 · B1F","route19":"19号水路 · 浅红南海岸","route20":"20号水路 · 双子岛东侧海域","route17":"17号道路 · 自行车道","route18":"18号道路 · 浅红市入口","route18-gate-1f":"18号道路关卡 · 1F","route18-gate-2f":"18号道路关卡 · 2F","route16":"16号道路 · 飞翔与自行车道","route16-gate-1f":"16号道路关卡 · 1F","route16-gate-2f":"16号道路关卡 · 2F","route16-fly-house":"16号道路 · 飞翔小屋","bike-shop":"华蓝市 · 自行车店","pokemon-fan-club":"枯叶市 · 宝可梦迷俱乐部","hall-of-fame":"宝可梦联盟 · 名人堂","league-lorelei":"宝可梦联盟 · 科拿","league-bruno":"宝可梦联盟 · 希巴","league-agatha":"宝可梦联盟 · 菊子","league-lance":"宝可梦联盟 · 渡","league-champion":"宝可梦联盟 · 冠军","indigo-lobby":"石英高原 · 联盟大厅","victory-road-2f":"冠军之路 · 2F压板与落石","victory-road-3f":"冠军之路 · 3F怪力与洞口","indigo-plateau":"石英高原 · 原出口","route22-gate":"联盟入口 · 灰色徽章检查","route23":"23号道路 · 八枚徽章与水路","victory-road-1f":"冠军之路 · 1F怪力机关","viridian-gym":"常青道馆 · Red原图与箭头地板","cinnabar-gym":"红莲道馆 · Red原迷宫 / FireRed队伍","pokemon-mansion-b1f":"宝可梦大宅 · B1F","pokemon-mansion-3f":"宝可梦大宅 · 3F","pokemon-mansion-2f":"宝可梦大宅 · 2F","pokemon-mansion-1f":"宝可梦大宅 · 1F","cinnabar-island":"红莲岛 · Red原图 / FireRed服务","cinnabar-center":"红莲岛 · 宝可梦中心","cinnabar-mart":"红莲岛 · 友好商店","route21":"21号水路 · Red原图 / FireRed队伍","wardens-house":"浅红市 · 园长家","safari-zone-west":"狩猎区 · West","safari-zone-secret-house":"狩猎区 · 秘密小屋","safari-zone-north":"狩猎区 · North","safari-zone-east":"狩猎区 · East","safari-zone-gate":"狩猎区 · 原入口","safari-zone-entry":"狩猎区 · Center","fuchsia-gym":"浅红道馆 · 原隐形墙迷宫","fuchsia-city":"浅红市 · Red原地图","fuchsia-center":"浅红市 · 宝可梦中心","fuchsia-mart":"浅红市 · 友好商店","route15":"15号道路 · 原东西道路","route15-gate-1f":"15号道路关卡 · 1F","route14":"14号道路 · 原纵向道路","route13":"13号道路 · 原围栏迷宫","route12":"12号道路 · 原南北道路","route12-gate-2f":"12号道路关卡 · 2F","route12-gate-1f":"12号道路关卡 · 1F","saffron-gym":"金黄道馆 · 原传送迷宫","silph-co-11f":"西尔佛公司 · 11层","silph-co-10f":"西尔佛公司 · 10层","silph-co-9f":"西尔佛公司 · 9层","silph-co-8f":"西尔佛公司 · 8层","silph-co-7f":"西尔佛公司 · 7层","silph-co-6f":"西尔佛公司 · 6层","silph-co-1f":"西尔佛公司 · 1层","silph-co-2f":"西尔佛公司 · 2层","silph-co-3f":"西尔佛公司 · 3层","silph-co-4f":"西尔佛公司 · 4层","silph-co-5f":"西尔佛公司 · 5层","silph-co-elevator":"西尔佛公司 · 电梯","route7-gate":"7号道路关卡 · 茶与共享通行","saffron-city":"金黄市 · Red原地图 / FireRed剧情","saffron-center":"金黄市 · 宝可梦中心","saffron-mart":"金黄市 · 友好商店","celadon-mansion-1f":"玉虹公寓 · 1F / Red原建筑","pokemon-tower-7f":"宝可梦塔 · 顶层救援","mr-fujis-house":"紫苑镇 · 富士的宝可梦之家","pokemon-tower-6f":"宝可梦塔 · 6层","pokemon-tower-5f":"宝可梦塔 · 5层净化区","pokemon-tower-4f":"宝可梦塔 · 4层","pokemon-tower-3f":"宝可梦塔 · 3层","pokemon-tower-2f":"宝可梦塔 · 2层劲敌","pokemon-tower-1f":"紫苑镇 · 宝可梦塔1层","rocket-hideout-elevator":"火箭队基地 · 电梯","rocket-hideout-b4f":"火箭队秘密基地 · 地下4层","rocket-hideout-b3f":"火箭队秘密基地 · 地下3层","rocket-hideout-b2f":"火箭队秘密基地 · 地下2层","game-corner":"玉虹游戏厅 · 海报后的秘密","rocket-hideout-b1f":"火箭队秘密基地 · 地下1层","celadon-gym":"玉虹道馆 · 莉佳 / FireRed完整队伍","celadon-city":"玉虹市 · Red地图 / FireRed规则","celadon-center":"玉虹市 · 宝可梦中心","celadon-mart-1f":"玉虹百货 · 1F服务大厅","celadon-mart-2f":"玉虹百货 · 2F训练家市场","route7":"7号道路 · Red地图 / FireRed规则","underground-route8":"地下通道 · 8号道路入口","underground-route7":"地下通道 · 7号道路入口","underground-west-east":"地下通道 · 东西通路","route8":"8号道路 · Red地图 / FireRed规则","route10-south":"10号道路南段 · 紫苑镇前","lavender-town":"紫苑镇 · Red地图 / FireRed规则","lavender-center":"紫苑镇 · 宝可梦中心","lavender-mart":"紫苑镇 · 友好商店","rock-tunnel-1f":"岩山隧道 · 一层 / U闪光照明","rock-tunnel-b1f":"岩山隧道 · 地下一层 / U闪光照明","route9":"9号道路 · Red地图 / FireRed规则","route10-north":"10号道路北段 · 岩山隧道前","vermilion-gym":"枯叶道馆 · 雷电机关","vermilion-dock":"枯叶港 · 圣安奴号码头","ssanne-captain":"圣安奴号 · 船长室","ssanne-2f":"圣安奴号 · 二层走廊","ssanne-1f-rooms":"圣安奴号 · 1F客房","ssanne-1f":"圣安奴号 · 1F大厅","underground-route5":"地下通道 · 5号道路入口","underground-route6":"地下通道 · 6号道路入口","underground-north-south":"地下通道 · 南北通路","route6":"6号道路 · Red地图 / FireRed规则","vermilion-center":"枯叶市 · 宝可梦中心","vermilion-mart":"枯叶市 · 友好商店","vermilion-city":"枯叶市 · 外部地图","pallet-town":"真新镇 · Red地图","route1":"1号道路 · Red地图 / FireRed遇敌","viridian-city":"常青市 · Red地图","viridian-center":"常青市 · 宝可梦中心","viridian-mart":"常青市 · 友好商店","route2":"2号道路 · Red地图 / FireRed遇敌","viridian-forest":"常青森林 · Red地图 / FireRed遇敌","forest-south-gate":"常青森林 · 南门","forest-north-gate":"常青森林 · 北门","route3":"3号道路 · Red地图 / FireRed规则","route5":"5号道路 · Red地图 / FireRed遇敌","cerulean-trashed-house":"华蓝市 · 被盗民宅","route25":"25号道路 · Red地图 / FireRed规则","bills-house":"海角小屋 · 正辉","route24":"24号道路 · 金珠桥 / FireRed规则","cerulean-gym":"华蓝道馆 · FireRed队伍","cerulean-city":"华蓝市 · Red地图","cerulean-center":"华蓝市 · 宝可梦中心","route4-east":"4号道路 · 月见山东侧","mtmoon-b1f":"月见山 · 地下一层","mtmoon-b2f":"月见山 · 地下二层","mtmoon-1f":"月见山 · 一层","route4-entrance":"月见山前 · 4号道路西段","mtmoon-center":"月见山前 · 宝可梦中心","pewter-city":"尼比市 · Red地图","pewter-gym":"尼比道馆 · FireRed队伍","pewter-center":"尼比市 · 宝可梦中心","route22":"22号道路 · Red地图 / FireRed劲敌"}[id]
	status.text = {"celadon-mart-3f":"E交谈 · 双倍奉还一次教学 · 四招可替换","celadon-mart-4f":"原楼梯与电梯开放 · 进化石已开放","celadon-mart-5f":"E柜员购买营养药或战斗道具 · O打开背包使用","celadon-mart-roof":"E售货机购买饮料 · 女孩一次性兑换TM · G教学","celadon-mart-elevator":"面向右上按钮 E · 1至5选择 · Esc取消", "cinnabar-lab":"东侧房间通化石研究室 · 其他房间未开放","cinnabar-lab-fossil-room":"E与研究员交谈 · 交付化石或领取复活宝可梦","route2-gate":"E与助手交谈 · 关都捕获或拥有10种领取HM05","route2-trade-house":"E交谈 · 南口返回2号道路 · 交换未开放","route11":"西返枯叶 · 东往12号道路 · 训练家与陆地遇敌已开放","route11-gate-1f":"两侧通行 · 2F及服务未开放","digletts-cave-route11":"地鼠洞南入口 · 洞内陆地遇敌已开放","digletts-cave":"南往11号道路 · 北往2号道路 · 陆地遇敌已开放","digletts-cave-route2":"北出口接2号道路东侧 · 助手在南方关卡 · HM05领取已开放","fighting-dojo":"E训练家 · 馆主胜后可选奖赏 · 南口返回金黄市","route5-gate":"静态守卫 · 返回5号道路或通金黄","route6-gate":"静态守卫 · 返回6号道路或通金黄","route8-gate":"静态守卫 · 返回8号道路或通金黄","seafoam-islands-b2f":"E怪力 · 落石通B3F · 双石后自由冲浪","seafoam-islands-b3f":"E怪力 · 未堵流强制水流 · 双石后自由冲浪","seafoam-islands-b4f":"强制水流 · B4F落石终端 · 急冻鸟暂不开放","seafoam-islands-1f":"E怪力 · 原楼梯与洞口 · 跨层落石保持","seafoam-islands-b1f":"原楼梯与洞口通B2F · 落石保持","route19":"北返浅红 · E冲浪/训练家 · 西接20号水路","route20":"东返19号水路 · E训练家 · 东侧洞口通双子岛1F","route17":"自动下滑 · B刹车 · E训练家 · 南接18号道路","route18":"E训练家 · 东接浅红市 · 西返17号道路","route18-gate-1f":"E交谈 · 两侧往返 · 楼梯通2F","route18-gate-2f":"E交谈 · 原楼梯返回1F","route16":"E居合/卡比兽/训练家 · F飞翔 · V骑车 · 南口通17号道路上段","route16-gate-1f":"自行车道需要自行车 · 北通飞翔小屋","route16-gate-2f":"E交谈 · 原楼梯返回1F","route16-fly-house":"E领取HM02 · L教学飞翔 · F使用飞翔","bike-shop":"E兑换自行车 · 需要会长兑换券","pokemon-fan-club":"E听会长故事 · 领取自行车兑换券","hall-of-fame":"E 与大木博士交谈 · 登记名人堂","league-lorelei":"E挑战科拿 · B战间用药 · 入口关闭 · 胜后北门开放","league-bruno":"第一门已通过 · 希巴挑战留第57片","league-agatha":"菊子挑战留第58片","league-lance":"渡挑战留第59片","league-champion":"E挑战冠军 · 胜后北门前往名人堂","indigo-lobby":"护士/PC/补给 · 北门挑战联盟 · 战间不会自动恢复","victory-road-2f":"E训练家/怪力 · 洞内遇敌 · 火焰鸟未开放","victory-road-3f":"E训练家/怪力 · 洞内遇敌 · 出洞前往联盟","indigo-plateau":"北入联盟大厅 · 治疗/PC/补给开放","route22-gate":"原步进徽章检查 · 北往23号道路","route23":"原逐关检查 · E冲浪 · 双洞口通冠军之路 · 北往高原","victory-road-1f":"E训练家/怪力 · 原压板开路 · 洞内遇敌","viridian-gym":"E 训练家/坂木 · 绿色徽章 · 胜后领取TM","cinnabar-gym":"E 问答/训练家 · 夏伯 · 胜后领取TM","pokemon-mansion-b1f":"E 雕像/秘密钥匙 · 原楼梯返回1F","pokemon-mansion-3f":"原跌落路径 · E 雕像/训练家","pokemon-mansion-2f":"E 雕像开关/训练家 · 原楼梯通3F","pokemon-mansion-1f":"E 雕像开关/训练家 · 楼层共享门状态","cinnabar-island":"北返21号水路 · 中心/商店开放 · 道馆需要秘密钥匙","cinnabar-center":"护士E治疗 · 右上PC · 不补球药","cinnabar-mart":"柜台E · 火红货单 · 购买与出售","route21":"北返真新镇 · 南往红莲岛 · E训练家 · 水上遇敌","wardens-house":"E交金牙/领取HM04 · J怪力教学 · E启用怪力后方向键推石","safari-zone-west":"狩猎区 · West","safari-zone-secret-house":"狩猎区 · 秘密小屋","safari-zone-north":"狩猎区 · North","safari-zone-east":"R退出 · 原图探索 · Safari捕获延期","safari-zone-gate":"E交谈 · 500入园 · 600步 · 退出归还临时球","safari-zone-entry":"R主动退出 · East开放 · 捕获延期","fuchsia-gym":"隐形墙 · E挑战阿桔 · 粉红徽章 · 胜后领取TM","fuchsia-city":"中心/商店/道馆开放 · 其他区域延期","fuchsia-center":"护士E治疗 · 右上PC","fuchsia-mart":"柜台E · 火红货单 · 购买与出售","route15":"E 训练家 · 东返14号道路 · 西往浅红市","route15-gate-1f":"原门楼往返 · 2F延期","route14":"E 训练家 · 东返13号道路 · 西往15号道路","route13":"E 训练家 · 北返12号道路 · 西往14号道路","route12":"E 训练家 · 南到13边界止 · 钓鱼延期","route12-gate-2f":"E与女孩交谈领取TM27报恩 · 楼梯返回1F","route12-gate-1f":"北返紫苑 · 南往卡比兽 · 楼梯通2F","saffron-gym":"原传送板 · E 对战 · 金色徽章","silph-co-11f":"E 对战/卡片门 · 原楼梯/传送板","silph-co-10f":"E 对战/卡片门 · 原楼梯/传送板","silph-co-9f":"E 对战/卡片门 · 原楼梯/传送板","silph-co-8f":"E 对战/卡片门 · 原楼梯/传送板","silph-co-7f":"E 对战/卡片门 · 原楼梯/传送板","silph-co-6f":"E 对战/卡片门 · 原楼梯/传送板","silph-co-1f":"原楼梯/电梯/传送板 · K 关键物品","silph-co-2f":"E 研究员/火箭队/卡片门","silph-co-3f":"E 对战/卡片门 · 原传送板","silph-co-4f":"E 对战/卡片门 · 原楼梯/传送板","silph-co-5f":"原卡片钥匙在南侧 · E 拾取/开门","silph-co-elevator":"面向右上按钮 E · 选择已开放楼层","route7-gate":"向东通金黄 · 守卫踏步检查茶 · 无需确认","saffron-city":"西返7号道路 · 中心/商店开放 · 公司1–11层开放 · 道馆后续切片","saffron-center":"护士E治疗 · 右上PC · 不补球药","saffron-mart":"柜台E · 火红金黄货单 · 购买与出售","celadon-mansion-1f":"E 与老奶奶交谈 · K 关键物品 · 楼上未开放","pokemon-tower-7f":"E 火箭队与富士老人 · K 关键物品","mr-fujis-house":"另与富士老人交谈领取宝可梦笛 · K 关键物品","pokemon-tower-6f":"母亲幽灵安息后可登顶 · E 灵媒对战","pokemon-tower-5f":"原净化格恢复HP/PP · E 灵媒对战","pokemon-tower-4f":"原楼梯 · E 灵媒对战 · 检视镜辨识","pokemon-tower-3f":"检视镜辨认幽灵 · E 灵媒对战","pokemon-tower-2f":"原楼梯通往3层","pokemon-tower-1f":"E 与悼念者交谈 · 原楼梯通往二层","rocket-hideout-elevator":"面向左上按钮 E · 原楼层 B1 / B2 / B4","rocket-hideout-b4f":"E 坂木与检视镜 · 原双守卫门锁 · 电梯 B1/B2/B4","rocket-hideout-b3f":"箭头地板强制移动 · E 训练家 · B4/钥匙/电梯延期","rocket-hideout-b2f":"箭头地板强制移动 · E 训练家 · B3已开放/电梯延期","game-corner":"E 海报与守卫 · 代币和小游戏延期","rocket-hideout-b1f":"E 训练家 · 原隔门击败守卫后开启 · B2已开放 / 电梯待接入","celadon-gym":"原树E居合斩 · 面向训练家E · 胜后领取TM","celadon-city":"东返7号道路 · 公寓1F/中心/百货全层/道馆开放","celadon-center":"护士E治疗 · 右上PC · 不补球药","celadon-mart-1f":"原楼梯与电梯通1至5F · 屋顶从5F楼梯前往","celadon-mart-2f":"道具与TM柜台开放 · 购买与出售","route7":"东经茶关卡到金黄 · 西返玉虹 · 地下通道返8号道路","underground-route8":"原楼梯通玉虹方向 · 南口返8号道路","underground-route7":"原楼梯通紫苑方向 · 南口入7号道路","underground-west-east":"西往7号道路 · 东返8号道路","route8":"东返紫苑镇 · 草区需居合斩 · 金黄关卡前置未满足", "route10-south":"北洞口返岩山隧道 · 南往紫苑镇 · E 对战","lavender-town":"西往8号道路 · 中心商店开放 · 宝可梦塔1/2F开放 · 富士/改名延期","lavender-center":"护士 E 治疗 · 右上 PC · 不补球药","lavender-mart":"柜台右侧朝左 E · 火红货单与出售","rock-tunnel-1f":"原楼梯往返 · 地面遇敌 · E 训练家对战 · U使用闪光照明","rock-tunnel-b1f":"原楼梯往返 · 地面遇敌 · E 训练家对战 · U使用闪光照明","route9":"原树 E 居合斩 · 面向训练家 E · 东往10号道路","route10-north":"北口入岩山隧道 · 中心内部延期 · 西返9号道路","vermilion-gym":"E 调查垃圾桶或对战 · 南口返枯叶市","vermilion-dock":"南下登船 · 北返枯叶市","ssanne-captain":"E 船长交谈 · M 秘传教学 · 南口返二层","ssanne-2f":"西侧楼梯返1F · 东北船长室 · M 秘传教学","ssanne-1f-rooms":"E 交谈或对战 · 北门返大厅","ssanne-1f":"北出口离船 · 六间1F客房开放","underground-route5":"原楼梯南下6号道路 · 交换未开放","underground-route6":"原楼梯北返5号道路 · 南往枯叶市","underground-north-south":"北往5号道路 · 南往6号道路","route6":"E 面向训练家 · 南往枯叶市 · 北入口返地下通道","vermilion-center":"护士 E 治疗 · 右上PC · 不补球药","vermilion-mart":"柜台右侧朝左 E · 火红货单与出售","vermilion-city":"M 秘传教学 · 面向小树 E · 道馆垃圾桶机关开放","pallet-town":"向北通往1号道路 · 房门关闭","route1":"北往常青市 · 南往真新镇","viridian-city":"中心与商店开放 · 道馆需要其余七枚徽章","viridian-center":"柜台前朝上按 E 与护士交谈","viridian-mart":"柜台右侧朝左按 E · 球200 / 药300","route2":"北往尼比 · 南返常青 · 地鼠洞开放 · E居合斩","viridian-forest":"草丛遇敌 · 面向捕虫少年按 E 对战","forest-south-gate":"北入森林 · 南返2号道路","forest-north-gate":"南入森林 · 北往2号道路北段","route3":"草丛遇敌 · 面向训练家按 E · 北往月见山","route5":"北返华蓝市 · 地下通道通6号道路 · 培育屋与关卡未开放","cerulean-trashed-house":"原后墙破洞通屋后 · E 与住户交谈","route25":"E 面向训练家 · 西返金珠桥 · 东往正辉小屋","bills-house":"E 交谈或操作电脑 · 细胞分离与船票","route24":"E 挑战桥上五人 · 东往25号道路与正辉小屋","cerulean-gym":"面向训练家 E · 小霞胜利获得蓝色徽章","cerulean-city":"中心、道馆与北口金珠桥开放","cerulean-center":"柜台前朝上 E 治疗 · 右上 PC","route4-east":"东往华蓝市 · 西侧原单向跳台","mtmoon-b1f":"原楼梯往返 · 东口通往4号道路","mtmoon-b2f":"E 对战 / 化石二选一 · B1F东口通4号道路","mtmoon-1f":"普通地面遇敌 · 地下通道开放","route4-entrance":"中心与月见山一层开放","mtmoon-center":"护士 E 治疗 · 右上 PC 可寄存","pewter-city":"东往3号道路 · 道馆与中心开放","pewter-gym":"面向训练家按 E · 小刚胜利获得灰色徽章","pewter-center":"柜台前朝上按 E 与护士交谈","route22":"向劲敌按 E 对战 · 东返常青市 · 北门通23号道路"}[id]
	_trace({"event":"map_changed","map":id,"position":[arrival.x,arrival.y]})

func _restore_location() -> void:
	cut_removed.clear()
	store.gym_rules.enter(store.state)
	var location: Variant = store.state.get("location",{})
	if not location is Dictionary:return
	var id: String = location.get("map_id","pallet-town") if location.get("map_id","") is String else "pallet-town"
	flash_active = bool(store.state.get("flash_active",false)) and id in ["rock-tunnel-1f","rock-tunnel-b1f"]
	if id!="route12-gate-2f" and id not in store.sevii.world and id not in store.travel.NEW_MAPS and id not in ["league-lorelei","league-bruno","league-agatha","league-lance","league-champion","hall-of-fame","indigo-lobby","victory-road-2f","victory-road-3f","indigo-plateau","route22-gate","route23","victory-road-1f","viridian-gym","cinnabar-gym","pokemon-mansion-b1f","pokemon-mansion-3f","pokemon-mansion-2f","pokemon-mansion-1f","cinnabar-island","cinnabar-center","cinnabar-mart","route21","wardens-house","safari-zone-west","safari-zone-secret-house","safari-zone-north","safari-zone-east","safari-zone-gate","safari-zone-entry","fuchsia-gym","fuchsia-city","fuchsia-center","fuchsia-mart","route15","route15-gate-1f","route14","route13","route12","route12-gate-1f","saffron-gym","silph-co-11f","silph-co-10f","silph-co-9f","silph-co-8f","silph-co-7f","silph-co-6f","silph-co-4f","silph-co-5f","silph-co-1f","silph-co-2f","silph-co-3f","silph-co-elevator","route7-gate","saffron-city","saffron-center","saffron-mart","celadon-mansion-1f","pokemon-tower-7f","mr-fujis-house","pokemon-tower-6f","pokemon-tower-5f","pokemon-tower-4f","pokemon-tower-3f","pokemon-tower-2f","pokemon-tower-1f","rocket-hideout-elevator","rocket-hideout-b4f","rocket-hideout-b3f","rocket-hideout-b2f","game-corner","rocket-hideout-b1f","celadon-gym","celadon-city","celadon-center","celadon-mart-1f","celadon-mart-2f","route7","underground-route8","underground-route7","underground-west-east","route8","route10-south","lavender-town","lavender-center","lavender-mart","rock-tunnel-1f","rock-tunnel-b1f","route9","route10-north","pallet-town","route1","viridian-city","viridian-center","viridian-mart","route22","route2","viridian-forest","forest-south-gate","forest-north-gate","pewter-city","pewter-gym","pewter-center","route3","route4-entrance","mtmoon-center","mtmoon-1f","mtmoon-b1f","mtmoon-b2f","route4-east","cerulean-city","cerulean-center","cerulean-gym","route24","route25","bills-house","route5","cerulean-trashed-house","underground-route5","underground-route6","underground-north-south","route6","vermilion-city","vermilion-center","vermilion-mart","vermilion-dock","ssanne-1f","ssanne-1f-rooms","ssanne-2f","ssanne-captain","vermilion-gym"]:id = "pallet-town"
	if id in ["vermilion-dock","ssanne-1f","ssanne-1f-rooms","ssanne-2f","ssanne-captain"] and not _has_ship_ticket():
		_change_map("vermilion-city",Vector2(296,473));return
	if id=="ssanne-captain" and not store.state.get("trainers",{}).get("ssanne_rival",false):
		_change_map("ssanne-2f",Vector2(600,153));return
	if not store.league.accessible(store.state,id):_change_map("indigo-lobby",Vector2(120,121));return
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/%s.json" % id))
	store.league.apply(id,data,store.state)
	if id=="vermilion-gym" and store.gym_rules.opened(store.state):
		for patch in store.gym_rules.data["door"]["openCells"]:data["solid"][patch["cell"][1]][patch["cell"][0]] = patch["solid"]
	if id in ["rocket-hideout-elevator","rocket-hideout-b4f","rocket-hideout-b1f","rocket-hideout-b2f","rocket-hideout-b3f"] and not store.rocket_rules.opened(store.state):
		_change_map("game-corner",Vector2(248,265));return
	if id in ["game-corner","rocket-hideout-b1f"]:store.rocket_rules.apply(id,data,store.state)
	store.post_b3.apply(id,data,store.state)
	store.tower_story.apply(id,data,store.state,tower_actors)
	store.ground_items.apply(id,data,store.state)
	store.saffron_rules.apply(id,data,store.state,saffron_actors)
	store.silph_story.apply(id,data,store.state,silph_actors)
	viridian_gym.geometry(id,data)
	if id=="route22":data["solid"][5][8]=0
	if id=="route22" and store.state.get("trainers",{}).get("route22_late",false):data["solid"][5][25]=0
	store.pokemon_mansion.apply(id,data,store.state)
	if id=="cinnabar-gym":store.cinnabar_gym.geometry(data,store.state)
	_apply_snorlax(id,data)
	store.safari_rewards.apply(id,data,store.state)
	store.surf.apply(id,data,store.state)
	store.sevii.apply(id,data,store.state)
	for actor in o05_actors:
		if actor["map"]==id:data["solid"][actor["cell"][1]][actor["cell"][0]]=1
	store.seafoam.source_blockers(id,data,store.state,o06_actors+o07_actors)
	if id=="victory-road-1f" and store.state.get("victory_road_1f_open",false):
		for patch in boulders.puzzle["openCells"]:data["solid"][patch["cell"][1]][patch["cell"][0]]=patch["solid"]
	victory_road.apply(id,data,store.state,league_actors)
	if id=="route7-gate" and not store.saffron_rules.opened(store.state):
		location = {"map_id":id,"x":24,"y":73}
	if store.safari.is_zone(id) and not store.safari.active(store.state):_change_map("safari-zone-gate",Vector2(56,73));return
	var safe: Array = data.get("safe",[88,108] if id=="pallet-town" else [168,553])
	var arrival := Vector2(safe[0],safe[1])
	var x: Variant = location.get("x")
	var y: Variant = location.get("y")
	if (x is float or x is int) and (y is float or y is int) and is_finite(float(x)) and is_finite(float(y)):
		var cell := Vector2i(floori(float(x)/16),floori((float(y)-1)/16))
		if cell.x>=0 and cell.x<int(data["width"]) and cell.y>=0 and cell.y<int(data["height"]) and int(data["solid"][cell.y][cell.x])==0:
			# Check the full 14x8 feet collision, not just the center cell.
			var clear: bool = true
			for px in [float(x)-7,float(x)+6.9]:
				for py in [float(y)-6,float(y)+1.9]:
					var cx: int = floori(px/16)
					var cy: int = floori(py/16)
					if cx<0 or cy<0 or cx>=int(data["width"]) or cy>=int(data["height"]) or int(data["solid"][cy][cx])!=0:clear = false
			if clear:arrival = Vector2(float(x),float(y))
	_change_map(id,arrival)

func _hall_dialog(phase: String) -> void:
	# FireRed PokemonLeague_HallOfFame_EnterRoom: Oak congratulation, then record. Walk-in, record field effect and credits are not animated.
	hall_phase = phase
	hall_ready_at = Time.get_ticks_msec()+250
	if is_instance_valid(modal):modal.queue_free()
	modal = Control.new()
	modal.theme = UI.setup_theme()
	overlay.get_parent().add_child(modal)
	player.active = false
	if phase=="oak":
		UI.panel(modal,Rect2(0,448,960,192))
		UI.label(modal,"大木博士 · FireRed原文中文译意",Rect2(30,452,850,24),16)
		UI.label(modal,"咳咳！恭喜你！这里是宝可梦名人堂。\n宝可梦联盟冠军的事迹和宝可梦都会记录在这里。\n你和你的宝可梦都是名人堂成员了！  E 继续 · Esc 稍后",Rect2(30,481,900,150),21)
	else:
		UI.panel(modal,Rect2(70,90,820,500))
		var count:int=store.hall_of_fame.teams(store.state).size()
		UI.label(modal,"名人堂 · 第%d次登记" % (count if phase=="done" else count+1),Rect2(100,100,760,40),26)
		var team:Array=store.hall_of_fame.teams(store.state)[-1] if phase=="done" else store.hall_of_fame.snapshot(store.state)
		for i in team.size():
			var mon:Dictionary=team[i]
			var icon := TextureRect.new()
			icon.texture = load("res://assets/pokemon/%s-icon.png" % mon["species_id"])
			icon.position = Vector2(110+(i%2)*390,150+(i/2)*110)
			icon.size = Vector2(64,64)
			icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			modal.add_child(icon)
			UI.label(modal,"#%03d %s  Lv%d\nID %s" % [int(store.species[mon["species_id"]]["num"]),store.species[mon["species_id"]]["name"],int(mon["level"]),str(mon["individual_id"]).substr(0,12)],Rect2(185+(i%2)*390,152+(i/2)*110,300,64),19)
		var tail:String={"record":"E 登记并保存（全队恢复，之后在真新镇继续）· Esc 稍后","done":"已登记并保存 · 首次通关 · E 返回真新镇","failed":"保存失败，名人堂未登记：%s\nE 重试 · Esc 稍后" % status.text}[phase]
		UI.label(modal,tail,Rect2(100,490,760,90),19)
	_trace({"event":"hall_of_fame_dialog","phase":phase})

func _hall_register() -> void:
	var failure:String=store.hall_of_fame.register(store)
	if failure!="":
		status.text=failure;_state_trace("hall_of_fame_failed");_hall_dialog("failed");return
	_state_trace("hall_of_fame_registered")
	_hall_dialog("done")

func _nurse_dialog(phase: String) -> void:
	nurse_phase = phase
	nurse_ready_at = Time.get_ticks_msec()+250
	if is_instance_valid(modal):modal.queue_free()
	modal = Control.new()
	modal.theme = UI.setup_theme()
	overlay.get_parent().add_child(modal)
	player.active = false
	UI.panel(modal,Rect2(0,448,960,192))
	UI.label(modal,"护士 · 原文中文译意",Rect2(30,452,850,24),16)
	var text: String = {"welcome":"欢迎来到宝可梦中心！\n我们能让你的宝可梦恢复健康。\nE / Enter 继续", "choice":"需要为你的宝可梦治疗吗？", "healed":"谢谢！你的宝可梦已经恢复了健康！\n希望还能再见到你！\nE / Enter 返回", "farewell":"希望还能再见到你！\nE / Enter 返回"}[phase]
	UI.label(modal,text,Rect2(30,483,890,140),22)
	if phase=="choice":
		UI.button(modal,"1 治疗",Rect2(520,505,195,65),_nurse_heal)
		UI.button(modal,"2 取消",Rect2(735,505,195,65),func():_nurse_dialog("farewell"))
	_trace({"event":"nurse_dialog","phase":phase})

func _nurse_heal() -> void:
	if nurse_phase!="choice" or Time.get_ticks_msec()<nurse_ready_at:return
	store.heal_party()
	_save()
	_nurse_dialog("healed")
	_state_trace("center_healed")

func _shop_dialog(phase: String) -> void:
	shop_phase = phase
	shop_ready_at = Time.get_ticks_msec()+250
	if is_instance_valid(modal):modal.queue_free()
	modal = Control.new()
	modal.theme = UI.setup_theme()
	overlay.get_parent().add_child(modal)
	player.active = false
	UI.panel(modal,Rect2(80,380,800,260))
	UI.label(modal,("玉虹百货4F · 余额 %d · O进化石袋" % int(store.state["money"])) if map_id=="celadon-mart-4f" else ("玉虹百货5F · 余额 %d" % int(store.state["money"])) if map_id=="celadon-mart-5f" else (("玉虹百货2F · 余额 %d · 球 %d / 药 %d" if map_id=="celadon-mart-2f" else "友好商店 · 余额 %d · 球 %d / 药 %d") % [int(store.state["money"]),int(store.state["balls"]),int(store.state["potions"])]),Rect2(105,393,750,36),23)
	var item: Dictionary = store.SHOP[shop_item]
	if phase=="list":
		UI.button(modal,"出售道具",Rect2(110,320,735,48),_shop_sell_menu)
		var scroll:=ScrollContainer.new();scroll.position=Vector2(100,435);scroll.size=Vector2(755,190);scroll.follow_focus=true;modal.add_child(scroll)
		var rows:=VBoxContainer.new();scroll.add_child(rows)
		for id in _shop_products():
			var button:=UI.button(rows,"%s  %d"%[store.SHOP[id]["name"],store.SHOP[id]["price"]],Rect2(0,0,710,44),_shop_select.bind(id));button.custom_minimum_size=Vector2(710,44)
			button.focus_mode=Control.FOCUS_ALL
			button.add_theme_color_override("font_focus_color",Color("303840"))
			if id==_shop_products()[0]:button.call_deferred("grab_focus")
	elif phase=="sell":
		var scroll:=ScrollContainer.new();scroll.position=Vector2(100,435);scroll.size=Vector2(755,190);scroll.follow_focus=true;modal.add_child(scroll)
		var rows:=VBoxContainer.new();scroll.add_child(rows)
		if int(store.state.get("nugget_bridge",{}).get("items",{}).get("nugget",0))>0:
			var bridge:=UI.button(rows,"金珠桥金珠 · 出售1个 5000",Rect2(0,0,710,44),_shop_sell.bind("bridge_nugget"));bridge.custom_minimum_size=Vector2(710,44)
		for id in store.SHOP:
			if store.inventory.quantity(store.state,id)<=0 or int(store.SHOP[id]["price"])<=0:continue
			var button:=UI.button(rows,"%s ×%d · 出售1个 %d"%[store.SHOP[id]["name"],store.inventory.quantity(store.state,id),int(store.SHOP[id]["price"])/2],Rect2(0,0,710,44),_shop_sell.bind(id));button.custom_minimum_size=Vector2(710,44)
	elif phase=="quantity":
		UI.label(modal,"%s × %d ＝ %d\n← / → 数量 · ↑ / ↓ 每次10 · 单次最多99" % [item["name"],shop_quantity,int(item["price"])*shop_quantity],Rect2(105,437,735,75),22)
		UI.button(modal,"−",Rect2(105,535,100,55),_shop_adjust.bind(-1))
		UI.button(modal,"+",Rect2(215,535,100,55),_shop_adjust.bind(1))
		UI.button(modal,"Enter 确认",Rect2(335,535,250,55),_shop_confirm)
		UI.button(modal,"Esc 返回",Rect2(605,535,245,55),_shop_back)
	elif phase=="confirm":
		UI.label(modal,"购买 %s × %d，总价 %d。确定吗？" % [item["name"],shop_quantity,int(item["price"])*shop_quantity],Rect2(105,437,735,60),22)
		UI.button(modal,"1 / Enter 购买",Rect2(105,520,350,60),_shop_buy)
		UI.button(modal,"2 / Esc 取消",Rect2(485,520,365,60),_shop_back)
	else:
		UI.label(modal,shop_message,Rect2(105,437,735,100),21)
		UI.button(modal,"Enter 返回商品 · Esc 离开",Rect2(105,550,745,55),_shop_back)
	_trace({"event":"shop_dialog","phase":phase,"quantity":shop_quantity,"item":shop_item,"message":shop_message})

func _shop_input(key: int) -> void:
	if Time.get_ticks_msec()<shop_ready_at:return
	if key in [KEY_ESCAPE,KEY_B]:
		if shop_phase in ["list","result"]:_shop_close()
		else:_shop_back()
	elif shop_phase=="list":
		var products:Array=_shop_products()
		if key==KEY_S:_shop_sell_menu()
		elif key>=KEY_1 and key<=KEY_9 and key-KEY_1<products.size():_shop_select(products[key-KEY_1])
	elif shop_phase=="quantity":
		if key in [KEY_LEFT,KEY_DOWN,KEY_RIGHT,KEY_UP]:_shop_adjust({KEY_LEFT:-1,KEY_DOWN:-10,KEY_RIGHT:1,KEY_UP:10}[key])
		elif key in [KEY_ENTER,KEY_E,KEY_SPACE]:_shop_confirm()
	elif shop_phase=="confirm":
		if key in [KEY_1,KEY_ENTER,KEY_E,KEY_SPACE]:_shop_buy()
		elif key==KEY_2:_shop_back()
	elif shop_phase=="result" and key in [KEY_ENTER,KEY_E,KEY_SPACE]:_shop_back()

func _shop_select(item: String) -> void:
	if shop_phase!="list" or Time.get_ticks_msec()<shop_ready_at or item not in _shop_products():return
	shop_item = item
	shop_quantity = 1
	_shop_dialog("quantity")

func _shop_adjust(delta: int) -> void:
	if shop_phase!="quantity" or Time.get_ticks_msec()<shop_ready_at:return
	shop_quantity = clampi(shop_quantity+delta,1,store.PURCHASE_LIMIT)
	_shop_dialog("quantity")

func _shop_confirm() -> void:
	if shop_phase=="quantity" and Time.get_ticks_msec()>=shop_ready_at:_shop_dialog("confirm")

func _shop_back() -> void:
	if Time.get_ticks_msec()>=shop_ready_at:_shop_dialog("list")

func _shop_close() -> void:
	if Time.get_ticks_msec()>=shop_ready_at:_close_modal()

func _shop_buy() -> void:
	if shop_phase!="confirm" or Time.get_ticks_msec()<shop_ready_at:return
	shop_phase = "busy"
	var before:Dictionary=store.state.duplicate(true)
	store.state["location"] = {"map_id":map_id,"x":player.position.x,"y":player.position.y}
	var failure: String = store.purchase(shop_item,shop_quantity)
	if failure!="":store.state=before
	shop_message = failure if failure!="" else "谢谢惠顾！已收到 %s × %d，扣款 %d。\n购买进度已保存。" % [store.SHOP[shop_item]["name"],shop_quantity,int(store.SHOP[shop_item]["price"])*shop_quantity]
	_shop_dialog("result")
	_state_trace("shop_rejected" if failure!="" else "shop_purchased")

func _add_story_actor(parent: Node,key: String,cell: Vector2i) -> void:
	var npc := Sprite2D.new();npc.texture = load("res://assets/cerulean-thief/%s.png" % key)
	npc.position = Vector2(cell.x*16+8,cell.y*16+8);parent.add_child(npc)

func _thief_interact(cell: Vector2i) -> bool:
	if map_id=="cerulean-city":
		var guard := Vector2i(28 if store.thief_rules.released(store.state) else 27,12)
		if absi(cell.x-guard.x)+absi(cell.y-guard.y)==1 and player.facing.dot(Vector2(guard-cell))>0.5:
			status.text = "警员：这里遭到了火箭队的盗窃。";_trace({"event":"thief_guard","released":store.thief_rules.released(store.state)});return true
		var rocket := Vector2i(30,8)
		if not store.state.has("stolen_tm") and absi(cell.x-30)+absi(cell.y-8)==1 and player.facing.dot(Vector2(rocket-cell))>0.5:
			if store.state.get("trainers",{}).get("cerulean_rocket_thief",false):_tm_dialog()
			else:_forest_trainer_interact(trainer_rules.thief[0])
			return true
	else:
		for target in [Vector2i(2,1),Vector2i(5,6)]:
			if absi(cell.x-target.x)+absi(cell.y-target.y)==1 and player.facing.dot(Vector2(target-cell))>0.5:
				status.text = "住户：失去的就失去了，我决定让地鼠自己学会挖洞。" if store.state.has("stolen_tm") else "住户：火箭队偷走了教宝可梦挖洞的招式学习器！"
				_trace({"event":"trashed_house_resident","tm28":store.state.has("stolen_tm")});return true
	return false

func _tm_dialog() -> void:
	tm_pending = true;trainer_ready_at = Time.get_ticks_msec()+250;_new_modal("收回被盗物品")
	UI.label(modal,"火箭队：好吧，我把偷来的招式学习器还给你！\n领取 TM28 挖洞 ×1（本轮仅持有，不可使用）。",Rect2(100,200,755,120),22)
	UI.label(modal,"E / Enter 领取 · Esc 暂缓，之后仍可领取",Rect2(100,365,755,45),20)
	_trace({"event":"tm28_dialog"})

func _tm_take() -> void:
	tm_pending = false;_close_modal()
	var before: Dictionary = store.state.duplicate(true)
	store.state["location"] = {"map_id":map_id,"x":player.position.x,"y":player.position.y}
	var failure: String = store.thief_rules.award(store)
	if failure!="":store.state = before;status.text = failure;_state_trace("tm28_failed");return
	_change_map(map_id,player.position);status.text = "收回 TM28 挖洞 ×1！火箭队离开了；G背包可以教学。";_state_trace("tm28_received")

func _bill_dialog(action: String,text: String) -> void:
	bill_pending = action;trainer_ready_at = Time.get_ticks_msec()+250
	_new_modal("正辉 · 原文译意")
	UI.label(modal,text,Rect2(100,185,755,150),22)
	UI.label(modal,"E / Enter 继续 · Esc 暂时取消"+(" · 2 拒绝" if action=="help" else ""),Rect2(100,375,755,55),19)
	_trace({"event":"bill_dialog","action":action,"stage":store.bill_rules.stage(store.state)})

func _bill_interact(cell: Vector2i) -> bool:
	var stage: String = store.bill_rules.stage(store.state)
	if cell==Vector2i(1,5) and player.facing.y<0:
		if stage=="machine":_bill_dialog("computer","启动传送器的细胞分离系统！")
		else:_bill_dialog("info","屏幕显示着传送器。" if stage!="visited" else "正辉：我的珍稀宝可梦资料就在这台电脑里。\n本轮未接资料查看。")
		return true
	var actor: Dictionary = store.bill_rules.actor(store.state)
	if actor.is_empty():return false
	var target := Vector2i(int(actor["cell"][0]),int(actor["cell"][1]))
	if absi(cell.x-target.x)+absi(cell.y-target.y)!=1 or player.facing.dot(Vector2(target-cell))<=0.5:return false
	if stage=="waiting":_bill_dialog("help","嗨！我不是宝可梦，我是正辉！\n实验失误让我和宝可梦合体了，能帮帮我吗？")
	elif stage=="restored":_bill_dialog("ticket","谢谢你，伙伴！我得好好感谢你。\n这张圣安奴号船票送给你吧！")
	else:_bill_dialog("info","圣安奴号停泊在枯叶市，乘客都是训练家。\n我不喜欢正式聚会，你代替我去吧！" if stage=="ticket" else "看看我电脑里收藏的珍稀宝可梦吧！")
	return true

func _bill_confirm() -> void:
	var action: String = bill_pending;bill_pending = "";_close_modal()
	if action=="info":return
	var failure: String = store.bill_rules.advance(store,action)
	if failure!="":status.text = failure;_state_trace("bill_failed");return
	_change_map(map_id,player.position)
	status.text = {"wardens-house":"E交金牙/领取HM04 · J怪力教学 · E启用怪力后方向键推石","pokemon-tower-7f":"E 火箭队与富士老人 · K 关键物品","mr-fujis-house":"另与富士老人交谈领取宝可梦笛 · K 关键物品","pokemon-tower-6f":"母亲幽灵安息后可登顶 · E 灵媒对战","pokemon-tower-5f":"原净化格恢复HP/PP · E 灵媒对战","pokemon-tower-4f":"原楼梯 · E 灵媒对战 · 检视镜辨识","pokemon-tower-3f":"检视镜辨认幽灵 · E 灵媒对战","pokemon-tower-2f":"原楼梯通往3层","pokemon-tower-1f":"E 与悼念者交谈 · 原楼梯通往二层","rocket-hideout-elevator":"面向左上按钮 E · 原楼层 B1 / B2 / B4","rocket-hideout-b4f":"E 坂木与检视镜 · 原双守卫门锁 · 电梯 B1/B2/B4","help":"正辉进入了传送器。请到左边电脑前朝上按 E。","computer":"细胞分离完成！正辉恢复人形，请与他交谈。","ticket":"获得圣安奴号船票 ×1！已保存，不能重复领取。"}[action]
	_state_trace("bill_"+action)

func _bridge_take() -> void:
	var failure: String = store.bridge_rules.award(store)
	bridge_pending = false
	_close_modal()
	if failure!="":
		status.text = failure;_state_trace("bridge_reward_failed");return
	_state_trace("bridge_nugget_received")
	_forest_trainer_interact(trainer_rules.definition("route24_rocket"))

var late_rival_latch: bool = false
func _late_rival_ready() -> bool:
	return store.state.get("badges",{}).get("earth",false) and not store.state.get("trainers",{}).get("route22_late",false)
func _late_rival_trigger(cell: Vector2i) -> bool:
	if map_id!="route22":late_rival_latch=false;return false
	if cell not in [Vector2i(29,4),Vector2i(29,5)]:late_rival_latch=false;return false
	if not _late_rival_ready() or late_rival_latch:return false
	late_rival_latch=true;player.velocity=Vector2.ZERO
	_forest_trainer_interact(trainer_rules.definition("route22_late"))
	_trace({"event":"late_rival_trigger","cell":[cell.x,cell.y]});return true
func _rival_interact() -> void:
	if store.state.get("badges",{}).get("earth",false):
		if _late_rival_ready():_forest_trainer_interact(trainer_rules.definition("route22_late"))
		else:status.text="劲敌已先行前往宝可梦联盟。23号道路尚未开放。"
	else:_start_trainer("route22_early")

func _forest_trainer_interact(entry: Dictionary) -> void:
	if entry["id"].begins_with("league_") and not store.league.can_challenge(store.state,entry["id"]):status.text="当前阶段不能挑战或重复领取奖金。";_state_trace("league_challenge_rejected");return
	if entry["id"]=="route24_rocket":
		if not store.bridge_rules.ready(store.state):
			status.text = "先打败桥上的五名训练家。";return
		if not store.state.has("nugget_bridge"):
			bridge_pending = true;trainer_ready_at = Time.get_ticks_msec()+250
			_new_modal("金珠桥 · 通关奖品")
			UI.label(modal,"恭喜！你打败了五名训练家！\n领取金珠 ×1（物品，不直接兑换金钱）。",Rect2(100,200,755,110),23)
			UI.label(modal,"E / Enter 领取 · Esc 暂不领取",Rect2(100,360,755,40),20)
			_trace({"event":"bridge_reward_dialog"});return
	if store.state.get("trainers",{}).get(entry["id"],false):
		if store.gym_rewards.data.has(entry["id"]) and not store.gym_rewards.claimed(store.state,entry["id"]):
			var failure:String=store.gym_rewards.claim(store,entry["id"])
			status.text=failure if failure!="" else "补领%s ×1，已保存。%s" % [store.gym_rewards.data[entry["id"]]["name"],store.gym_rewards.description(store.gym_rewards.data[entry["id"]]["item"],tm_rules)]
			_state_trace("gym_tm_claim_failed" if failure!="" else "gym_tm_claimed");return
		status.text = entry["name"]+"："+entry["after"]+"（已击败）"
		_trace({"event":"trainer_already_defeated","id":entry["id"],"money":store.state["money"]})
		return
	pending_trainer = entry["id"]
	trainer_ready_at = Time.get_ticks_msec()+250
	_new_modal(entry["name"]+" · 原文译意")
	var intro_label: Label = UI.label(modal,entry["intro"],Rect2(100,200,755,100),23)
	if entry["id"] in ["route22_late","viridian_giovanni"]:intro_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UI.label(modal,"E / Enter 开始对战 · Esc 取消",Rect2(100,360,755,40),20)
	_trace({"event":"trainer_dialog","id":entry["id"]})

func _cinnabar_gym_interact(cell: Vector2i) -> bool:
	for entry in store.cinnabar_gym.all_trainers():
		var target:=Vector2i(entry["cell"][0],entry["cell"][1]);var delta:=target-cell
		if absi(delta.x)+absi(delta.y)==1 and Vector2(delta).normalized().dot(player.facing)>0.9:_forest_trainer_interact(entry);return true
	for hidden in store.cinnabar_gym.quiz["redHiddenEvents"]:
		if hidden["routine"]!="PrintCinnabarQuiz":continue
		var target:=Vector2i(hidden["x"],hidden["y"]);var delta:=target-cell
		if absi(delta.x)+absi(delta.y)!=1 or Vector2(delta).normalized().dot(player.facing)<0.9:continue
		var index:int=int(hidden["argValue"])&15
		if store.cinnabar_gym.gates(store.state)[index-1]:status.text="这道题已经答过，门已打开。";return true
		cinnabar_quiz_pending=index;trainer_ready_at=Time.get_ticks_msec()+250;_new_modal("宝可梦知识问答")
		UI.label(modal,store.cinnabar_gym.question(index)["question"]+"\n1 / E 是 · 2 否 · Esc 取消",Rect2(100,190,755,150),23);_state_trace("cinnabar_quiz_prompt");return true
	if cell==Vector2i(16,14) and player.facing.y<0:
		status.text="你击败了火焰专家！" if store.cinnabar_gym.badge_state(store.state) else "夏伯擅长火属性宝可梦，水属性很有效。";return true
	return false

func _start_trainer(id: String) -> void:
	if id.begins_with("league_") and (map_id!={"league_lorelei":"league-lorelei","league_bruno":"league-bruno","league_agatha":"league-agatha","league_lance":"league-lance","league_champion":"league-champion"}.get(id,"") or not store.league.can_challenge(store.state,id)):status.text="当前联盟阶段不能挑战。";return
	if id=="route22_late" and not _late_rival_ready():return
	if in_battle or is_instance_valid(modal) or is_instance_valid(pc):return
	if store.state.get("trainers",{}).get(id,false):
		status.text = "训练家已击败 · 本场奖金已领取，不能重复挑战。"
		_trace({"event":"rival_already_defeated" if id=="route22_early" else "trainer_already_defeated","id":id,"money":store.state["money"]})
		return
	if int(store.state["team"][int(store.state["lead"])]["hp"])<=0:
		status.text = "首发倒下，请先换首发或到中心治疗。"
		return
	var doubles:bool=trainer_rules.definition(id).get("doubleBattle",false)
	if doubles and store.state["team"].filter(func(p):return int(p["hp"])>0).size()<2:
		status.text="双打需要至少两只未倒下的伙伴。";return
	if not _save():return
	in_battle = true
	player.active = false
	overlay.hide()
	battle = preload("res://scripts/double_battle.gd").new() if doubles else BATTLE_SCENE.instantiate()
	battle.theme = UI.setup_theme()
	battle.store = store
	battle.item_terrain=_item_battle_terrain()
	if map_id in ["route19","route20"]:battle.field_terrain="Water" if store.state.get("surfing",false) else "Ground"
	if map_id in ["rock-tunnel-1f","rock-tunnel-b1f","mtmoon-1f","mtmoon-b1f","mtmoon-b2f"]:battle.arena_path = "res://assets/mtmoon-1f/cave-arena.png"
	battle.north_rules = id.begins_with("sevii_") or id.begins_with("o05_") or id.begins_with("league_") or id.begins_with("viridian_") or id.begins_with("cinnabar_") or id.begins_with("mansion_") or id.begins_with("fuchsia") or id.begins_with("route15_") or id.begins_with("route14_") or id.begins_with("route13_") or id.begins_with("route12_") or id.begins_with("saffron") or id.begins_with("silph") or id.begins_with("tower") or id in ["route22_late","cerulean_north_rival","cerulean_rocket_thief","ssanne_rival","tower_rival"] or id.begins_with("rocket_") or id.begins_with("celadon_") or id.begins_with("route8_") or id.begins_with("rock_") or id.begins_with("route9_") or id.begins_with("route10_") or id.begins_with("route24_") or id.begins_with("route25_") or id.begins_with("route6_") or id.begins_with("ssanne1f_") or id.begins_with("vermilion_")
	battle.trainer_id = id
	battle.enemy_party = trainer_rules.party(store,id)
	battle.finished.connect(_return_to_map)
	battle.telemetry.connect(_trace)
	overlay.get_parent().add_child(battle)
	_trace({"event":"trainer_started","id":id,"enemies":battle.enemy_party.duplicate(true),"state":store.state.duplicate(true)})

func _pc_open() -> void:
	# Original Red hiddenObjects: investigate [13,3] from [13,4], facing up; computer is baked into ground art.
	store.state["location"] = {"map_id":map_id,"x":player.position.x,"y":player.position.y}
	player.active = false
	pc = preload("res://scripts/storage_view.gd").new()
	pc.store = store
	pc.closed.connect(func():
		pc.queue_free()
		player.active = true
		interaction_ready_at = Time.get_ticks_msec()+250)
	pc.telemetry.connect(_trace)
	overlay.get_parent().add_child(pc)

func _has_ship_ticket() -> bool:
	return store.state.get("bill",{}).get("items",{}).get("ss_ticket",0)==1

func _ship_ticket_dialog(check: bool) -> void:
	var allowed: bool = _has_ship_ticket()
	if check:ship_pass = allowed
	_new_modal("圣安奴号 · 登船员")
	ship_dialog = true
	interaction_ready_at = Time.get_ticks_msec()+250
	var message: String = "欢迎来到圣安奴号！请从左侧验票后登船。"
	if check:message = "船票已核验，欢迎登船！船票不消耗。" if allowed else "登船需要圣安奴号船票。请先取得船票。"
	UI.label(modal,message+"\nE / Enter 返回",Rect2(100,180,750,120),22)
	_trace({"event":"ship_ticket","checked":check,"allowed":allowed,"text":message})

func _ship_rival_trigger(cell: Vector2i) -> bool:
	if map_id!="ssanne-2f" or store.state.get("trainers",{}).get("ssanne_rival",false):return false
	if cell.x not in [36,37] or cell.y<8 or cell.y>8:
		ship_rival_latch = false
		if cell.x in [36,37] and cell.y<8:
			player.position.y = 137
			status.text = "先完成走廊劲敌战，再前往船长室。"
			return true
		return false
	if ship_rival_latch:return false
	ship_rival_latch = true
	ship_rival_revealed = true
	var position_before: Vector2 = player.position
	_build_map(map_id,position_before)
	_forest_trainer_interact(trainer_rules.ship_rival)
	_trace({"event":"ship_rival_trigger","cell":[cell.x,cell.y],"source_hidden_cell":[36,4],"staged_cell":[36,7]})
	return true

func _ship_transition(cell: Vector2i) -> bool:
	if map_id=="vermilion-city" and cell==Vector2i(18,30) and player.velocity.y>0 and not ship_pass:
		_ship_ticket_dialog(true)
		if not ship_pass:player.position.y = 473
		return true
	if map_id not in ship_warps:return false
	var key: String = "%s:%d:%d" % [map_id,cell.x,cell.y]
	if key==moon_warp_latch:return false
	moon_warp_latch = ""
	for warp in ship_warps[map_id]:
		if cell!=Vector2i(int(warp["cell"][0]),int(warp["cell"][1])):continue
		if warp.get("closed",false):
			status.text = warp["reason"];return false
		if player.velocity==Vector2.ZERO:return false
		var required: Vector2 = Vector2.DOWN if warp["direction"]=="down" else Vector2.UP
		if player.velocity.dot(required)<=0:return false
		if map_id=="vermilion-city" and (not ship_pass or not _has_ship_ticket()):
			player.position = Vector2(296,473);_ship_ticket_dialog(true);return true
		if warp["target"]=="ssanne-captain" and not store.state.get("trainers",{}).get("ssanne_rival",false):
			status.text = "先完成二层走廊劲敌战。";return false
		var from: String = map_id
		var dest: Array = warp["arrival"]
		_change_map(warp["target"],Vector2(int(dest[0])*16+8,int(dest[1])*16+9))
		_trace({"event":"ship_warp","from":from,"index":warp["index"],"to":map_id,"target_index":warp["target_index"],"arrival":dest})
		return true
	return false

func _forest_transition(cell: Vector2i) -> bool:
	if _sevii_transition(cell):return true
	if _o13_boundary():return true
	if _seafoam_fall(cell):return true
	if _o05_transition(cell):return true
	if map_id=="safari-zone-entry" and cell.y==25 and cell.x in [14,15] and player.velocity.y>0:
		player.velocity = Vector2.ZERO;_safari_prompt("leave");return true
	if map_id=="safari-zone-gate" and cell.y==1 and cell.x in [3,4] and player.velocity.y<0:
		player.velocity = Vector2.ZERO;_safari_prompt("enter");return true
	if map_id=="pokemon-tower-6f" and cell==Vector2i(9,16) and not store.state["trainers"].get("tower_mother_released",false):
		status.text = "母亲幽灵尚未安息。";return true
	if _ship_transition(cell):return true
	var target: String = ""
	var arrival := Vector2.ZERO
	if map_id=="pokemon-mansion-3f" and player.velocity!=Vector2.ZERO:
		var falls:Array=JSON.parse_string(FileAccess.get_file_as_string("res://data/pokemon-mansion-falls.json"))
		for fall in falls:
			if cell==Vector2i(int(fall["cell"][0]),int(fall["cell"][1])):
				var dest:Array=fall["arrival"];_change_map(fall["target"],Vector2(int(dest[0])*16+8,int(dest[1])*16+9))
				_trace({"event":"mansion_fall","to":map_id,"dungeon_index":fall["dungeon_index"],"arrival":dest});return true
	if map_id=="victory-road-3f" and cell==Vector2i(23,15):
		_change_map("victory-road-2f",Vector2(360,265));_trace({"event":"victory_player_fall","arrival":[22,16]});return true
	if map_id=="route23" and player.position.y<10 and player.velocity.y<0:
		_change_map("indigo-plateau",Vector2(player.position.x,265));return true
	if map_id=="indigo-plateau" and player.position.y>280 and player.velocity.y>0:
		_change_map("route23",Vector2(player.position.x,9));return true
	if map_id in moon_warps:
		var key: String = "%s:%d:%d" % [map_id,cell.x,cell.y]
		if key!=moon_warp_latch:
			moon_warp_latch = ""
			for warp in moon_warps[map_id]:
				if cell==Vector2i(int(warp["cell"][0]),int(warp["cell"][1])):
					if warp.get("requires","")=="secret_key" and not store.pokemon_mansion.has_key(store.state):status.text="红莲道馆的门锁着！需要秘密钥匙。";return false
					if map_id=="game-corner" and warp["index"]==2 and not store.rocket_rules.opened(store.state):
						status.text = "海报后的开关尚未按下。";return false
					if warp.get("closed",false):
						status.text = warp["reason"];return false
					if player.velocity==Vector2.ZERO:return false
					var required: Vector2 = {"left":Vector2.LEFT,"right":Vector2.RIGHT,"up":Vector2.UP,"down":Vector2.DOWN}.get(warp.get("direction",""),Vector2.ZERO)
					if required!=Vector2.ZERO and player.velocity.dot(required)<=0:return false
					var facing: Vector2 = player.facing
					var from: String = map_id
					var dest: Array = warp["arrival"]
					var destination: String = warp["target"]
					if destination in ["route5-gate","route6-gate","route8-gate"] and not store.saffron_rules.opened(store.state):
						status.text="金黄市通行需要已交付的茶。";_state_trace("o11_gate_denied");return true
					if destination=="saffron-gym" and not store.silph_story.liberated(store.state):
						status.text = "请先解放西尔佛公司。";return false
					if destination=="silph-co-1f" and from=="saffron-city" and not store.tower_story.rescued(store.state):
						status.text = "公司仍被门卫封锁。";return false
					if destination=="celadon-mart-elevator":
						var failure:String=store.celadon_lift.select_floor(store,map_id,{"map_id":destination,"x":int(dest[0])*16+8,"y":int(dest[1])*16+9})
						if failure!="":status.text=failure;return false
					if map_id=="celadon-mart-elevator":
						destination=store.celadon_lift.floor_id(store.state)
						for door in moon_warps[destination]:
							if door.get("target","")=="celadon-mart-elevator":dest=door["cell"];break
					if destination=="silph-co-elevator":
						var failure: String = store.silph_story.select_floor(store,map_id)
						if failure!="":status.text = failure;return false
					if map_id=="silph-co-elevator":
						destination = store.silph_story.floor_id(store.state)
						dest = moon_warps[destination][3 if destination=="silph-co-1f" else 1 if destination=="silph-co-11f" else 2]["cell"]
					if destination=="rocket-hideout-elevator":
						var failure: String = store.post_b3.transition(store,"enter_lift",map_id)
						if failure!="":status.text = failure;return false
					if map_id=="rocket-hideout-elevator":
						destination = store.post_b3.lift_floor(store.state)
						var source_index: int = {"rocket-hideout-b1f":4,"rocket-hideout-b2f":4,"rocket-hideout-b4f":2}[destination]
						var selected: Dictionary = moon_warps[destination][source_index if warp["index"]==1 else (1 if destination=="rocket-hideout-b4f" else 2)]
						dest = selected["cell"]
					if store.safari.is_zone(from):
						var result: String = store.safari.step(store,{"map_id":destination,"x":int(dest[0])*16+8,"y":int(dest[1])*16+9})
						_state_trace("safari_step")
						if result!="":_restore_location();status.text = result;_state_trace("safari_"+result);return true
					if warp.get("league",false):
						var refusal:String=store.league.transition(store,from,destination,{"map_id":destination,"x":int(dest[0])*16+8,"y":int(dest[1])*16+9})
						if refusal!="":status.text=refusal;_state_trace("league_gate_rejected");return false
						_state_trace("league_transition")
					_change_map(destination,Vector2(int(dest[0])*16+8,int(dest[1])*16+9))
					player.facing = {"left":Vector2.LEFT,"right":Vector2.RIGHT,"up":Vector2.UP,"down":Vector2.DOWN}.get(warp.get("arrival_direction",""),facing)
					_trace({"event":"moon_warp","from":from,"index":warp["index"],"to":map_id,"target_index":warp["target_index"],"arrival":dest,"facing":[facing.x,facing.y]})
					return true
	if map_id=="route12" and player.position.y>1719 and player.velocity.y>0:
		_change_map("route13",Vector2(player.position.x+640,9));return true
	if map_id=="route13" and player.position.y<8 and player.velocity.y<0 and cell.x>=40:
		_change_map("route12",Vector2(player.position.x-640,1721));return true
	if map_id=="route13" and player.position.x<8 and player.velocity.x<0:
		_change_map("route14",Vector2(312,player.position.y));return true
	if map_id=="route14" and player.position.x>311 and player.velocity.x>0:
		_change_map("route13",Vector2(9,player.position.y));return true
	if map_id=="route14" and player.position.x<8 and player.velocity.x<0 and player.position.y>=576:
		_change_map("route15",Vector2(951,player.position.y-576));return true
	if map_id=="route15" and player.position.x>951 and player.velocity.x>0:
		_change_map("route14",Vector2(9,player.position.y+576));return true
	if map_id=="route15" and player.position.x<8 and player.velocity.x<0:
		_change_map("fuchsia-city",Vector2(631,player.position.y+128));return true
	if map_id=="fuchsia-city" and player.position.x>631 and player.velocity.x>0:
		_change_map("route15",Vector2(9,player.position.y-128));return true
	if map_id=="route12" and player.position.y<8 and player.velocity.y<0:
		_change_map("lavender-town",Vector2(player.position.x,279));return true
	if map_id=="route6":
		if player.position.y>569 and player.velocity.y>0:
			_change_map("vermilion-city",Vector2(player.position.x+160,9));return true
		if cell.y<=0 and player.velocity.y<0:
			if store.saffron_rules.opened(store.state):_change_map("route6-gate",Vector2(player.position.x-160,73));return true
			status.text="金黄市通行需要已交付的茶。"
	if map_id in ["vermilion-center","vermilion-mart"] and cell.y==7 and cell.x in [3,4] and player.velocity.y>0:
		_change_map("vermilion-city",Vector2(184,73) if map_id=="vermilion-center" else Vector2(376,233));return true
	if map_id=="vermilion-gym" and cell.y==17 and cell.x in [4,5] and player.velocity.y>0:
		_change_map("vermilion-city",Vector2(200,329));return true
	if map_id=="cinnabar-gym" and cell.y==17 and cell.x in [16,17] and player.velocity.y>0:
		_change_map("cinnabar-island",Vector2(296,73));return true
	if map_id=="vermilion-city":
		if cell==Vector2i(12,20) and player.velocity.y<0 and player.position.y<=328:
			_change_map("vermilion-gym",Vector2(72,265));return true
		if cell==Vector2i(11,3) and player.velocity.y<0:
			_change_map("vermilion-center",Vector2(56,105));return true
		if cell==Vector2i(23,13) and player.velocity.y<0:
			_change_map("vermilion-mart",Vector2(56,105));return true
		if player.position.y<8 and player.velocity.y<0 and cell.x>=10 and cell.x<30:
			_change_map("route6",Vector2(player.position.x-160,569));return true
		for entrance in layout.get("unopenedEntrances",[]):
			if entrance["destMapName"] not in ["VermilionPokecenter","VermilionMart","VermilionDock","VermilionGym"] and cell.x==int(entrance["x"]) and absi(cell.y-int(entrance["y"]))<=1:status.text = "这处建筑本轮未开放。"
		if cell.x>=39 and player.velocity.x>0:status.text = "11号道路与地鼠洞本轮未开放。"
	if map_id=="route10-south" and player.position.y>int(layout["height"])*16-9 and player.velocity.y>0:
		_change_map("lavender-town",Vector2(player.position.x,9));return true
	if map_id=="route16" and player.position.x>631 and player.velocity.x>0:
		_change_map("celadon-city",Vector2(9,player.position.y+128));return true
	if map_id=="route16" and player.position.y>280 and player.velocity.y>0 and cell.x<20:
		_change_map("route17",Vector2(player.position.x,25));return true
	if map_id=="route17" and player.position.y<8 and player.velocity.y<0:
		_change_map("route16",Vector2(player.position.x,281));return true
	if map_id=="route17" and player.position.y>int(layout["height"])*16-9 and player.velocity.y>0:
		_change_map("route18",Vector2(player.position.x,25));return true
	if map_id=="route18" and player.position.y<8 and player.velocity.y<0:
		_change_map("route17",Vector2(player.position.x,144*16-25));return true
	if map_id=="route18" and player.position.x>int(layout["width"])*16-9 and player.velocity.x>0:
		_change_map("fuchsia-city",Vector2(9,player.position.y+128));return true
	if map_id=="fuchsia-city" and player.position.x<8 and player.velocity.x<0 and cell.y>=8 and cell.y<26:
		_change_map("route18",Vector2(50*16-9,player.position.y-128));return true
	if map_id=="celadon-city":
		if player.position.x<8 and player.velocity.x<0 and cell.y>=8 and cell.y<26:
			_change_map("route16",Vector2(631,player.position.y-128));return true
		if player.position.x>791 and player.velocity.x>0 and player.position.y>=128 and player.position.y<416:
			_change_map("route7",Vector2(9,player.position.y-128));return true
		for entrance in layout.get("unopenedEntrances",[]):
			if entrance["destMapName"] not in ["CeladonMansion1F","GameCorner","CeladonGym","CeladonPokecenter","CeladonMart1F"] and cell.x==int(entrance["x"]) and absi(cell.y-int(entrance["y"]))<=1:status.text = "其他民宅与飞翔剧情延期。"
		if cell.x<=0:status.text = "向西通往16号道路。"
	if map_id=="route7":
		if player.position.x>311 and player.velocity.x>0 and cell.y in [9,10]:
			_change_map("saffron-city",Vector2(9,player.position.y+128));return true
		if player.position.x<8 and player.velocity.x<0:
			_change_map("celadon-city",Vector2(791,player.position.y+128));return true
	if map_id=="saffron-city":
		if player.position.x<8 and player.velocity.x<0 and cell.y in [17,18]:
			_change_map("route7",Vector2(311,player.position.y-128));return true
		if cell.y>=35 and player.velocity.y>0 and cell.x in [18,19]:
			if store.saffron_rules.opened(store.state):_change_map("route5-gate",Vector2(56,9));return true
			status.text="华蓝市通行需要已交付的茶。"
		if cell.y<=0 and player.velocity.y<0 and cell.x in range(30,40):
			if store.saffron_rules.opened(store.state):_change_map("route8-gate",Vector2(8,57));return true
			status.text="紫苑镇通行需要已交付的茶。"
		if cell.y<=1 or cell.y>=34 or cell.x>=38:status.text = "其他金黄市建筑与道路本片未开放。"
	if map_id in ["route5-gate","route6-gate","route8-gate"]:
		pass
		pass
	if map_id=="route8":
		if player.position.x>951 and player.velocity.x>0:
			_change_map("lavender-town",Vector2(9,player.position.y));return true
		if cell.x<=0 and player.velocity.x<0 and cell.y in [9,10]:
			if store.saffron_rules.opened(store.state):_change_map("route8-gate",Vector2(72,73));return true
			status.text="金黄市通行需要已交付的茶。"
	if map_id=="lavender-town":
		if player.position.x<8 and player.velocity.x<0:
			_change_map("route8",Vector2(951,player.position.y));return true
		if player.position.y<8 and player.velocity.y<0:
			_change_map("route10-south",Vector2(player.position.x,375));return true
		if player.velocity.y<0 and cell==Vector2i(3,5):
			_change_map("lavender-center",Vector2(56,105));return true
		if player.velocity.y<0 and cell==Vector2i(15,13):
			_change_map("lavender-mart",Vector2(56,105));return true
		for entrance in layout.get("unopenedEntrances",[]):
			if cell.x==int(entrance["x"]) and absi(cell.y-int(entrance["y"]))<=1:status.text = "宝可梦塔、富士、民宅与改名剧情本轮未开放。"
		if player.position.y>int(layout["height"])*16-9 and player.velocity.y>0:
			_change_map("route12",Vector2(player.position.x,9));return true
	if map_id in ["lavender-center","lavender-mart"] and cell.y==7 and cell.x in [3,4] and player.velocity.y>0:
		_change_map("lavender-town",Vector2(56,105) if map_id=="lavender-center" else Vector2(248,233));return true
	if map_id=="route9":
		if player.position.x<8 and player.velocity.x<0:
			_change_map("cerulean-city",Vector2(631,player.position.y+128));return true
		if player.position.x>951 and player.velocity.x>0:
			_change_map("route10-north",Vector2(9,player.position.y));return true
	if map_id=="route10-north":
		if player.position.x<8 and player.velocity.x<0 and cell.y<18:
			_change_map("route9",Vector2(951,player.position.y));return true

		if cell.x==11 and cell.y in [19,20] and player.velocity.y<0:status.text = "这座宝可梦中心内部本轮延期。"
	if map_id=="route4-east" and player.position.x>int(layout["width"])*16-9 and player.velocity.x>0:
		_change_map("cerulean-city",Vector2(9,player.position.y+128));return true
	if map_id=="route24" and player.position.y>569 and player.velocity.y>0:
		_change_map("cerulean-city",Vector2(player.position.x+160,9));return true
	if map_id=="route24" and player.position.x>311 and player.velocity.x>0 and cell.y<18:
		_change_map("route25",Vector2(9,player.position.y));return true
	if map_id=="route25" and player.position.x<8 and player.velocity.x<0:
		_change_map("route24",Vector2(311,player.position.y));return true
	if map_id=="route25" and cell==Vector2i(45,3) and player.velocity.y<0:
		_change_map("bills-house",Vector2(40,105));return true
	if map_id=="bills-house" and cell.y==7 and cell.x in [2,3] and player.velocity.y>0:
		if store.bill_rules.stage(store.state)=="ticket":
			var failure: String = store.bill_rules.advance(store,"leave")
			if failure!="":status.text = failure;return true
		_change_map("route25",Vector2(728,73));return true
	if map_id=="cerulean-city":
		if player.position.x>631 and player.velocity.x>0 and cell.y>=8 and cell.y<26:
			_change_map("route9",Vector2(9,player.position.y-128));return true
		if not store.state.get("trainers",{}).get("cerulean_north_rival",false) and cell.x in [20,21] and cell.y<=6 and player.velocity.y<0:
			player.position.y = 109;status.text = "先面向北口劲敌按 E 确认对战。";return true
		if player.position.y>569 and player.velocity.y>0 and cell.x>=10 and cell.x<30:
			_change_map("route5",Vector2(player.position.x-160,9));return true
		if cell==Vector2i(27,11) and player.velocity.y<0:
			_change_map("cerulean-trashed-house",Vector2(40,105));return true
		if cell==Vector2i(27,9) and player.velocity.y>0:
			_change_map("cerulean-trashed-house",Vector2(56,9));return true
		if player.position.y<8 and player.velocity.y<0 and cell.x>=10 and cell.x<30:
			_change_map("route24",Vector2(player.position.x-160,569));return true
		if player.position.x<8 and player.velocity.x<0 and cell.y>=8 and cell.y<26:
			_change_map("route4-east",Vector2(1047,player.position.y-128));return true
		if cell==Vector2i(30,19) and player.velocity.y<0:
			_change_map("cerulean-gym",Vector2(72,201));return true
		if cell==Vector2i(19,17) and player.velocity.y<0:
			_change_map("cerulean-center",Vector2(56,105));return true
		if (cell.y<=0 and player.velocity.y<0) or (cell.y>=35 and player.velocity.y>0) or (cell.x>=39 and player.velocity.x>0):
			status.text = "从东侧原通路前往9号道路。"
		for door in layout.get("closedDoors",[]):
			if cell.x==int(door[0]) and cell.y==int(door[1])+1 and player.velocity.y<0:status.text = "这处建筑或洞口本轮未开放。"
	if map_id=="route5":
		if player.position.y<8 and player.velocity.y<0:
			_change_map("cerulean-city",Vector2(player.position.x+160,569));return true
		for entrance in layout.get("unopenedEntrances",[]):
			if entrance["destMap"]!="UNDERGROUND_PATH_ROUTE_5" and cell.x==int(entrance["x"]) and absi(cell.y-int(entrance["y"]))<=1:
				status.text = "培育屋功能本轮未开放。" if entrance["destMap"]=="DAYCARE" else "地下通道本轮未开放。" if entrance["destMap"]=="UNDERGROUND_PATH_ROUTE_5" else "关卡与金黄市通行本轮未开放。"
		if cell.y>=35 and player.velocity.y>0:status.text = "金黄市通行本轮未开放。"
	if map_id=="route5-gate" and cell.y==7 and player.velocity.y>0:_change_map("route5",Vector2(168,521));return true
	if map_id=="cerulean-trashed-house":
		if cell.y==7 and cell.x in [2,3] and player.velocity.y>0:
			_change_map("cerulean-city",Vector2(440,201));return true
		if player.position.y<8 and cell.x==3 and player.velocity.y<0:
			_change_map("cerulean-city",Vector2(440,137));return true
	if map_id=="cerulean-gym" and cell.y==13 and cell.x in [4,5] and player.velocity.y>0:
		_change_map("cerulean-city",Vector2(488,329));return true
	if map_id=="cerulean-center" and cell.y==7 and cell.x in [3,4] and player.velocity.y>0:
		_change_map("cerulean-city",Vector2(312,297));return true
	if map_id=="mtmoon-1f":
		if cell.y==35 and cell.x in [14,15] and player.velocity.y>0:
			_change_map("route4-entrance",Vector2(296,105));return true
	if map_id=="route4-entrance" and cell==Vector2i(18,5) and player.velocity.y<0:
		_change_map("mtmoon-1f",Vector2(232,553));return true
	if map_id=="pewter-city" and player.position.x>631 and player.velocity.x>0 and cell.y in [14,15,16,17]:
		if not store.state.get("trainers",{}).get("pewter_brock",false):
			player.position.x = 630
			status.text = "先挑战尼比道馆的小刚。"
			_trace({"event":"route3_badge_gate"})
			return true
		target = "route3";arrival = Vector2(9,player.position.y-128)
	elif map_id=="route3" and player.position.x<8 and player.velocity.x<0 and cell.y in [6,7,8,9]:
		target = "pewter-city";arrival = Vector2(631,player.position.y+128)
	elif map_id=="route3" and player.position.y<8 and player.velocity.y<0 and cell.x>=50:
		target = "route4-entrance";arrival = Vector2(player.position.x-800,281)
	elif map_id=="route4-entrance" and player.position.y>281 and player.velocity.y>0:
		target = "route3";arrival = Vector2(player.position.x+800,9)
	elif map_id=="route4-entrance" and cell==Vector2i(11,5) and player.velocity.y<0:
		target = "mtmoon-center";arrival = Vector2(56,105)
	elif map_id=="mtmoon-center" and cell.y==7 and cell.x in [3,4] and player.velocity.y>0:
		target = "route4-entrance";arrival = Vector2(184,105)
	elif map_id=="route2" and player.position.y<8 and player.velocity.y<0:
		target = "pewter-city";arrival = Vector2(player.position.x+160,569)
	elif map_id=="pewter-city" and player.position.y>569 and player.velocity.y>0 and cell.x>=10 and cell.x<30:
		target = "route2";arrival = Vector2(player.position.x-160,9)
	elif map_id=="pewter-city" and cell==Vector2i(16,17) and player.velocity.y<0:
		target = "pewter-gym";arrival = Vector2(72,201)
	elif map_id=="pewter-city" and cell==Vector2i(13,25) and player.velocity.y<0:
		target = "pewter-center";arrival = Vector2(56,105)
	elif map_id=="pewter-gym" and cell.y==13 and cell.x in [4,5] and player.velocity.y>0:
		target = "pewter-city";arrival = Vector2(264,297)
	elif map_id=="pewter-center" and cell.y==7 and cell.x in [3,4] and player.velocity.y>0:
		target = "pewter-city";arrival = Vector2(216,425)
	elif map_id=="viridian-city" and player.position.y<8 and player.velocity.y<0 and cell.x in [17,18,19]:
		target = "route2";arrival = Vector2(player.position.x-160,1145)
	elif map_id=="route2" and player.position.y>1144 and player.velocity.y>0 and cell.x in [7,8,9]:
		target = "viridian-city";arrival = Vector2(player.position.x+160,9)
	elif map_id=="route2" and cell==Vector2i(3,43) and player.velocity.y<0:
		target = "forest-south-gate";arrival = Vector2(72,105)
	elif map_id=="route2" and cell==Vector2i(3,11) and player.velocity.y>0:
		target = "forest-north-gate";arrival = Vector2(72,25)
	elif map_id=="forest-south-gate":
		if cell.x in [4,5] and cell.y==0 and player.velocity.y<0:target = "viridian-forest";arrival = Vector2(264,745)
		elif cell.x in [4,5] and cell.y==7 and player.velocity.y>0:target = "route2";arrival = Vector2(56,713)
	elif map_id=="forest-north-gate":
		if cell.x in [4,5] and cell.y==0 and player.velocity.y<0:target = "route2";arrival = Vector2(56,169)
		elif cell.x in [4,5] and cell.y==7 and player.velocity.y>0:target = "viridian-forest";arrival = Vector2(24,25)
	elif map_id=="viridian-forest":
		if cell.y==47 and cell.x in [15,16,17,18] and player.velocity.y>0:target = "forest-south-gate";arrival = Vector2(72,25)
		elif cell.y==0 and cell.x in [1,2] and player.velocity.y<0:target = "forest-north-gate";arrival = Vector2(72,105)
	if target=="":return false
	_change_map(target,arrival)
	return true

func _build_fossil_actors() -> void:
	if is_instance_valid(fossil_actors):
		fossil_actors.get_parent().remove_child(fossil_actors);fossil_actors.queue_free()
	fossil_actors = Node2D.new();world.add_child(fossil_actors)
	var data: Dictionary = store.fossil_rules.data
	var actors: Array = [{"cell":store.fossil_rules.scientist_cell(store.state),"sprite":data["trainer"]["sprite"]}]
	if not store.state.has("moon_fossil"):actors.append_array(data["items"])
	for entry in actors:
		var cell: Array = entry["cell"]
		var sprite := Sprite2D.new();sprite.texture = load(entry["sprite"]);sprite.position = Vector2(int(cell[0])*16+8,int(cell[1])*16+8);fossil_actors.add_child(sprite)
		_add_solid(fossil_actors,Rect2(int(cell[0])*16,int(cell[1])*16,16,16))

func _fossil_interact(cell: Vector2i) -> bool:
	var data: Dictionary = store.fossil_rules.data
	var scientist: Array = store.fossil_rules.scientist_cell(store.state)
	var target := Vector2i(scientist[0],scientist[1])
	if absi(cell.x-target.x)+absi(cell.y-target.y)==1 and player.facing.dot(Vector2(target-cell))>0.5:
		if store.state.has("moon_fossil"):
			status.text = "米格尔：红莲岛的宝可梦研究所正在研究复活化石。（未实现复活）"
		else:_forest_trainer_interact(data["trainer"])
		return true
	for item in data["items"]:
		target = Vector2i(item["cell"][0],item["cell"][1])
		if absi(cell.x-target.x)+absi(cell.y-target.y)==1 and player.facing.dot(Vector2(target-cell))>0.5:
			if store.state.has("moon_fossil"):
				status.text = "化石已经分好，不能重复领取。";_trace({"event":"fossil_already_taken"});return true
			if not store.state.get("trainers",{}).get("mtmoonb2f_miguel",false):
				status.text = "米格尔：这些化石都是我的！请先与我对战。";_trace({"event":"fossil_locked"});return true
			fossil_pending = item["id"];trainer_ready_at = Time.get_ticks_msec()+250
			_new_modal(item["name"]+" · 原文译意")
			UI.label(modal,"要拿走%s吗？\n我们一人一块，不许贪心！" % item["name"],Rect2(100,190,755,100),23)
			UI.button(modal,"1 是，拿走",Rect2(105,350,350,65),_fossil_take)
			UI.button(modal,"2 / Esc 暂时不拿",Rect2(475,350,350,65),func():fossil_pending = "";_close_modal();_trace({"event":"fossil_cancelled"}))
			_trace({"event":"fossil_choice","item":item["id"]});return true
	return false

func _fossil_take() -> void:
	if fossil_pending=="" or Time.get_ticks_msec()<trainer_ready_at:return
	var selected: String = fossil_pending;fossil_pending = ""
	var failure: String = store.fossil_rules.select(store,selected)
	_close_modal()
	if failure!="":status.text = failure;_state_trace("fossil_rejected");return
	_build_fossil_actors()
	status.text = "获得%s！米格尔：那么，另一块就是我的了！已保存。" % ("甲壳化石" if selected=="dome_fossil" else "贝壳化石")
	_state_trace("fossil_received")

func _cut_close() -> void:
	cut_phase = "";cut_learner = -1;cut_slot = -1;cut_tree = {};_close_modal()

func _cut_dialog(title: String,text: String,phase: String) -> void:
	cut_phase = phase
	_new_modal(title)
	UI.label(modal,text,Rect2(110,178,730,236),21)
	UI.button(modal,"Esc / B 取消",Rect2(110,470,245,52),_cut_close)
	trainer_ready_at = Time.get_ticks_msec()+250

func _cut_interact(cell: Vector2i) -> bool:
	if map_id=="ssanne-captain":
		var target := Vector2i(4,2)
		if absi(cell.x-target.x)+absi(cell.y-target.y)==1 and player.facing.dot(Vector2(target-cell))>0.5:
			if store.cut_rules.has_hm(store.state):
				_cut_dialog("船长 · 已领取HM01","谢谢你，我已经好多了！\nHM01居合斩可以反复教学，不会消耗。\n地图上按 M 选择宝可梦；蓝色徽章允许场外砍树。\n本轮尚未接入离港，船仍可进出。\nE / Esc 返回。","info")
				_state_trace("captain_repeat")
			else:
				_cut_dialog("船长 · 晕船","呜……我晕船了。\n帮船长揉揉背，让他恢复精神吗？\nE / Enter 帮忙并领取HM01居合斩。\nEsc 取消，不改变进度。","captain")
				_trace({"event":"captain_dialog"})
			return true
	if store.cut_rules.has_trees(map_id):
		for tree in store.cut_rules.trees(map_id):
			var target := Vector2i(tree["cell"][0],tree["cell"][1])
			if absi(cell.x-target.x)+absi(cell.y-target.y)!=1 or player.facing.dot(Vector2(target-cell))<=0.5:continue
			if tree["cell"] in cut_removed:return false
			var error: String = store.cut_rules.field_error(store.state,true)
			if error!="":status.text = error;_trace({"event":"cut_rejected","reason":error});return true
			cut_tree = tree.duplicate(true)
			_cut_dialog("居合斩 · 可砍的树","%s可以使用居合斩！\n要砍掉面前的小树吗？\nE / Enter 确认，Esc 取消。\n不会消耗PP；离开地图后小树恢复。" % store.growth.species[store.state["team"][store.cut_rules.cutter(store.state)]["species_id"]]["name"],"tree")
			_trace({"event":"cut_tree_dialog"});return true
	return false

func _hm_menu() -> void:
	var error:String="" if _hm_rules().has_hm(store.state) else "还没有对应秘传机。"
	if error!="":status.text = error;return
	cut_phase = "party";_new_modal("HM%02d · %s教学 · 不消耗" % [store.sevii_hm.catalog[sevii_teaching]["hm"],store.sevii_hm.catalog[sevii_teaching]["name"]] if sevii_teaching!="" else "HM05 · 闪光教学 · 不消耗" if flash_teaching else "HM02 · 飞翔教学 · 不消耗" if fly_teaching else "HM04 · 怪力教学 · 不消耗" if strength_teaching else "HM03 · 冲浪教学 · 不消耗" if surf_teaching else "HM01 · 居合斩教学 · 不消耗")
	for i in range(store.state["team"].size()):
		var pet: Dictionary = store.state["team"][i]
		var reason: String = _hm_rules().learn_error(store.state,i)
		UI.button(modal,"%d %s · %s" % [i+1,store.growth.species[pet["species_id"]]["name"],"可以学习" if reason=="" else reason],Rect2(110,168+i*46,738,42),_hm_select.bind(i))
	UI.button(modal,"Esc / B 返回",Rect2(110,478,738,48),_cut_close)
	trainer_ready_at = Time.get_ticks_msec()+250;_state_trace("hm_party_menu")

func _hm_select(index: int) -> void:
	var error: String = _hm_rules().learn_error(store.state,index)
	if error!="":status.text = error;_trace({"event":"hm_rejected","reason":error});return
	cut_learner = index
	var pet: Dictionary = store.state["team"][index]
	if pet["moves"].size()<4:_hm_slot(pet["moves"].size());return
	cut_phase = "slot";_new_modal(store.sevii_hm.catalog[sevii_teaching]["name"]+" · 选择遗忘的招式" if sevii_teaching!="" else "闪光 · 选择遗忘的招式" if flash_teaching else "飞翔 · 选择遗忘的招式" if fly_teaching else "怪力 · 选择遗忘的招式" if strength_teaching else "冲浪 · 选择遗忘的招式" if surf_teaching else "居合斩 · 选择遗忘的招式")
	for i in range(pet["moves"].size()):
		UI.button(modal,"%d %s · PP %d/%d" % [i+1,store.growth.moves[pet["moves"][i]]["name"],pet["pp"][pet["moves"][i]],store.growth.moves[pet["moves"][i]]["pp"]],Rect2(110,178+i*57,738,50),_hm_slot.bind(i))
	UI.button(modal,"Esc / B 放弃学习",Rect2(110,478,738,48),_cut_close)
	trainer_ready_at = Time.get_ticks_msec()+250;_trace({"event":"hm_replace_menu","index":index})

func _hm_slot(slot: int) -> void:
	var pet: Dictionary = store.state["team"][cut_learner]
	if slot<pet["moves"].size() and pet["moves"][slot] in store.growth.HM_MOVES:status.text = "秘传招式不能在这里遗忘。";return
	cut_slot = slot
	var old: String = store.growth.moves[pet["moves"][slot]]["name"] if slot<pet["moves"].size() else "空位"
	_cut_dialog(store.sevii_hm.catalog[sevii_teaching]["name"]+" · 最后确认" if sevii_teaching!="" else "闪光 · 最后确认" if flash_teaching else "飞翔 · 最后确认" if fly_teaching else "怪力 · 最后确认" if strength_teaching else "冲浪 · 最后确认" if surf_teaching else "居合斩 · 最后确认","%s将学习%s。
替换：%s。其他HP、PP和个体身份保留。
秘传机不会消耗。
E / Enter 确认，Esc 放弃。" % [store.growth.species[pet["species_id"]]["name"],store.sevii_hm.catalog[sevii_teaching]["name"]+"（PP%d）" % store.growth.moves[sevii_teaching]["pp"] if sevii_teaching!="" else "闪光（命中70 / PP20 / 命中率降一级）" if flash_teaching else "飞翔（70 / 95 / PP15）" if fly_teaching else "怪力（80 / 100 / PP15）" if strength_teaching else "冲浪（95 / 100 / PP15）" if surf_teaching else "居合斩（50 / 95 / PP30）",old],"learn")
	_trace({"event":"hm_confirm_dialog","index":cut_learner,"slot":slot})

func _cut_input(key: int) -> void:
	if Time.get_ticks_msec()<trainer_ready_at:return
	if key in [KEY_ESCAPE,KEY_B]:_trace({"event":"cut_cancelled","phase":cut_phase});_cut_close();return
	if cut_phase=="party" and key>=KEY_1 and key<=KEY_6:_hm_select(key-KEY_1);return
	if cut_phase=="slot" and key>=KEY_1 and key<=KEY_4:_hm_slot(key-KEY_1);return
	if key not in [KEY_E,KEY_ENTER,KEY_SPACE]:return
	match cut_phase:
		"captain":
			var error: String = store.cut_rules.claim(store)
			if error!="":status.text = error;_cut_close();return
			_cut_dialog("船长 · 获得HM01居合斩","谢谢！我已经恢复精神了！\n获得HM01居合斩，已经保存。\n地图按 M，选择兼容的宝可梦学习。\n有蓝色徽章且队伍学会居合斩，就能砍小树。\nE / Esc 返回。","info")
			_state_trace("captain_received")
		"learn":
			var error: String = _hm_rules().teach(store,cut_learner,cut_slot)
			_cut_close();status.text = ("学会了%s！秘传机保留；面向岩石/瀑布按E使用。" % store.sevii_hm.catalog[sevii_teaching]["name"] if sevii_teaching!="" else "学会了闪光！HM05保留；U在岩山隧道使用。" if flash_teaching else "学会了飞翔！HM02保留；户外按F。" if fly_teaching else "学会了怪力！HM04保留。" if strength_teaching else "学会了冲浪！HM03保留；面向水面按E。" if surf_teaching else "学会了居合斩！HM01保留；面向小树按 E。") if error=="" else error
			_state_trace("hm_learned" if error=="" else "hm_failed")
		"tree":
			var tree: Dictionary = cut_tree.duplicate(true)
			_cut_close();cut_removed.append(tree["cell"]);_build_map(map_id,player.position)
			status.text = "使用居合斩！小树已砍开，离开地图后恢复。"
			_trace({"event":"cut_tree_removed","cell":tree["cell"],"state":store.state.duplicate(true)})
		"info":_cut_close()

func _gym_interact(cell: Vector2i) -> bool:
	for entry in trainer_rules.vermilion:
		var target := Vector2i(entry["cell"][0],entry["cell"][1])
		if absi(cell.x-target.x)+absi(cell.y-target.y)==1 and player.facing.dot(Vector2(target-cell))>0.5:
			if entry["id"]=="vermilion_surge" and not store.gym_rules.opened(store.state):status.text = "先解除两道电锁。";return true
			_forest_trainer_interact(entry);return true
	for can in store.gym_rules.data["cans"]:
		var target := Vector2i(can["cell"][0],can["cell"][1])
		if absi(cell.x-target.x)+absi(cell.y-target.y)!=1 or player.facing.dot(Vector2(target-cell))<=0.5:continue
		var result: Dictionary = store.gym_rules.investigate(store,int(can["id"]))
		_build_map(map_id,player.position)
		gym_phase = true;_new_modal("枯叶道馆 · 垃圾桶调查")
		UI.label(modal,result["text"]+"\nE / Esc 返回。",Rect2(110,185,730,230),22)
		trainer_ready_at = Time.get_ticks_msec()+250
		_trace({"event":"gym_puzzle_"+result["event"],"can":can["id"],"first":store.gym_rules.first,"second":store.gym_rules.second,"state":store.state.duplicate(true)})
		return true
	var guide := Vector2i(4,14)
	if absi(cell.x-guide.x)+absi(cell.y-guide.y)==1 and player.facing.dot(Vector2(guide-cell))>0.5:
		status.text = "第二开关紧邻第一开关。失败会重置！战胜馆主可得雷电徽章。TM34教学、徽章加速与飞翔许可延期。";return true
	return false

func _rocket_interact(cell: Vector2i) -> bool:
	if map_id=="rocket-hideout-elevator":
		var panel := Vector2i(1,1)
		if absi(cell.x-panel.x)+absi(cell.y-panel.y)==1 and player.facing.dot(Vector2(panel-cell))>0.5:
			if not store.post_b3.has_item(store.state,"lift_key"):status.text = "看来需要一把钥匙。";_state_trace("lift_no_key");return true
			lift_pending = true;trainer_ready_at = Time.get_ticks_msec()+250;_new_modal("火箭队基地 · 电梯")
			UI.label(modal,"去哪个楼层？\n1 地下1层\n2 地下2层\n3 地下4层\nEsc 取消",Rect2(150,180,680,280),23);_state_trace("lift_menu");return true
		return false
	if map_id not in ["rocket-hideout-b4f","game-corner","rocket-hideout-b1f","rocket-hideout-b2f","rocket-hideout-b3f"]:return false
	if map_id=="game-corner" and cell==Vector2i(9,5) and player.facing.y<0:
		if store.rocket_rules.opened(store.state):
			status.text = "海报后的开关已经按下，秘密楼梯已出现。";_state_trace("rocket_switch_repeat");return true
		var failure: String = store.rocket_rules.push(store)
		if failure!="":status.text = failure;_state_trace("rocket_switch_failed");return true
		_change_map(map_id,player.position)
		status.text = "海报后面有个开关！按下了！秘密楼梯出现了。"
		_state_trace("rocket_switch_opened");return true
	for actor in post_b3_actors+rocket_depth_actors+rocket_actors:
		if actor["map"]!=map_id:continue
		if actor in post_b3_actors and not store.post_b3.visible(actor,store.state):continue
		if actor.get("id","")=="rocket_poster" and store.rocket_rules.guard_gone(store.state):continue
		var target := Vector2i(actor["cell"][0],actor["cell"][1])
		if absi(cell.x-target.x)+absi(cell.y-target.y)!=1 or player.facing.dot(Vector2(target-cell))<=0.5:continue
		if actor in post_b3_actors:
			var id: String = "rocket_b4_"+str(int(actor["redObject"]))
			if int(actor["redObject"])==1:
				_forest_trainer_interact(trainer_rules.definition("rocket_giovanni"));return true
			if actor["item"]=="SILPH_SCOPE":
				var failure: String = store.post_b3.transition(store,"take","silph_scope")
				_change_map(map_id,player.position);status.text = failure if failure!="" else "获得西尔佛检视镜！可以辨认宝可梦塔幽灵。";_state_trace("silph_scope_taken");return true
			if id in ["rocket_b4_2","rocket_b4_3"]:
				_forest_trainer_interact(trainer_rules.definition(id));return true
			if id=="rocket_b4_4":
				if store.state.get("trainers",{}).get(id,false):
					var failure: String = store.post_b3.transition(store,"drop")
					_change_map(map_id,player.position);status.text = failure if failure!="" else "糟了！电梯钥匙掉在旁边了！";_state_trace("lift_key_dropped");return true
				_forest_trainer_interact(trainer_rules.definition(id));return true
			if actor["item"]=="LIFT_KEY":
				var failure: String = store.post_b3.transition(store,"take","lift_key")
				_change_map(map_id,player.position);status.text = failure if failure!="" else "获得电梯钥匙！";_state_trace("lift_key_taken");return true
			status.text = "基地后续战斗或道具随后接入。";return true
		if actor.has("party"):_forest_trainer_interact(actor)
		else:status.text = "道具拾取本轮延期。" if actor.get("item_deferred",false) else "游戏厅代币、奖品与小游戏本轮延期。"
		return true
	return false

func _tower_interact(cell: Vector2i) -> bool:
	if not map_id.begins_with("pokemon-tower-") and map_id!="mr-fujis-house":return false
	for actor in tower_actors+post_b3_actors:
		if actor["map"]!=map_id or not store.tower_story.visible(actor,store.state) or (actor in post_b3_actors and not store.post_b3.visible(actor,store.state)):continue
		var target := Vector2i(actor["cell"][0],actor["cell"][1])
		if absi(cell.x-target.x)+absi(cell.y-target.y)==1 and player.facing.dot(Vector2(target-cell))>0.5:
			if (map_id=="pokemon-tower-7f" and actor["redObject"]==4) or (map_id=="mr-fujis-house" and actor["redObject"]==5):
				_fuji_dialog();return true
			for entry in trainer_rules.tower:
				if entry["map"]==map_id and entry["redObject"]==actor["redObject"]:_forest_trainer_interact(entry);return true
			if map_id=="pokemon-tower-6f" and actor.get("item","")=="RARE_CANDY":
				var failure: String = store.tower_story.take_candy(store)
				if failure=="":_change_map(map_id,player.position)
				status.text = "获得神奇糖果×1，已放入背包并保存。" if failure=="" else failure
				_state_trace("tower_candy_taken" if failure=="" else "tower_candy_failed");return true
			if actor.get("item","")!="":status.text = "普通楼层物品本批延期。";return true
			if map_id=="pokemon-tower-2f" and actor["redObject"]==1:
				_forest_trainer_interact(trainer_rules.definition("tower_rival"));return true
			status.text = actor["text"];_trace({"event":"tower_dialog","object":actor["redObject"],"text":actor["text"]});return true
	return false

func _tower_trigger(cell: Vector2i) -> bool:
	if map_id=="pokemon-tower-6f":
		if cell!=Vector2i(10,16):tower_trigger_latch = "";return false
		if store.state["trainers"].get("tower_mother_released",false) or tower_trigger_latch=="mother":return false
		tower_trigger_latch = "mother"
		if not store.post_b3.has_item(store.state,"silph_scope"):
			status.text = "幽灵无法辨认！需要检视镜。";_trace({"event":"mother_scope_refused"});return true
		_new_modal("母亲幽灵 · 退下！入侵者！")
		UI.label(modal,"检视镜辨认出Lv30嘎啦嘎啦。E / Enter 对战 · Esc 取消",Rect2(100,220,755,100),22)
		pending_mother = true;_trace({"event":"mother_dialog"});return true
	if map_id!="pokemon-tower-2f":tower_trigger_latch = "";return false
	var key: String = "%d:%d" % [cell.x,cell.y]
	if cell not in [Vector2i(15,5),Vector2i(14,6)]:tower_trigger_latch = "";return false
	if tower_trigger_latch==key or store.state.get("trainers",{}).get("tower_rival",false):return false
	tower_trigger_latch = key
	player.facing = Vector2.LEFT if cell.x==15 else Vector2.UP
	_trace({"event":"tower_rival_trigger","cell":[cell.x,cell.y]})
	_forest_trainer_interact(trainer_rules.definition("tower_rival"));return true

func _tower_purified(cell: Vector2i) -> bool:
	if map_id!="pokemon-tower-5f" or cell not in [Vector2i(10,8),Vector2i(11,8),Vector2i(10,9),Vector2i(11,9)]:
		purified_latch = false;return false
	if purified_latch:return false
	var before: Dictionary = store.state.duplicate(true)
	store.heal_party()
	if not _save():
		store.state = before;status.text = store.error;purified_latch = true;return true
	purified_latch = true;status.text = "净化区域！宝可梦HP、状态与PP已恢复。";_state_trace("tower_purified");return true

func _start_mother() -> void:
	if in_battle or store.state["trainers"].get("tower_mother_released",false) or not store.post_b3.has_item(store.state,"silph_scope"):return
	if int(store.state["team"][int(store.state["lead"])]["hp"])<=0:return
	if not _save():return
	in_battle = true;player.active = false;overlay.hide()
	battle = BATTLE_SCENE.instantiate();battle.theme = UI.setup_theme();battle.store = store
	battle.north_rules = true;battle.mother_ghost = true
	battle.enemy = store.create_individual("marowak",-1,30)
	for stat in store.growth.STATS:battle.enemy["ivs"][stat] = 31
	battle.enemy["hp"] = store.growth.stats(battle.enemy)["hp"]
	battle.finished.connect(_return_to_map);battle.telemetry.connect(_trace);overlay.get_parent().add_child(battle)
	_trace({"event":"mother_started","enemy":battle.enemy.duplicate(true)})

func _fuji_dialog() -> void:
	if map_id=="pokemon-tower-7f" and not store.tower_story.ready(store.state):status.text = "先击败塔顶三名火箭队员。";_trace({"event":"fuji_early"});return
	if map_id=="mr-fujis-house" and store.tower_story.flute(store.state):status.text = "富士老人：宝可梦笛帮上忙了吗？（已领取）";_trace({"event":"fuji_repeat"});return
	fuji_action = "rescue" if map_id=="pokemon-tower-7f" else "flute"
	_new_modal("富士老人")
	UI.label(modal,"谢谢你，请随我回宝可梦之家。E / Enter 确认 · Esc 取消" if fuji_action=="rescue" else "请收下宝可梦笛！E / Enter 领取 · Esc 取消",Rect2(100,200,755,150),22)
	_trace({"event":"fuji_dialog","action":fuji_action})

func _tea_interact(cell: Vector2i) -> bool:
	if map_id!="celadon-mansion-1f":return false
	for actor in mansion_actors:
		var target := Vector2i(actor["cell"][0],actor["cell"][1])
		if absi(cell.x-target.x)+absi(cell.y-target.y)!=1 or player.facing.dot(Vector2(target-cell))<=0.5:continue
		if actor["redObject"]!=2:
			status.text = {"wardens-house":"E交金牙/领取HM04 · J怪力教学 · E启用怪力后方向键推石",1:"喵喵：喵～（蹭着老奶奶）",3:"皮皮：皮～（轻轻摇摆）",4:"尼多兰：尼多～（竖起耳朵）"}[int(actor["redObject"])];return true
		if store.state.get("mansion_tea",{}).get("received",false):status.text = "老奶奶：可爱的宝可梦们一直陪着我。（茶已领取）";_state_trace("tea_repeat");return true
		tea_pending = true;_new_modal("老奶奶 · 香茶")
		UI.label(modal,"不要喝那么多凉饮料。尝尝我泡的热茶吧！\nE / Enter 领取 · Esc 取消",Rect2(100,200,755,150),22)
		_state_trace("tea_dialog");return true
	return false

func _saffron_gate_trigger(cell: Vector2i) -> bool:
	if map_id!="route7-gate" or cell.x!=3 or cell.y not in [3,4]:gate_latch = false;return false
	if store.saffron_rules.opened(store.state) or gate_latch:return false
	gate_latch = true
	var failure: String = store.saffron_rules.deliver(store,map_id)
	if failure!="":
		player.position.x = 40;player.velocity = Vector2.ZERO
		status.text = failure;_state_trace("gate_denied");return true
	status.text = "守卫：这茶真好喝！我会分给其他守卫。茶已交付，通行已保存。"
	_state_trace("gate_tea_delivered");return true

func _saffron_interact(cell: Vector2i) -> bool:
	for a in saffron_actors:
		if a["map"]!=map_id or not store.saffron_rules.visible(a,store.state):continue
		if map_id=="saffron-center" and a["redObject"]==1 or map_id=="saffron-mart" and a["redObject"]==1:continue
		var target := Vector2i(a["cell"][0],a["cell"][1])
		if absi(cell.x-target.x)+absi(cell.y-target.y)!=1 or player.facing.dot(Vector2(target-cell))<0.5:continue
		var message: String = "金黄市终于恢复和平了！娜姿道馆将在后续切片开放。" if store.silph_story.liberated(store.state) else "火箭队占领了金黄市。其他建筑和道路尚未开放。"
		if map_id=="route7-gate":message = "守卫：你好！茶会分给其他关卡的守卫。" if store.saffron_rules.opened(store.state) else "守卫：站岗真渴啊！"
		elif map_id=="saffron-city" and (a["redObject"]==14 or a["redObject"]==15):message = "守卫正在打瞌睡。公司可进入；更高楼层分片开放。" if store.tower_story.rescued(store.state) else "火箭队：我是这里的警卫！不许进入。"
		elif map_id=="saffron-city" and a["redObject"]==3:message = "娜姿道馆仍被火箭队封锁；须先解放西尔佛公司。"
		elif map_id=="saffron-center":message = "护士可恢复伙伴；联机服务未开放。"
		elif map_id=="saffron-mart":message = "暂复用好伤药700货单；金黄原货品尚未实现。"
		status.text = message;_trace({"event":"saffron_npc","map":map_id,"object":a["redObject"],"text":message});return true
	return false

func _silph_interact(cell: Vector2i) -> bool:
	if map_id=="silph-co-elevator":
		var panel := Vector2i(3,0)
		if absi(cell.x-panel.x)+absi(cell.y-panel.y)==1 and player.facing.dot(Vector2(panel-cell))>0.5:
			silph_lift_pending = true;trainer_ready_at = Time.get_ticks_msec()+250;_new_modal("西尔佛公司 · 电梯")
			var text: String = "去哪个楼层？\n"
			for i in range(1,store.silph_story.MAX_FLOOR+1):text += "%d  %d层\n" % [i,i]
			UI.label(modal,text+"Esc 取消",Rect2(150,130,680,440),23);_state_trace("silph_lift_menu");return true
	for a in silph_actors:
		if a["map"]!=map_id or not store.silph_story.visible(a,store.state):continue
		var target := Vector2i(a["cell"][0],a["cell"][1])
		if absi(cell.x-target.x)+absi(cell.y-target.y)!=1 or player.facing.dot(Vector2(target-cell))<=0.5:continue
		if map_id=="silph-co-11f" and a["redObject"]==1:
			if not store.silph_story.liberated(store.state):status.text = "请先击败坂木，救出公司。";_state_trace("silph_president_blocked");return true
			if store.state.get("silph_story",{}).get("master_ball_received",false):status.text = "大师球是我们的秘密试作品，一定能捉到野生宝可梦。";_state_trace("silph_president_repeat");return true
			_silph_confirm("president",map_id,"谢谢你救了我们！领取大师球 ×1？");return true
		if map_id=="silph-co-7f" and a["redObject"]==1:
			if store.state.get("silph_story",{}).get("lapras_received",false):status.text = "拉普拉斯就拜托你了！火箭队老大在董事会议室。";_state_trace("silph_gift_repeat");return true
			_silph_confirm("gift",map_id,"把这只拉普拉斯交给你照顾，好吗？");return true
		if map_id=="silph-co-9f" and a["redObject"]==1:
			var freed: bool = store.silph_story.liberated(store.state)
			var failure: String = store.silph_story.nurse(store)
			status.text = failure if failure!="" else "谢谢你救了我们！" if freed else "先睡一小觉吧。伙伴已经恢复了！不要放弃！"
			_state_trace("silph_nurse_thanks" if freed else "silph_nurse_healed");return true
		if a.get("item","")=="CARD_KEY":_silph_confirm("take",map_id,"拾取卡片钥匙？");return true
		for entry in trainer_rules.silph:
			if entry["map"]==map_id and entry["redObject"]==a["redObject"]:_forest_trainer_interact(entry);return true
		status.text = "普通物品与研究报告将在后续扩展。" if a.get("item","")!="" else "职员：谢谢你救了公司！火箭队已经离开。" if store.silph_story.liberated(store.state) else "职员：火箭队占领了公司，请小心！"
		_trace({"event":"silph_npc","map":map_id,"object":a["redObject"]});return true
	for door in store.silph_story.doors:
		if door["map"]!=map_id:continue
		for patch in door["cells"]:
			var target := Vector2i(patch["cell"][0],patch["cell"][1])
			if cell+Vector2i(player.facing)==target:
				if store.silph_story.door_open(store.state,door["id"]):status.text = "卡片门已经打开。";_state_trace("silph_door_repeat");return true
				if not store.silph_story.has_key(store.state):status.text = "卡片门锁住了。需要卡片钥匙。";_state_trace("silph_door_locked");return true
				_silph_confirm("open",door["id"],"使用卡片钥匙开门？");return true
	return false

func _silph_confirm(action: String,value: String,text: String) -> void:
	silph_action = action;silph_value = value;trainer_ready_at = Time.get_ticks_msec()+250;_new_modal("西尔佛公司 · 剧情与奖励")
	UI.label(modal,text+"\nE / Enter 确认 · Esc 取消",Rect2(140,200,680,160),23);_state_trace("silph_action_dialog")

func _dojo_interact(cell: Vector2i) -> bool:
	for actor in o12_actors:
		if actor["map"]!=map_id:continue
		var delta := Vector2i(actor["cell"][0],actor["cell"][1])-cell
		if absi(delta.x)+absi(delta.y)!=1 or Vector2(delta).dot(player.facing)<0.9:continue
		if actor["redObject"] in [6,7]:continue
		for entry in trainer_rules.o12:
			if entry["redObject"]!=actor["redObject"]:continue
			if entry["id"]=="o12_koichi" and store.state.get("trainers",{}).get("o12_koichi",false):
				if store.state.get("dojo_story",{}).get("gift_received",false):
					status.text="已经领取过道场奖赏。";return true
				dojo_choice_pending=true;trainer_ready_at=Time.get_ticks_msec()+250;_new_modal("格斗道场 · 馆主奖励")
				UI.label(modal,"选择一只宝可梦作为奖赏：\n1 飞腿郎 Hitmonlee　　2 快拳郎 Hitmonchan\nEsc 暂不领取",Rect2(95,190,770,170),22)
				_state_trace("dojo_gift_prompt");return true
			_forest_trainer_interact(entry);return true
	return false

func _saffron_roads_interact(cell: Vector2i) -> bool:
	for a in saffron_roads_actors:
		if a["map"]!=map_id:continue
		if map_id=="route12" and a["redObject"]==1 and store.state.get("static_encounters",{}).get("route12_snorlax",false):continue
		var delta := Vector2i(a["cell"][0],a["cell"][1])-cell
		if absi(delta.x)+absi(delta.y)!=1 or Vector2(delta).dot(player.facing)<0.9:continue
		if map_id=="route12" and a["redObject"]==1:
			if not store.tower_story.flute(store.state):status.text = "宝可梦在熟睡，需要宝可梦笛。";_state_trace("snorlax_no_flute");return true
			snorlax_pending = true;trainer_ready_at = Time.get_ticks_msec()+250;_new_modal("卡比兽 · 宝可梦笛");UI.label(modal,"要使用宝可梦笛吗？\nE / Enter 确认 · Esc 取消",Rect2(140,200,680,160),23);_state_trace("snorlax_flute_dialog");return true
		for tr in trainer_rules.saffron_roads:
			if tr["map"]==map_id and tr["redObject"]==a["redObject"]:_forest_trainer_interact(tr);return true
		status.text = "娜姿：超能力也是锻炼的结果。" if a["redObject"]==1 else "金黄道馆的传送板连接各个房间。";return true
	return false

func _fuchsia_interact(cell: Vector2i) -> bool:
	for a in fuchsia_actors:
		if a["map"]!=map_id:continue
		var delta := Vector2i(a["cell"][0],a["cell"][1])-cell
		var distance: int = absi(delta.x)+absi(delta.y)
		if distance!=(2 if map_id=="safari-zone-gate" and a["redObject"]==1 else 1) or Vector2(delta).normalized().dot(player.facing)<0.9:continue
		if map_id=="safari-zone-gate" and a["redObject"]==1:_safari_prompt("enter");return true
		if map_id=="safari-zone-gate":status.text = "请向右侧柜台办理入园。";return true
		if map_id=="fuchsia-mart" and a["redObject"]==1:return false
		if map_id=="fuchsia-center" and a["redObject"]==1:return false
		for tr in trainer_rules.fuchsia:
			if tr["map"]==map_id and tr["redObject"]==a["redObject"]:_forest_trainer_interact(tr);return true
		status.text = "阿桔挑战尚未开放。" if map_id=="fuchsia-gym" and a["redObject"]==1 else "沿隐形墙绕行，面向训练家按E挑战。" if map_id=="fuchsia-gym" else "这里暂时不能使用。";return true
	return false

func _apply_snorlax(mid: String,data: Dictionary) -> void:
	if mid=="route12" and store.state.get("static_encounters",{}).get("route12_snorlax",false):
		data["solid"][62][10] = 0
	if mid=="route16" and store.state.get("static_encounters",{}).get("route16_snorlax",false):data["solid"][10][26]=0
func _start_snorlax() -> void:
	if in_battle or not store.tower_story.flute(store.state) or store.state.get("static_encounters",{}).get(map_id+"_snorlax",false):return
	if not _save():return
	var before: Dictionary = store.state.duplicate(true)
	# Source sets hide/woke before battle. Adaptation persists that transition with battle result/capture.
	_start_battle({"species_id":"snorlax","level":30})
	if not in_battle:return
	battle.static_id = map_id+"_snorlax";battle.battle_before = before;battle.north_rules = true
	_state_trace("snorlax_awakened")

func _safari_prompt(action: String) -> void:
	safari_action = action
	trainer_ready_at = Time.get_ticks_msec() - 1
	_new_modal("狩猎区 · 入园/退出")
	UI.label(modal,"要支付500入园吗？600步 / 30临时球。"+char(10)+"原图探索，Safari捕获延期。"+char(10)+"E确认 / Esc取消" if action=="enter" else "要提前离开吗？剩余临时球将归还。"+char(10)+"E确认 / Esc继续探索",Rect2(100,200,760,220),22)
	_state_trace("safari_prompt")

func _safari_interact(cell: Vector2i) -> bool:
	for a in safari_actors:
		if a["map"]!=map_id:continue
		var delta:=Vector2i(a["cell"][0],a["cell"][1])-cell
		if absi(delta.x)+absi(delta.y)!=1 or player.facing.dot(Vector2(delta))<0.9:continue
		var key:String="gold_teeth" if a.get("item","")=="GOLD_TEETH" else "hm03" if map_id=="safari-zone-secret-house" else ""
		if key=="":status.text="该普通物品留待后续；Safari捕获未开放。";return true
		if store.safari_rewards.claimed(store.state,key):status.text="已经领取过这份奖励。";_state_trace("safari_reward_repeat");return true
		safari_reward=key;_new_modal("金牙" if key=="gold_teeth" else "秘密小屋 · HM03冲浪")
		UI.label(modal,"E / Enter 领取；Esc取消。
奖励与领取标志会一同保存。",Rect2(100,200,760,180),22)
		_state_trace("safari_reward_prompt");return true
	return false

func _surf_interact(cell: Vector2i) -> bool:
	if store.state.get("surfing",false):return false
	var direction := Vector2i(roundi(player.facing.x),roundi(player.facing.y))
	if absi(direction.x)+absi(direction.y)!=1:return false
	var front := cell+direction
	if not store.surf.water(map_id,layout,front):return false
	var failure: String = store.surf.field_error(store.state)
	if failure=="" and store.surf.pair_blocked(map_id,layout,cell,front):failure = "这段岸边不能上水。"
	if failure!="":status.text = failure;_state_trace("surf_rejected");return true
	surf_target = front;surf_pending = true;_new_modal("飞翔 · 选择遗忘的招式" if fly_teaching else "怪力 · 选择遗忘的招式" if strength_teaching else "冲浪 · 上水")
	UI.label(modal,"要使用冲浪吗？
E / Enter确认，Esc取消。",Rect2(100,200,760,180),22);_state_trace("surf_prompt");return true

func _pokemon_mansion_interact(cell:Vector2i)->bool:
	for entry in store.pokemon_mansion.data["switches"]:
		if entry["map"]==map_id and cell+Vector2i.UP==Vector2i(int(entry["cell"][0]),int(entry["cell"][1])) and player.facing.y<0:
			mansion_pending=true;trainer_ready_at=Time.get_ticks_msec()+250
			_new_modal("秘密开关");UI.label(modal,"雕像里藏着秘密开关！要按下吗？
E / Enter 确认 · Esc 取消",Rect2(100,200,755,140),23);_state_trace("mansion_prompt");return true
	for a in pokemon_mansion_actors:
		if a["map"]!=map_id:continue
		var dd:=Vector2i(int(a["cell"][0]),int(a["cell"][1]))-cell
		if absi(dd.x)+absi(dd.y)!=1 or Vector2(dd).normalized().dot(player.facing)<0.9:continue
		for tr in trainer_rules.pokemon_mansion:
			if tr["map"]==map_id and tr["redObject"]==a["redObject"]:_forest_trainer_interact(tr);return true
		if a.get("item","")=="SECRET_KEY":
			if store.pokemon_mansion.has_key(store.state):status.text="秘密钥匙已经领取。";_state_trace("mansion_key_repeat");return true
			mansion_key_pending=true;trainer_ready_at=Time.get_ticks_msec()+250
			_new_modal("秘密钥匙");UI.label(modal,"发现秘密钥匙！要拾取吗？\nE / Enter 确认 · Esc 取消",Rect2(100,200,755,140),23);_state_trace("mansion_key_prompt");return true
		status.text="此物品或日记的交互尚未开放。";return true
	return false

func _viridian_gym_trigger(cell: Vector2i) -> bool:
	if map_id=="viridian-city" and cell.x==32 and cell.y in [7,8] and player.velocity.y<0:
		if not viridian_gym.opened(store.state):
			player.position=Vector2(520,169);player.velocity=Vector2.ZERO;interaction_ready_at=Time.get_ticks_msec()+400
			status.text="常青道馆的门紧锁着。需要除绿色徽章外的七枚徽章。"
			_state_trace("viridian_gym_locked");return true
		_change_map("viridian-gym",Vector2(280,265));return true
	if map_id=="viridian-gym" and cell.x in [16,17] and cell.y==17 and player.velocity.y>0:
		_change_map("viridian-city",Vector2(520,137));return true
	return false

func _viridian_gym_interact(cell: Vector2i) -> bool:
	for actor in viridian_gym.actors:
		if actor["map"]!=map_id:continue
		var target:=Vector2i(actor["cell"][0],actor["cell"][1])
		if absi(cell.x-target.x)+absi(cell.y-target.y)!=1 or player.facing.dot(Vector2(target-cell))<0.5:continue
		if map_id=="viridian-gym" and int(actor["redObject"])==1:
			_forest_trainer_interact(trainer_rules.definition("viridian_giovanni"));return true
		if map_id=="viridian-gym" and int(actor["redObject"]) in range(2,10):
			for entry in trainer_rules.viridian:
				if int(entry["redObject"])==int(actor["redObject"]):_forest_trainer_interact(entry);return true
		if actor["role"]=="guide" and store.state.get("badges",{}).get("earth",false):
			status.text="真不敢相信！坂木竟然就是常青道馆的馆主！";return true
		status.text=viridian_gym.news(store.state) if actor["role"]=="city_gym_news" else "常青道馆：箭头地板会将你送到停止格。" if actor["role"]=="guide" else "该物品的拾取将在后续接入。" if actor["role"]=="item_deferred" else "常青道馆的对战将在后续切片接入。"
		_trace({"event":"viridian_actor_dialog","object":actor["redObject"],"text":status.text});return true
	return false

func _league_gate_trigger(cell:Vector2i)->bool:
	var badge:String=league_gate.badge(map_id,cell)
	if badge=="":league_gate.latch="";return false
	var key:String=map_id+":"+badge
	if league_gate.latch==key:return false
	league_gate.latch=key
	var allowed:bool=store.state.get("badges",{}).get(badge,false)
	if not allowed:
		player.position=Vector2(cell.x*16+8,(cell.y+1)*16+9);player.velocity=Vector2.ZERO;player.facing=Vector2.DOWN
	status.text=("确认%s徽章，请通过。" if allowed else "没有%s徽章，不能通过！")%league_gate.NAMES[badge]
	_trace({"event":"league_badge_checked","badge":badge,"allowed":allowed,"cell":[cell.x,cell.y]})
	return not allowed

func _commit_victory_switch()->bool:
	var before:Dictionary=store.state.duplicate(true)
	store.state["victory_road_1f_open"]=true
	store.state["location"]={"map_id":"victory-road-1f","x":136,"y":265}
	if not store.save_game():
		store.state=before;status.text=store.error;_trace({"event":"victory_switch_failed"});return false
	_state_trace("victory_switch_opened");return true

func _field_bag()->void:
	field_bag_open=true;_new_modal("背包 · 战间恢复道具")
	if field_item=="":
		var list:Array=store.medicine.MEDICINES+["repels","super_repels","max_repels"]+store.vitamins.ITEMS+store.ordinary_items.ITEMS
		var scroll := ScrollContainer.new()
		scroll.position = Vector2(100,170);scroll.size = Vector2(760,330)
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		scroll.follow_focus = true
		modal.add_child(scroll)
		var grid := GridContainer.new();grid.columns = 2
		grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_theme_constant_override("h_separation",10)
		grid.add_theme_constant_override("v_separation",9)
		scroll.add_child(grid)
		for i in list.size():
			var id:String=list[i]
			var button := UI.button(grid,"%d %s ×%d"%[i+1,store.SHOP[id]["name"] if store.SHOP.has(id) else "神奇糖果" if id=="rare_candies" else "离洞绳" if id=="escape_ropes" else store.ground_items.NAMES.get(id,id),store.state.get("ground_inventory",{}).get(id,0) if id=="escape_ropes" else store.state.get(id,0)],Rect2(0,0,365,66),_field_bag_select.bind(i))
			button.custom_minimum_size = Vector2(365,66)
			button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			button.add_theme_color_override("font_focus_color",Color("303840"))
			button.focus_mode = Control.FOCUS_ALL
			if i==0:button.call_deferred("grab_focus")
	else:
		for i in store.state["team"].size():
			var pet:Dictionary=store.state["team"][i]
			UI.button(modal,"%d %s HP%d/%d"%[i+1,store.species[pet["species_id"]]["name"],pet["hp"],store.growth.stats(pet)["hp"]],Rect2(110,170+i*53,730,48),_field_bag_select.bind(i))
	UI.label(modal,"Esc 取消 · 无效目标不消耗 · 糖果、离洞绳可在列表使用",Rect2(110,510,730,35),20)
	_state_trace("field_bag_open")
func _field_bag_select(index:int)->void:
	if field_item=="":
		var list:Array=store.medicine.MEDICINES+["repels","super_repels","max_repels"]+store.vitamins.ITEMS+store.ordinary_items.ITEMS
		if index<0 or index>=list.size():return
		field_item=list[index]
		if field_item not in ["repels","super_repels","max_repels","escape_ropes"]:_field_bag();return
	else:
		if index<0 or index>=store.state["team"].size():return
	if field_item=="rare_candies":
		candy_index=index;candy_pending=store.ordinary_items.candy_preview(store,index)
		if candy_pending.is_empty():status.text="不能使用神奇糖果。";field_bag_open=false;field_item="";_close_modal();return
		field_bag_open=false;field_item="";_candy_next();return
	if field_item=="escape_ropes":
		var rope_failure:String=store.ordinary_items.rope(store,map_id)
		field_bag_open=false;field_item="";_close_modal()
		if rope_failure=="":
			var loc:Dictionary=store.state["location"];_change_map(loc["map_id"],Vector2(loc["x"],loc["y"]))
		status.text="离洞绳使用成功，已保存。" if rope_failure=="" else rope_failure;_state_trace("field_item_used" if rope_failure=="" else "field_item_rejected");return
	var item:String=field_item;var failure:String=store.roof_drinks.drink(store,item,index,{"map_id":map_id,"x":player.position.x,"y":player.position.y}) if item in store.roof_drinks.ITEMS else store.vitamins.use(store,item,index,{"map_id":map_id,"x":player.position.x,"y":player.position.y}) if item in store.vitamins.ITEMS else store.medicine.use_field(store,item,index)
	field_bag_open=false;field_item="";_close_modal();status.text=store.SHOP[item]["name"]+"使用成功，已保存。" if failure=="" else failure
	_state_trace("field_item_used" if failure=="" else "field_item_rejected")

func _stone_bag()->void:
	stone_bag_open=true;_new_modal("进化石袋")
	if stone_item=="":
		for i in store.stone_evolution.ITEMS.size():
			var id:String=store.stone_evolution.ITEMS[i];UI.button(modal,"%d %s ×%d"%[i+1,store.SHOP[id]["name"] if store.SHOP.has(id) else "日之石",store.state.get("ground_inventory",{}).get(id,0) if id=="escape_ropes" else store.state.get(id,0)],Rect2(110,155+i*55,735,49),_stone_bag_select.bind(i))
	else:
		for i in store.state["team"].size():
			var pet:Dictionary=store.state["team"][i];var target:String=store.stone_evolution.target(stone_item,pet)
			UI.button(modal,"%d %s · %s"%[i+1,store.species[pet["species_id"]]["name"],"可进化为"+store.species[target]["name"] if target!="" and store.species.has(target) else "不兼容"],Rect2(110,160+i*55,735,49),_stone_bag_select.bind(i))
	UI.label(modal,"Esc取消 · 不兼容不消耗 · 进化成功立即保存",Rect2(110,510,735,36),19)

func _stone_bag_select(index:int)->void:
	if stone_item=="":
		if index<0 or index>=store.stone_evolution.ITEMS.size():return
		stone_item=store.stone_evolution.ITEMS[index];_stone_bag();return
	if index<0 or index>=store.state["team"].size():return
	var plan:Dictionary=store.stone_evolution.preview(store,stone_item,index)
	stone_bag_open=false;stone_item=""
	if plan.is_empty():_close_modal();status.text="不能进化：检查石头、不变之石及全国图鉴条件。";return
	_evolution_begin(plan,index,"stone")

func _hm_rules()->RefCounted:
	return store.sevii_hm if sevii_teaching!="" else store.flash if flash_teaching else store.travel if fly_teaching else store.strength if strength_teaching else store.surf if surf_teaching else store.cut_rules

func _travel_prompt(action:String,title:String,text:String)->void:
	travel_action=action;trainer_ready_at=Time.get_ticks_msec()+250;_new_modal(title)
	UI.label(modal,text+"\nE / Enter确认 · Esc取消",Rect2(105,190,745,240),22)
	_state_trace("travel_prompt_"+action)

func _travel_input(key:int)->void:
	if Time.get_ticks_msec()<trainer_ready_at:return
	if key in [KEY_ESCAPE,KEY_B]:travel_action="";travel_target="";_close_modal();_state_trace("travel_cancelled");return
	if travel_action=="destinations":
		var choices:Array=store.state.get("travel",{}).get("visited",[])
		if key>=KEY_1 and key<=KEY_9 and key-KEY_1<choices.size():_fly_confirm(choices[key-KEY_1])
		return
	if key not in [KEY_E,KEY_ENTER,KEY_SPACE]:return
	var action:String=travel_action;travel_action="";_close_modal()
	if action=="info":return
	store.state["location"]={"map_id":map_id,"x":player.position.x,"y":player.position.y}
	var failure:String=store.travel.fly_to(store,map_id,travel_target) if action=="fly" else store.travel.transaction(store,action,map_id)
	if failure=="" and action=="fly":riding=false;_restore_location()
	status.text=failure if failure!="" else {"hm02":"获得HM02飞翔！L教学，户外F选择已到城镇。","voucher":"听完会长的故事，获得自行车兑换券！请到华蓝市车店兑换。","bicycle":"兑换券已交还，获得自行车！户外按V骑乘。","fly":"飞翔到达！HP、PP与物品保持原状。"}.get(action,"")
	travel_target="";_state_trace("travel_"+action+("_failed" if failure!="" else "_success"))

func _fly_menu()->void:
	var failure:String=store.travel.field_error(store.state,map_id)
	if failure!="":status.text=failure;_state_trace("fly_refused");return
	travel_action="destinations";_new_modal("飞翔 · 仅限实际到达的城镇")
	var choices:Array=store.state.get("travel",{}).get("visited",[])
	for i in choices.size():
		UI.button(modal,"%d %s"%[i+1,choices[i]],Rect2(105+(i/6)*375,165+(i%6)*46,365,42),_fly_confirm.bind(choices[i]))
	UI.button(modal,"Esc 取消",Rect2(105,480,740,45),func():travel_action="";_close_modal())
	trainer_ready_at=Time.get_ticks_msec()+250;_state_trace("fly_destinations")

func _fly_confirm(target:String)->void:
	travel_target=target;_travel_prompt("fly","飞翔 · 确认目的地","要飞往%s吗？不会消耗PP。"%target)

func _bicycle_toggle()->void:
	if riding and store.travel.cycling(map_id,player.position):status.text="自行车道上不能下车。";_state_trace("bicycle_dismount_refused");return
	var failure:String=store.travel.ride_error(store.state,map_id)
	if failure!="":status.text=failure;_state_trace("bicycle_refused");return
	riding=not riding;player.cycling=riding
	player.sprite.texture=load("res://assets/bicycle/ride-0.png" if riding else "res://assets/pokemon/red-0.png")
	status.text="骑上自行车！V下车。" if riding else "已下车。";_state_trace("bicycle_mounted" if riding else "bicycle_dismounted")

func _travel_interact(cell:Vector2i)->bool:
	if map_id in ["route17","route18","route19","route20"]:
		for tr in trainer_rules.route17+trainer_rules.o04+trainer_rules.o05:
			if tr["map"]!=map_id:continue
			var target:=Vector2i(tr["cell"][0],tr["cell"][1]);var delta:=target-cell
			if absi(delta.x)+absi(delta.y)==1 and Vector2(delta).normalized().dot(player.facing)>=0.9:_forest_trainer_interact(tr);return true
	for a in travel_actors+o04_actors:
		if a["map"]!=map_id:continue
		var target:=Vector2i(a["cell"][0],a["cell"][1]);var delta:=target-cell
		var distance:int=absi(delta.x)+absi(delta.y)
		if distance!=(2 if map_id=="bike-shop" and a["redObject"]==1 else 1) or Vector2(delta).normalized().dot(player.facing)<0.9:continue
		if map_id=="route18-gate-1f":
			status.text="自行车道上坡很辛苦！" if store.travel.bicycle(store.state) else "自行车道禁止行人，请先取得自行车。";return true
		elif map_id=="route18-gate-2f":
			status.text="这里可以眺望自行车道。宝可梦交换尚未开放。";return true
		elif map_id=="route16":
			if a["redObject"]==7:
				if store.state.get("static_encounters",{}).get("route16_snorlax",false):continue
				if not store.tower_story.flute(store.state):status.text="宝可梦在熟睡，需要宝可梦笛。";_state_trace("snorlax_no_flute");return true
				snorlax_pending=true;trainer_ready_at=Time.get_ticks_msec()+250;_new_modal("卡比兽 · 宝可梦笛");UI.label(modal,"要使用宝可梦笛吗？\nE确认 · Esc取消",Rect2(120,210,720,160),23);return true
			for tr in trainer_rules.route16:
				if tr["redObject"]==a["redObject"]:_forest_trainer_interact(tr);return true
		elif map_id=="route16-fly-house" and a["redObject"]==1:
			_travel_prompt("info" if store.travel.has_hm(store.state) else "hm02","飞翔小屋","HM02可以反复教学。雷电徽章允许场外飞翔到实际到达的城镇。" if store.travel.has_hm(store.state) else "你发现了我的秘密小屋！请替我保密，我把HM02飞翔送给你。");return true
		elif map_id=="pokemon-fan-club" and a["redObject"]==5:
			_travel_prompt("info" if store.state.get("travel",{}).get("voucher_claimed",false) else "voucher","宝可梦迷俱乐部 · 会长","兑换券已经给你了。华蓝市车店可以兑换自行车。" if store.state.get("travel",{}).get("voucher_claimed",false) else "愿意听听我的宝可梦吗？我的烈焰马既可爱又聪明，温暖又美丽！\n听完故事，可获得自行车兑换券。");return true
		elif map_id=="bike-shop" and a["redObject"]==1:
			_travel_prompt("info" if store.travel.bicycle(store.state) else "bicycle","自行车店","新自行车骑得怎么样？" if store.travel.bicycle(store.state) else "欢迎！持自行车兑换券可换一辆自行车。\n无券售价100万元，不能购买。");return true
		else:
			status.text="大嘴雀：咕嘎！" if map_id=="route16-fly-house" else "自行车道禁止行人，请带好自行车。" if map_id=="route16-gate-1f" else "我们一起骑车来玩。" if map_id=="route16-gate-2f" else "自行车很方便！" if map_id=="bike-shop" else "我最喜欢自己的宝可梦！"
			_state_trace("travel_visitor");return true
	return false

func _o05_transition(cell:Vector2i)->bool:
	if map_id=="fuchsia-city" and cell.x in [16,17,18,19,20,21,23] and player.position.y>=568 and player.velocity.y>0:
		_change_map("route19",Vector2(player.position.x-160,9));return true
	if map_id=="route19" and cell.x in [6,7,8,9,10,11,13] and player.position.y<=9 and player.velocity.y<0:
		_change_map("fuchsia-city",Vector2(player.position.x+160,569));return true
	if map_id=="route19" and cell.y>=36 and player.position.x<=9 and player.velocity.x<0 and store.state.get("surfing",false):
		_change_map("route20",Vector2(888,player.position.y-576));return true
	if map_id=="route20" and player.position.x<=8 and cell.y in [2,3,4,5,6,7,8] and player.velocity.x<0 and store.state.get("surfing",false):
		_change_map("cinnabar-island",Vector2(56,cell.y*16+9));return true
	if map_id=="route20" and player.position.x>=888 and player.velocity.x>0 and store.state.get("surfing",false):
		_change_map("route19",Vector2(8,player.position.y+576));return true
	if map_id=="cinnabar-island" and player.position.x>=48 and cell.y in [2,3,4,5,6,7,8] and player.velocity.x>0 and store.state.get("surfing",false):
		_change_map("route20",Vector2(8,cell.y*16+9));return true
	return false

func _seafoam_fall(cell:Vector2i)->bool:
	if player.velocity==Vector2.ZERO:return false
	var row:Dictionary=store.seafoam.edge(map_id,cell)
	if row.is_empty():return false
	if not store.seafoam.player_open(map_id,store.state):
		status.text="强制水流与B4F留待O08；此洞暂不开放。";return true
	var before:Dictionary=store.state.duplicate(true)
	var destination:String=row["target"];var at:Array=row["arrival"]
	store.state["surfing"]=destination in ["seafoam-islands-b3f","seafoam-islands-b4f"]
	store.state["location"]={"map_id":destination,"x":int(at[0])*16+8,"y":int(at[1])*16+9}
	if not store.save_game():
		store.state=before;status.text=store.error;_state_trace("seafoam_player_fall_failed");return true
	_change_map(destination,Vector2(int(at[0])*16+8,int(at[1])*16+9))
	_state_trace("seafoam_player_fell");return true

func _seafoam_begin(cell:Vector2i,entered:bool)->bool:
	if not seafoam_current.is_empty() or not map_id.begins_with("seafoam-islands-"):return false
	var row:Dictionary=store.seafoam.current(map_id,cell,store.state,entered)
	if row.is_empty():return false
	seafoam_current=row["steps"].duplicate();seafoam_current_index=0;seafoam_current_clock=0.0;seafoam_current_land=row["land"]
	var end:Vector2i=cell
	for step in seafoam_current:end+=step
	seafoam_current_end=Vector2(end.x*16+8,end.y*16+9)
	player.position=Vector2(cell.x*16+8,cell.y*16+9);player.active=false;player.velocity=Vector2.ZERO
	_trace({"event":"seafoam_current_started","map":map_id,"steps":seafoam_current.size()});return true
func _seafoam_tick(delta:float)->void:
	player.active=false;player.velocity=Vector2.ZERO;seafoam_current_clock-=delta
	if seafoam_current_clock>0:return
	var step:Vector2i=seafoam_current[seafoam_current_index]
	var old:=Vector2i(floori(player.position.x/16),floori((player.position.y-1)/16));var next:Vector2i=old+step
	var water_step:bool=next.x>=0 and next.y>=0 and next.x<int(layout["width"]) and next.y<int(layout["height"]) and store.surf.water(map_id,layout,next)
	if next.x<0 or next.y<0 or next.x>=int(layout["width"]) or next.y>=int(layout["height"]) or layout["solid"][next.y][next.x]!=0 and not water_step:
		seafoam_current_fault=true;seafoam_current=[];player.active=true;push_error("Invalid source Seafoam current step");return
	player.position=Vector2(next.x*16+8,next.y*16+9);player.facing=Vector2(step);seafoam_current_index+=1;seafoam_current_clock=0.12
	if seafoam_current_index<seafoam_current.size():return
	seafoam_current=[];player.active=true
	if map_id=="seafoam-islands-b3f":
		player.velocity=Vector2(step)*84;moon_warp_latch="";_forest_transition(next)
	elif seafoam_current_land:
		store.state["surfing"]=false;_build_map(map_id,player.position)
	_trace({"event":"seafoam_current_stopped","map":map_id,"cell":[next.x,next.y]})

func _o13_boundary() -> bool:
	if map_id=="vermilion-city" and player.position.x>631 and player.velocity.x>0 and player.position.y>=128 and player.position.y<416 and _o13_landing_clear("route11",0,player.position.y-128):
		_change_map("route11",Vector2(9,player.position.y-128));player.facing=Vector2.RIGHT;return true
	if map_id=="route11" and player.position.x<8 and player.velocity.x<0 and _o13_landing_clear("vermilion-city",39,player.position.y+128):
		_change_map("vermilion-city",Vector2(631,player.position.y+128));player.facing=Vector2.LEFT;return true
	if map_id=="route11" and player.position.x>951 and player.velocity.x>0 and _o13_landing_clear("route12",0,player.position.y+864):
		_change_map("route12",Vector2(9,player.position.y+864));player.facing=Vector2.RIGHT;return true
	if map_id=="route12" and player.position.x<8 and player.velocity.x<0 and player.position.y>=864 and player.position.y<1152 and _o13_landing_clear("route11",59,player.position.y-864):
		_change_map("route11",Vector2(951,player.position.y-864));player.facing=Vector2.LEFT;return true
	return false

func _o13_edge_colliders(parent:Node2D,id:String,east:bool) -> void:
	var destination:String="route11" if id!="route11" else "route12" if east else "vermilion-city"
	var target:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://data/%s.json" % destination))
	var offset:int=-8 if id=="vermilion-city" else -54 if id=="route12" else 54 if east else 8
	var tx:int=0 if east else int(target["width"])-1
	for y in range(int(layout["height"])):
		var ty:int=y+offset
		if ty<0 or ty>=int(target["height"]) or int(target["solid"][ty][tx])!=0:
			_add_solid(parent,Rect2(int(layout["width"])*16 if east else -16,y*16,16,16))

func _o13_landing_clear(id:String,x:int,y:float) -> bool:
	var d:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://data/%s.json" % id))
	for py in [y-6,y+1.9]:
		var cy:int=floori(py/16)
		if cy<0 or cy>=int(d["height"]) or int(d["solid"][cy][x])!=0:return false
	return true

func _o14_interact(cell:Vector2i)->bool:
	for actor in o14_actors:
		if actor["map"]!=map_id or cell+Vector2i(player.facing)!=Vector2i(int(actor["cell"][0]),int(actor["cell"][1])):continue
		if actor["role"]=="aide":
			if store.flash_reward.claimed(store.state):status.text="HM05闪光已经领取过。I教学；U在岩山隧道使用。"
			else:
				flash_pending=true;_new_modal("大木博士的助手 · HM05闪光")
				UI.label(modal,"图鉴有至少10种关都宝可梦的捕获或拥有资料吗？\n1 / E 确认检查 · 2 拒绝 · Esc / B 取消。",Rect2(100,200,755,180),22)
		elif map_id=="route2-gate":status.text="岩山隧道很黑。闪光可以照亮洞穴；I教学；U在岩山隧道使用。"
		elif int(actor["redObject"])==1:status.text="这里是2号道路东侧的民居。南方关卡里有大木博士的助手。"
		else:status.text="这里的宝可梦交换服务尚未开放。"
		_state_trace("o14_location_dialogue");return true
	return false

func _flash_field() -> Dictionary:
	var permission: Dictionary=store.flash.field_permission(store.state,map_id,flash_active)
	if bool(permission["allowed"]):
		var before: Dictionary=store.state.duplicate(true)
		flash_active=true
		store.state["flash_active"]=true
		if not _save():
			store.state=before;flash_active=false;permission={"allowed":false,"reason":store.error,"user_index":permission["user_index"]}
		else:
			if is_instance_valid(flash_mask):flash_mask.material.set_shader_parameter("enabled",true)
			_state_trace("flash_activated")
	status.text=permission["reason"]
	_trace({"event":"flash_permission","permission":permission,"map":map_id})
	return permission

func _flash_update_center() -> void:
	if is_instance_valid(flash_mask) and is_instance_valid(player):
		var center: Vector2 = (player.get_global_transform_with_canvas() * Vector2(0,-8) - flash_mask.position) / flash_mask.size
		flash_mask.material.set_shader_parameter("light_center",center)

func _flash_mask_material() -> ShaderMaterial:
	var shader := Shader.new()
	# Source darkness is a small player-centred window; Flash removes darkness.
	# Pixel aspect correction keeps the adapted opening circular on the 960x576 map area.
	shader.code = "shader_type canvas_item; uniform vec2 light_center = vec2(0.5); uniform float radius = 48.0; uniform bool enabled = false; void fragment(){ float d=length((UV-light_center)*vec2(960.0,576.0)); float alpha=enabled ? 0.0 : smoothstep(radius-4.0,radius,d); COLOR=vec4(0.0,0.0,0.0,alpha); }"
	var material := ShaderMaterial.new()
	material.shader=shader
	material.set_shader_parameter("radius",48.0)
	material.set_shader_parameter("enabled",false)
	return material

func _o15_interact(cell:Vector2i)->bool:
	for actor in o15_actors:
		if actor["map"]!=map_id or cell+Vector2i(player.facing)!=Vector2i(int(actor["cell"][0]),int(actor["cell"][1])):continue
		if actor["role"]=="fossil_scientist":_lab_fossil_menu();return true
		elif actor["role"]=="trade_deferred":status.text="这里的宝可梦交换服务尚未开放。"
		else:status.text="这里是红莲研究所。东侧房间研究化石；其他房间尚未开放。"
		_state_trace("o15_location_dialogue");return true
	return false

func _lab_fossil_menu()->void:
	if store.state.has("fossil_lab"):
		if store.state["fossil_lab"]["stage"]=="ready":
			var failure:String=store.fossil_rules.claim(store,{"map_id":map_id,"x":player.position.x,"y":player.position.y})
			status.text=failure if failure!="" else "复活宝可梦已领取并保存。队满时已送入盒子。"
			fossil_label.text=store.fossil_rules.summary(store.state)
			_state_trace("lab_fossil_claim_failed" if failure!="" else "lab_fossil_claimed")
		else:status.text="已经领取，不能重复领取。" if store.state["fossil_lab"]["stage"]=="claimed" else "正在复活。请先离开研究室，再回来领取。不能重复提交。"
		return
	var choices:Array[String]=store.fossil_rules.available(store.state)
	if choices.is_empty():status.text="没有可交付的化石，未收取物品。";return
	lab_fossil_phase="select";lab_fossil_item="";trainer_ready_at=Time.get_ticks_msec()+250
	_new_modal("化石研究员 · 选择化石")
	UI.label(modal,"选择要交付的化石。Esc取消。\n交付后先离开研究室，再回来领取。",Rect2(100,175,750,95),22)
	for i in range(choices.size()):
		var item:String=choices[i]
		UI.button(modal,"%d %s"%[i+1,_lab_fossil_name(item)],Rect2(120,290+i*70,710,60),func():_lab_fossil_choose(item))
	UI.button(modal,"Esc 取消",Rect2(120,450,710,60),_lab_fossil_cancel)
	_state_trace("lab_fossil_selection")

func _lab_fossil_name(item:String)->String:
	return "甲壳化石" if item=="dome_fossil" else "贝壳化石"

func _lab_fossil_choose(item:String)->void:
	if lab_fossil_phase!="select" or Time.get_ticks_msec()<trainer_ready_at:return
	if item not in store.fossil_rules.available(store.state):_lab_fossil_cancel();return
	lab_fossil_phase="confirm";lab_fossil_item=item;trainer_ready_at=Time.get_ticks_msec()+250
	_new_modal("化石研究员 · 确认交付")
	UI.label(modal,"交付%s？\n确认后收取化石并保存。\n离开研究室后返回领取。"%_lab_fossil_name(item),Rect2(100,190,750,140),23)
	UI.button(modal,"1 / E 确认交付",Rect2(105,370,350,65),_lab_fossil_confirm)
	UI.button(modal,"2 / Esc 取消",Rect2(475,370,350,65),_lab_fossil_cancel)
	_state_trace("lab_fossil_confirmation")

func _lab_fossil_cancel()->void:
	lab_fossil_phase="";lab_fossil_item="";_close_modal();status.text="已取消，未收取化石。";_state_trace("lab_fossil_cancelled")

func _lab_fossil_confirm()->void:
	if lab_fossil_phase!="confirm" or Time.get_ticks_msec()<trainer_ready_at:return
	var item:String=lab_fossil_item
	lab_fossil_phase="";lab_fossil_item="";_close_modal()
	var failure:String=store.fossil_rules.deliver(store,item,{"map_id":map_id,"x":player.position.x,"y":player.position.y})
	status.text=failure if failure!="" else "已交付%s并保存。离开研究室后返回领取。"%_lab_fossil_name(item)
	fossil_label.text=store.fossil_rules.summary(store.state)
	_state_trace("lab_fossil_failed" if failure!="" else "lab_fossil_delivered")

func _lab_fossil_input(k:int)->void:
	if Time.get_ticks_msec()<trainer_ready_at:return
	if k in [KEY_ESCAPE,KEY_B] or (lab_fossil_phase=="confirm" and k==KEY_2):_lab_fossil_cancel();return
	if lab_fossil_phase=="confirm":
		if k in [KEY_1,KEY_E,KEY_ENTER,KEY_SPACE]:_lab_fossil_confirm()
	elif k in [KEY_1,KEY_2]:
		var choices:Array[String]=store.fossil_rules.available(store.state)
		var index:int=k-KEY_1
		if index<choices.size():_lab_fossil_choose(choices[index])

func _celadon_mart_interact(cell:Vector2i)->bool:
	if map_id=="celadon-mart-elevator":
		var panel:=Vector2i(3,0)
		if absi(cell.x-panel.x)+absi(cell.y-panel.y)==1 and player.facing.dot(Vector2(panel-cell))>0.5:
			celadon_lift_pending=true;trainer_ready_at=Time.get_ticks_msec()+250;_new_modal("玉虹百货 · 电梯")
			UI.label(modal,"1  1F\n2  2F\n3  3F\n4  4F\n5  5F\nEsc 取消 · 屋顶请走5F楼梯",Rect2(150,170,680,350),23);_state_trace("celadon_lift_menu");return true
	for actor in o16_actors:
		if actor["map"]!=map_id:continue
		var ac:=Vector2i(int(actor["cell"][0]),int(actor["cell"][1]))
		if absi(cell.x-ac.x)+absi(cell.y-ac.y)==1 and player.facing.dot(Vector2(ac-cell))>0.5:
			if map_id=="celadon-mart-3f":
				if int(actor["redObject"])==1:_counter_menu("offer")
				else:status.text=store.counter_tutor.data["dialogue"][str(int(actor["redObject"]))]+"（交换与通信进化未开放。）"
				return true
			if map_id=="celadon-mart-4f":
				if int(actor["redObject"])==1:_shop_dialog("list")
				else:status.text="进化石能让特定宝可梦进化；皮皮玩偶用于野战逃脱，复古邮件可从G袋写信。"
				return true
			if map_id=="celadon-mart-5f":
				if int(actor["redObject"]) in [1,2]:
					shop_stock_kind="battle" if int(actor["redObject"])==2 else "vitamins"
					_shop_dialog("list")
				else:status.text="5F出售营养药与战斗道具。"
				return true
			if map_id=="celadon-mart-roof":
				if int(actor["redObject"])==1:_roof_vending();return true
				if int(actor["redObject"])==2:_roof_girl();return true
			status.text="本层交互尚未开放；教学、商品、饮料与交易后续开放。";return true
	if map_id=="celadon-mart-roof":
		for actor in o16_actors:
			if actor["map"]!=map_id:continue
			var ac:=Vector2i(int(actor["cell"][0]),int(actor["cell"][1]))
			if absi(cell.x-ac.x)+absi(cell.y-ac.y)==1 and player.facing.dot(Vector2(ac-cell))>0.5:
				if int(actor["redObject"])==1:_roof_vending();return true
				if int(actor["redObject"])==2:_roof_girl();return true
	# Counters are solid source props, not active services.
	if map_id=="celadon-mart-5f":
		for actor in o16_actors:
			if actor["map"]!=map_id:continue
			var ac:=Vector2i(int(actor["cell"][0]),int(actor["cell"][1]))
			if absi(cell.x-ac.x)+absi(cell.y-ac.y)==1 and player.facing.dot(Vector2(ac-cell))>0.5:
				if int(actor["redObject"]) in [1,2]:
					shop_stock_kind="battle" if int(actor["redObject"])==2 else "vitamins"
					_shop_dialog("list")
				else:status.text="5F出售营养药与战斗道具。"
				return true
	if map_id=="celadon-mart-3f":
		status.text="本层交互尚未开放；教学、商品与交易后续开放。";return true
	return false

func _roof_vending()->void:
	shop_stock_kind="roof";_new_modal("玉虹百货屋顶 · 自动售货机");roof_phase="vending"
	UI.label(modal,"余额 %d\n1 清凉水 200（HP +50）\n2 苏打汽水 300（HP +60）\n3 柠檬汽水 350（HP +80）\nEsc 离开"%int(store.state["money"]),Rect2(110,170,735,250),22);trainer_ready_at=Time.get_ticks_msec()+250
func _roof_girl()->void:
	var available:Array[String]=[]
	for item in store.roof_drinks.ITEMS:
		if int(store.state.get(item,0))>0 and not store.state.get("roof_exchanges",{}).get(item,false):available.append(item)
	if available.is_empty():status.text="女孩：我还想喝饮料呢！你可以从自动售货机购买。";return
	roof_phase="drink";_new_modal("屋顶女孩 · 饮料兑换");trainer_ready_at=Time.get_ticks_msec()+250
	UI.label(modal,"选择要送给女孩的饮料。兑换后会消耗饮料，并获得对应TM。",Rect2(110,160,735,70),20)
	for i in available.size():UI.button(modal,"%d %s → %s"%[i+1,store.roof_drinks.NAMES[available[i]],store.roof_drinks.TM_NAMES[store.roof_drinks.TM[available[i]]]],Rect2(115,250+i*60,720,52),_roof_choose.bind(available[i]))
	UI.button(modal,"Esc 取消",Rect2(115,460,720,50),_roof_close)
func _roof_choose(item:String)->void:
	roof_item=item;roof_phase="confirm";_new_modal("确认饮料兑换")
	UI.label(modal,"交出%s，获得%s并放入TM口袋？"%[store.roof_drinks.NAMES[item],store.roof_drinks.TM_NAMES[store.roof_drinks.TM[item]]],Rect2(110,190,735,130),22)
	UI.button(modal,"1 / E 确认",Rect2(110,385,355,60),_roof_confirm)
	UI.button(modal,"Esc 取消",Rect2(485,385,355,60),_roof_close);trainer_ready_at=Time.get_ticks_msec()+250
func _roof_select(index:int)->void:
	var failure:String=store.roof_drinks.exchange_error(store.state,roof_item,index)
	if failure!="":status.text=failure;return
	roof_index=index;var pet:Dictionary=store.state["team"][index]
	if pet["moves"].size()<4:_roof_slot(pet["moves"].size())
	else:
		roof_phase="slot";_new_modal("选择要替换的招式")
		for i in pet["moves"].size():UI.button(modal,"%d %s%s"%[i+1,store.growth.moves[pet["moves"][i]]["name"]," · 秘传不可替换" if pet["moves"][i] in store.growth.HM_MOVES else ""],Rect2(110,165+i*58,735,50),_roof_slot.bind(i))
		var cancel := UI.button(modal,"Esc 取消",Rect2(110,505,735,42),_roof_close)
		cancel.focus_mode = Control.FOCUS_ALL
		cancel.call_deferred("grab_focus")
		cancel.add_theme_color_override("font_focus_color",Color("303840"))
		trainer_ready_at=Time.get_ticks_msec()+250
func _roof_slot(slot:int)->void:
	var pet:Dictionary=store.state["team"][roof_index]
	if slot<pet["moves"].size() and pet["moves"][slot] in store.growth.HM_MOVES:status.text="秘传招式不能在这里遗忘。";return
	roof_slot=slot;roof_phase="confirm";_new_modal("确认饮料兑换")
	var old:String=store.growth.moves[pet["moves"][slot]]["name"] if slot<pet["moves"].size() else "空位"
	UI.label(modal,"交出%s，获得%s并学习%s？\n会替换：%s。确认后不可重复兑换。"%[store.roof_drinks.NAMES[roof_item],store.roof_drinks.TM_NAMES[store.roof_drinks.TM[roof_item]],store.growth.moves[store.roof_drinks.MOVES[roof_item]]["name"],old],Rect2(110,185,735,150),21)
	UI.button(modal,"1 / E 确认",Rect2(110,385,355,60),_roof_confirm);UI.button(modal,"2 / Esc 取消",Rect2(485,385,355,60),_roof_close);trainer_ready_at=Time.get_ticks_msec()+250
func _roof_confirm()->void:
	if roof_phase!="confirm":return
	roof_phase="";_close_modal();var failure:String=store.roof_drinks.exchange(store,roof_item,roof_index,roof_slot,{"map_id":map_id,"x":player.position.x,"y":player.position.y})
	status.text=failure if failure!="" else "获得%s，已放入TM口袋。G选择教学。"%store.roof_drinks.TM_NAMES[store.roof_drinks.TM[roof_item]];_state_trace("roof_exchange_failed" if failure!="" else "roof_exchange_success")
func _roof_close()->void:
	roof_phase="";roof_item="";roof_index=-1;_close_modal();status.text="已取消，饮料与兑换机会保留。"
func _roof_input(key:int)->void:
	if Time.get_ticks_msec()<trainer_ready_at:return
	if key in [KEY_ESCAPE,KEY_B] or roof_phase=="confirm" and key==KEY_2:_roof_close();return
	if roof_phase=="vending" and key in [KEY_1,KEY_2,KEY_3]:
		var item:String=store.roof_drinks.ITEMS[key-KEY_1];var failure:String=store.purchase(item,1)
		status.text=failure if failure!="" else "购买%s ×1，已保存。"%store.roof_drinks.NAMES[item];_state_trace("roof_vend_failed" if failure!="" else "roof_vend_success");roof_phase="";_close_modal()
	elif roof_phase=="drink" and key in [KEY_1,KEY_2,KEY_3]:
		var available:Array=[]
		for item in store.roof_drinks.ITEMS:
			if int(store.state.get(item,0))>0 and not store.state.get("roof_exchanges",{}).get(item,false):available.append(item)
		if key-KEY_1<available.size():_roof_choose(available[key-KEY_1])
	elif roof_phase=="party" and key>=KEY_1 and key<=KEY_6:_roof_select(key-KEY_1)
	elif roof_phase=="slot" and key>=KEY_1 and key<=KEY_4:_roof_slot(key-KEY_1)
	elif roof_phase=="confirm" and key in [KEY_1,KEY_E,KEY_ENTER,KEY_SPACE]:_roof_confirm()

func _counter_close()->void:
	counter_phase="";counter_index=-1;counter_slot=-1;_close_modal()
func _counter_menu(phase:String)->void:
	if map_id!="celadon-mart-3f":return
	if store.state.get("counter_taught",false):status.text="我教的双倍奉还，用得怎么样？只能教一次。";return
	counter_phase=phase;trainer_ready_at=Time.get_ticks_msec()+250
	_new_modal("玉虹百货3F · 双倍奉还教学")
	if phase=="offer":
		UI.label(modal,"我终于通关宝可梦了！要教你的宝可梦双倍奉还吗？\n只能成功教学一次。不是指我靠着的柜台哦！\n1 / E 接受，Esc 取消。",Rect2(105,180,745,190),22)
		UI.button(modal,"接受教学",Rect2(110,390,735,60),_counter_menu.bind("party"))
	elif phase=="party":
		for i in range(store.state["team"].size()):
			var pet:Dictionary=store.state["team"][i]
			var error:String=store.counter_tutor.learn_error(store.state,i)
			UI.button(modal,"%d %s · %s"%[i+1,store.species[pet["species_id"]]["name"],"可以学习" if error=="" else error],Rect2(105,168+i*46,745,42),_counter_select.bind(i))
	elif phase=="slot":
		var pet:Dictionary=store.state["team"][counter_index]
		for i in range(4):UI.button(modal,"%d 遗忘%s"%[i+1,store.growth.moves[pet["moves"][i]]["name"]],Rect2(105,175+i*60,745,52),_counter_pick_slot.bind(i))
	elif phase=="confirm":
		var pet:Dictionary=store.state["team"][counter_index]
		var old:String=store.growth.moves[pet["moves"][counter_slot]]["name"] if counter_slot<pet["moves"].size() else "空位"
		UI.label(modal,"学习双倍奉还（PP20），替换：%s。\n成功后本次教学机会用尽。\n1 / E 确认，Esc 取消。"%old,Rect2(105,190,745,170),22)
		UI.button(modal,"确认学习",Rect2(110,390,735,60),_counter_confirm)
	UI.button(modal,"Esc 取消",Rect2(110,485,735,50),_counter_close)
func _counter_select(index:int)->void:
	var error:String=store.counter_tutor.learn_error(store.state,index)
	if error!="":status.text=error;return
	counter_index=index
	if store.state["team"][index]["moves"].size()<4:_counter_pick_slot(store.state["team"][index]["moves"].size())
	else:_counter_menu("slot")
func _counter_pick_slot(slot:int)->void:
	var pet:Dictionary=store.state["team"][counter_index]
	if slot<0 or slot>pet["moves"].size() or slot>=4:return
	if slot<pet["moves"].size() and pet["moves"][slot] in store.growth.HM_MOVES:status.text="秘传招式不能在这里遗忘。";return
	counter_slot=slot;_counter_menu("confirm")
func _counter_confirm()->void:
	if counter_phase!="confirm":return
	var error:String=store.counter_tutor.teach(store,counter_index,counter_slot,{"map_id":map_id,"x":player.position.x,"y":player.position.y})
	_counter_close();status.text=error if error!="" else "学会了双倍奉还！教学机会已使用，已保存。"
	_state_trace("counter_tutor_failed" if error!="" else "counter_tutor_taught")
func _counter_input(k:int)->void:
	if Time.get_ticks_msec()<trainer_ready_at:return
	if k in [KEY_ESCAPE,KEY_B]:_counter_close();return
	if counter_phase=="offer" and k in [KEY_1,KEY_E,KEY_ENTER,KEY_SPACE]:_counter_menu("party")
	elif counter_phase=="party" and k>=KEY_1 and k<=KEY_6:_counter_select(k-KEY_1)
	elif counter_phase=="slot" and k>=KEY_1 and k<=KEY_4:_counter_pick_slot(k-KEY_1)
	elif counter_phase=="confirm" and k in [KEY_1,KEY_E,KEY_ENTER,KEY_SPACE]:_counter_confirm()

func _ground_item_interact(cell: Vector2i) -> bool:
	for entry in store.ground_items.entries:
		if entry["map"]!=map_id or store.ground_items.claimed(store.state,entry):continue
		var target:=Vector2i(entry["cell"][0],entry["cell"][1])
		if cell+Vector2i(player.facing)!=target or boulders.index(target)>=0:continue
		var before_position:Vector2=player.position
		var before_state:Dictionary=store.state.duplicate(true)
		var saved_position:Vector2=boulders.safe_position(before_position)
		store.state["location"]={"map_id":map_id,"x":saved_position.x,"y":saved_position.y}
		var failure:String=store.ground_items.take(store,entry)
		if failure=="":_change_map(map_id,before_position)
		else:store.state=before_state
		status.text=("获得%s×1，已放入背包并保存。G查看地面道具。" % store.ground_items.display_name(store,entry)) if failure=="" else failure
		_state_trace("ground_item_taken" if failure=="" else "ground_item_failed")
		_trace({"event":"ground_item_result","key":entry["key"],"success":failure=="","failure":failure})
		return true
	return false

func _ground_item_bag() -> void:
	_new_modal("背包 · 地面道具 · Esc返回")
	var scroll:=ScrollContainer.new();scroll.position=Vector2(100,145);scroll.size=Vector2(755,400);modal.add_child(scroll)
	var rows:=VBoxContainer.new();rows.size_flags_horizontal=Control.SIZE_EXPAND_FILL;scroll.add_child(rows)
	var seen:Array=[]
	for entry in store.ground_items.entries:
		if entry["inventory"].begins_with("fr_tm") or entry["inventory"] in seen:continue
		seen.append(entry["inventory"])
		var amount:int=store.ground_items.quantity(store.state,entry)
		if amount<=0:continue
		var item:String=entry["inventory"]
		var text:String="%s ×%d" % [tm_rules.display_name(item) if tm_rules.data.has(item) else store.ground_items.display_name(store,entry),amount]
		if tm_rules.data.has(item) or item in store.medicine.MEDICINES+store.vitamins.ITEMS+store.ordinary_items.ITEMS+store.stone_evolution.ITEMS:
			var button:=UI.button(rows,text+" · 使用",Rect2(0,0,700,48),_ground_use.bind(item))
			button.custom_minimum_size=Vector2(700,48)
		else:
			var label:=Label.new();label.add_theme_color_override("font_color",Color("303840"));label.text=text;rows.add_child(label)
	if tm_rules.quantity(store.state,"tm_dig")>0:
		var button:=UI.button(rows,"TM28 挖洞 · 教学",Rect2(0,0,700,48),_ground_use.bind("tm_dig"));button.custom_minimum_size=Vector2(700,48)
	for item in store.state.get("tm_inventory",{}):
		if tm_rules.quantity(store.state,item)<=0:continue
		var reward:Dictionary=store.gym_rewards.item_row(item)
		var caption:String=tm_rules.display_name(item) if tm_rules.data.has(item) else store.gym_rewards.description(item,tm_rules) if not reward.is_empty() else str(store.SHOP[item]["name"])+" · 教学"
		if not tm_rules.data.has(item):
			var label:=Label.new();label.add_theme_color_override("font_color",Color("303840"));label.text="%s ×%d"%[caption,tm_rules.quantity(store.state,item)];rows.add_child(label)
		else:
			var button:=UI.button(rows,"%s ×%d"%[caption,tm_rules.quantity(store.state,item)],Rect2(0,0,700,48),_ground_use.bind(item));button.custom_minimum_size=Vector2(700,48)
	for reward in tm_acquisition.TABLE:
		var reward_item:String=reward[1]
		if reward_item=="fr_tm10" or reward_item in seen:continue
		var reward_quantity:int=store.inventory.quantity(store.state,reward_item)
		if reward_quantity>0:
			var reward_label:=Label.new();reward_label.text="%s ×%d"%[store.inventory.catalog["items"].get(reward_item,{}).get("name",reward_item),reward_quantity];rows.add_child(reward_label)
	if int(store.state.get("retro_mail",0))>0 or store.state["team"].any(func(p):return p.get("held_item","")=="retro_mail"):
		var mail_button:=UI.button(rows,"复古邮件 · 写信／阅读／取下",Rect2(0,0,700,48),_mail_menu);mail_button.custom_minimum_size=Vector2(700,48)
	for i in range(store.state["team"].size()):
		var held:String=store.state["team"][i].get("held_item","")
		if tm_acquisition.TABLE.any(func(row):return row[1]==held):
			var take_button:=UI.button(rows,"%s · 取下 %s"%[store.species[store.state["team"][i]["species_id"]]["name"],tm_rules.display_name(held) if tm_rules.data.has(held) else store.inventory.catalog["items"].get(held,{}).get("name",held)],Rect2(0,0,700,48),_pickup_take.bind(i));take_button.custom_minimum_size=Vector2(700,48)
	for key in ["meteorite","tri_pass","ruby","rainbow_pass","iapapa_berry"]:
		var amount:int=int(store.state.get("sevii",{}).get(key,0))
		if amount>0:
			var label:=Label.new();label.text={"meteorite":"陨石","tri_pass":"三岛通行证","ruby":"红宝石","rainbow_pass":"彩虹通行证","iapapa_berry":"芭亚果"}[key]+" ×%d"%amount;label.add_theme_color_override("font_color",Color("303840"));rows.add_child(label)
	_state_trace("ground_item_bag_open")

func _candy_next()->void:
	var pet:Dictionary=candy_pending["pet"]
	while not candy_pending["learns"].is_empty():
		var move:String=candy_pending["learns"][0]
		if pet["moves"].size()<4:
			store.growth.resolve_learning(pet,move,pet["moves"].size());candy_pending["learns"].pop_front();continue
		_new_modal("神奇糖果 · 选择替换招式")
		UI.label(modal,"学习%s：1–4替换；5放弃学习；Esc取消本次使用。"%store.growth.moves[move]["name"],Rect2(100,175,750,100),20)
		for i in 4:UI.label(modal,"%d %s"%[i+1,store.growth.moves[pet["moves"][i]]["name"]],Rect2(110,280+i*45,730,40),20)
		candy_pending["phase"]="learn";return
	if not candy_pending["evolution"].is_empty():
		_new_modal("神奇糖果 · 进化")
		UI.label(modal,"进化为%s？1确认；2不进化；Esc取消本次使用。"%store.species[candy_pending["evolution"]["target"]]["name"],Rect2(100,210,750,100),20)
		candy_pending["phase"]="evolve";return
	_new_modal("使用神奇糖果？")
	UI.label(modal,"升到%d级并消耗1个糖果。1确认；Esc取消。"%pet["level"],Rect2(100,210,750,100),20)
	candy_pending["phase"]="confirm"

func _candy_key(key:int)->void:
	if key==KEY_ESCAPE:candy_pending={};candy_index=-1;_close_modal();return
	var phase:String=candy_pending["phase"]
	if phase=="learn" and key>=KEY_1 and key<=KEY_5:
		var slot:int=key-KEY_1
		if slot<4 and not store.growth.resolve_learning(candy_pending["pet"],candy_pending["learns"][0],slot):return
		candy_pending["learns"].pop_front();_candy_next()
	elif phase=="evolve" and key in [KEY_1,KEY_2]:
		if key==KEY_1:
			var events:Array=store.ordinary_items.evolution.apply(candy_pending["pet"],candy_pending["evolution"],store.state)
			for e in events:candy_pending["learns"].append(e["move"])
		candy_pending["evolution"]={};_candy_next()
	elif phase=="confirm" and key==KEY_1:
		var failure:String=store.ordinary_items.commit_candy(store,candy_index,candy_pending)
		candy_pending={};candy_index=-1;_close_modal();status.text="神奇糖果使用成功，已保存。" if failure=="" else failure;_state_trace("field_item_used" if failure=="" else "field_item_rejected")

func _ground_use(item:String)->void:
	_close_modal()
	if not store.gym_rewards.item_row(item).is_empty() and not tm_rules.data.has(item):
		status.text=store.gym_rewards.description(item,tm_rules);return
	if tm_rules.data.has(item):
		teaching_item=item;_teaching_menu("party");return
	if item in store.stone_evolution.ITEMS:
		stone_item=item;_stone_bag();return
	field_bag_open=true;field_item=item
	if item=="escape_ropes":_field_bag_select(0)
	else:_field_bag()

func _teaching_menu(phase:String)->void:
	teaching_phase=phase;trainer_ready_at=Time.get_ticks_msec()+250
	_new_modal("招式学习器 · 成功才消耗 · Esc取消")
	UI.label(modal,tm_rules.display_name(teaching_item),Rect2(105,147,745,32),20)
	var details:Label=UI.label(modal,tm_rules.summary(store,teaching_item),Rect2(105,179,745,92),17)
	details.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	if phase=="party":
		for i in range(store.state["team"].size()):
			var pet:Dictionary=store.state["team"][i]
			var error:String=tm_rules.learn_error(store,teaching_item,i)
			UI.button(modal,"%d %s · %s"%[i+1,store.species[pet["species_id"]]["name"],"可以学习" if error=="" else error],Rect2(105,276+i*33,745,31),_teaching_select.bind(i))
	elif phase=="slot":
		var pet:Dictionary=store.state["team"][teaching_index]
		for i in range(pet["moves"].size()):
			var old:String=pet["moves"][i]
			UI.button(modal,"%d %s · PP%d/%d%s"%[i+1,store.growth.moves[old]["name"],int(pet["pp"][old]),int(store.growth.moves[old]["pp"])," · 秘传不可遗忘" if old in store.growth.HM_MOVES else ""],Rect2(105,278+i*45,745,40),_teaching_pick.bind(i))
	elif phase=="confirm":
		var pet:Dictionary=store.state["team"][teaching_index]
		var old:String=store.growth.moves[pet["moves"][teaching_slot]]["name"] if teaching_slot<pet["moves"].size() else "空位"
		UI.label(modal,"%s将学习%s。\n替换：%s；新招式为满PP。\n确认后消耗一个，其他招式和PP保留。"%[store.species[pet["species_id"]]["name"],tm_rules.data[teaching_item]["name"],old],Rect2(105,285,745,110),20)
		UI.button(modal,"1 / E 确认学习",Rect2(110,410,735,48),_teaching_commit.bind(teaching_slot))
	UI.button(modal,"Esc 取消",Rect2(110,485,735,50),_teaching_close)
	_state_trace("tm_teaching_"+phase)
func _teaching_close()->void:
	teaching_phase="";teaching_item="";teaching_index=-1;teaching_slot=-1;_close_modal()
	_state_trace("tm_teaching_cancelled")
func _teaching_select(index:int)->void:
	var error:String=tm_rules.learn_error(store,teaching_item,index)
	if error!="":status.text=error;_trace({"event":"tm_teaching_rejected","reason":error});return
	teaching_index=index
	if store.state["team"][index]["moves"].size()<4:_teaching_pick(store.state["team"][index]["moves"].size())
	else:_teaching_menu("slot")
func _teaching_pick(slot:int)->void:
	var pet:Dictionary=store.state["team"][teaching_index]
	if slot<0 or slot>pet["moves"].size() or slot>=4:return
	if slot<pet["moves"].size() and pet["moves"][slot] in store.growth.HM_MOVES:
		status.text="秘传招式不能在这里遗忘。";_trace({"event":"tm_teaching_rejected","reason":status.text});return
	teaching_slot=slot;_teaching_menu("confirm")
func _teaching_commit(slot:int)->void:
	if teaching_phase!="confirm" or slot!=teaching_slot:return
	var error:String=tm_rules.teach(store,teaching_item,teaching_index,slot,{"map_id":map_id,"x":player.position.x,"y":player.position.y})
	_teaching_close();status.text=error if error!="" else "学会了招式，消耗一个学习器，已保存。"
	_state_trace("ground_tm_failed" if error!="" else "ground_tm_taught")
func _teaching_input(key:int)->void:
	if Time.get_ticks_msec()<trainer_ready_at:return
	if key in [KEY_ESCAPE,KEY_B]:_teaching_close();return
	if teaching_phase=="party" and key>=KEY_1 and key<=KEY_6:_teaching_select(key-KEY_1)
	elif teaching_phase=="slot" and key>=KEY_1 and key<=KEY_4:_teaching_pick(key-KEY_1)
	elif teaching_phase=="confirm" and key in [KEY_1,KEY_E,KEY_ENTER,KEY_SPACE]:_teaching_commit(teaching_slot)

func _sell_nugget()->void:
	var bridge:bool=int(store.state.get("ground_inventory",{}).get("nuggets",0))<=0
	var error:String=tm_rules.sell_nugget(store,map_id,bridge)
	shop_phase="";_close_modal();status.text=error if error!="" else "出售金珠 ×1，获得5000，已保存。"
	_state_trace("nugget_sell_failed" if error!="" else "nugget_sold")

func _visual_kind(from: String, to: String) -> String:
	if from in store.travel.OUTDOORS and to in store.travel.OUTDOORS:return "road"
	if from==to:return "road"
	if (from in store.travel.OUTDOORS) != (to in store.travel.OUTDOORS):
		var interior: String = to if from in store.travel.OUTDOORS else from
		return "cave" if interior.contains("cave") or interior.contains("mtmoon") or interior.contains("tunnel") or interior.contains("victory-road") or interior.contains("seafoam") else "door"
	return "stairs"

func _visual_begin(id: String, arrival: Vector2) -> void:
	visual_transition=true;visual_generation+=1
	var generation: int = visual_generation
	visual_deadline=Time.get_ticks_msec()+2500
	visual_source_map=map_id;visual_source_position=player.safe_position()
	visual_pending={"id":id,"arrival":arrival}
	player.active=false;player.velocity=Vector2.ZERO
	var kind: String = _visual_kind(map_id,id)
	_trace({"event":"visual_transition_started","kind":kind,"from":map_id,"to":id})
	visual_cover=ColorRect.new();visual_cover.color=Color(0.02,0.03,0.04,0)
	visual_cover.position=Vector2(0,40);visual_cover.size=Vector2(960,564)
	visual_cover.mouse_filter=Control.MOUSE_FILTER_IGNORE
	visual_cover.z_index=100
	overlay.get_parent().add_child(visual_cover)
	if kind=="door" and map_id in store.travel.OUTDOORS:
		var ground: Sprite2D = world.get_node_or_null("Ground")
		if ground!=null and ground.texture!=null:
			visual_door=preload("res://scripts/door_visual.gd").new()
			var cell:=Vector2(floori(player.position.x/16)*16,floori((player.position.y-1)/16)*16)
			visual_door.position=cell;visual_door.texture=ground.texture;visual_door.source=Rect2(cell,Vector2(16,16))
			world.add_child(visual_door)
			var opening:=create_tween();opening.tween_property(visual_door,"openness",1.0,0.18)
			await opening.finished
			if generation!=visual_generation:return
			var enter:=create_tween();enter.set_parallel(true)
			enter.tween_property(player.sprite,"position",player.sprite.position+Vector2(0,-8),0.16)
			enter.tween_property(player.sprite,"modulate:a",0.0,0.16)
			await enter.finished
			if generation!=visual_generation:return
			var closing:=create_tween();closing.tween_property(visual_door,"openness",0.0,0.16)
			await closing.finished
			if generation!=visual_generation:return
	var fade:=create_tween();fade.tween_property(visual_cover,"color:a",1.0,0.12)
	await fade.finished
	if generation!=visual_generation:return
	visual_committing=true
	_change_map(id,arrival)
	visual_committing=false
	player.active=false;player.velocity=Vector2.ZERO
	# Reveal the destination actor at its original authoritative landing, with a short walk-out pose.
	if kind=="door":player.sprite.position.y-=6;player.sprite.modulate.a=0.0
	var reveal:=create_tween();reveal.set_parallel(true)
	reveal.tween_property(visual_cover,"color:a",0.0,0.16)
	reveal.tween_property(player.sprite,"modulate:a",1.0,0.16)
	reveal.tween_property(player.sprite,"position:y",-8.0 if player.surfing or player.cycling else -16.0,0.16)
	await reveal.finished
	if generation!=visual_generation:return
	_visual_recover(false)
	_trace({"event":"visual_transition_finished","kind":kind,"map":map_id})

func _visual_recover(timed_out: bool = true) -> void:
	visual_generation+=1
	if is_instance_valid(visual_cover):visual_cover.queue_free()
	if is_instance_valid(visual_door):visual_door.queue_free()
	visual_cover=null;visual_door=null
	visual_transition=false;visual_committing=false;visual_pending={}
	if is_instance_valid(player):
		player.sprite.modulate.a=1.0
		player.sprite.position=Vector2(0,-8 if player.surfing or player.cycling else -16)
		player.active=not in_battle and not is_instance_valid(modal) and not is_instance_valid(pc)
		player.velocity=Vector2.ZERO
	interaction_ready_at=Time.get_ticks_msec()+250
	if timed_out:_trace({"event":"visual_transition_recovered","map":map_id})

func _evolution_service_menu()->void:
	evolution_menu_open=true;evolution_phase="menu";_new_modal("进化服务 · 本地单机适配")
	UI.label(modal,"1 本地通信进化（交换后返还原个体）
2 携带 / 取下进化道具
3 购买进化物资（全国图鉴后）
4 大木博士：全国图鉴（真新镇）
5 起始物种领取 / 垂钓（单机适配）
伊布昼夜分支：火红没有时钟，原版禁用。
Esc 取消 · 队伍、携物与进化原子保存",Rect2(105,155,745,355),20)
	_state_trace("evolution_service_open")
func _evolution_party(phase:String)->void:
	evolution_phase=phase;_new_modal("选择宝可梦 · Esc取消")
	for i in store.state["team"].size():
		var pet:Dictionary=store.state["team"][i]
		var target:String=store.evolution_service.trade_target(pet,store.state)
		UI.button(modal,"%d %s · %s · 亲密%d"%[i+1,store.species[pet["species_id"]]["name"],("→"+store.species[target]["name"] if target!="" else "通信条件不满足") if phase=="trade_party" else store.evolution_service.ITEMS.get(pet.get("held_item",""),{}).get("name","未携带"),store.friendship.value(pet)],Rect2(105,160+i*52,745,47),_evolution_choose.bind(i))
func _evolution_choose(index:int)->void:
	if index<0 or index>=store.state["team"].size():return
	if evolution_phase=="trade_party":
		var plan:Dictionary=store.evolution_service.trade_preview(store,index)
		if plan.is_empty():status.text="通信条件不满足：核对携物、不变之石和全国图鉴。";return
		_evolution_begin(plan,index,"trade")
	elif evolution_phase=="hold_party":
		var failure:String=store.evolution_service.hold(store,index,evolution_hold_item)
		evolution_menu_open=false;_close_modal();status.text="携带物已保存。" if failure=="" else failure;_state_trace("evolution_hold_result")
func _evolution_begin(plan:Dictionary,index:int,kind:String)->void:
	evolution_menu_open=true;evolution_plan=plan;evolution_index=index;evolution_kind=kind;evolution_phase="confirm"
	_new_modal("本地通信进化确认" if kind=="trade" else "使用进化石确认")
	UI.label(modal,"%s → %s
1 确认 · Esc取消（不消耗）
%s"%[store.species[plan["original"]["species_id"]]["name"],store.species[plan["pet"]["species_id"]]["name"],"符合条件的通信携物会消耗；本地交换返还原个体。" if kind=="trade" else "确认后消耗一块进化石，学招结束立即保存。"],Rect2(105,185,745,230),22)
	_state_trace("evolution_service_confirm")
func _evolution_learn_next()->void:
	var pet:Dictionary=evolution_plan["pet"]
	while not evolution_plan["learns"].is_empty():
		var move:String=evolution_plan["learns"][0]
		if move in pet["moves"]:evolution_plan["learns"].pop_front();continue
		if pet["moves"].size()<4:store.growth.resolve_learning(pet,move,pet["moves"].size());evolution_plan["learns"].pop_front();continue
		evolution_phase="learn";_new_modal("进化后学习招式")
		UI.label(modal,"学习%s：1–4替换；5放弃。
Esc取消整个事务；秘传招式不可遗忘。"%store.growth.moves[move]["name"],Rect2(105,170,745,100),20)
		for i in pet["moves"].size():UI.label(modal,"%d %s"%[i+1,store.growth.moves[pet["moves"][i]]["name"]],Rect2(110,290+i*45,730,40),20)
		return
	var failure:String=store.stone_evolution.commit(store,evolution_index,evolution_plan,{"map_id":map_id,"x":player.position.x,"y":player.position.y}) if evolution_kind=="stone" else store.evolution_service.commit(store,evolution_index,evolution_plan)
	evolution_plan={};evolution_menu_open=false;evolution_phase="";_close_modal();status.text="进化完成，已保存。" if failure=="" else failure
	_state_trace("evolution_service_committed" if failure=="" else "evolution_service_failed")
func _evolution_key(key:int)->void:
	if key in [KEY_ESCAPE,KEY_B]:evolution_plan={};evolution_menu_open=false;evolution_phase="";_close_modal();_state_trace("evolution_service_cancelled");return
	var index:int=key-KEY_1
	if evolution_phase=="confirm" and key==KEY_1:_evolution_learn_next();return
	if evolution_phase=="learn" and index>=0 and index<=4:
		if index<4 and not store.growth.resolve_learning(evolution_plan["pet"],evolution_plan["learns"][0],index):return
		evolution_plan["learns"].pop_front();_evolution_learn_next();return
	if evolution_phase in ["trade_party","hold_party"]:_evolution_choose(index);return
	if evolution_phase=="menu":
		if key==KEY_1:_evolution_party("trade_party")
		elif key in [KEY_2,KEY_3]:
			evolution_phase="hold_items" if key==KEY_2 else "purchase";_new_modal("选择携带物" if key==KEY_2 else "进化物资 · 单机适配商店")
			var choices:Array=store.evolution_service.ITEMS.keys()
			for i in choices.size():
				var item:String=choices[i];var row:Dictionary=store.evolution_service.ITEMS[item]
				UI.label(modal,"%d %s · %d元 · 库存%d"%[i+1,row["name"],row["price"],int(store.state.get(item,0)) if item=="sun_stones" else int(store.state.get("evolution_inventory",{}).get(item,0))],Rect2(110,150+i*45,735,40),20)
			if key==KEY_2:UI.label(modal,"8 取下携带物（日之石在O石袋使用）",Rect2(110,470,735,40),19)
		elif key==KEY_5:
			evolution_phase="acquire";_new_modal("起始物种 · 明示单机适配")
			UI.label(modal,"玉虹市领取：
1 伊布 Lv25 · 一次赠送（原版屋顶赠礼）
2 迷你龙 Lv18 · 56000元（2800代币直兑）
3 多边兽 Lv26 · 199980元（9999代币直兑）
4 大钳蟹垂钓 · 12号道路 · Lv5–15
垂钓直接进入野生战斗，需要正常捕获；无需钓竿适配。",Rect2(105,155,745,350),20)
		elif key==KEY_4:
			status.text=store.evolution_service.unlock(store) if map_id=="pallet-town" else "请回到真新镇，再联系大木博士。"
			if status.text=="":status.text="大木：全国图鉴升级完成，已保存！"
			_state_trace("national_dex_result")
	elif evolution_phase=="purchase" and index>=0 and index<store.evolution_service.ITEMS.size():
		var failure:String=store.evolution_service.purchase(store,store.evolution_service.ITEMS.keys()[index]);status.text="购买成功，已保存。" if failure=="" else failure;_state_trace("evolution_purchase_result")
	elif evolution_phase=="hold_items" and index>=0 and index<=7:
		evolution_hold_item="" if index==7 else store.evolution_service.ITEMS.keys()[index]
		if evolution_hold_item=="sun_stones":status.text="日之石请在O进化石袋使用。";return
		_evolution_party("hold_party")

	elif evolution_phase=="acquire" and index>=0 and index<=3:
		if index==3:
			if map_id!="route12":status.text="请到12号道路使用垂钓服务。";return
			evolution_menu_open=false;evolution_phase="";_close_modal();_start_battle({"species_id":"krabby","level":randi_range(5,15)});return
		var failure:String=store.evolution_service.acquire(store,["eevee","dratini","porygon"][index],map_id)
		status.text="宝可梦已领取并保存。" if failure=="" else failure;_state_trace("evolution_acquire_result")

func _shop_products()->Array:
	var products:Array=store.inventory.catalog["shops"].get(map_id,[]).duplicate()
	if map_id=="celadon-mart-5f":products=products.filter(func(id):return id in store.BATTLE_ITEMS if shop_stock_kind=="battle" else id in store.vitamins.ITEMS)
	return products
func _shop_sell_menu()->void:
	_shop_dialog("sell")
func _shop_sell(item:String)->void:
	if shop_phase!="sell" or Time.get_ticks_msec()<shop_ready_at:return
	var failure:String=tm_rules.sell_nugget(store,map_id,true) if item=="bridge_nugget" else store.sell(item,1)
	shop_message=failure if failure!="" else "出售成功，已保存。";_shop_dialog("result")
func _field_flute()->void:
	var failure:String=store.tower_story.play_flute(store)
	_close_modal();status.text=failure if failure!="" else "吹响了宝可梦笛，队伍醒来了。"

func _item_battle_terrain()->String:
	var cell:=Vector2i(floori(player.position.x/16),floori((player.position.y-1)/16))
	if cell.y>=0 and cell.y<int(layout["height"]) and cell.x>=0 and cell.x<int(layout["width"]) and int(layout["grass"][cell.y][cell.x])==1:return "grass"
	if store.state.get("surfing",false):return "water" if map_id in ["route19","route20","route21"] else "pond"
	if map_id.begins_with("mtmoon-") or map_id.begins_with("rock-tunnel-") or map_id.begins_with("diglett") or map_id.begins_with("seafoam-") or map_id.begins_with("victory-road-"):return "cave"
	return "plain"

func _mail_menu()->void:
	mail_phase="party"
	_new_modal("复古邮件 · 选择伙伴")
	for i in store.state["team"].size():
		var pet:Dictionary=store.state["team"][i]
		UI.button(modal,"%s · %s"%[store.species[pet["species_id"]]["name"],"阅读／取下" if pet.get("held_item","")=="retro_mail" else "写信并携带"],Rect2(105,165+i*54,745,48),_mail_select.bind(i))
func _mail_select(index:int)->void:
	mail_phase="editor"
	_new_modal("复古邮件")
	var pet:Dictionary=store.state["team"][index]
	if pet.get("held_item","")=="retro_mail":
		var letter:=UI.label(modal,pet.get("mail_text",""),Rect2(110,180,735,190),22)
		letter.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
		UI.button(modal,"取下邮件（清除信文）",Rect2(110,405,735,55),_mail_take.bind(index))
	else:
		mail_editor=LineEdit.new();mail_editor.position=Vector2(110,200);mail_editor.size=Vector2(735,65);mail_editor.max_length=120;modal.add_child(mail_editor);mail_editor.grab_focus()
		UI.button(modal,"写好并交给伙伴",Rect2(110,405,735,55),_mail_give.bind(index))
func _mail_give(index:int)->void:
	var failure:String=store.item_mail.give(store,index,mail_editor.text)
	_close_modal();status.text=failure if failure!="" else "邮件已交给伙伴并保存。"
func _mail_take(index:int)->void:
	var failure:String=store.item_mail.take(store,index)
	_close_modal();status.text=failure if failure!="" else "邮件已取下，信文已清除并保存。"

func _sevii_draw(objects:Node2D,id:String)->void:
	if id=="sevii-mt-ember-exterior" and store.sevii.rockets_done(store.state):
		var door:=Sprite2D.new();door.texture=load("res://assets/sevii-mt-ember-exterior/ruby-entrance.png");door.position=Vector2(42*16,39*16);door.centered=false;world.add_child(door)
	if id=="sevii-four-island-icefall-cave-1-f":
		for at in store.sevii.ice:_sevii_ice_patch(Vector2i(at[0],at[1]),false)
	for a in store.sevii.actors(id):
		if not store.sevii.visible(a,store.state):continue
		var at:Array=a["cell"]
		if a["script"]=="EventScript_StrengthBoulder":
			var bi:int=boulders.object_ids.find(int(a["source_index"]))
			if bi>=0:at=boulders.cells[bi]
		var npc:=Sprite2D.new();npc.texture=load(a["sprite"]);npc.position=Vector2(at[0]*16+8,at[1]*16+16-float(a["size"][1])/2);objects.add_child(npc)
	if id=="vermilion-city" and store.sevii.stage(store.state)>=3:
		var sailor:=Sprite2D.new();sailor.texture=load("res://assets/sevii-one-island-harbor/actor-2.png");sailor.position=Vector2(296,440);objects.add_child(sailor);_add_solid(world,Rect2(288,432,16,16))
	if id=="cinnabar-center" and store.state.get("badges",{}).get("volcano",false) and not store.state.get("sevii",{}).get("departed",false):
		var npc:=Sprite2D.new();npc.texture=load("res://assets/sevii-one-island-pokemon-center-1-f/actor-2.png");npc.position=Vector2(120,72);objects.add_child(npc);_add_solid(world,Rect2(112,64,16,16))
func _sevii_prompt(action:String,title:String,text:String)->void:
	sevii_action=action;_new_modal(title);UI.label(modal,text+"\nE / Enter 确认 · Esc取消",Rect2(100,190,760,230),21);trainer_ready_at=Time.get_ticks_msec()+250;_state_trace("sevii_prompt_"+action)
func _sevii_interact(cell:Vector2i)->bool:
	var step:=Vector2i(roundi(player.facing.x),roundi(player.facing.y))
	if absi(step.x)+absi(step.y)!=1:return false
	if map_id=="cinnabar-center" and cell+step==Vector2i(7,4) and store.state.get("badges",{}).get("volcano",false) and not store.state.get("sevii",{}).get("departed",false):
		_sevii_prompt("depart","比尔 · 前往一岛","愿意和我去一岛拜访锦辉吗？先到中心会面，再领取岛屿任务。");return true
	if map_id=="vermilion-city" and cell+step==Vector2i(18,27) and store.sevii.stage(store.state)>=3:_sevii_ferry_menu();return true
	if not store.sevii.world.has(map_id):return false
	if layout.has("behaviors") and store.state.get("surfing",false) and step==Vector2i.UP:
		var plan:Dictionary=store.sevii.waterfall(layout,store.state,cell,step)
		if not plan.is_empty():
			if plan.has("error"):status.text=plan["error"];_state_trace("waterfall_rejected");return true
			sevii_actor=plan;_sevii_prompt("waterfall","攀瀑","使用攀瀑登上眼前的真实水瀑吗？不消耗PP。");return true
	for a in store.sevii.actors(map_id):
		if not store.sevii.visible(a,store.state) or cell+step!=Vector2i(a["cell"][0],a["cell"][1]):continue
		sevii_actor=a.duplicate(true)
		var script:String=a["script"]
		if script.ends_with("RockSmashMan"):
			if store.state.get("sevii_hms",{}).get("rocksmash",false):status.text="HM06已领取；碎岩需金色徽章和队伍已学会。";_state_trace("hm06_repeat")
			else:_sevii_prompt("hm06","温泉老人 · HM06碎岩","我用这个开凿了温泉。要领取HM06碎岩吗？")
			return true
		if script=="EventScript_RockSmash":
			var failure:String=store.sevii.field_error(store.state,"rocksmash")
			if failure!="":status.text=failure;_state_trace("rocksmash_rejected");return true
			_sevii_prompt("smash","碎岩 · 岩石","打碎面前的岩石吗？离开地图后恢复，不消耗PP。");return true
		if script.ends_with("Sailor"):_sevii_ferry_menu();return true
		if script.ends_with("_Nurse"):_sevii_prompt("heal","一岛 · 治疗","恢复队伍的HP、PP与异常状态吗？");return true
		if script.ends_with("_Bill") or script.ends_with("_Celio"):
			var stage:int=store.sevii.stage(store.state)
			if stage==0:_sevii_prompt("meet","比尔与锦辉","请把陨石交给二岛游戏厅的父亲。这张三岛通行证能往返一、二、三岛。")
			elif stage==2:_sevii_prompt("return","比尔 · 返回关都","这边的维修完成了。一起回红莲岛吧！")
			elif stage==3:_sevii_prompt("ruby_request","锦辉 · 红宝石委托","有全国图鉴后，能帮我寻找灯火山的红宝石吗？")
			elif stage==4 and store.state.get("sevii",{}).get("ruby",false):_sevii_prompt("rainbow","锦辉 · 彩虹通行证","交付红宝石并把三岛通行证换成彩虹通行证？将开放前往四岛的航线。")
			else:status.text="请去寻找红宝石。" if stage==4 else "彩虹通行证已可使用；本轮开放至四岛。" if stage==5 else "请把陨石送到二岛，并帮助寻找迷失女孩。"
			return true
		if script.ends_with("LostellesDaddy"):
			_sevii_prompt("deliver" if store.state.get("sevii",{}).get("rescued",false) and store.state.get("sevii",{}).get("meteorite",false) else "moon" if store.sevii.stage(store.state)>=2 else "ask_rescue","迷失女孩的父亲","交付比尔的陨石。" if store.state.get("sevii",{}).get("rescued",false) else "我的女儿还没回来！请去三岛寻找迷失女孩。");return true
		if script=="ThreeIsland_EventScript_Biker" or script=="ThreeIsland_EventScript_Biker6" or script.contains("AntiBiker"):
			if not store.state.get("sevii",{}).get("rescue_asked",false):status.text="先去二岛游戏厅了解迷失女孩的委托。";return true
			for key in store.sevii.BIKERS:
				if not store.state.get("trainers",{}).get(key,false):_forest_trainer_interact(trainer_rules.definition(key));return true
			status.text="暴走族已经离开，西边的桥通向果实森林。";return true
		if script=="ThreeIsland_BerryForest_EventScript_Lostelle":
			_sevii_prompt("rescue" if store.state.get("sevii",{}).get("hypno_done",false) else "hypno","迷失女孩 · 果实森林","谢谢你！请带我回二岛游戏厅。" if store.state.get("sevii",{}).get("hypno_done",false) else "好可怕的宝可梦又来了！催眠貘 Lv30。");return true
		if script.contains("MtEmber_Exterior_EventScript_Grunt"):
			if store.sevii.stage(store.state)!=4:status.text="火箭队正在挖掘；先接受锦辉的红宝石委托。";return true
			_forest_trainer_interact(trainer_rules.definition("sevii_grunt43" if script.ends_with("Grunt1") else "sevii_grunt44"));return true
		if script=="MtEmber_RubyPath_B5F_EventScript_Ruby":_sevii_prompt("ruby","红宝石","拾取这里的红宝石吗？");return true
		if script.ends_with("ItemHM07"):_sevii_prompt("hm07","HM07攀瀑","拾取HM07攀瀑吗？");return true
		if script=="EventScript_StrengthBoulder":return false
		status.text="该源角色或支线不属于当前HM路线。";return true
	return false
func _sevii_ferry_menu()->void:
	sevii_action="ferry";_new_modal("海烈焰马号 · 目的地")
	var names:Array=["一岛","二岛","三岛","四岛（彩虹通行证）","枯叶（完成正常返航后）"]
	for i in names.size():UI.button(modal,str(i+1)+" "+names[i],Rect2(110,170+i*50,738,44),_sevii_sail.bind(i))
	UI.button(modal,"Esc取消",Rect2(110,475,738,44),func():sevii_action="";_close_modal())
	trainer_ready_at=Time.get_ticks_msec()+250;_state_trace("sevii_ferry_menu")
func _sevii_sail(index:int)->void:
	var dest:String=["sevii-one-island-harbor","sevii-two-island-harbor","sevii-three-island-harbor","sevii-four-island-harbor","vermilion-city"][index]
	var loc:Dictionary={"map_id":dest,"x":136 if index<4 else 312,"y":89 if index<4 else 441}
	var failure:String=store.sevii.ferry(store,dest,loc)
	sevii_action="";_close_modal()
	if failure=="":_change_map(dest,Vector2(loc["x"],loc["y"]));_state_trace("sevii_sailed")
	else:status.text=failure;_state_trace("sevii_ferry_failed")
func _sevii_input(key:int)->void:
	if Time.get_ticks_msec()<trainer_ready_at:return
	if key in [KEY_ESCAPE,KEY_B]:sevii_action="";_close_modal();_state_trace("sevii_cancelled");return
	if sevii_action=="ferry":
		if key>=KEY_1 and key<=KEY_5:_sevii_sail(key-KEY_1)
		return
	if key not in [KEY_E,KEY_ENTER,KEY_SPACE]:return
	var action:String=sevii_action;sevii_action="";_close_modal()
	if action=="waterfall":_sevii_begin_motion(sevii_actor["cells"]);return
	if action=="hypno":
		if not store.sevii.bikers_done(store.state):status.text="请先解决三岛暴走族。";return
		if not _save():return
		_start_battle({"species_id":"hypno","level":30})
		if in_battle:battle.static_id="sevii_hypno";battle.north_rules=true
		return
	var loc:Dictionary={}
	if action=="depart":loc={"map_id":"sevii-one-island-pokemon-center-1-f","x":152,"y":137}
	if action=="return":loc={"map_id":"cinnabar-island","x":168,"y":73}
	if action=="rescue":loc={"map_id":"sevii-two-island-joyful-game-corner","x":104,"y":105}
	var failure:String=store.sevii.claim_hm06(store,map_id,sevii_actor) if action=="hm06" else store.sevii.smash(store.state,map_id,int(sevii_actor["source_index"])) if action=="smash" else store.sevii.transact(store,action,loc)
	if failure!="":status.text=failure;_state_trace("sevii_failed_"+action);return
	var facing_before:Vector2=player.facing
	_change_map(loc.get("map_id",map_id),Vector2(loc["x"],loc["y"]) if not loc.is_empty() else player.position)
	if loc.is_empty():player.facing=facing_before
	status.text="使用碎岩！岩石已消失，离图恢复。" if action=="smash" else "已完成并保存："+action
	_state_trace("sevii_done_"+action)
func _sevii_transition(cell:Vector2i)->bool:
	if not store.sevii.world.has(map_id):return false
	if store.state.get("surfing",false) and Input.is_action_pressed("walk_down"):
		var fall:Dictionary=store.sevii.waterfall(layout,store.state,cell,Vector2i.DOWN)
		if fall.has("cells"):_sevii_begin_motion(fall["cells"]);return true
	var key:String="%s:%d:%d" % [map_id,cell.x,cell.y]
	if key==sevii_warp_latch:
		var exit_step:bool=false
		for warp in store.sevii.world[map_id]["warps"]:
			if cell==Vector2i(warp["cell"][0],warp["cell"][1]) and int(layout["behaviors"][cell.y][cell.x])==101 and Input.is_action_pressed("walk_down"):exit_step=true
		if not exit_step:return false
	sevii_warp_latch=""
	if cell.x>=0 and cell.y>=0 and cell.x<int(layout["width"]) and cell.y<int(layout["height"]):
		if map_id=="sevii-four-island-icefall-cave-1-f" and cell!=last_cell and int(layout["behaviors"][cell.y][cell.x]) in [38,39]:
			if int(layout["behaviors"][cell.y][cell.x])==38:
				store.sevii.ice.append([cell.x,cell.y]);layout["behaviors"][cell.y][cell.x]=39;_sevii_ice_patch(cell,false);_state_trace("sevii_ice_cracked")
			else:
				var below:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://data/sevii-four-island-icefall-cave-b1-f.json"))
				if int(below["solid"][cell.y][cell.x])==0:_change_map("sevii-four-island-icefall-cave-b1-f",Vector2(cell.x*16+8,cell.y*16+9));_state_trace("sevii_ice_fell");return true
		var row:Dictionary=store.sevii.world[map_id]
		for warp in row["warps"]:
			if cell!=Vector2i(warp["cell"][0],warp["cell"][1]):continue
			if warp.get("door",false) and player.velocity.y>=0:return false
			if warp.get("closed",false):status.text=warp["reason"];sevii_warp_latch=key;return false
			if map_id=="sevii-mt-ember-exterior" and int(warp["index"])==5 and (store.sevii.stage(store.state)<4 or not store.sevii.rockets_done(store.state)):status.text="先接受锦辉委托并击败两个火箭队员。";return false
			var at:Array=warp["arrival"];_change_map(warp["target"],Vector2(at[0]*16+8,at[1]*16+9));return true
	var step:Vector2i=Vector2i.RIGHT if player.velocity.x>0 else Vector2i.LEFT if player.velocity.x<0 else Vector2i.DOWN if player.velocity.y>0 else Vector2i.UP
	for c in store.sevii.world[map_id]["connections"]:
		var direction:String=c["direction"]
		var edge:bool=direction=="right" and player.position.x>=int(layout["width"])*16-8 and step==Vector2i.RIGHT or direction=="left" and player.position.x<=8 and step==Vector2i.LEFT or direction=="up" and player.position.y<=9 and step==Vector2i.UP or direction=="down" and player.position.y>=int(layout["height"])*16-7 and step==Vector2i.DOWN
		if not edge:continue
		if map_id=="sevii-three-island" and direction=="left" and not store.sevii.bikers_done(store.state):status.text="先解决三岛暴走族。";return false
		var target:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://data/%s.json" % c["target"]))
		var at:=Vector2i(cell.x-int(c["offset"]),0 if direction=="down" else int(target["height"])-1) if direction in ["up","down"] else Vector2i(0 if direction=="right" else int(target["width"])-1,cell.y-int(c["offset"]))
		if at.x<0 or at.y<0 or at.x>=int(target["width"]) or at.y>=int(target["height"]):return false
		var clear:bool=int(target["solid"][at.y][at.x])==0 or store.state.get("surfing",false) and store.surf.water(c["target"],target,at)
		if not clear:return false
		_change_map(c["target"],Vector2(at.x*16+8,at.y*16+9));return true
	return false
func _sevii_begin_motion(cells:Array)->void:
	if cells.is_empty():return
	sevii_motion_origin=player.position;sevii_motion=cells.duplicate(true);sevii_motion_clock=0;player.active=false;player.velocity=Vector2.ZERO;_state_trace("waterfall_started")
func _sevii_motion_tick(delta:float)->void:
	player.active=false;player.velocity=Vector2.ZERO;sevii_motion_clock-=delta
	if sevii_motion_clock>0:return
	var at:Array=sevii_motion.pop_front();player.position=Vector2(at[0]*16+8,at[1]*16+9);sevii_motion_clock=0.10
	if sevii_motion.is_empty():player.active=true;last_cell=Vector2i(at[0],at[1]);_state_trace("waterfall_stopped")

func _sevii_ice_patch(cell:Vector2i,hole:bool)->void:
	var patch:=Sprite2D.new();patch.texture=load("res://assets/sevii-four-island-icefall-cave-1-f/ice-hole.png" if hole else "res://assets/sevii-four-island-icefall-cave-1-f/ice-cracked.png");patch.centered=false;patch.position=Vector2(cell.x*16,cell.y*16);world.add_child(patch)

func _tm_gift_interact(cell:Vector2i)->bool:
	if map_id!="route12-gate-2f" or cell+Vector2i(player.facing)!=Vector2i(3,4):return false
	store.state["location"]={"map_id":map_id,"x":player.position.x,"y":player.position.y}
	var failure:String=tm_acquisition.gift(store)
	status.text="获得TM27报恩，已放入招式学习器盒并保存。G查看。" if failure=="" else failure
	_trace({"event":"tm27_gift","success":failure=="","failure":failure});return true

func _pickup_take(index:int)->void:
	var failure:String=tm_acquisition.take_held(store,index)
	_close_modal();status.text="携带物已放入背包并保存。" if failure=="" else failure
	_trace({"event":"pickup_take","success":failure=="","failure":failure})
