extends RefCounted
## Reachable original CHECK_BAD_MOVE / CHECK_VIABILITY / TRY_TO_FAINT branches.
## battle_ai_scripts.s: AttackDown, DefenseDown, AccuracyDown and direct damage.
## No new strategy; uses existing damage subset, not complete GBA battle simulation.
var rules = preload("res://scripts/rules.gd").new()
func roll() -> int:return randi()%256
func choose(user: Dictionary, target: Dictionary, us: Dictionary, ts: Dictionary, seeded_target: bool = false, bad_move_only: bool = false, cerulean_leader: bool = false, ship: Dictionary = {}) -> String:
	var best: int = -999
	var choices: Array[String] = []
	var uh: int = floori(100.0*int(user["hp"])/int(rules.pet_stats(user)["hp"]))
	var th: int = floori(100.0*int(target["hp"])/int(rules.pet_stats(target)["hp"]))
	for id in user["moves"]:
		if int(user["pp"][id])<=0:continue
		var score: int = 100
		var move: Dictionary = rules.moves[id]
		if rules.power(id,target)>0:
			if rules.effectiveness(move["type"],target["species_id"])==0:score -= 10
			# This party has exactly one direct damage move, always most powerful.
			var simulated: int = rules.damage(user,target,id,us,ts,1.0)*(100-randi()%16)/100
			if not bad_move_only and maxi(1,simulated)>=int(target["hp"]):score += 6 if not ship.is_empty() and id=="quickattack" else 4
			elif not ship.is_empty():
				var strongest: int = 0
				for other in user["moves"]:
					if int(user["pp"][other])>0 and rules.power(other,target)>1:strongest = maxi(strongest,rules.damage(user,target,other,us,ts))
				if rules.damage(user,target,id,us,ts)<strongest:score -= 1
		else:
			if not ship.is_empty():
				score += _ship_status(id,user,target,us,ts,seeded_target,uh,th,ship)
				if score>best:
					best = score
					choices.clear()
				if score==best:choices.append(id)
				continue
			if cerulean_leader:
				if id=="harden" and int(us["def"])==6:score -= 10
				if id=="recover":
					if uh==100:score -= 3
					elif rules.speed(target,ts)<=rules.speed(user,us):score -= 8
					elif uh<70 or roll()<30:
						if roll()>=20:score += 2
					else:score -= 3
				if score>best:
					best = score
					choices.clear()
				if score==best:choices.append(id)
				continue
			if bad_move_only:
				if id in ["harden","defensecurl","withdraw"] and int(us["def"])==6:score -= 10
				elif id=="stringshot" and int(ts["spe"])==-6:score -= 10
				elif id=="sandattack" and int(ts["accuracy"])==-6:score -= 10
				elif id=="leer" and int(ts["def"])==-6:score -= 10
				elif id=="sing" and target.get("status","")!="":score -= 10
				if score>best:
					best = score
					choices.clear()
				if score==best:choices.append(id)
				continue
			# FireRed EFFECT_DEFENSE_CURL only has the CHECK_BAD_MOVE ceiling
			# branch; CHECK_VIABILITY dispatch does not include this effect.
			if id=="defensecurl":
				if int(us["def"])==6:score -= 10
				if score>best:
					best = score
					choices.clear()
				if score==best:choices.append(id)
				continue
			var stat: String = "atk" if id=="growl" else "def" if id=="tailwhip" else "accuracy"
			if int(ts[stat])==-6:score -= 10
			if id=="growl":
				if int(ts["atk"])!=0:
					score -= 1
					if uh<=90:score -= 1
					if int(ts["atk"])<=-3 and roll()>=50:score -= 2
				if th<=70:score -= 2
				var physical: Array = ["Normal","Fighting","Ground","Rock","Bug","Steel"]
				if not rules.species[target["species_id"]]["types"].any(func(t):return t in physical) and roll()>=50:score -= 2
			elif id=="tailwhip":
				if (uh<70 or int(ts["def"])<=-3) and roll()>=50:score -= 2
				if th<=70:score -= 2
			elif id=="sandattack":
				if (uh<70 or th<=70) and roll()>=100:score -= 1
				if int(us["accuracy"])<=-2 and roll()>=80:score -= 2
				if seeded_target and roll()>=70:score += 2
				if uh<=70 and int(ts["accuracy"])!=0:
					if uh<40 or th<40 or roll()>=70:score -= 2
		if score>best:
			best = score
			choices.clear()
		if score==best:choices.append(id)
	return "struggle" if choices.is_empty() else choices[randi()%choices.size()]

