extends "res://scripts/battle.gd"
## Four battler adapter; individual effects, animations and settlement reuse Battle.
# Positions follow FireRed: player left, opponent left, player right, opponent right.
var slots:Array=[-1,-1,-1,-1]
var slot_stages:Array=[]
var sprites:Array=[]
var bars:Array=[]
var names:Array=[]
var levels:Array=[]
var commands:Dictionary={}
var cursor:int=0
var pending_move:String=""
var selected_target:int=1
var context_actor:int=-1
var context_target:int=-1
var follow_me:Dictionary={}
var helping:Dictionary={}
var seeds:Dictionary={}
var resolving:bool=false
var replacement:int=-1
var awarded:Dictionary={}
var action_history:Array=[]
var round_order:Array=[]

func party_for(slot:int)->Array:return store.state["team"] if slot%2==0 else enemy_party
func pet_at(slot:int)->Dictionary:
	if slot<0 or slot>3 or slots[slot]<0:return {}
	return party_for(slot)[slots[slot]]
func alive(slot:int)->bool:return not pet_at(slot).is_empty() and int(pet_at(slot)["hp"])>0
func slot_of(pet:Dictionary)->int:
	for i in range(4):
		if not pet_at(i).is_empty() and pet_at(i)["individual_id"]==pet["individual_id"]:return i
	return -1
func _field_pets()->Array:
	var result:Array=[]
	for i in range(4):
		if not pet_at(i).is_empty():result.append(pet_at(i))
	return result
func _effect_key(pet:Dictionary)->String:return str(slot_of(pet))
func _effect_pet(key:String)->Dictionary:return pet_at(int(key))
func active_pet()->Dictionary:
	if context_actor>=0 and context_actor%2==0:return pet_at(context_actor)
	if context_target>=0 and context_target%2==0:return pet_at(context_target)
	return pet_at(cursor if cursor%2==0 and slots[cursor]>=0 else 0)
func bind_context(actor:int,target:int)->void:
	context_actor=actor;context_target=target
	var ps:int=actor if actor%2==0 else target if target%2==0 else 0
	var es:int=actor if actor%2==1 else target if target%2==1 else 1
	if slots[ps]>=0:
		store.state["lead"]=slots[ps];player_stages=slot_stages[ps]
		if not sprites.is_empty():portrait=sprites[ps];hp_bar=bars[ps]
	if slots[es]>=0:
		enemy_index=slots[es];enemy=pet_at(es);enemy_stages=slot_stages[es]
		if not sprites.is_empty():enemy_portrait=sprites[es];enemy_bar=bars[es]
func _ready()->void:
	rules.ability_resolver=_item_ability
	battle_before=store.state.duplicate(true);trainer_before=battle_before.duplicate(true)
	for p in store.state["team"]+enemy_party:original_held_items[p["individual_id"]]=p.get("held_item","")
	for i in range(4):slot_stages.append(rules.stages())
	slots[0]=int(store.state["lead"]);slots[1]=0
	for i in range(store.state["team"].size()):
		if i!=slots[0] and int(store.state["team"][i]["hp"])>0:slots[2]=i;break
	if enemy_party.size()>1:slots[3]=1
	for i in [0,2]:
		if slots[i]>=0:participants.append(slots[i])
	canvas=Control.new();add_child(canvas);_image(arena_path,Rect2(0,0,960,448))
	for i in range(4):
		var player:bool=i%2==0
		var x:float=80 if i==0 else 300 if i==2 else 520 if i==1 else 740
		var img:TextureRect=_image("res://assets/pokemon/healthbox-player.png",Rect2(x,205 if player else 15,200,56))
		img.mouse_filter=Control.MOUSE_FILTER_IGNORE
		var sprite:TextureRect=_image(store.species[pet_at(i)["species_id"]]["back" if player else "sprite"] if slots[i]>=0 else "res://assets/pokemon/healthbox-player.png",Rect2(x,270 if player else 74,180,170))
		sprites.append(sprite)
		names.append(UI.label(canvas,"",Rect2(x+8,208 if player else 18,185,25),17))
		levels.append(UI.label(canvas,"",Rect2(x+8,231 if player else 41,65,23),14))
		var bar:ProgressBar=_bar(Vector2(x+74,240 if player else 50));bar.size=Vector2(115,6);bars.append(bar)
	UI.panel(canvas,Rect2(0,448,960,192));log_label=UI.label(canvas,"",Rect2(24,460,420,166),19);log_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	menu=Control.new();canvas.add_child(menu)
	bind_context(0,1)
	presentation=preload("res://scripts/battle_presentation.gd").new();canvas.add_child(presentation);presentation.setup(self)
	presentation.presented.connect(func(e:Dictionary):telemetry.emit(e))
	telemetry.connect(func(e:Dictionary):
		if visual_depth>0 and e.get("event","")!="battle_animation":visual_events.append(e.duplicate(true)))
	var entries:Array=[0,1,2,3];entries.shuffle();entries.sort_custom(func(a,b):return rules.speed(pet_at(a),slot_stages[a])>rules.speed(pet_at(b),slot_stages[b]) if alive(a) and alive(b) else alive(a))
	for i in entries:
		if alive(i):_ability_entry(pet_at(i),i%2==0)
	for p in _field_pets():store.pokedex.register(store.state,store.species,p["species_id"],false)
	log_text="双打：双方各两个出战位。\n为左、右伙伴分别下达指令。";_update()

