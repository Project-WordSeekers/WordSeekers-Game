extends Node

var world_map_point_name: StringName = &"Point01"
var pending_spawn_name: StringName = &""

func _ready() -> void:
	if not InputMap.has_action("interact"):
		InputMap.add_action("interact")
		var event := InputEventKey.new()
		event.physical_keycode = KEY_E
		InputMap.action_add_event("interact", event)
