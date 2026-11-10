extends RefCounted
## Gen III necessary subset, data exported from @pkmn/sim Dex.forGen(3).
## Growth stats and battle-local ability resolver; see docs/single-abilities.md.
var moves: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/moves.json"))
var types: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/types.json"))
var species: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/pets.json"))

var transformed_stats: Dictionary = {}
var type_overrides:Dictionary={}
var weather_type:String=""
var ability_resolver:Callable
var flash_fire:Dictionary={}
var double_damage:bool=false
var spread_damage:bool=false
var helping_damage:bool=false
var double_screen_count:int=1
func ability(pet:Dictionary)->String:return ability_resolver.call(pet) if ability_resolver.is_valid() else "NONE"
func pet_types(pet:Dictionary)->Array:return type_overrides.get(pet.get("individual_id",""),species[pet["species_id"]]["types"])
var growth = preload("res://scripts/growth.gd").new()
func stats(id: String, level: int = 10) -> Dictionary:
	return growth.stats({"species_id":id,"level":level})
func pet_stats(pet: Dictionary) -> Dictionary:
	return transformed_stats.get(pet["individual_id"],growth.stats(pet))

func stages() -> Dictionary:
	return {"atk":0,"def":0,"spa":0,"spd":0,"spe":0,"accuracy":0,"evasion":0}

func staged(value: int, stage: int) -> int:
	return maxi(1,floori(value*(2.0+maxi(stage,0))/(2.0+maxi(-stage,0))))

func effectiveness(type: String, target_id: String,pet:Dictionary={}) -> float:
	var mult: float = 1.0
	for target_type in (pet_types(pet) if not pet.is_empty() else species[target_id]["types"]):
		match int(types[target_type].get(type,0)):
			1: mult *= 2.0
			2: mult *= 0.5
			3: mult = 0.0
	return mult

func power(move_id: String, defender: Dictionary) -> int:
	if move_id in ["dragonrage","nightshade","sonicboom","seismictoss","magnitude","flail"]:return 1
	if move_id!="lowkick":return int(moves[move_id]["power"])
	var kg: float = float(species[defender["species_id"]].get("weightkg",0))
	for entry in [[10,20],[25,40],[50,60],[100,80],[200,100]]:
		if kg<float(entry[0]):return int(entry[1])
	return 120

