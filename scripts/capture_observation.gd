extends RefCounted
## Read-only conservative capture observations. Unknown effects are not damage-safe.
const SIMPLE = ["pound","tackle","scratch","peck","vinewhip","cut","strength","quickattack","hyperfang","rockthrow","headbutt","snore"]
const STATUS = ["hypnosis","sing","lovelykiss","sleeppowder","thunderwave","glare","stunspore"]
static func bounds(b: Node, attacker: Dictionary, defender: Dictionary, a: Dictionary, d: Dictionary) -> Dictionary:
	var out: Dictionary = {}
	for id in attacker["moves"]:
		if id not in SIMPLE:continue
		# No weather/charge/type amplification applies to this deliberately small whitelist.
		var normal: int = b.rules.damage(attacker,defender,id,a,d,1.0,1.0,false,0,true,false)
		var critical: int = b.rules.damage(attacker,defender,id,a,d,1.0,1.0,true,0,true,false)
		out[id] = maxi(normal,critical)
	return out
static func observe(b: Node) -> Dictionary:
	var pet: Dictionary = b.active_pet()
	var enemy: Dictionary = b.enemy
	var allowed: Array = []
	for id in pet["moves"]:
		if id not in STATUS or enemy.get("status","")!="" or b._safeguarded(enemy):continue
		var status: String = "sleep" if id in ["hypnosis","sing","lovelykiss","sleeppowder"] else "paralysis"
		var copy: Dictionary = enemy.duplicate(true)
		if not b.rules.inflict(copy,status):continue
		if id=="thunderwave" and b.rules.effectiveness("Electric",enemy["species_id"],enemy)==0:continue
		if id=="sleeppowder" and b.rules.effectiveness("Grass",enemy["species_id"],enemy)==0:continue
		allowed.append(id)
	var threat: int = 0
	var enemy_bounds: Dictionary = bounds(b,enemy,pet,b.enemy_stages,b.player_stages)
	for id in enemy["moves"]:
		if enemy_bounds.has(id):threat=maxi(threat,int(enemy_bounds[id]))
		elif id not in ["growl","tailwhip","leer","splash","rest","yawn","hypnosis","sing","thunderwave"]:threat=999999
	var unsafe: bool = not b.confused.is_empty() or b.seeded_player or b.seeded_enemy or b.sand_turns>0 or b.hail_turns>0
	for group in [b.underground,b.airborne,b.submerged,b.solar_charges,b.rampages,b.rollouts,b.encored_moves,b.imprisoned_by,b.cursed,b.nightmares,b.bindings,b.future_attacks,b.perish_counts,b.destiny_bonds]:
		if not group.is_empty():unsafe=true
	return {"enemy":enemy.duplicate(true),"enemy_max_hp":int(b.rules.pet_stats(enemy)["hp"]),"player_max_hp":int(b.rules.pet_stats(pet)["hp"]),"catch_rate":b.store.species[enemy["species_id"]]["catch_rate"],"player_stages":b.player_stages.duplicate(true),"enemy_stages":b.enemy_stages.duplicate(true),"damage_upper":bounds(b,pet,enemy,b.player_stages,b.enemy_stages),"status_moves":allowed,"enemy_damage_upper":threat,"unsafe_effects":unsafe}
