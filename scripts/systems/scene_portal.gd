extends Area2D

@export_file("*.tscn") var target_scene_path: String
@export var target_spawn_name: StringName = &""

var _transition_started: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if _transition_started:
		return
	if not body.is_in_group("player"):
		return
	if target_scene_path.is_empty():
		push_warning("ScenePortal sem cena de destino configurada: %s" % get_path())
		return

	_transition_started = true
	GameState.pending_spawn_name = target_spawn_name
	SceneTransition.change_scene_to_file(target_scene_path)
