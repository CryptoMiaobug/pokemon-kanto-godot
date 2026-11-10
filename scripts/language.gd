extends RefCounted
## Small display-only adapter. Preferences are separate from progress.json.
const PATH = "user://settings.cfg"
const EN = {
 "team.title":"Party · Poké Balls %d · Potions %d",
 "team.member":"%d %s Lv%d %s",
 "team.lead":"Lead", "team.choose":"%d Lead",
 "team.back":"P / Esc Back to map",
 "team.language":"English / 中文 · F8",
 "npc.guard":"Officer: TEAM ROCKET stole here.",
 "battle.damage":"%s used %s!\nDealt %d damage.%s",
 "battle.super":" Super effective!", "battle.weak":" Not very effective."
}
static var catalog:Dictionary={}
static var names:Dictionary={}
static var errors:Dictionary={}
static var locale:String="zh"
static var loaded:bool=false
static func ensure()->void:
 if loaded:return
 loaded=true
 catalog=JSON.parse_string(FileAccess.get_file_as_string("res://data/localization/ui.en.json"))
 errors=JSON.parse_string(FileAccess.get_file_as_string("res://data/localization/errors.en.json"))
 names=JSON.parse_string(FileAccess.get_file_as_string("res://data/localization/names.en.json"))
 var config:=ConfigFile.new()
 if config.load(PATH)==OK:locale="en" if config.get_value("display","language","zh")=="en" else "zh"
static func text(key:String,chinese:String,args:Array=[])->String:
 ensure()
 var value:String=str(EN.get(key,catalog.get(key,chinese))) if locale=="en" else chinese
 return value % args if not args.is_empty() else value
static func toggle()->Error:
 ensure()
 var config:=ConfigFile.new()
 var error:Error=config.load(PATH)
 if error!=OK and error!=ERR_FILE_NOT_FOUND:return error
 var next:String="en" if locale=="zh" else "zh"
 config.set_value("display","language",next)
 error=config.save(PATH)
 if error==OK:locale=next
 return error
static func display_name(pet:Dictionary,fallback:String)->String:
 # Never translate user-entered data, or write derived names back into the individual.
 return str(pet["nickname"]) if pet.has("nickname") else name(fallback)

static func name(chinese:String)->String:
 ensure()
 return str(names.get(chinese,chinese)) if locale=="en" else chinese

static func message(value:String)->String:
 ensure()
 if locale!="en":return value
 # Errors may be joined with a rollback suffix. Only known full phrases are replaced.
 value=story(value)
 for chinese in errors:value=value.replace(chinese,str(errors[chinese]))
 return value

# Story templates are translated before interpolation. No state or user text is changed.
static var story_catalog:Dictionary={}
static var story_loaded:bool=false
static func story(value:String,args:Array=[])->String:
 ensure()
 if not story_loaded:
  story_loaded=true
  for path in ["res://data/localization/story-dialogue.en.json","res://data/localization/story-runtime.en.json"]:
   if FileAccess.file_exists(path):
    var parsed:Variant=JSON.parse_string(FileAccess.get_file_as_string(path))
    if parsed is Dictionary:story_catalog.merge(parsed,true)
 var translated:String=str(story_catalog.get(value,names.get(value,errors.get(value,value)))) if locale=="en" else value
 return translated % args if not args.is_empty() else translated

static func trainer_name(id:String,chinese:String)->String:
 ensure()
 if locale!="en":return chinese
 var registry:Variant=JSON.parse_string(FileAccess.get_file_as_string("res://data/localization/trainers.en.json"))
 return str(registry.get(id,name(chinese)))
