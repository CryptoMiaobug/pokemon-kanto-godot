extends RefCounted
## FR field_specials.c ordered Random16 modulo branches, mapped to Red bin coordinates.
var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/vermilion-puzzle.json"))
var first: int = 0
var second: int = 0
var found: bool = false
func valid(state: Dictionary) -> bool:
	return not state.has("vermilion_gym") or (state["vermilion_gym"] is Dictionary and state["vermilion_gym"].size()==1 and state["vermilion_gym"].get("unlocked") is bool and state["vermilion_gym"]["unlocked"]==true)
func opened(state: Dictionary) -> bool:return state.get("vermilion_gym",{}).get("unlocked",false)
func pair_from_rolls(a: int,b: int) -> Array:
	var one: int = a%15+1
	var options: Array = data["neighborDeltas"][one-1]
	var two: int = one+int(options[b%options.size()])
	if two>15:two = one-1 if one%5==0 else one+1
	return [one,two]
func reset() -> void:
	var pair: Array = pair_from_rolls(randi()%65536,randi()%65536)
	first = pair[0];second = pair[1];found = false
func enter(state: Dictionary) -> void:
	found = false
	if not opened(state):reset()
func investigate(store: RefCounted,id: int) -> Dictionary:
	if id<1 or id>15:return {"event":"invalid","text":"这里不是可调查的垃圾桶。"}
	if opened(store.state):return {"event":"open_repeat","text":"只有垃圾。两道锁已经打开。"}
	if not found:
		if id!=first:return {"event":"trash","text":"这里面只有垃圾。"}
		found = true
		return {"event":"first","text":"垃圾下面有开关！第一道锁解除了。\n第二个开关一定在相邻垃圾桶里。"}
	if id!=second:
		reset()
		return {"event":"reset","text":"只有垃圾！两道锁都重置了，开关位置也变了。"}
	var before: Dictionary = store.state.duplicate(true)
	store.state["vermilion_gym"] = {"unlocked":true}
	if not store.save_game():
		store.state = before
		return {"event":"save_failed","text":store.error+" 第二道锁未保存，请重试。"}
	found = false
	return {"event":"unlocked","text":"第二道锁解除了！电门打开，已经保存。"}
