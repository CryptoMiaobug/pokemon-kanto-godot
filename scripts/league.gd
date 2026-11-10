extends RefCounted
## First league challenge; per-run flags, source whiteout, no automatic healing between rooms.
const ROOMS := ["league-lorelei", "league-bruno", "league-agatha", "league-lance", "league-champion"]
const IDS := ["league_lorelei", "league_bruno", "league_agatha", "league_lance", "league_champion"]

func active(s: Dictionary) -> bool:
    return s.get("league", {}).get("active", false)

func stage(s: Dictionary) -> int:
    return int(s.get("league", {}).get("stage", 0))

func valid(s: Dictionary) -> bool:
    if not s.has("league"):
        return true
    var v: Variant = s["league"]
    return v is Dictionary and v.get("active") is bool and (v.get("stage") is int or v.get("stage") is float) and float(v["stage"]) == int(v["stage"]) and int(v["stage"]) >= 0 and int(v["stage"]) <= 5 and (v["active"] or int(v["stage"]) == 0)

func can_challenge(s: Dictionary, id: String) -> bool:
    return id in IDS and active(s) and stage(s) == IDS.find(id) and not s.get("trainers", {}).get(id, false)

func transition(store: RefCounted, from: String, to: String, arrival: Dictionary) -> String:
    var before: Dictionary = store.state.duplicate(true)
    if from == "indigo-lobby" and to == ROOMS[0]:
        if active(store.state):
            return "联盟挑战已经开始，不能重新领取本轮奖励。"
        if store.state.get("hall_of_fame", {}).get("game_clear", false):
            return "已登记名人堂。联盟重赛不在本主线范围，不重复发放奖金。"
        for badge in ["boulder", "cascade", "thunder", "rainbow", "soul", "marsh", "volcano", "earth"]:
            if not store.state.get("badges", {}).get(badge, false):
                return "挑战联盟需要八枚徽章。"
        if not store.state["team"].any(func(p): return int(p["hp"]) > 0):
            return "请先治疗队伍。"
        store.state["league"] = {"active": true, "stage": 0}
        for trainer_id in IDS:
            store.state["trainers"].erase(trainer_id)
    elif from in ROOMS:
        var index: int = ROOMS.find(from)
        if not active(store.state):
            return "当前没有联盟挑战。"
        if index == 4 and to == "hall-of-fame":
            if stage(store.state) != 5 or not store.state.get("trainers", {}).get("league_champion", false):
                return "必须先击败冠军。"
        elif to not in ROOMS or ROOMS.find(to) != index + 1:
            return "入口已关闭，不能临阵退缩！"
        elif stage(store.state) <= index:
            return "必须先击败本房间的四天王。"
        elif index > 3:
            return "冠军房间只能前往名人堂。"
    else:
        return "不能跳过联盟阶段。"
    store.state["location"] = arrival.duplicate(true)
    if not store.save_game():
        store.state = before
        return store.error
    return ""

func result_state(candidate: Dictionary, won: bool, id: String, growth: RefCounted) -> Dictionary:
    var s: Dictionary = candidate.duplicate(true)
    if not can_challenge(s, id):
        return s
    if won:
        s["league"]["stage"] = stage(s) + 1
        s["trainers"][id] = true
        s["money"] = mini(999999, int(s["money"]) + int({"league_lorelei": 5400, "league_bruno": 5600, "league_agatha": 5800, "league_lance": 6000, "league_champion": 12600}.get(id, 0)))
    else:
        var count: int = 0
        for value in s.get("badges", {}).values():
            if value:
                count += 1
        var highest: int = 1
        for pet in s["team"]:
            highest = maxi(highest, int(pet["level"]))
        s["money"] = maxi(0, int(s["money"]) - highest * 4 * [2, 4, 6, 9, 12, 16, 20, 25, 30][mini(count, 8)])
        s["league"] = {"active": false, "stage": 0}
        for trainer_id in IDS:
            s["trainers"].erase(trainer_id)
        for pet in s["team"]:
            pet["hp"] = int(growth.stats(pet)["hp"])
            for move in pet["moves"]:
                pet["pp"][move] = int(growth.moves[move]["pp"])
            for key in ["status", "sleep_turns", "toxic_counter"]:
                pet.erase(key)
        s["lead"] = 0
        s["location"] = {"map_id": "indigo-lobby", "x": 120, "y": 121}
    return s

func accessible(s: Dictionary, map: String) -> bool:
    return map not in ROOMS or (active(s) and ROOMS.find(map) <= stage(s) and ROOMS.find(map) <= 4)

func apply(map: String, layout: Dictionary, s: Dictionary) -> void:
    if map not in ROOMS:
        return
    var index: int = ROOMS.find(map)
    if index < 3:
        for x in [4, 5]:
            for y in [0, 1]:
                layout["solid"][y][x] = 0 if active(s) and stage(s) > index else 1
    # Entry returns are rejected by stage transition, not by an invisible collision.
