extends Node

signal health_changed(current_hp: int, max_hp: int)
signal dictionary_changed(owned: bool, uses: int, max_uses: int)

const APPEARANCE_MALE: int = 0
const APPEARANCE_FEMALE: int = 1
const APPEARANCE_GIRL: int = 2
const APPEARANCE_ELF_MALE: int = 3
const MAX_HEALTH: int = 10
const CITY01_SCENE: String = "res://scenes/locations/colchester/colchester.tscn"

const DICTIONARY_NAME: String = "O Dicionário"
const DICTIONARY_DESCRIPTION: String = "Um grimório misterioso. O dicionário tem o poder de ajudar seu usuário a desvendar o mistério das palavras."
const DICTIONARY_MAX_USES: int = 3

# Encontros aleatorios: guarda o ponto de chegada para retornar apos a batalha.
var random_encounter_active: bool = false
# Chance inicial de 5%; aumenta 5 pontos percentuais por viagem sem batalha.
var consecutive_travels_without_battle: int = 0

func get_next_battle_chance() -> float:
	return minf(0.05 * float(consecutive_travels_without_battle + 1), 0.20)

func register_travel_battle_roll(battle_started: bool) -> void:
	if battle_started:
		consecutive_travels_without_battle = 0
	else:
		consecutive_travels_without_battle += 1
var world_map_point_name: StringName = &"Colchester"
var pending_spawn_name: StringName = &""
# Retorno do templo: definido pela entrada da cidade, nunca pelo interior compartilhado.
var temple_return_scene: String = ""
var temple_return_spawn: StringName = &""

func register_temple_origin(city_scene: String, return_spawn: StringName) -> void:
	temple_return_scene = city_scene
	temple_return_spawn = return_spawn

func clear_temple_origin() -> void:
	temple_return_scene = ""
	temple_return_spawn = &""

var player_appearance: int = APPEARANCE_MALE
var player_health: int = MAX_HEALTH

var dictionary_owned: bool = false
var dictionary_uses: int = 0

func _ready() -> void:
	load_progress()
	_ensure_key_action("interact", KEY_E)
	_ensure_key_action("help", KEY_H)
	_ensure_key_action("inventory", KEY_I)
	_ensure_key_action("translate", KEY_T)

func _ensure_key_action(action_name: StringName, keycode: Key) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)

	for input_event: InputEvent in InputMap.action_get_events(action_name):
		if input_event is InputEventKey:
			var key_event: InputEventKey = input_event as InputEventKey
			if key_event.physical_keycode == keycode:
				return

	var event: InputEventKey = InputEventKey.new()
	event.physical_keycode = keycode
	InputMap.action_add_event(action_name, event)

func set_player_appearance(appearance: int) -> void:
	player_appearance = clampi(appearance, APPEARANCE_MALE, APPEARANCE_ELF_MALE)

func is_female_player() -> bool:
	return player_appearance == APPEARANCE_FEMALE

func set_health(value: int) -> void:
	player_health = clampi(value, 0, MAX_HEALTH)
	health_changed.emit(player_health, MAX_HEALTH)

func damage_player(amount: int = 1) -> int:
	if amount <= 0:
		return player_health
	set_health(player_health - amount)
	return player_health

func heal_player(amount: int = 1) -> int:
	if amount <= 0:
		return player_health
	set_health(player_health + amount)
	return player_health

func restore_full_health() -> void:
	set_health(MAX_HEALTH)

func grant_dictionary() -> bool:
	if dictionary_owned:
		return false
	dictionary_owned = true
	dictionary_uses = DICTIONARY_MAX_USES
	dictionary_changed.emit(dictionary_owned, dictionary_uses, DICTIONARY_MAX_USES)
	return true

func use_dictionary() -> bool:
	if not dictionary_owned or dictionary_uses <= 0:
		return false
	dictionary_uses -= 1
	dictionary_changed.emit(dictionary_owned, dictionary_uses, DICTIONARY_MAX_USES)
	return true

const MAGNIFIER_MAX_USES := 3
# -1 indica que o jogador ainda não recebeu o item.
var magnifier_uses: int = -1

func grant_magnifier() -> void:
	if magnifier_uses < 0:
		magnifier_uses = MAGNIFIER_MAX_USES
		save_progress()

func use_magnifier() -> bool:
	if magnifier_uses <= 0:
		return false
	magnifier_uses -= 1
	save_progress()
	return true

func reset_inventory() -> void:
	dictionary_owned = false
	dictionary_uses = 0
	dictionary_changed.emit(dictionary_owned, dictionary_uses, DICTIONARY_MAX_USES)

func return_to_city01_after_defeat() -> void:
	random_encounter_active = false
	world_map_point_name = &"Colchester"
	pending_spawn_name = &""
	restore_full_health()
	SceneTransition.change_scene_to_file(CITY01_SCENE)