func _disabled(pet:Dictionary,id:String)->bool:
	var key:String=pet["individual_id"]
	if disabled_moves.get(key,{}).get("move","")==id or taunted.has(key) and rules.moves[id]["category"]=="Status" or tormented.has(key) and last_moves.get(key,"")==id and id!="struggle":return true
	for p in _field_pets():
		if _side(p)!=_side(pet) and int(p["hp"])>0 and imprisoned_by.has(p["individual_id"]) and id in p["moves"]:return true
	return false
func legal_targets(actor:int,id:String)->Array:
	var kind:String=rules.moves[id]["source_target"];var result:Array=[]
	if id=="helpinghand":return [actor^2] if alive(actor^2) else []
	if kind in ["MOVE_TARGET_USER","MOVE_TARGET_OPPONENTS_FIELD"]:return [actor]
	if kind=="MOVE_TARGET_DEPENDS":
		if id in ["magiccoat","snatch"]:return [actor^1] if alive(actor^1) else [actor^3]
		if id in ["counter","mirrorcoat"]:
			var source:String=direct_damage_sources.get(pet_at(actor)["individual_id"],"")
			for i in range(4):
				if alive(i) and pet_at(i)["individual_id"]==source:return [i]
		return [actor^1] if alive(actor^1) else [actor^3]
	for i in range(4):
		if not alive(i):continue
		if kind=="MOVE_TARGET_BOTH" and i%2!=actor%2:result.append(i)
		elif kind=="MOVE_TARGET_FOES_AND_ALLY" and i!=actor:result.append(i)
		elif kind=="MOVE_TARGET_RANDOM" and i%2!=actor%2:result.append(i)
		elif kind=="MOVE_TARGET_SELECTED" and i!=actor:result.append(i)
	return result
func targets_for(actor:int,id:String,chosen:int)->Array:
	var legal:Array=legal_targets(actor,id);var kind:String=rules.moves[id]["source_target"]
	if legal.is_empty():return []
	if kind in ["MOVE_TARGET_BOTH","MOVE_TARGET_FOES_AND_ALLY"]:return legal
	if kind in ["MOVE_TARGET_USER","MOVE_TARGET_OPPONENTS_FIELD","MOVE_TARGET_DEPENDS"] or id=="helpinghand":return legal
	if kind=="MOVE_TARGET_RANDOM":chosen=legal.pick_random()
	if chosen not in legal:
		var foes:Array=legal.filter(func(i):return i%2!=actor%2)
		chosen=foes[0] if not foes.is_empty() else legal[0]
	var opposite:int=1-actor%2
	if kind=="MOVE_TARGET_SELECTED" and follow_me.has(opposite) and alive(follow_me[opposite]):return [follow_me[opposite]]
	# FireRed redirects to the opposing Lightning Rod, no Gen V immunity/boost.
	if rules.moves[id]["type"]=="Electric" and kind!="MOVE_TARGET_USER" and not follow_me.has(opposite):
		for i in round_order+[1,3,0,2]:
			if alive(i) and i%2!=actor%2 and _item_ability(pet_at(i))=="LIGHTNING_ROD":return [i]
	return [chosen]
