extends Area2D

@export var speaker_name: String = "NPC"
@export_multiline var dialogue_text: String = "Hello!"
@export var prompt_text: String = "[E] Falar"

@onready var prompt: Label = $Prompt

var _player_nearby: bool = false

func _ready() -> void:
	prompt.text = prompt_text
	prompt.visible = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _unhandled_input(event: InputEvent) -> void:
	if not _player_nearby or not event.is_action_pressed("interact"):
		return

	var dialogue_ui := get_tree().get_first_node_in_group("simple_dialogue")
	if dialogue_ui != null and dialogue_ui.has_method("show_dialogue"):
		dialogue_ui.show_dialogue(speaker_name, dialogue_text)
		prompt.visible = false
		get_viewport().set_input_as_handled()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_nearby = true
		prompt.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_nearby = false
		prompt.visible = false
