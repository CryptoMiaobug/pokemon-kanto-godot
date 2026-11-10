extends Node2D
## Presentation only. No geometry, encounters, persistence or authoritative player movement.
var actor: Node2D
var terrain: Dictionary
var ground_texture: Texture2D
var clock: float = 0.0
var last_grass := Vector2i(-999,-999)
var ripples: Array[Dictionary] = []
var environment: Dictionary = {}
var frames: Dictionary = {"flower":[],"water":[]}
var stopped_in_grass: bool = false

func setup(mid: String, data: Dictionary, player: Node2D, texture: Texture2D) -> void:
	actor = player;terrain = data;ground_texture = texture
	z_index = 2
	var manifest: String = "res://assets/field-fx/environment.json"
	if FileAccess.file_exists(manifest):
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(manifest))
		if parsed is Dictionary:environment = parsed.get(mid,{})
	for kind in frames:
		for i in range(3 if kind=="flower" else 8):
			var path: String = "res://assets/field-fx/%s-%d.png" % [kind,i]
			if ResourceLoader.exists(path):frames[kind].append(load(path))

func grass_cell(at: Vector2) -> Vector2i:
	var cell := Vector2i(floori(at.x/16),floori((at.y-1)/16))
	if cell.y<0 or cell.y>=int(terrain.get("height",0)) or cell.x<0 or cell.x>=int(terrain.get("width",0)):return Vector2i(-999,-999)
	if int(terrain.get("grass",[])[cell.y][cell.x])!=1:return Vector2i(-999,-999)
	return cell

func _process(delta: float) -> void:
	clock += delta
	for effect in ripples:effect["age"] += delta
	ripples = ripples.filter(func(effect: Dictionary) -> bool:return effect["age"]<0.35)
	if not is_instance_valid(actor):return
	var cell: Vector2i = grass_cell(actor.position) if not actor.ledge_jumping and not actor.surfing else Vector2i(-999,-999)
	var stopped: bool = actor.velocity.length()<0.01
	if cell.x!=-999 and (cell!=last_grass or stopped and not stopped_in_grass):
		ripples.append({"cell":cell,"age":0.0})
	last_grass = cell;stopped_in_grass = stopped
	queue_redraw()

func _draw() -> void:
	# Exact 8px tile replacements stay below actors by drawing in a ground-only child.
	if not is_instance_valid(actor) or ground_texture==null:return
	for effect in ripples:
		var cell: Vector2i = effect["cell"]
		var age: float = effect["age"]
		var p := Vector2(cell)*16
		var sway: float = sin(age/0.35*TAU)*1.5
		for side in [-1,1]:
			var origin := p+Vector2(8+side*(4+age*16),11-age*15)
			draw_line(origin,origin+Vector2(side*2+sway,-3),Color("61774b",1-age/0.35),1.0)
	if last_grass.x!=-999:
		# Copy only the source grass feet strip over the actor; never cover its head.
		var p := Vector2(last_grass)*16
		var strip := Rect2(p+Vector2(0,11),Vector2(16,5))
		draw_texture_rect_region(ground_texture,strip,strip)

func attach_environment(parent: Node2D) -> void:
	var layer := Node2D.new()
	layer.set_script(preload("res://scripts/field_environment.gd"))
	layer.environment = environment;layer.frames = frames
	parent.add_child(layer)
	parent.move_child(layer,1)
