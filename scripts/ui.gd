extends RefCounted
const Language = preload("res://scripts/language.gd")
## Small shared UI primitives; coordinates are in the 960 × 640 canvas.

static func setup_theme() -> Theme:
	var theme := Theme.new()
	theme.default_font = load("res://assets/cjk-subset.otf") as Font
	theme.default_font_size = 20
	return theme

static func label(parent: Node, text: String, rect: Rect2, size: int = 20, color: Color = Color("303840")) -> Label:
	var node := Label.new()
	node.text = text
	node.position = rect.position
	node.size = rect.size
	node.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	node.add_theme_font_size_override("font_size", size)
	if Language.locale=="en":
		node.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
		_fit(node,node.text,rect,size)
	node.add_theme_color_override("font_color", color)
	parent.add_child(node)
	return node

static func panel(parent: Node, rect: Rect2, color: Color = Color("203b40")) -> Panel:
	var node := Panel.new()
	node.position = rect.position
	node.size = rect.size
	node.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var style := StyleBoxTexture.new()
	style.texture = load("res://assets/pokemon/window.png")
	style.texture_margin_left = 8
	style.texture_margin_right = 8
	style.texture_margin_top = 8
	style.texture_margin_bottom = 8
	node.add_theme_stylebox_override("panel", style)
	parent.add_child(node)
	return node

static func button(parent: Node, text: String, rect: Rect2, action: Callable) -> Button:
	var node := Button.new()
	node.text = text
	node.position = rect.position
	node.size = rect.size
	node.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	node.add_theme_color_override("font_color",Color("303840"))
	for state in ["normal","hover","pressed","disabled"]:
		var style := StyleBoxTexture.new()
		style.texture = load("res://assets/pokemon/window.png")
		style.texture_margin_left = 8
		style.texture_margin_right = 8
		style.texture_margin_top = 8
		style.texture_margin_bottom = 8
		node.add_theme_stylebox_override(state,style)
	if Language.locale=="en":
		node.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
		_fit(node,node.text,rect,20)
	node.focus_mode = Control.FOCUS_NONE
	node.pressed.connect(action)
	parent.add_child(node)
	return node

static func _fit(node:Control,text:String,rect:Rect2,size:int)->void:
	var font:Font=load("res://assets/cjk-subset.otf")
	var available:float=maxf(20,rect.size.x-14)
	var longest:float=0
	for line in text.split("\n"):longest=maxf(longest,font.get_string_size(line,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x)
	var rows:int=maxi(1,floori((rect.size.y-12)/(size+4.0)))
	var fitted:int=clampi(floori(size*available*rows/maxf(available,longest)),12,size)
	node.add_theme_font_size_override("font_size",fitted)
