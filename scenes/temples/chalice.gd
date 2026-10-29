extends Area2D

@onready var prompt: Label = $Prompt
var player_nearby: bool = false

func _ready() -> void:
	prompt.hide()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _unhandled_input(event: InputEvent) -> void:
	if not player_nearby or not event.is_action_pressed("interact"):
		return
	if DialogueUI.is_open():
		return

	prompt.hide()
	get_viewport().set_input_as_handled()

	GameState.restore_full_health()
	_on_closed()

func _on_closed() -> void:
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
