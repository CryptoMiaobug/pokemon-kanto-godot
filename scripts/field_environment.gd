extends Node2D
var environment: Dictionary = {}
var frames: Dictionary = {}
var clock: float = 0.0
var phase: int = -1
func _process(delta: float) -> void:
	clock += delta
	var next: int = int(clock*3.0)
	if next!=phase:phase=next;queue_redraw()
func _draw() -> void:
	for kind in environment:
		var textures: Array = frames.get(kind,[])
		if textures.is_empty():continue
		var texture: Texture2D = textures[phase%textures.size() if phase>=0 else 0]
		for cell in environment[kind]:draw_texture(texture,Vector2(cell[0],cell[1]))
