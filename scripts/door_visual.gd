extends Node2D
## Source door pixels split into sliding halves; all dimensions remain local Red 16px.
var texture: Texture2D
var source := Rect2()
var openness: float = 0.0:
	set(value):openness=value;queue_redraw()
func _draw() -> void:
	if texture==null:return
	draw_rect(Rect2(0,0,16,16),Color("263536"))
	var width: float = 8*(1-openness)
	if width<=0:return
	draw_texture_rect_region(texture,Rect2(0,0,width,16),Rect2(source.position,Vector2(width,16)))
	draw_texture_rect_region(texture,Rect2(16-width,0,width,16),Rect2(source.position+Vector2(16-width,0),Vector2(width,16)))
