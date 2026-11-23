extends CharacterBody2D

var player: Node2D = null
var talking: bool = false
@onready var prompt: Label = $Prompt

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") as Node2D
	add_to_group("npc")
	prompt.text = "[E] Falar"
	prompt.add_theme_color_override("font_color", Color(1.0, 0.92, 0.55, 1.0))
	prompt.hide()

func _process(_delta: float) -> void:
	if player == null:
		player = get_tree().get_first_node_in_group("player") as Node2D
		return
	var close: bool = global_position.distance_to(player.global_position) < 90.0
	prompt.visible = close and not talking and not DialogueUI.is_open()

func _unhandled_input(event: InputEvent) -> void:
	if player == null or talking or DialogueUI.is_open():
		return
	if not event.is_action_pressed("interact"):
		return
	if global_position.distance_to(player.global_position) >= 90.0:
		return

	talking = true
	prompt.hide()
	DialogueUI.show_dialogue(
		"Morador",
		"Olá! Bem-vindo à vila!\nUse WASD ou as setas para andar.\nChegue perto de mim e aperte E para conversar.",
		Callable(self, "_on_dialogue_closed")
	)
	get_viewport().set_input_as_handled()

func _on_dialogue_closed() -> void:
	talking = false
