extends CharacterBody2D
## Origin is the feet. Collision is only 14×8 px around the visible sole.
const SPEED: float = 84.0
var active: bool = true
var cycling: bool = false
var cycling_road: bool = false
var surfing: bool = false
var surf_clock: float = 0.0
var sevii_clock:float=0.0
var sevii_ice_step:=Vector2i.ZERO
var facing := Vector2.DOWN
var walking_time: float = 0.0
var sprite: Sprite2D
var layout: Dictionary = {}
# The body stays on its safe takeoff footpoint until landing; only the sprite flies.
const LEDGE_DURATION: float = 0.38
const LEDGE_HEIGHT: float = 12.0
var ledge_jumping: bool = false
var ledge_elapsed: float = 0.0
var ledge_origin := Vector2.ZERO
var ledge_target := Vector2.ZERO
var ledge_shadow: Sprite2D
var ledge_dust: Sprite2D
var dust_elapsed: float = -1.0
var dust_origin := Vector2.ZERO

func safe_position() -> Vector2:
	return ledge_origin if ledge_jumping else position

func _begin_ledge(displacement: Vector2) -> void:
	ledge_jumping = true
	ledge_elapsed = 0.0
	ledge_origin = position
	ledge_target = position + displacement
	velocity = Vector2.ZERO
	ledge_shadow.visible = true
	ledge_dust.visible = false
	dust_elapsed = -1.0

func _tick_ledge(delta: float) -> void:
	ledge_elapsed += delta
	var phase: float = minf(ledge_elapsed / LEDGE_DURATION, 1.0)
	var travel: Vector2 = (ledge_target - ledge_origin) * phase
	var base: Vector2 = Vector2(0, -8 if cycling else -16)
	sprite.position = base + travel + Vector2(0, -4.0 * LEDGE_HEIGHT * phase * (1.0 - phase))
	ledge_shadow.position = travel
	velocity = Vector2.ZERO
	if phase >= 1.0:
		position = ledge_target
		sprite.position = base
		ledge_shadow.visible = false
		ledge_shadow.position = Vector2.ZERO
		ledge_jumping = false
		dust_elapsed = 0.0
		dust_origin = position
		ledge_dust.position = Vector2.ZERO
		ledge_dust.frame = 0
		ledge_dust.visible = true


func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	sprite = Sprite2D.new()
	sprite.texture = load("res://assets/surf/ride-0.png" if surfing else "res://assets/bicycle/ride-0.png" if cycling else "res://assets/pokemon/red-0.png")
	sprite.position = Vector2(0, -8 if surfing or cycling else -16)
	sprite.scale = Vector2(1, 1)
	add_child(sprite)
	ledge_shadow = Sprite2D.new()
	ledge_shadow.texture = preload("res://assets/ledge/player_shadow.png")
	ledge_shadow.offset = Vector2(0, -6)
	ledge_shadow.visible = false
	ledge_shadow.z_index = 0
	add_child(ledge_shadow)
	move_child(ledge_shadow, 0)
	ledge_dust = Sprite2D.new()
	ledge_dust.texture = preload("res://assets/ledge/jump_landing_dust.png")
	ledge_dust.hframes = 3
	ledge_dust.offset = Vector2(0, -6)
	ledge_dust.visible = false
	ledge_dust.z_index = 1
	add_child(ledge_dust)
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(14, 8)
	collision.shape = shape
	collision.position = Vector2(0, -2)
	add_child(collision)

