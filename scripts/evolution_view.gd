extends Control
const Language = preload("res://scripts/language.gd")
## Original FireRed art and shrink/expand state, adapted to the 960x640 Godot canvas.
signal resolved(cancelled: bool)
signal completed(cancelled: bool)
const UI = preload("res://scripts/ui.gd")
var before: String
var after: String
var species: Dictionary
var layer: TextureRect
var old_sprite: TextureRect
var new_sprite: TextureRect
var message: Label
var sparkles: Array = []
var elapsed: float = 0.0
var ticks: float = 0.0
var direction: bool = false
var speed: int = 8
var old_scale: int = 256
var new_scale: int = 16
var phase: String = "intro"
var result_ready: int = 0
var cancelled: bool = false
var silhouette: ShaderMaterial
func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var bg := TextureRect.new()
	bg.texture = load("res://assets/pokemon/evolution-bg.png")
	bg.position = Vector2(-32,-96)
	bg.size = Vector2(1024,1024)
	add_child(bg)
	layer = TextureRect.new()
	layer.texture = load("res://assets/pokemon/evolution-bg2.png")
	layer.position = Vector2(-32,-96)
	layer.size = Vector2(1024,1024)
	layer.modulate.a = 0.5
	add_child(layer)
	var shader := Shader.new()
	shader.code = "shader_type canvas_item; void fragment(){vec4 c=texture(TEXTURE,UV);COLOR=vec4(vec3(1.0),c.a);}"
	silhouette = ShaderMaterial.new()
	silhouette.shader = shader
	old_sprite = _sprite(before)
	new_sprite = _sprite(after)
	new_sprite.hide()
	for i in range(12):
		var sparkle := TextureRect.new()
		sparkle.texture = load("res://assets/pokemon/evolution-sparkle.png")
		sparkle.size = Vector2(32,32)
		sparkle.hide()
		add_child(sparkle)
		sparkles.append(sparkle)
	UI.panel(self,Rect2(0,448,960,192))
	message = UI.label(self,Language.text("ui.63ddca016436","咦？%s的样子……\n进化中按 B 取消。") % Language.name(species[before]["name"]),Rect2(32,470,890,120),26)
func _sprite(id: String) -> TextureRect:
	var sprite := TextureRect.new()
	sprite.texture = load(species[id]["sprite"])
	sprite.position = Vector2(352,120)
	sprite.size = Vector2(256,256)
	sprite.pivot_offset = Vector2(128,128)
	add_child(sprite)
	return sprite
func _process(delta: float) -> void:
	elapsed += delta
	layer.position.x = -32+roundf(sin(elapsed)*16)
	if phase=="intro" and elapsed>=1.0:
		phase = "cycling"
		old_sprite.material = silhouette
		new_sprite.material = silhouette
		new_sprite.show()
		direction = true
		speed = 10
	if phase!="cycling":return
	for i in range(sparkles.size()):
		var angle: float = elapsed*2+TAU*i/sparkles.size()
		sparkles[i].show()
		sparkles[i].position = Vector2(464,232)+Vector2(cos(angle)*160,sin(angle)*128)
	ticks += delta*60
	while ticks>=1 and phase=="cycling":
		ticks -= 1
		if direction:
			new_scale = mini(256,new_scale+speed)
			old_scale = maxi(16,old_scale-speed)
		else:
			old_scale = mini(256,old_scale+speed)
			new_scale = maxi(16,new_scale-speed)
		old_sprite.scale = Vector2.ONE*old_scale/256.0
		new_sprite.scale = Vector2.ONE*new_scale/256.0
		if (direction and new_scale==256 and old_scale==16) or (not direction and old_scale==256 and new_scale==16):
			if speed==128:_complete(false)
			else:
				speed += 2
				direction = not direction
func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:return
	if event.physical_keycode==KEY_B and phase in ["intro","cycling"]:
		_complete(true)
		get_viewport().set_input_as_handled()
	elif event.physical_keycode in [KEY_ENTER,KEY_SPACE,KEY_E] and phase=="result" and Time.get_ticks_msec()>=result_ready:
		phase = "done"
		get_viewport().set_input_as_handled()
		resolved.emit(cancelled)
func _complete(stopped: bool) -> void:
	if phase=="result" or phase=="done":return
	cancelled = stopped
	phase = "result"
	result_ready = Time.get_ticks_msec()+350
	old_sprite.material = null
	new_sprite.material = null
	old_sprite.scale = Vector2.ONE
	new_sprite.scale = Vector2.ONE
	old_sprite.visible = stopped
	new_sprite.visible = not stopped
	for sparkle in sparkles:sparkle.hide()
	message.text = Language.text("ui.104d1cbaf92a","%s停止了进化。\nEnter 继续") % Language.name(species[before]["name"]) if stopped else Language.text("ui.a4455f9c8284","恭喜！%s进化成了%s！\nEnter 继续") % [Language.name(species[before]["name"]),Language.name(species[after]["name"])]

	completed.emit(stopped)
