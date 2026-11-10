extends Control
signal closed
signal telemetry(value: Dictionary)
const UI = preload("res://scripts/ui.gd")
var store
var box: int = 0
var slot: int = 0
var party: int = 0
var action: String = ""
var message: String = "选择盒内位置，再取出；或选择队伍成员寄存、交换。"
var ready_at: int = 0
var content: Control
func _ready() -> void:
	theme = UI.setup_theme()
	box = int(store.state["storage"]["current_box"])
	_render()
func _image(path: String, rect: Rect2) -> void:
	var image := TextureRect.new()
	image.texture = load(path)
	image.position = rect.position
	image.size = rect.size
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(image)
func _render() -> void:
	if is_instance_valid(content):
		remove_child(content)
		content.queue_free()
	content = Control.new()
	add_child(content)
	UI.panel(content,Rect2(20,42,920,560))
	UI.label(content,"宝可梦电脑 · 盒子%d / 14 · 每盒30只" % (box+1),Rect2(42,53,680,36),25)
	UI.button(content,"Q 上盒",Rect2(697,53,105,40),_page.bind(-1))
	UI.button(content,"E 下盒",Rect2(812,53,105,40),_page.bind(1))
	_image("res://assets/storage/forest.png",Rect2(42,102,600,360))
	for i in range(30):
		var pet: Variant = store.state["storage"]["boxes"][box][i]
		var x: int = 44+(i%6)*99
		var y: int = 104+(i/6)*71
		UI.button(content,("▶ " if i==slot else "")+str(i+1)+( " · 空" if pet==null else ""),Rect2(x,y,96,68),_slot.bind(i))
		if pet!=null:_image("res://assets/pokemon/%s-icon.png" % pet["species_id"],Rect2(x+25,y+25,48,40))
	UI.label(content,"队伍 · 点击或数字1–6选择",Rect2(660,101,265,30),17)
	for i in range(store.state["team"].size()):
		var pet: Dictionary = store.state["team"][i]
		UI.button(content,("▶ " if party==i else "")+"%d %s Lv%d" % [i+1,store.species[pet["species_id"]]["name"],pet["level"]],Rect2(660,138+i*45,258,42),_party.bind(i))
	var selected: Variant = store.state["storage"]["boxes"][box][slot]
	var description: String = "位置%d · 空" % (slot+1)
	if selected!=null:description = "位置%d · %s Lv%d · HP %d" % [slot+1,store.species[selected["species_id"]]["name"],selected["level"],selected["hp"]]
	UI.label(content,description,Rect2(43,465,860,28),20)
	UI.label(content,message,Rect2(43,495,870,44),18)
	if action=="":
		UI.button(content,"D 寄存",Rect2(43,545,196,42),_prepare.bind("deposit"))
		UI.button(content,"W 取出",Rect2(251,545,196,42),_prepare.bind("withdraw"))
		UI.button(content,"X 交换",Rect2(459,545,196,42),_prepare.bind("exchange"))
		UI.button(content,"Esc 退出",Rect2(667,545,250,42),_close)
	else:
		UI.button(content,"Enter 确认",Rect2(43,545,420,42),_confirm)
		UI.button(content,"Esc 取消",Rect2(480,545,437,42),_cancel)
	ready_at = Time.get_ticks_msec()+150
	telemetry.emit({"event":"pc_view","box":box,"slot":slot,"party":party,"action":action,"message":message})
func _input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo or Time.get_ticks_msec()<ready_at:return
	get_viewport().set_input_as_handled()
	var k: int = event.physical_keycode
	if action!="":
		if k in [KEY_ENTER,KEY_SPACE]:_confirm()
		elif k in [KEY_ESCAPE,KEY_B]:_cancel()
		return
	if k==KEY_ESCAPE:_close()
	elif k==KEY_Q:_page(-1)
	elif k==KEY_E:_page(1)
	elif k in [KEY_1,KEY_2,KEY_3,KEY_4,KEY_5,KEY_6]:_party(k-KEY_1)
	elif k in [KEY_LEFT,KEY_RIGHT,KEY_UP,KEY_DOWN]:_slot(posmod(slot+{KEY_LEFT:-1,KEY_RIGHT:1,KEY_UP:-6,KEY_DOWN:6}[k],30))
	elif k==KEY_D:_prepare("deposit")
	elif k==KEY_W:_prepare("withdraw")
	elif k==KEY_X:_prepare("exchange")
func _slot(i: int) -> void:
	if action!="" or Time.get_ticks_msec()<ready_at:return
	slot = i
	_render()
func _party(i: int) -> void:
	if action!="" or Time.get_ticks_msec()<ready_at or i>=store.state["team"].size():return
	party = i
	_render()
func _page(delta: int) -> void:
	if action!="" or Time.get_ticks_msec()<ready_at:return
	var next: int = posmod(box+delta,14)
	var failure: String = store.pc_action("select",next)
	if failure=="":box = next
	message = failure if failure!="" else "已切换盒子。满队捕获从当前盒开始寻找空位。"
	_render()
func _prepare(kind: String) -> void:
	if action!="" or Time.get_ticks_msec()<ready_at:return
	action = kind
	message = {"deposit":"确定将选中队伍成员寄存到此空位？","withdraw":"确定将此位置的伙伴取出到队伍？","exchange":"确定交换选中队伍成员与此位置伙伴？"}[kind]
	_render()
func _confirm() -> void:
	if action=="" or Time.get_ticks_msec()<ready_at:return
	var kind: String = action
	action = "busy"
	var failure: String = store.pc_action(kind,box,slot,party)
	message = failure if failure!="" else "操作完成，队伍与盒子已共同保存。"
	party = mini(party,store.state["team"].size()-1)
	action = ""
	telemetry.emit({"event":"pc_rejected" if failure!="" else "pc_committed","kind":kind,"state":store.state.duplicate(true),"message":message})
	_render()
func _cancel() -> void:
	if Time.get_ticks_msec()<ready_at:return
	action = ""
	message = "已取消，未移动伙伴。"
	_render()
func _close() -> void:
	if Time.get_ticks_msec()>=ready_at:closed.emit()