# SS Anne rival source flags BAD_MOVE + VIABILITY + TRY_TO_FAINT.
# Only roster-reachable effects, using current subset damage/speed and battle-local context.
func _ship_status(id: String,user: Dictionary,target: Dictionary,us: Dictionary,ts: Dictionary,seeded: bool,uh: int,th: int,context: Dictionary) -> int:
	var score: int = 0
	if id=="teleport":return -10
	if id in ["sleeppowder","poisonpowder"]:
		if target.get("status","")!="":score -= 10
		if id=="poisonpowder":
			if rules.species[target["species_id"]]["types"].any(func(t):return t in ["Poison","Steel"]):score -= 10
			if uh<50 or th<=50:score -= 1
		return score
	if id=="leechseed":
		if seeded or "Grass" in rules.species[target["species_id"]]["types"]:score -= 10
		if user["moves"].any(func(m):return rules.power(m,target)>0):
			if uh<=50 and roll()>=50:score -= 3
			if th<=50 and roll()>=50:score -= 3
		return score
	if id=="disable":
		if context.get("target_disabled",false):score -= 8
		if rules.speed(target,ts)<=rules.speed(user,us):
			if rules.power(context.get("target_last","tackle"),user)>0:score += 1
			elif roll()>=100:score -= 1
		return score
	if id=="withdraw":
		if int(us["def"])==6:score -= 10
		if int(us["def"])>=3:
			if roll()>=100:score -= 1
		elif uh==100 and roll()>=128:score += 2
		if uh<70 or roll()>=200:
			if uh<40:score -= 2
			else:
				var last: String = context.get("target_last","tackle")
				if rules.power(last,user)>0 and rules.moves[last]["type"] not in ["Normal","Fighting","Poison","Ground","Flying","Rock","Bug","Ghost","Steel"]:score -= 2
				elif roll()>=60:score -= 2
		return score
	var stat: String = "atk" if id=="growl" else "def" if id=="tailwhip" else "accuracy"
	if int(ts[stat])==-6:score -= 10
	if id=="growl":
		if int(ts["atk"])!=0:
			score -= 1
			if uh<=90:score -= 1
			if int(ts["atk"])<=-3 and roll()>=50:score -= 2
		if th<=70:score -= 2
		if not rules.species[target["species_id"]]["types"].any(func(t):return t in ["Normal","Fighting","Ground","Rock","Bug","Steel"]) and roll()>=50:score -= 2
	elif id=="tailwhip":
		if (uh<70 or int(ts["def"])<=-3) and roll()>=50:score -= 2
		if th<=70:score -= 2
	else:
		if (uh<70 or th<=70) and roll()>=100:score -= 1
		if int(us["accuracy"])<=-2 and roll()>=80:score -= 2
		if seeded and roll()>=70:score += 2
		if uh<=70 and int(ts["accuracy"])!=0:
			if uh<40 or th<40 or roll()>=70:score -= 2
	return score

# FR gym roster-reachable AI, with existing subset damage/speed and no abilities.
func choose_gym(user: Dictionary,target: Dictionary,us: Dictionary,ts: Dictionary,leader: bool,seeded: bool,confusion: bool) -> String:
	var best: int = -999
	var choices: Array = []
	for id in user["moves"]:
		if int(user["pp"][id])<=0:continue
		var score: int = gym_score(id,user,target,us,ts,leader,seeded,confusion)
		if score>best:best = score;choices.clear()
		if score==best:choices.append(id)
	return "struggle" if choices.is_empty() else choices[randi()%choices.size()]
