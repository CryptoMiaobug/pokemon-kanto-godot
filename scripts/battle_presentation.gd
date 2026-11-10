extends Control
## Presentation consumes settled values only. No battle mutation or random draws.
signal presented(value:Dictionary)
var battle:Control
var sequence:int=0
var history:Array=[]
var effect:Label
const COLORS={"hit":Color("fff0a0"),"substitute":Color("9adbc0"),"miss":Color("b8c4d8"),"immune":Color("b8c4d8"),"charge":Color("ffe680"),"release":Color("ffe680"),"recoil":Color("ff876e"),"status":Color("d6a0ff"),"heal":Color("80efb0")}
func setup(owner_battle:Control)->void:
 battle=owner_battle;mouse_filter=Control.MOUSE_FILTER_IGNORE;set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 effect=Label.new();effect.add_theme_font_size_override("font_size",28);effect.add_theme_color_override("font_shadow_color",Color.BLACK);effect.add_theme_constant_override("shadow_offset_x",2);effect.add_theme_constant_override("shadow_offset_y",2);effect.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;effect.size=Vector2(300,46);effect.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(effect);effect.hide()
func play(kind:String,player:bool,detail:Dictionary={})->void:
 if not is_instance_valid(battle):return
 battle._sync_battler_visuals()
 sequence+=1
 var event:Dictionary={"event":"battle_animation","phase":"begin","kind":kind,"player":player,"detail":detail.duplicate(true),"sequence":sequence}
 history.append(event.duplicate(true));presented.emit(event)
 var sprite:TextureRect=battle.portrait if player else battle.enemy_portrait
 var bar:ProgressBar=battle.hp_bar if player else battle.enemy_bar
 var pos:Vector2=sprite.position;var tint:Color=sprite.modulate
 effect.position=Vector2(76,245) if player else Vector2(570,105)
 effect.text=str(detail.get("text",kind));effect.modulate=COLORS.get(kind,Color.WHITE);effect.show()
 var tween:=create_tween();tween.set_parallel(true)
 # Even invisible Dig actors retain correct visibility; never reveal one here.
 if kind in ["hit","recoil","substitute"]:
  sprite.modulate=COLORS[kind];sprite.position=pos+Vector2(10 if player else -10,0)
  tween.tween_property(sprite,"position",pos,.20).set_trans(Tween.TRANS_SINE)
  tween.tween_property(sprite,"modulate",tint,.20)
 elif kind in ["charge","release","status","heal"]:
  sprite.modulate=COLORS[kind];tween.tween_property(sprite,"modulate",tint,.28)
 if detail.has("before_hp"):
  bar.value=detail["before_hp"];tween.tween_property(bar,"value",float(detail["hp"]),.22)
 tween.tween_property(effect,"position:y",effect.position.y-14,.28)
 tween.tween_property(effect,"modulate:a",0.0,.28)
 await tween.finished
 sprite.position=pos;sprite.modulate=tint;effect.hide()
 event=event.duplicate(true);event["phase"]="end";history.append(event);presented.emit(event)
