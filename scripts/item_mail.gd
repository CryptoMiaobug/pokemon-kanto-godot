extends RefCounted
## Local correspondence: physical mail stays with its individual; no external transport exists.
func give(store:RefCounted,index:int,text:String)->String:
 if index<0 or index>=store.state["team"].size() or text.strip_edges()=="" or text.length()>120:return "请选择伙伴并填写1至120字的信。"
 var pet:Dictionary=store.state["team"][index]
 if pet.get("held_item","")!="":return "请先取下原有携带物。"
 if int(store.state.get("retro_mail",0))<=0:return "没有复古邮件。"
 var before:Dictionary=store.state.duplicate(true)
 pet["held_item"]="retro_mail";pet["mail_text"]=text;store.state["retro_mail"]-=1
 if not store.save_game():store.state=before;return store.error
 return ""
func take(store:RefCounted,index:int)->String:
 if index<0 or index>=store.state["team"].size():return "请选择伙伴。"
 var pet:Dictionary=store.state["team"][index]
 if pet.get("held_item","")!="retro_mail":return "没有携带邮件。"
 var failure:String=store.inventory.receive_error(store.state,"retro_mail")
 if failure!="":return failure
 var before:Dictionary=store.state.duplicate(true)
 store.inventory.add(store.state,"retro_mail",1);pet.erase("held_item");pet.erase("mail_text")
 if not store.save_game():store.state=before;return store.error
 return ""