func _unhandled_key_input(event:InputEvent)->void:
	if is_instance_valid(evolution_view):return
	if not event is InputEventKey or not event.pressed or event.echo or busy:return
	if not learning.is_empty():
		if event.physical_keycode in [KEY_1,KEY_2,KEY_3,KEY_4,KEY_5]:_learn_choice(event.physical_keycode-KEY_1)
		return
	if ended:
		if event.physical_keycode in [KEY_E,KEY_ENTER,KEY_SPACE]:finished.emit(won)
		return
	if event.physical_keycode==KEY_ESCAPE:
		if replacement>=0:return
		if mode=="target":mode="moves"
		elif mode!="root":mode="root"
		else:commands.clear();cursor=0 if alive(0) else 2
		_update();return
	if event.physical_keycode in [KEY_1,KEY_2,KEY_3,KEY_4,KEY_5,KEY_6]:_select(event.physical_keycode-KEY_1)
func _select(index:int)->void:
	if busy or ended:return
	if replacement>=0:
		if _can_switch(replacement,index):
			var slot:int=replacement;replacement=-1
			if baton_pending:
				var old:String=pet_at(slot)["individual_id"];var carry:Array=[];var sets:Array=[confused,focused,cursed,perish_counts,rooted,mud_sport,water_sport,substitutes]
				for values in sets:carry.append(values.get(old,null))
				_replace(slot,index,true)
				for j in range(sets.size()):
					if carry[j]!=null:sets[j][pet_at(slot)["individual_id"]]=carry[j]
				baton_pending=false;busy=true;mode="root"
			else:_replace(slot,index);_fill_slots()
		return
	match mode:
		"root":
			if index==0:mode="moves"
			elif index==1:mode="team"
			elif index==2:commands.clear();cursor=0 if alive(0) else 2
			_update()
		"moves":
			var p:Dictionary=pet_at(cursor);var ids:Array=p["moves"] if _has_usable_move(p) else ["struggle"]
			if index>=ids.size():return
			_choose(ids[index])
		"target":
			if index in legal_targets(cursor,pending_move):_queue({"move":pending_move,"target":index})
		"team":
			if _can_switch(cursor,index):_queue({"switch":index})
func _choose(id:String)->void:
	if busy or ended or commands.has(cursor) or not alive(cursor):return
	id=_forced_move(pet_at(cursor),id)
	if _disabled(pet_at(cursor),id) or id!="struggle" and int(pet_at(cursor)["pp"].get(id,0))<=0 and _forced_move(pet_at(cursor),"")=="":return
	pending_move=id
	if rules.moves[id]["source_target"]=="MOVE_TARGET_SELECTED" and id!="helpinghand":mode="target";_update()
	else:
		var targets:Array=legal_targets(cursor,id);_queue({"move":id,"target":targets[0] if not targets.is_empty() else cursor})
func _queue(command:Dictionary)->void:
	if busy or ended or commands.has(cursor):return
	command["actor"]=cursor;command["individual_id"]=pet_at(cursor)["individual_id"];commands[cursor]=command
	if cursor==0 and alive(2):cursor=2;mode="root";_update();return
	_resolve_round()
func _can_switch(slot:int,index:int)->bool:
	var party:Array=party_for(slot)
	if index<0 or index>=party.size() or int(party[index]["hp"])<=0:return false
	for i in range(slot%2,4,2):
		if slots[i]==index:return false
	for command in commands.values():
		if command.get("switch",-1)==index and command["actor"]%2==slot%2:return false
	if not alive(slot):return true
	var p:Dictionary=pet_at(slot);var key:String=p["individual_id"]
	if bindings.has(key) or trapped.has(key) or rooted.has(key) or _forced_move(p,"")!="":return false
	for foe in _field_pets():
		if _side(foe)!=_side(p) and int(foe["hp"])>0 and _ability_trapped(p,foe):return false
	return true