func _physics_process(delta: float) -> void:
	if dust_elapsed >= 0.0:
		ledge_dust.position = dust_origin - position
		dust_elapsed += delta
		if dust_elapsed >= 0.3:
			ledge_dust.visible = false
			dust_elapsed = -1.0
		else:
			ledge_dust.frame = mini(int(dust_elapsed / 0.1), 2)
	if ledge_jumping:
		_tick_ledge(delta)
		return
	var previous_position: Vector2 = position
	var direction := Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down") if active else Vector2.ZERO
	if cycling_road and active and direction == Vector2.ZERO and not Input.is_key_pressed(KEY_B):
		direction = Vector2.DOWN
	if layout.has("sourceMap"):
		_sevii_walk(direction,delta)
		return
	if surfing:
		surf_clock -= delta
		velocity = Vector2.ZERO
		if direction!=Vector2.ZERO and surf_clock<=0:
			var step := Vector2i(signi(int(direction.x)),0) if absf(direction.x)>absf(direction.y) else Vector2i(0,signi(int(direction.y)))
			facing = Vector2(step);var cell := Vector2i(floori(position.x/16),floori((position.y-1)/16));var target := cell+step
			if target.x>=0 and target.y>=0 and target.x<int(layout["width"]) and target.y<int(layout["height"]) and layout["solid"][target.y][target.x]==0:
				var blocked:bool=false
				for pair in layout.get("pairCollisionsLand",[]):
					var a:int=layout["footTiles"][cell.y][cell.x];var b:int=layout["footTiles"][target.y][target.x]
					if a==int(pair[0]) and b==int(pair[1]) or a==int(pair[1]) and b==int(pair[0]):blocked=true
				if not blocked:position=Vector2(target.x*16+8,target.y*16+9);velocity=Vector2(step)*SPEED
			if layout.get("o05SeaExit","")=="left" and cell.x==0 and cell.y>=36 and step==Vector2i.LEFT or layout.get("o05SeaExit","")=="right" and cell.x==int(layout["width"])-1 and step==Vector2i.RIGHT:
				velocity=Vector2(step)*SPEED
			if layout.get("o05SeaExit","")=="right" and cell.x==0 and cell.y in [2,3,4,5,6,7,8] and step==Vector2i.LEFT:
				velocity=Vector2(step)*SPEED
			surf_clock=16.0/SPEED;walking_time+=16.0/SPEED
			var base:int=0 if step.y>0 else 1 if step.y<0 else 2
			var frame:int=base if int(walking_time*8)%2==0 else base+3
			sprite.texture=load("res://assets/surf/ride-%d.png"%frame);sprite.flip_h=step.x>0
		return
	velocity = direction * SPEED * (2.0 if cycling else 1.0)
	move_and_slide()
	if active and direction.y>0 and get_slide_collision_count()>0 and not layout.is_empty():
		var cx: int = floori(position.x/16)
		var cy: int = floori((position.y-5)/16)
		if cy>=0 and cy+2<int(layout["height"]) and cx>=0 and cx<int(layout["width"]):
			for ledge in layout.get("ledges",[]):
				if ledge["facing"]=="down" and int(layout["footTiles"][cy][cx])==int(ledge["standingTile"]) and int(layout["footTiles"][cy+1][cx])==int(ledge["ledgeTile"]) and int(layout["solid"][cy+2][cx])==0:
					_begin_ledge(Vector2(0, 32))
					return
	if active and direction.x!=0 and direction.y==0 and get_slide_collision_count()>0 and layout.get("horizontalLedges",false):
		var ledge_step := Vector2i(1 if direction.x>0 else -1,0)
		var cell := Vector2i(floori(position.x/16),floori((position.y-5)/16))
		var landing: Vector2i = cell+ledge_step*2
		if landing.x>=0 and landing.x<int(layout["width"]) and cell.y>=0 and cell.y<int(layout["height"]):
			for ledge in layout.get("ledges",[]):
				if ledge["facing"]==("right" if ledge_step.x>0 else "left") and int(layout["footTiles"][cell.y][cell.x])==int(ledge["standingTile"]) and int(layout["footTiles"][cell.y][cell.x+ledge_step.x])==int(ledge["ledgeTile"]) and int(layout["solid"][landing.y][landing.x])==0:
					_begin_ledge(Vector2(ledge_step.x*32, 0))
					return
	if direction != Vector2.ZERO:
		facing = direction.normalized()
	var distance: float = position.distance_to(previous_position)
	var base: int = 0 if facing.y > 0 else 1 if facing.y < 0 else 2
	var frame: int = base
	if distance > 0.01:
		walking_time += distance / SPEED
		var phase: int = int(walking_time * 8.0) % 4
		frame = base + ([3, 0, 6, 0][phase] if not cycling else [3, 0, 3, 0][phase])
	else:
		walking_time = 0.0
	var path: String = ("res://assets/bicycle/ride-%d.png" if cycling else "res://assets/pokemon/red-%d.png") % frame
	if ResourceLoader.exists(path):sprite.texture = load(path)
	sprite.flip_h = facing.x > 0

# FireRed source cells use grid steps; retain native jump animation and field ownership.
func _sevii_walk(direction:Vector2,delta:float)->void:
	sevii_clock=maxf(0,sevii_clock-delta);velocity=Vector2.ZERO
	if not active:return
	var cell:=Vector2i(floori(position.x/16),floori((position.y-1)/16))
	if cell.x<0 or cell.y<0 or cell.x>=int(layout["width"]) or cell.y>=int(layout["height"]):return
	var on_ice:bool=int(layout["behaviors"][cell.y][cell.x])==35
	var step:=Vector2i(signi(int(direction.x)),0) if absf(direction.x)>absf(direction.y) else Vector2i(0,signi(int(direction.y)))
	if on_ice and sevii_ice_step!=Vector2i.ZERO:step=sevii_ice_step
	elif not on_ice:sevii_ice_step=Vector2i.ZERO
	if step==Vector2i.ZERO or sevii_clock>0:return
	facing=Vector2(step);var target:Vector2i=cell+step
	sevii_clock=16.0/SPEED;surf_clock=sevii_clock
	if target.x<0 or target.y<0 or target.x>=int(layout["width"]) or target.y>=int(layout["height"]):velocity=Vector2(step)*SPEED;return
	var behavior:int=int(layout["behaviors"][target.y][target.x])
	var jump:int={Vector2i.RIGHT:56,Vector2i.LEFT:57,Vector2i.UP:58,Vector2i.DOWN:59}.get(step,-1)
	if not surfing and behavior==jump:
		var landing:Vector2i=target+step
		if landing.x>=0 and landing.y>=0 and landing.x<int(layout["width"]) and landing.y<int(layout["height"]) and int(layout["solid"][landing.y][landing.x])==0:
			position=Vector2(cell.x*16+8,cell.y*16+9);_begin_ledge(Vector2(step)*32);return
	if int(layout["solid"][target.y][target.x])!=0 or preload("res://scripts/sevii.gd").edge_blocked(layout,cell,target):
		sevii_ice_step=Vector2i.ZERO;return
	position=Vector2(target.x*16+8,target.y*16+9);velocity=Vector2(step)*SPEED;sevii_ice_step=step
	walking_time+=16.0/SPEED
	var base:int=0 if step.y>0 else 1 if step.y<0 else 2
	var frame:int=base if int(walking_time*8)%2==0 else base+3
	sprite.texture=load(("res://assets/surf/ride-%d.png" if surfing else "res://assets/pokemon/red-%d.png")%frame);sprite.flip_h=step.x>0