func gym_score(id: String,user: Dictionary,target: Dictionary,us: Dictionary,ts: Dictionary,leader: bool,seeded: bool,confusion: bool) -> int:
	var score: int = 100
	var uh: int = floori(100.0*int(user["hp"])/int(rules.pet_stats(user)["hp"]))
	var th: int = floori(100.0*int(target["hp"])/int(rules.pet_stats(target)["hp"]))
	if rules.power(id,target)>0:
		if rules.effectiveness(rules.moves[id]["type"],target["species_id"])==0:return 90
		if leader:
			if id=="sonicboom":return score # FR power1 bypasses can-faint / strongest evaluation
			var simulated: int = rules.damage(user,target,id,us,ts,1.0)*(100-randi()%16)/100
			if simulated>=int(target["hp"]):score += 6 if id=="quickattack" else 4
			else:
				var strongest: int = 0
				for other in user["moves"]:
					if int(user["pp"][other])>0:strongest = maxi(strongest,rules.damage(user,target,other,us,ts))
				if rules.damage(user,target,id,us,ts)<strongest:score -= 1
			if id=="shockwave":
				if int(ts["evasion"])>4 or int(us["accuracy"])< -4:
					score += 1
					if roll()>=100:score += 1
				elif int(ts["evasion"])>2 or int(us["accuracy"])< -2:
					if roll()>=100:score += 1
		return score
	if id=="screech":
		if int(ts["def"])==-6:score -= 10
		if leader:
			if (uh<70 or int(ts["def"])<=-3) and roll()>=50:score -= 2
			if th<=70:score -= 2
	elif id=="thunderwave":
		if rules.effectiveness("Electric",target["species_id"])==0 or target.get("status","")!="":score -= 10
		if leader:
			if rules.speed(target,ts)>rules.speed(user,us):
				if roll()>=20:score += 3
			elif uh<=70:score -= 1
	elif id=="doubleteam":
		if int(us["evasion"])==6:score -= 10
		if leader:
			if uh>=90 and roll()>=100:score += 3
			if int(us["evasion"])>=3 and roll()>=128:score -= 1
			if seeded and roll()>=70:score += 3
			if uh<=70 and int(us["evasion"])!=0 and (uh<40 or th<40 or roll()>=70):score -= 2
	elif id=="supersonic" and confusion:score -= 5
	return score

# FR Sabrina's three AI scripts, only her explicit four-move roster effects.
func choose_sabrina(user: Dictionary,target: Dictionary,us: Dictionary,ts: Dictionary,context: Dictionary) -> String:
	var best: int = -999
	var choices: Array = []
	for id in user["moves"]:
		if int(user["pp"][id])<=0:continue
		var score: int = sabrina_score(id,user,target,us,ts,context)
		if score>best:best = score;choices.clear()
		if score==best:choices.append(id)
	return "struggle" if choices.is_empty() else choices[randi()%choices.size()]
func sabrina_score(id: String,u: Dictionary,t: Dictionary,us: Dictionary,ts: Dictionary,c: Dictionary) -> int:
	var score: int = 100
	var hp: int = int(u["hp"])*100/int(rules.pet_stats(u)["hp"])
	if id=="futuresight":return 90 if c.get("future",false) else 100
	if rules.power(id,t)>0:
		if rules.effectiveness(rules.moves[id]["type"],t["species_id"])==0:return 90
		if rules.damage(u,t,id,us,ts,1.0)*(100-randi()%16)/100>=int(t["hp"]):score += 4
		else:
			var maximum: int = 0
			for other in u["moves"]:
				if int(u["pp"][other])>0 and other!="futuresight":maximum = maxi(maximum,rules.damage(u,t,other,us,ts))
			if rules.damage(u,t,id,us,ts)<maximum:score -= 1
		return score
	if id=="reflect":
		if c.get("reflect",0)>0:score -= 8
		if hp<50:score -= 2
		elif not rules.species[t["species_id"]]["types"].any(func(v):return v in ["Normal","Fighting","Flying","Poison","Ground","Rock","Bug","Ghost","Steel"]) and roll()>=50:score -= 2
	elif id=="barrier":
		if int(us["def"])==6:score -= 10
	elif id=="calmmind":
		if int(us["spa"])==6 and int(us["spd"])==6:score -= 10
	elif id=="recover":
		if hp==100:score -= 3
		elif rules.speed(t,ts)<=rules.speed(u,us):score -= 8
		elif hp<70 or roll()<30:
			if roll()>=20:score += 2
		else:score -= 3
	elif id=="supersonic" and c.get("confused",false):score -= 5
	elif id=="batonpass":
		if int(c.get("reserves",0))==0:return 90
		var boost: int = 0
		for stat in ["atk","def","spa","spd","evasion"]:boost = maxi(boost,int(us[stat]))
		var fast_target: bool = rules.speed(t,ts)>rules.speed(u,us)
		if boost>=3:
			if hp<=(70 if fast_target else 60) and roll()>=80:score += 2
		elif boost<2 or (hp>=70 if fast_target else hp>60):score -= 2
	return score