func _replace(slot:int,index:int,baton:bool=false)->void:
	var substitute_hp:int=int(substitutes.get(pet_at(slot).get("individual_id",""),0)) if baton else 0
	if slots[slot]>=0:
		var outgoing:Dictionary=pet_at(slot);var key:String=outgoing["individual_id"]
		if _item_ability(outgoing)=="NATURAL_CURE":_clear_status(outgoing)
		_restore_mimic(key);_restore_transform(key)
		seeds.erase(key);_release_bindings(key)
		for effects in [confused,focused,cursed,perish_counts,rooted,mud_sport,water_sport,substitutes,infatuated,trapped,identified,nightmares,yawned,disabled_moves,encored_moves,imprisoned_by,taunted,tormented,recharging,protected,enduring,protect_uses,rampages,rampage_moves,rollouts,rollout_moves,stockpiles,minimized,charged,biding,uproars,copied_abilities,airborne,underground,submerged,solar_charges,field_turns]:effects.erase(key)
	slots[slot]=index
	if substitute_hp>0:substitutes[pet_at(slot)["individual_id"]]=substitute_hp
	if not baton:slot_stages[slot]=rules.stages()
	bind_context(slot,slot^1 if alive(slot^1) else slot^3)
	var p:Dictionary=pet_at(slot)
	if slot%2==0 and index not in participants:participants.append(index)
	_spikes_entry(p,slot%2==0);_ability_entry(p,slot%2==0)
	store.pokedex.register(store.state,store.species,p["species_id"],false)
	telemetry.emit({"event":"double_replacement","slot":slot,"index":index,"hp":p["hp"]});_update()
func _fill_slots()->void:
	if _terminal():return
	for i in [0,1,2,3]:
		if alive(i):continue
		var candidates:Array=[]
		for j in range(party_for(i).size()):
			if _can_switch(i,j):candidates.append(j)
		if candidates.is_empty():continue
		if i%2==0:
			replacement=i;cursor=i;busy=false;mode="team";log_text="伙伴倒下了，选择后备补位。";_update();return
		_replace(i,candidates[0]);_fill_slots();return
	replacement=-1;cursor=0 if alive(0) else 2;context_actor=-1;context_target=-1;busy=false;mode="root";_update()
func _resolve_round()->void:
	if busy or resolving or ended:return
	busy=true;resolving=true;mode="root"
	acted.clear();flinched.clear();direct_damage_sources.clear();direct_damage_amounts.clear();direct_damage_physical.clear();follow_me.clear();helping.clear()
	for i in [1,3]:
		if not alive(i):continue
		bind_context(i,0 if alive(0) else 2)
		var id:String=_forced_move(pet_at(i),_enemy_move());var targets:Array=legal_targets(i,id)
		var foes:Array=targets.filter(func(t):return t%2!=i%2)
		commands[i]={"actor":i,"individual_id":pet_at(i)["individual_id"],"move":id,"target":foes.pick_random() if not foes.is_empty() else targets[0] if not targets.is_empty() else i}
	_sync_weather()
	var order:Array=ordered_actions(commands.values());round_order=order.map(func(c):return c["actor"])
	telemetry.emit({"event":"double_order","turn":turn,"order":round_order})
	for command in order:
		var actor:int=command["actor"]
		if not alive(actor) or pet_at(actor)["individual_id"]!=command["individual_id"]:continue
		if command.has("switch"):
			# A queued opposing Pursuit intercepts the outgoing target exactly once.
			for later in order:
				if later.get("move","")=="pursuit" and later.get("target",-1)==actor and later["actor"]%2!=actor%2 and alive(later["actor"]) and not later.get("spent",false):
					later["spent"]=true;pursuit_spent=true;await execute_action(later);pursuit_spent=false
			_replace(actor,command["switch"])
		elif not command.get("spent",false):await execute_action(command)
		if _terminal():break
	commands.clear();resolving=false;context_actor=-1;context_target=-1
	if ended:return
	await _round_end()
	if not ended:_fill_slots()
