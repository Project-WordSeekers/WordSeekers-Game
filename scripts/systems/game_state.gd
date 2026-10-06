extends Node

signal health_changed(current_hp: int, max_hp: int)
signal dictionary_changed(owned: bool, uses: int, max_uses: int)

const APPEARANCE_MALE: int = 0
const APPEARANCE_FEMALE: int = 1
const MAX_HEALTH: int = 10
const CITY01_SCENE: String = "res://scenes/locations/cena1/cena1.tscn"

const DICTIONARY_NAME: String = "O Dicionário"
const DICTIONARY_DESCRIPTION: String = "Um grimório misterioso. O dicionário tem o poder de ajudar seu usuário a desvendar o mistério das palavras."
const DICTIONARY_MAX_USES: int = 3

var world_map_point_name: StringName = &"Point01"
var pending_spawn_name: StringName = &""
var player_appearance: int = APPEARANCE_MALE
var player_health: int = MAX_HEALTH

var dictionary_owned: bool = false
var dictionary_uses: int = 0

func _ready() -> void:
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
	player_appearance = clampi(appearance, APPEARANCE_MALE, APPEARANCE_FEMALE)

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

func reset_inventory() -> void:
	dictionary_owned = false
	dictionary_uses = 0
	dictionary_changed.emit(dictionary_owned, dictionary_uses, DICTIONARY_MAX_USES)

func return_to_city01_after_defeat() -> void:
	world_map_point_name = &"Point01"
	pending_spawn_name = &""
	restore_full_health()
	SceneTransition.change_scene_to_file(CITY01_SCENE)
