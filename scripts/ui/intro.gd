extends VideoStreamPlayer

const CHARACTER_SELECTION_SCENE: String = "res://scenes/ui/character_selection/character_selection.tscn"

var transition_started: bool = false

func _ready() -> void:
	finished.connect(_on_video_finished)

func _unhandled_input(event: InputEvent) -> void:
	if transition_started:
		return

	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		go_to_character_selection()
		get_viewport().set_input_as_handled()

func _on_video_finished() -> void:
	go_to_character_selection()

func go_to_character_selection() -> void:
	if transition_started:
		return

	transition_started = true
	SceneTransition.change_scene_to_file(CHARACTER_SELECTION_SCENE)