func ordered_actions(input:Array)->Array:
	var order:Array=input.duplicate(true)
	# Shuffle once, then stable priority/speed sorting: fair ties without an inconsistent random comparator.
	order.shuffle()
	for c in order:
		c["priority"]=6 if c.has("switch") else int(rules.moves[c["move"]]["priority"])
		c["speed"]=rules.speed(pet_at(c["actor"]),slot_stages[c["actor"]])
	order.sort_custom(func(a,b):return a["priority"]>b["priority"] if a["priority"]!=b["priority"] else a["speed"]>b["speed"])
	# Gen III switches resolve in battler position order, before all moves.
	var switches:Array=order.filter(func(c):return c.has("switch"));switches.sort_custom(func(a,b):return a["actor"]<b["actor"])
	return switches+order.filter(func(c):return not c.has("switch"))
func execute_action(command:Dictionary)->void:
	var actor:int=command["actor"];var id:String=command["move"]
	if not alive(actor):return
	var targets:Array=targets_for(actor,id,command["target"])
	if targets.is_empty():
		if id!="struggle":pet_at(actor)["pp"][id]=maxi(0,int(pet_at(actor)["pp"].get(id,0))-1)
		acted[pet_at(actor)["individual_id"]]=true;return
	bind_context(actor,targets[0]);selected_target=command["target"]
	action_history.append({"turn":turn,"actor":actor,"move":id,"targets":targets.duplicate()})
	telemetry.emit({"event":"double_action","actor":actor,"move":id,"targets":targets})
	await _move(pet_at(actor),pet_at(targets[0]),id,slot_stages[actor],slot_stages[targets[0]],actor%2==0)

func _dispatch_effect(a:Dictionary,d:Dictionary,id:String,ast:Dictionary,dst:Dictionary,player:bool,move:Dictionary,result:Dictionary)->void:
	var actor:int=slot_of(a);var targets:Array=targets_for(actor,id,selected_target)
	var kind:String=move["source_target"]
	if id=="helpinghand":
		var ally:int=actor^2;var applied:bool=alive(ally) and not helping.has(actor) and not helping.has(ally)
		if applied:helping[ally]=true
		log_text="帮助同伴，招式威力提高！" if applied else "帮助失败。";result["succeeded"]=applied;_update();return
	if id=="followme":follow_me[actor%2]=actor;log_text="成为注目焦点，吸引对手攻击！";result["succeeded"]=true;_update();return
	if id=="haze":
		for stages in slot_stages:
			for stat in stages:stages[stat]=0
		result["succeeded"]=true;return
	if id=="perishsong":
		for p in _field_pets():
			if int(p["hp"])>0 and _item_ability(p)!="SOUNDPROOF" and not perish_counts.has(p["individual_id"]):perish_counts[p["individual_id"]]=3
		result["succeeded"]=true;return
	if id=="leechseed":
		if not seeds.has(d["individual_id"]) and "Grass" not in rules.pet_types(d):seeds[d["individual_id"]]=actor;result["succeeded"]=true
		return
	var opponents:int=0
	for i in range(4):
		if alive(i) and i%2!=actor%2:opponents+=1
	rules.double_damage=true;rules.spread_damage=kind=="MOVE_TARGET_BOTH" and opponents==2;rules.helping_damage=helping.has(actor)
	for target in targets:
		if not alive(target):continue
		bind_context(actor,target);rules.double_screen_count=_field_pets().filter(func(p):return int(p["hp"])>0 and _side(p)==_side(pet_at(target))).size()
		# Damp checks the whole field before self-KO; later hits still execute.
		if id in ["explosion","selfdestruct"] and _field_pets().any(func(p):return int(p["hp"])>0 and _item_ability(p)=="DAMP"):break
		await super._execute_effect(a,pet_at(target),id,ast,slot_stages[target],player,move,result)
	rules.double_damage=false;rules.spread_damage=false;rules.helping_damage=false
	bind_context(actor,targets[0] if not targets.is_empty() else actor)