# FR battle_ai_scripts.s: Koga CBM / TryToFaint / CV reachable subset.
func choose_koga(u: Dictionary,t: Dictionary,us: Dictionary,ts: Dictionary,c: Dictionary) -> String:
	var best: int = -999
	var choices: Array = []
	for id in u["moves"]:
		if int(u["pp"][id])<=0:continue
		var score: int = koga_score(id,u,t,us,ts,c)
		if score>best:best = score;choices.clear()
		if score==best:choices.append(id)
	return "struggle" if choices.is_empty() else choices[randi()%choices.size()]
func koga_score(id: String,u: Dictionary,t: Dictionary,us: Dictionary,ts: Dictionary,c: Dictionary) -> int:
	var score: int = 100
	var hp: int = int(u["hp"])*100/int(rules.pet_stats(u)["hp"])
	var th: int = int(t["hp"])*100/int(rules.pet_stats(t)["hp"])
	if id=="toxic":
		if t.get("status","")!="" or rules.species[t["species_id"]]["types"].any(func(v):return v in ["Poison","Steel"]):return 90
		if hp<=50 and roll()>=50:score -= 3
		if th<=50 and roll()>=50:score -= 3
		return score
	if rules.power(id,t)>0:
		if rules.effectiveness(rules.moves[id]["type"],t["species_id"])==0:return 90
		if id=="selfdestruct":
			if int(c.get("user_reserves",0))==0:score -= 10 if int(c.get("target_reserves",0))>0 else 1
			if int(ts["evasion"])>=1:score -= 1
			if int(ts["evasion"])>=4 and roll()>=128:score -= 1
			if hp>=80 and rules.speed(u,us)>=rules.speed(t,ts):
				if roll()>=50:score -= 3
			elif hp<=50:
				if roll()>=128:score += 1
				if hp<=30 and roll()>=50:score += 1
			elif roll()>=50:score -= 1
		else:
			if rules.damage(u,t,id,us,ts)*(100-randi()%16)/100>=int(t["hp"]):score += 4
			var strongest: int = 0
			for other in u["moves"]:
				if other!="selfdestruct" and int(u["pp"][other])>0:strongest = maxi(strongest,rules.damage(u,t,other,us,ts))
			if rules.damage(u,t,id,us,ts)<strongest:score -= 1
		return score
	if id=="acidarmor":
		if int(us["def"])==6:return 90
		if int(us["def"])>=3:
			if roll()>=100:score -= 1
		elif hp==100 and roll()>=128:score += 2
		if hp<70 or roll()>=200:
			var previous: String = c.get("last","")
			if hp<40 or previous!="" and rules.power(previous,u)>0 and rules.moves[previous]["category"]!="Physical" or roll()>=60:score -= 2
	elif id=="minimize":
		if int(us["evasion"])==6:return 90
		if hp>=90 and roll()>=100:score += 3
		if int(us["evasion"])>=3 and roll()>=128:score -= 1
		if t.get("status","")=="toxic" and (hp>50 or roll()>=80) and roll()>=50:score += 3
		if c.get("seeded",false) and roll()>=70:score += 3
		if c.get("rooted",false) and roll()>=128:score += 2
		if c.get("cursed",false) and roll()>=70:score += 3
		if hp<=70 and (hp<40 or th<40 or roll()>=70):score -= 2
	elif id=="smokescreen":
		if int(ts["accuracy"])==-6:return 90
		if (hp<70 or th<=70) and roll()>=100:score -= 1
		# Preserve the source's user-accuracy check, despite targeting opponent.
		if int(us["accuracy"])<=-2 and roll()>=80:score -= 2
		if t.get("status","")=="toxic" and roll()>=70:score += 2
		if c.get("seeded",false) and roll()>=70:score += 2
		if c.get("rooted",false) and roll()>=128:score += 1
		if c.get("cursed",false) and roll()>=70:score += 2
		if hp<=70 and int(ts["accuracy"])!=-6 and (hp<40 or th<40 or roll()>=70):score -= 2
	return score