# Persistent city progression and battle quiz history.
const CITY_LEVELS: Dictionary = {
	"Cambridge":1,"Canterbury":1,"Birmingham":1,"Nottingham":1,"Winchester":1,
	"York":2,"Stratford":2,"Bath":2,"London":2,"Manchester":2,
	"Newcastle":3,"Liverpool":3,"Oxford":3,"Salisbury":3,"Plymouth":3
}
const PROGRESS_PATH: String = "user://wordseekers_progress.json"
var npc_cities_completed: Dictionary = {}
var talked_npcs: Dictionary = {}
var encountered_monster_ids: Dictionary = {}
var quiz_pool: Array = []
const KNOWLEDGE_NPCS = preload("res://assets/knowledge_npcs.json")
const MONSTER_GOAL := 100
var knowledge_scroll_owned := false
var boss_defeated := false

func knowledge_dialogues_completed() -> int:
	var count := 0
	for npc_id in KNOWLEDGE_NPCS.data:
		if talked_npcs.has(npc_id):
			count += 1
	return count

func endgame_ready() -> bool:
	return not boss_defeated and knowledge_scroll_owned and encountered_monster_ids.size() >= MONSTER_GOAL and knowledge_dialogues_completed() == KNOWLEDGE_NPCS.data.size()

func load_progress() -> void:
	if not FileAccess.file_exists(PROGRESS_PATH):
		return
	var f := FileAccess.open(PROGRESS_PATH, FileAccess.READ)
	if f == null:
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if not parsed is Dictionary:
		return
	knowledge_scroll_owned = bool(parsed.get("knowledge_scroll_owned", false))
	boss_defeated = bool(parsed.get("boss_defeated", false))
	magnifier_uses = clampi(int(parsed.get("magnifier_uses", -1)), -1, MAGNIFIER_MAX_USES)
	for city in parsed.get("npc_cities_completed", []):
		if CITY_LEVELS.has(String(city)):
			npc_cities_completed[String(city)] = true
	for npc_id in parsed.get("talked_npcs", []):
		talked_npcs[String(npc_id)] = true
	# Os formatos anteriores registravam encontros ou vitórias por ID de quiz.
	for key in ["encountered_monster_ids", "used_quiz_ids", "defeated_monster_ids"]:
		for quiz_id in parsed.get(key, []):
			encountered_monster_ids[String(quiz_id)] = true

func save_progress() -> void:
	var f := FileAccess.open(PROGRESS_PATH, FileAccess.WRITE)
	if f == null:
		push_warning("Unable to save progress")
		return
	f.store_string(JSON.stringify({"knowledge_scroll_owned": knowledge_scroll_owned, "boss_defeated": boss_defeated, "magnifier_uses": magnifier_uses, "npc_cities_completed": npc_cities_completed.keys(), "talked_npcs": talked_npcs.keys(), "encountered_monster_ids": encountered_monster_ids.keys()}))


func has_talked_to_npc(npc_id: String) -> bool:
	return talked_npcs.has(npc_id)

func register_npc_talked(npc_id: String, city: String = String(world_map_point_name)) -> void:
	var changed: bool = false
	if npc_id != "" and not talked_npcs.has(npc_id):
		talked_npcs[npc_id] = true
		changed = true
	if CITY_LEVELS.has(city) and not npc_cities_completed.has(city):
		npc_cities_completed[city] = true
		changed = true
	if changed:
		save_progress()

func register_npc_dialogue_completed(city: String) -> void:
	register_npc_talked("", city)

func is_level_unlocked(level: int) -> bool:
	if level <= 1:
		return true
	for city in CITY_LEVELS:
		if int(CITY_LEVELS[city]) < level and not npc_cities_completed.has(city):
			return false
	return true

func can_enter_city(city: String) -> bool:
	if city == "Colchester":
		return true
	return CITY_LEVELS.has(city) and is_level_unlocked(int(CITY_LEVELS[city]))

func load_quiz_pool() -> void:
	if not quiz_pool.is_empty():
		return
	var f := FileAccess.open("res://assets/battle_quizzes.json", FileAccess.READ)
	if f == null:
		push_error("Missing battle quiz JSON")
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if parsed is Dictionary:
		quiz_pool = parsed.get("conjuntos", [])

func has_unused_quizzes() -> bool:
	if boss_defeated:
		return false
	load_quiz_pool()
	for quiz in quiz_pool:
		if quiz is Dictionary and not encountered_monster_ids.has(String(quiz.get("id", ""))):
			return true
	return false

func reserve_random_quiz() -> Dictionary:
	if boss_defeated:
		return {}
	load_quiz_pool()
	var available: Array = []
	for quiz in quiz_pool:
		if quiz is Dictionary and not encountered_monster_ids.has(String(quiz.get("id", ""))):
			available.append(quiz)
	if available.is_empty():
		return {}
	var selected: Dictionary = available.pick_random()
	encountered_monster_ids[String(selected["id"])] = true
	save_progress()
	return selected
