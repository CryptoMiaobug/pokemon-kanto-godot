extends RefCounted
## Read-only dispatch observation; never invokes story predicates or persistence.
## Branch order mirrors main._unhandled_key_input. Keys are classes, not legal-action guarantees.
static func state(g: Node) -> Dictionary:
	var s: Dictionary = {"event":"input_state","mode":"overworld","phase":"field","busy":false,"input_ready":false,"movement_ready":false,"interaction_ready":false,"cooldown_wait":false,"key_classes":[]}
	if g.in_battle:
		s.mode = "battle"
		if not is_instance_valid(g.battle):
			s.phase = "unavailable";s.busy = true;return s
		var b: Node = g.battle
		# Current read-only battle observation; never reconstruct HP from move logs.
		s.battle_state = {"team":b.store.state["team"].duplicate(true),"lead":b.store.state["lead"],"disabled_moves":b.disabled_moves.duplicate(true),"items":{}}
		s.battle_state.capture = preload("res://scripts/capture_observation.gd").observe(b)
		s.battle_state.commitments = {
			"underground": b.underground.duplicate(true), "airborne": b.airborne.duplicate(true),
			"submerged": b.submerged.duplicate(true), "solar_charges": b.solar_charges.duplicate(true),
			"rampages": b.rampages.duplicate(true), "rollouts": b.rollouts.duplicate(true)
		}
		for item in b.BAG_ITEMS:s.battle_state.items[item] = b.store.state.get(item,0)
		s.phase = b.mode
		s.menu_phase = b.mode
		s.baton_pending = b.baton_pending
		s.ended = b.ended
		s.forced_switch = not b.store.state.get("team",[]).is_empty() and int(b.active_pet().get("hp",0))<=0
		if is_instance_valid(b.evolution_view):
			var e: Node = b.evolution_view
			s.phase = "evolution:"+e.phase
			s.cooldown_wait = e.phase=="result" and Time.get_ticks_msec()<e.result_ready
			s.input_ready = e.phase in ["intro","cycling"] or (e.phase=="result" and not s.cooldown_wait)
			s.key_classes = ["B:cancel_evolution"] if e.phase in ["intro","cycling"] else ["E/Enter/Space:continue"] if s.input_ready else []
		elif b.busy:
			s.phase = "busy";s.busy = true
		elif not b.learning.is_empty():
			s.phase = "learning";s.input_ready = true;s.key_classes = ["1-5:learning_choice"]
		elif b.ended:
			s.phase = "next_enemy" if b.waiting_next else "ended";s.input_ready = true;s.key_classes = ["E/Enter/Space:continue"]
			if not b.waiting_next and b.trainer_id=="":s.key_classes.append("R:debug_heal_and_return")
		elif b.baton_pending:
			s.phase = "baton_switch";s.input_ready = true;s.key_classes = ["1-6:team"]
		else:
			s.input_ready = true
			s.key_classes = ["1-6:menu_choice","Esc:root","T:team","C:capture_attempt"]
			if s.forced_switch:s.phase = "forced_switch:"+b.mode
		return s
	if is_instance_valid(g.pc):
		s.mode = "pc";s.phase = "select" if g.pc.action=="" else g.pc.action
		return gate(s,g.pc.ready_at,["arrows:slot","1-6:party","Q/E:box","D/W/X:operation","Esc:close"] if g.pc.action=="" else ["Enter/Space:confirm","Esc/B:cancel"])
	if g.rocket_spin.active or not g.seafoam_current.is_empty() or not g.sevii_motion.is_empty():
		s.mode = "automatic_movement";s.phase = "spin" if g.rocket_spin.active else "current";s.busy = true;return s
	# [property, mode, deadline property]; this list follows dispatch precedence.
	var branches: Array = [
		["sevii_action","sevii","trainer_ready_at"],["teaching_phase","tm_teaching","trainer_ready_at"],["travel_action","travel","trainer_ready_at"],["counter_phase","counter","trainer_ready_at"],["roof_phase","roof","trainer_ready_at"],["lab_fossil_phase","fossil_lab","trainer_ready_at"],
		["mansion_key_pending","dialog","trainer_ready_at"],["mansion_pending","dialog","trainer_ready_at"],["snorlax_pending","dialog","trainer_ready_at"],["silph_action","dialog","trainer_ready_at"],
		["celadon_lift_pending","lift","trainer_ready_at"],["silph_lift_pending","lift","trainer_ready_at"],["lift_pending","lift","trainer_ready_at"],["gym_phase","dialog","trainer_ready_at"],["cinnabar_quiz_pending","quiz","trainer_ready_at"],
		["cut_phase","hm","trainer_ready_at"],["ship_dialog","dialog","interaction_ready_at"],["tm_pending","dialog","trainer_ready_at"],["bill_pending","dialog","trainer_ready_at"],["bridge_pending","dialog","trainer_ready_at"],["fossil_pending","dialog","trainer_ready_at"],
		["field_bag_open","field_bag",""],["stone_bag_open","stone_bag",""],["shop_phase","shop","shop_ready_at"],
		["tea_pending","dialog",""],["fuji_action","dialog",""],["pending_mother","dialog",""],["boulder_pending","dialog",""],["warden_pending","dialog",""],["surf_pending","dialog",""],["safari_reward","dialog",""],["safari_action","dialog",""],
		["hall_phase","hall","hall_ready_at"],["flash_pending","dialog",""],["dojo_choice_pending","dialog","trainer_ready_at"],["pending_trainer","trainer","trainer_ready_at"],["nurse_phase","nurse","nurse_ready_at"]]
	for branch in branches:
		var v: Variant = g.get(branch[0])
		if (v is String and v.is_empty()) or (v is bool and not v) or (v is int and v==0):continue
		s.mode = branch[1];s.phase = str(v) if v is String else branch[0]
		s.global_shortcuts = ["I/U/L/F/V:field_shortcut"] if not is_instance_valid(g.modal) and branch[0] not in ["travel_action","counter_phase","roof_phase","lab_fossil_phase"] else []
		s.handler = branch[0]
		# Exact generic key availability varies with the phase; only advertise audited cases.
		var keys: Array = []
		if branch[0]=="shop_phase":
			keys = ["Esc/B:back_or_close"]
			if v=="list":keys.append("digits:stock_choice")
			elif v=="quantity":keys.append_array(["arrows:quantity","E/Enter/Space:confirm"])
			elif v=="confirm":keys.append_array(["1/E/Enter/Space:buy","2:back"])
			elif v=="result":keys.append("E/Enter/Space:back")
		elif branch[0]=="nurse_phase":
			keys = ["1/E/Enter/Space:continue"] if v=="welcome" else ["1/E/Enter/Space:heal","2/Esc/B:decline"] if v=="choice" else ["E/Enter/Space/Esc/B:close"]
		var deadline: int = int(g.get(branch[2])) if branch[2]!="" else 0
		return gate(s,deadline,keys)
	if is_instance_valid(g.modal):
		s.mode = "modal";s.phase = "starter" if g.load_status=="missing" else "generic_loaded" if g.load_status=="loaded" else "load_error"
		s.input_ready = g.load_status in ["missing","loaded"]
		s.key_classes = ["1-3:starter"] if g.load_status=="missing" else ["1-6:lead","Esc/P:close"] if g.load_status=="loaded" else []
		return s
	if not is_instance_valid(g.player):
		s.phase = "unavailable";s.busy = true;return s
	s.input_ready = true
	s.movement_ready = g.player.active and (not g.player.surfing or g.player.surf_clock<=0)
	s.interaction_ready = Time.get_ticks_msec()>=g.interaction_ready_at
	s.cooldown_wait = not s.interaction_ready or (g.player.surfing and g.player.surf_clock>0)
	s.key_classes = ["WASD/arrows:movement","E/Enter/Space:interact","B:bag","P:party"]
	s.global_shortcuts = ["I/U/L/F/V:field_shortcut"]
	if g.player.cycling_road:s.phase = "cycling_road_auto_down"
	return s

static func gate(s: Dictionary, deadline: int, keys: Array) -> Dictionary:
	s.cooldown_wait = Time.get_ticks_msec()<deadline
	s.input_ready = not s.cooldown_wait
	s.key_classes = keys
	return s
