extends RefCounted
## Cinnabar quiz, gate state and trainer victory flags.
var quiz: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/cinnabar-gym-quiz.json"))
var trainers: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/cinnabar-gym-trainers.json"))
func valid(state: Dictionary) -> bool:
	if state.has("cinnabar_quiz") and (not state["cinnabar_quiz"] is Array or state["cinnabar_quiz"].size()!=6):return false
	if state.has("cinnabar_quiz"):
		for value in state["cinnabar_quiz"]:
			if not value is bool:return false
	if state.has("trainers") and state["trainers"] is Dictionary:
		for id in state["trainers"]:
			if str(id).begins_with("cinnabar_") and not state["trainers"][id] is bool:return false
	if state.has("badges") and state["badges"] is Dictionary and state["badges"].has("volcano") and not state["badges"]["volcano"] is bool:return false
	return true
func gates(state: Dictionary) -> Array:
	var result: Array=[]
	for i in range(6):result.append(bool(state.get("cinnabar_quiz",[])[i]) if state.get("cinnabar_quiz",[]).size()==6 else false)
	if state.get("trainers",{}).get("cinnabar_blaine",false):return [true,true,true,true,true,true]
	return result
func geometry(layout: Dictionary,state: Dictionary) -> void:
	var opened:=gates(state)
	for gate in quiz["gates"]:
		var is_open:bool=opened[int(gate["id"])-1]
		var collision:Array=gate["openCollision"] if is_open else gate["closedCollision"]
		for i in range(gate["cells"].size()):
			var cell:Array=gate["cells"][i]
			var cell_index:int=int(cell[1])%2*2+int(cell[0])%2
			layout["solid"][int(cell[1])][int(cell[0])]=int(collision[cell_index])
func question(index:int) -> Dictionary:return quiz["gates"][index-1]
func mark_correct(state:Dictionary,index:int) -> void:
	var flags:Array=gates(state);flags[index-1]=true;state["cinnabar_quiz"]=flags
func trainer_gate(state:Dictionary,id:String) -> void:
	var quiz_index:int={"cinnabar_quinn":1,"cinnabar_avery":2,"cinnabar_ramon":3,"cinnabar_derek":4,"cinnabar_dusty":5,"cinnabar_zac":6}.get(id,0)
	if quiz_index==0:return
	var flags:Array=gates(state);flags[quiz_index-1]=true;state["cinnabar_quiz"]=flags
func definition(id:String)->Dictionary:
	for entry in trainers:
		if entry["id"]==id:return entry
	return {}
func all_trainers()->Array:return trainers
func badge_state(state:Dictionary)->bool:return state.get("badges",{}).get("volcano",false)

func answer(state:Dictionary,index:int,yes:bool)->Dictionary:
	var gate:Dictionary=question(index)
	var correct:bool=yes==bool(gate["answer"])
	return {"correct":correct,"trainer":{1:"cinnabar_quinn",2:"cinnabar_avery",3:"cinnabar_ramon",4:"cinnabar_derek",5:"cinnabar_dusty",6:"cinnabar_zac"}[index] if not correct else ""}
