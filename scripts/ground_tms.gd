extends RefCounted
var data:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://data/ground-tms.json"))["items"]
func display_name(item:String)->String:
 if not data.has(item):return item
 var row:Dictionary=data[item]
 var old:String=row.get("legacy_name","")
 if row.get("fire_red_tm")!=null:
  return str(row["name"])+("（旧%s）"%old if not item.begins_with("fr_tm") and old!="" and old!=row["name"] else "")
 return old+"（旧版保留；非火红TM）"
func summary(store:RefCounted,item:String)->String:
 var row:Dictionary=data[item]
 if not row["implemented"]:return str(row["disabled_reason"])+"；道具保留。"
 var move:Dictionary=store.growth.moves[row["move"]]
 return "%s · 威力%s · 命中%s · PP%d\n%s%s" % [move["type"],"—" if int(move["power"])==0 else str(move["power"]),str(move["accuracy"]),int(move["pp"]),row["description"],("\n"+str(row["limitation"])) if row.get("limitation","")!="" else ""]
func quantity(s:Dictionary,item:String)->int:
 if item.begins_with("fr_tm"):return int(s.get("tm_inventory",{}).get(item,0))
 if item=="tm_dig":return int(s.get("stolen_tm",{}).get("items",{}).get("tm28",0))
 return int(s.get("ground_inventory",{}).get(item,0))
func learn_error(store:RefCounted,item:String,index:int)->String:
 if not data.has(item):return "未知招式学习器。"
 if not data[item]["implemented"]:return str(data[item]["disabled_reason"])+"；招式学习器保留。"
 if quantity(store.state,item)<=0:return "没有这个招式学习器。"
 if index<0 or index>=store.state["team"].size():return "请选择队伍里的宝可梦。"
 var pet:Dictionary=store.state["team"][index]
 if pet["species_id"] not in data[item]["species"]:return "这只宝可梦不能学习。"
 if pet["moves"].any(func(move):return str(move).replace("_","")==str(data[item]["move"]).replace("_","")):return "已经学会这个招式。"
 return ""
func teach(store:RefCounted,item:String,index:int,slot:int,location:Dictionary)->String:
 if not store.validate(store.state):return "存档数据无效，未教学。"
 var error:String=learn_error(store,item,index)
 if error!="":return error
 var pet:Dictionary=store.state["team"][index]
 if slot<0 or slot>pet["moves"].size() or slot>=4:return "已取消学习。"
 if slot<pet["moves"].size() and pet["moves"][slot] in store.growth.HM_MOVES:return "秘传招式不能在这里遗忘。"
 var before:Dictionary=store.state.duplicate(true)
 if not store.growth.resolve_learning(pet,data[item]["move"],slot):store.state=before;return "无法学习。"
 store.friendship.adjust(pet,"tmhm",store.state.get("location",{}).get("map_id",""))
 if item.begins_with("fr_tm"):store.state["tm_inventory"][item]-=1
 elif item=="tm_dig":store.state["stolen_tm"]["items"]["tm28"]-=1
 else:store.state["ground_inventory"][item]-=1
 store.state["location"]=location.duplicate(true)
 if not store.save_game():store.state=before;return store.error+" 学习已撤销。"
 return ""

func sell_nugget(store:RefCounted,map:String,bridge:bool=false)->String:
 if map not in ["viridian-mart","vermilion-mart","lavender-mart","fuchsia-mart","saffron-mart","cinnabar-mart","celadon-mart-2f"]:return "请到友好商店出售。"
 var amount:int=int(store.state.get("nugget_bridge",{}).get("items",{}).get("nugget",0)) if bridge else int(store.state.get("ground_inventory",{}).get("nuggets",0))
 if amount<=0:return "没有金珠。"
 if int(store.state["money"])+5000>store.MAX_MONEY:return "金额达到上限，未出售。"
 var before:Dictionary=store.state.duplicate(true)
 if bridge:store.state["nugget_bridge"]["items"]["nugget"]-=1
 else:store.state["ground_inventory"]["nuggets"]-=1
 store.state["money"]+=5000
 if not store.save_game():store.state=before;return store.error+" 出售已撤销。"
 return ""