func _ability_entry(p:Dictionary,player:bool)->void:
	if int(p["hp"])<=0:return
	var slot:int=slot_of(p);var foes:Array=[]
	for i in range(4):
		if alive(i) and i%2!=slot%2:foes.append(i)
	if _item_ability(p)=="TRACE" and not foes.is_empty():
		var target:Dictionary=pet_at(foes.pick_random());var ability:String=_item_ability(target)
		if ability not in ["NONE","TRACE"]:copied_abilities[p["individual_id"]]=ability
	if _item_ability(p)=="INTIMIDATE":
		for i in foes:
			var other:Dictionary=pet_at(i)
			if not substitutes.has(other["individual_id"]) and not _stat_immune(other,"atk"):slot_stages[i]["atk"]=maxi(-6,int(slot_stages[i]["atk"])-1)
	telemetry.emit({"event":"ability_entry","ability":_item_ability(p),"id":p["individual_id"]});_sync_weather()
func _force_out(a:Dictionary,d:Dictionary,player:bool)->bool:
	var slot:int=slot_of(d)
	if _item_ability(d)=="SUCTION_CUPS" or rooted.has(d["individual_id"]):return false
	var candidates:Array=[]
	for j in range(party_for(slot).size()):
		if j not in [slots[slot%2],slots[slot%2+2]] and int(party_for(slot)[j]["hp"])>0:candidates.append(j)
	if candidates.is_empty() or not rules.roar_succeeds(int(a["level"]),int(d["level"]),randi()%65536):return false
	_replace(slot,candidates.pick_random());return true
func _begin_baton(player:bool)->void:
	var actor:int=context_actor;var candidates:Array=[]
	for j in range(party_for(actor).size()):
		if j not in [slots[actor%2],slots[actor%2+2]] and int(party_for(actor)[j]["hp"])>0:candidates.append(j)
	if candidates.is_empty():return
	# Same production party picker; round waits until the selection is completed.
	if player:
		baton_pending=true;replacement=actor;busy=false;mode="team";_update()
		while baton_pending:await get_tree().process_frame
	else:_replace(actor,candidates[0],true)
func _terminal()->bool:
	if ended:return true
	var ours:bool=store.state["team"].any(func(p):return int(p["hp"])>0)
	var theirs:bool=enemy_party.any(func(p):return int(p["hp"])>0)
	if not ours or not theirs:_finish(ours and not theirs,"draw" if not ours and not theirs else "victory" if ours else "defeat");return true
	return false
func _finish(victory:bool,result:String="")->void:
	if ended:return
	for id in mimicked.keys():_restore_mimic(id)
	for id in transformed.keys():_restore_transform(id)
	_restore_knocked_items();rules.type_overrides.clear()
	ended=true;busy=false;won=victory;outcome=result if result!="" else "victory" if victory else "defeat";waiting_next=false
	growth_events=[]
	for foe in enemy_party:
		if int(foe["hp"])<=0:growth_events.append_array(store.growth.award(store.state["team"],participants,foe,"victory",true,store.state.get("location",{}).get("map_id","")))
	trainer_events=growth_events.duplicate(true);evolution_queue=evolution.candidates(store.state["team"],trainer_events,outcome,store.state)
	for p in _field_pets():
		if _side(p)=="player" and int(p["hp"])<=0:store.friendship.adjust(p,"faint")
	for effect in [substitutes,follow_me,helping,airborne,underground,submerged,solar_charges,copied_abilities]:effect.clear()
	telemetry.emit({"event":"battle_ended","won":won,"outcome":outcome,"double":true});_next_growth_event()
func _round_end()->void:
	for p in _field_pets():
		var key:String=p["individual_id"]
		if seeds.has(key) and int(p["hp"])>0:
			var amount:int=mini(int(p["hp"]),maxi(1,int(rules.pet_stats(p)["hp"])/8));p["hp"]-=amount
			var receiver:Dictionary=pet_at(seeds[key])
			if not receiver.is_empty() and int(receiver["hp"])>0:receiver["hp"]=maxi(0,int(receiver["hp"])-amount) if _item_ability(p)=="LIQUID_OOZE" else mini(int(rules.pet_stats(receiver)["hp"]),int(receiver["hp"])+amount)
	await super._round_end()
	follow_me.clear();helping.clear()
