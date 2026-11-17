extends Area2D

@onready var prompt: Label = $Prompt
var player_nearby: bool = false

func _ready() -> void:
	prompt.hide()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _unhandled_input(event: InputEvent) -> void:
	if not player_nearby or not event.is_action_pressed("interact") or event.is_echo():
		return
	if DialogueUI.is_open():
		return

	prompt.hide()
	get_viewport().set_input_as_handled()

	# Mostra uma mensagem para o jogador saber que o cálice funcionou.
	var message: String
	if GameState.player_health >= GameState.MAX_HEALTH:
		message = "Your strength is already full.\n(Sua vida já está cheia: %d/%d)" % [GameState.player_health, GameState.MAX_HEALTH]
	else:
		GameState.restore_full_health()
		message = "The chalice restores your strength!\n(O cálice restaurou sua vida: %d/%d)" % [GameState.player_health, GameState.MAX_HEALTH]
	DialogueUI.show_dialogue("Cálice Sagrado", message, Callable(self, "_on_closed"))

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