func damage(attacker: Dictionary, defender: Dictionary, move_id: String, attack_stages: Dictionary, defense_stages: Dictionary, random_factor: float = 1.0, power_factor: float = 1.0, critical: bool = false, dynamic_power: int = 0, identified: bool = false, reflected: bool = false, light_screened: bool = false) -> int:
	if move_id in ["dragonrage","nightshade","sonicboom","seismictoss"]:
		return 0 if move_effectiveness(moves[move_id]["type"],defender["species_id"],identified,defender)==0 else 40 if move_id=="dragonrage" else 20 if move_id=="sonicboom" else int(attacker["level"])
	var move: Dictionary = moves[move_id]
	if move_id=="weatherball" and weather_type!="":
		move=move.duplicate();move["type"]=weather_type;move["category"]="Physical" if weather_type=="Rock" else "Special";dynamic_power=100
	if move_id=="hiddenpower":
		move=move.duplicate();var hidden:Dictionary=hidden_power(attacker);move["type"]=hidden["type"];move["category"]="Physical" if hidden["type"] in ["Fighting","Flying","Poison","Ground","Rock","Bug","Ghost","Steel"] else "Special";dynamic_power=hidden["power"]
	if move_id in ["return","frustration"]:dynamic_power=maxi(1,int((int(attacker.get("friendship",70)) if move_id=="return" else 255-int(attacker.get("friendship",70)))*10/25))
	if move_id in ["eruption","waterspout"]:dynamic_power=maxi(1,150*int(attacker["hp"])/int(pet_stats(attacker)["hp"]))
	if move_id=="smellingsalt" and defender.get("status","")=="paralysis":dynamic_power=120
	if move_id in ["flail","reversal"]:dynamic_power = flail_power(int(attacker["hp"]),int(pet_stats(attacker)["hp"]))
	if move_id=="facade" and attacker.get("status","") in ["poison","toxic","paralysis","burn"]:dynamic_power = int(move["power"])*2
	var base_power: int = floori((dynamic_power if dynamic_power>0 else power(move_id,defender))*power_factor)
	if helping_damage:base_power=base_power*15/10
	if base_power==0:
		return 0
	var attack_stat: String = "atk" if move["category"]=="Physical" else "spa"
	var defense_stat: String = "def" if move["category"]=="Physical" else "spd"
	var attack: int = int(pet_stats(attacker)[attack_stat])
	if attacker.get("held_item","")=="blackbelt" and move["type"]=="Fighting" or attacker.get("held_item","")=="metalcoat" and move["type"]=="Steel":attack = attack*110/100
	if attack_stat=="atk" and ability(attacker)=="GUTS" and attacker.get("status","")!="":attack=attack*3/2
	if (ability(attacker)=="OVERGROW" and move["type"]=="Grass" or ability(attacker)=="BLAZE" and move["type"]=="Fire" or ability(attacker)=="TORRENT" and move["type"]=="Water" or ability(attacker)=="SWARM" and move["type"]=="Bug") and int(attacker["hp"])<=int(pet_stats(attacker)["hp"])/3:attack=attack*3/2
	if ability(defender)=="THICK_FAT" and move["type"] in ["Fire","Ice"]:attack=maxi(1,attack/2)
	if flash_fire.has(attacker["individual_id"]) and move["type"]=="Fire":attack=attack*3/2
	var a: int = staged(attack,maxi(0,int(attack_stages[attack_stat])) if critical else int(attack_stages[attack_stat]))
	var defense: int = int(pet_stats(defender)[defense_stat])
	if move_id in ["selfdestruct","explosion"]:defense = maxi(1,defense/2)
	var d: int = staged(defense,mini(0,int(defense_stages[defense_stat])) if critical else int(defense_stages[defense_stat]))
	# Standard integer base damage, followed by STAB/type/random modifiers.
	var base_damage: int = floori(floori((floori(2.0*int(attacker["level"])/5.0)+2)*base_power*float(a)/d)/50.0)+2
	if attacker.get("status","")=="burn" and move["category"]=="Physical" and ability(attacker)!="GUTS":base_damage = floori((base_damage-2)/2.0)+2
	if reflected and not critical and move["category"]=="Physical":base_damage = (2*((base_damage-2)/3) if double_damage and double_screen_count==2 else maxi(1,floori((base_damage-2)/2.0)))+2
	if light_screened and not critical and move["category"]=="Special":base_damage = (2*((base_damage-2)/3) if double_damage and double_screen_count==2 else maxi(1,floori((base_damage-2)/2.0)))+2
	if spread_damage:base_damage=maxi(1,(base_damage-2)/2)+2
	# FireRed CalculateBaseDamage physical minimum is 1 before the final +2.
	# O12 Jump Kick and Hi Jump Kick use this path for hypothetical crash damage.
	if move_id in ["hijumpkick","jumpkick"]:base_damage = maxi(3,base_damage)
	if critical:base_damage *= 2
	var stab: float = 1.5 if move["type"] in pet_types(attacker) else 1.0
	var mult: float = move_effectiveness(move["type"],defender["species_id"],identified,defender)
	return 0 if mult==0 else maxi(1,floori(floori(floori(base_damage*stab)*mult)*random_factor))

func first(attacker: Dictionary, defender: Dictionary, player_move: String, enemy_move: String, player_stages: Dictionary, enemy_stages: Dictionary) -> bool:
	var ap: int = int(moves[player_move]["priority"])
	var dp: int = int(moves[enemy_move]["priority"])
	if ap!=dp:
		return ap>dp
	var a: int = speed(attacker,player_stages)
	var d: int = speed(defender,enemy_stages)
	return a>d or (a==d and randf()<0.5)

# pret/pokefirered 7e3f822: battle_script_commands.c Cmd_handleballthrow.
# Ordinary Poke Ball x1; implemented poison/paralysis x1.5. Four 16-bit shake checks.
func capture(hp: int, max_hp: int, rate: int, rolls: Array, status: String = "", ball_multiplier:int=10) -> Dictionary:
	var odds: int = floori(float(floori(rate*ball_multiplier/10.0)*(3*max_hp-2*hp))/(3*max_hp))
	if status in ["sleep","freeze"]:odds *= 2
	if status in ["poison","toxic","paralysis","burn"]:odds = floori(odds*15.0/10)
	if odds>254:return {"caught":true,"shakes":4,"odds":odds}
	if odds<=0:return {"caught":false,"shakes":0,"odds":odds}
	var root: int = floori(sqrt(floori(sqrt(floori(16711680.0/odds)))))
	var threshold: int = floori(1048560.0/root)
	var shakes: int = 0
	for roll in rolls:
		if int(roll)>=threshold:break
		shakes += 1
	return {"caught":shakes==4,"shakes":shakes,"odds":odds,"threshold":threshold}

