extends Area2D

@export var speaker_name: String = "NPC"
@export_multiline var dialogue_text: String = "Hello!"
@export var prompt_text: String = "[E] Falar"

@onready var prompt: Label = $Prompt
var player_nearby: bool = false

func _ready() -> void:
	prompt.text = prompt_text
	prompt.hide()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _unhandled_input(event: InputEvent) -> void:
	if not player_nearby or not event.is_action_pressed("interact"):
		return
	if DialogueUI.is_open():
		return

	prompt.hide()
	DialogueUI.show_dialogue(
		speaker_name,
		dialogue_text,
		Callable(self, "_on_dialogue_closed")
	)
	get_viewport().set_input_as_handled()

func _on_dialogue_closed() -> void:
	if player_nearby:
		prompt.show()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true
		if not DialogueUI.is_open():
			prompt.show()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
		prompt.hide()