func _visual_deltas(before:Dictionary,kind:String,recoil_id:String="")->void:
	var old_actor:int=context_actor;var old_target:int=context_target
	for i in range(4):
		var p:Dictionary=pet_at(i)
		if p.is_empty() or not before.has(p["individual_id"]):continue
		var previous:Dictionary=before[p["individual_id"]];var delta:int=int(p["hp"])-int(previous["hp"])
		if delta!=0:
			if i%2==0:portrait=sprites[i];hp_bar=bars[i]
			else:enemy_portrait=sprites[i];enemy_bar=bars[i]
			await presentation.play("heal" if delta>0 else "recoil" if p["individual_id"]==recoil_id else kind,i%2==0,{"text":str(delta),"before_hp":previous["hp"],"hp":p["hp"]})
	if old_actor>=0:bind_context(old_actor,old_target)
func _sync_battler_visuals()->void:
	for i in range(sprites.size()):
		var p:Dictionary=pet_at(i)
		if not p.is_empty():_set_battler_visual(sprites[i],p,i%2==0)

func _update()->void:
	if not is_instance_valid(menu):return
	_sync_battler_visuals()
	for i in range(4):
		var p:Dictionary=pet_at(i);sprites[i].visible=not p.is_empty() and int(p["hp"])>0 and not underground.has(p.get("individual_id",""))
		if p.is_empty():names[i].text="空位";levels[i].text="";bars[i].value=0;continue
		names[i].text="%d %s%s"%[i+1,store.species[p["species_id"]]["name"]," · "+str(p["status"]) if p.has("status") else ""]
		levels[i].text="Lv%d"%p["level"];bars[i].max_value=rules.pet_stats(p)["hp"];bars[i].value=p["hp"]
	log_label.text=log_text
	for c in menu.get_children():c.queue_free()
	if not learning.is_empty():
		var learner:Dictionary=store.state["team"][learning["index"]]
		for i in range(5):UI.button(menu,"%d %s"%[i+1,"遗忘 "+rules.moves[learner["moves"][i]]["name"] if i<4 else "放弃学习"],Rect2(470+i%2*240,459+i/2*52,235,48),_learn_choice.bind(i))
		return
	if ended:return
	if not busy and replacement<0:log_label.text="%s · %s指令\n%s"%["左位" if cursor==0 else "右位",store.species[pet_at(cursor)["species_id"]]["name"],log_text]
	var labels:Array=[];var values:Array=[]
	match mode:
		"root":labels=["战斗","换人","重选双方指令"];values=[0,1,2]
		"moves":
			var p:Dictionary=pet_at(cursor)
			for id in (p["moves"] if _has_usable_move(p) else ["struggle"]):labels.append(rules.moves[id]["name"]+" PP "+str(p["pp"].get(id,1)));values.append(values.size())
		"target":
			log_label.text="选择目标（数字对应出战位）\n"+rules.moves[pending_move]["name"]+" · Esc取消"
			for i in legal_targets(cursor,pending_move):labels.append(("友方 " if i%2==0 else "对方 ")+store.species[pet_at(i)["species_id"]]["name"]);values.append(i)
		"team":
			for i in range(store.state["team"].size()):labels.append(store.species[store.state["team"][i]["species_id"]]["name"]+" HP "+str(store.state["team"][i]["hp"]));values.append(i)
	for i in range(labels.size()):
		var value:int=values[i];var button:Button=UI.button(menu,"%d %s"%[value+1,labels[i]],Rect2(470+i%2*240,459+floori(i/2.0)*54,235,50),_select.bind(value));button.add_theme_font_size_override("font_size",17);button.disabled=busy
		if mode=="team":button.disabled=busy or not _can_switch(replacement if replacement>=0 else cursor,value)
