extends Node

const APPEARANCE_MALE: int = 0
const APPEARANCE_FEMALE: int = 1

var world_map_point_name: StringName = &"Point01"
var pending_spawn_name: StringName = &""
var player_appearance: int = APPEARANCE_MALE

func _ready() -> void:
	if not InputMap.has_action("interact"):
		InputMap.add_action("interact")
		var event: InputEventKey = InputEventKey.new()
		event.physical_keycode = KEY_E
		InputMap.action_add_event("interact", event)

func set_player_appearance(appearance: int) -> void:
	player_appearance = clampi(appearance, APPEARANCE_MALE, APPEARANCE_FEMALE)

func is_female_player() -> bool:
	return player_appearance == APPEARANCE_FEMALE