# battle_main.c TryRunFromBattle: speedVar is u8 (intentional modulo 256).
func escape(speed: int, enemy_speed: int, tries: int, roll: int) -> bool:
	if speed>=enemy_speed:return true
	var speed_var: int = (floori(float(speed*128)/enemy_speed)+tries*30)%256
	return speed_var>roll

func speed(pet: Dictionary, stages_value: Dictionary) -> int:
	var value: int = staged(pet_stats(pet)["spe"],int(stages_value["spe"]))
	if ability(pet)=="SWIFT_SWIM" and weather_type=="Water" or ability(pet)=="CHLOROPHYLL" and weather_type=="Fire":value*=2
	return maxi(1,floori(value/4.0)) if pet.get("status","")=="paralysis" else value

func inflict(pet: Dictionary, status: String) -> bool:
	if int(pet["hp"])<=0 or pet.get("status","")!="":return false
	if status in ["poison","toxic"] and ability(pet)=="IMMUNITY" or status=="burn" and ability(pet)=="WATER_VEIL" or status=="paralysis" and ability(pet)=="LIMBER" or status=="sleep" and ability(pet) in ["INSOMNIA","VITAL_SPIRIT"]:return false
	if status in ["poison","toxic"] and ("Poison" in pet_types(pet) or "Steel" in pet_types(pet)):return false
	if status=="freeze" and "Ice" in pet_types(pet):return false
	if status=="burn" and "Fire" in pet_types(pet):return false
	pet["status"] = status
	if status=="toxic":pet["toxic_counter"] = 0
	return true

# Source Cmd_critcalc no abilities/items: focus +2, high-critical move +1.
func crit_denominator(move: String, focus: bool) -> int:
	var stage: int = (2 if focus else 0)+(1 if move in ["razorleaf","karatechop","slash","crosschop","aircutter","crabhammer","aeroblast","blazekick","poisontail","leafblade","razorwind"] else 0)
	return [16,8,4,3,2][mini(4,stage)]

# pret Cmd_magnitudedamagecalculation: Random()%100 thresholds.
func magnitude(roll: int) -> Array:
	for row in [[5,4,10],[15,5,30],[35,6,50],[65,7,70],[85,8,90],[95,9,110],[100,10,150]]:
		if roll%100<int(row[0]):return [row[1],row[2]]
	return []
func roar_succeeds(user_level: int,target_level: int,roll: int) -> bool:
	return user_level>=target_level or (((roll&255)*(user_level+target_level)>>8)+1)>target_level/4
func move_effectiveness(type: String,target_id: String,identified: bool = false,pet:Dictionary={}) -> float:
	var mult: float = 1.0
	for target_type in (pet_types(pet) if not pet.is_empty() else species[target_id]["types"]):
		if identified and target_type=="Ghost" and type in ["Normal","Fighting"]:continue
		match int(types[target_type].get(type,0)):
			1:mult *= 2
			2:mult *= .5
			3:mult = 0
	return mult

# FR Cmd_rolloutdamagecalculation: five powers, doubled by Defense Curl.
func rollout_power(hit: int,defense_curl: bool) -> int:
	return 30*(1<<clampi(hit,0,4))*(2 if defense_curl else 1)

func flail_power(hp: int,maximum: int) -> int:
	var ratio: int = hp*48/maximum
	for p in [[1,200],[4,150],[9,100],[16,80],[32,40],[48,20]]:
		if ratio<=p[0]:return p[1]
	return 20

# FireRed Cmd_ohko strict source roll check; no accuracy/evasion stages.
func horn_drill_hits(user_level: int,target_level: int,roll: int,sure_hit: bool = false) -> bool:
	return user_level>=target_level and (sure_hit or roll%100+1<30+user_level-target_level)

# FireRed Cmd_hiddenpowercalc uses IV order HP, Atk, Def, Speed, SpAtk, SpDef.
func hidden_power(pet:Dictionary)->Dictionary:
	var bits:int=0;var power_bits:int=0;var order:Array=["hp","atk","def","spe","spa","spd"]
	for i in range(6):
		var iv:int=int(pet.get("ivs",growth.zeros())[order[i]])
		bits|=(iv&1)<<i;power_bits|=((iv>>1)&1)<<i
	return {"type":["Fighting","Flying","Poison","Ground","Rock","Bug","Ghost","Steel","Fire","Water","Grass","Electric","Psychic","Ice","Dragon","Dark"][bits*15/63],"power":30+power_bits*40/63}
