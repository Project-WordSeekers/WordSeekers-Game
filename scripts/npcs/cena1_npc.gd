extends CharacterBody2D

var player: Node2D
var talking := false
@onready var prompt: Label = $Prompt

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	add_to_group("npc")
	prompt.visible = false

func _process(_delta: float) -> void:
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		return

	var close := global_position.distance_to(player.global_position) < 90.0
	prompt.visible = close and not talking

func _unhandled_input(event: InputEvent) -> void:
	if talking or player == null:
		return

	if not event.is_action_pressed("interact"):
		return

	var close := global_position.distance_to(player.global_position) < 90.0
	if not close:
		return

	talking = true
	prompt.visible = false

	var ui = get_tree().get_first_node_in_group("dialogue")
	if ui:
		ui.show_dialogue("Morador", "Hello there!\nWelcome to our village!\nThis is a good place to learn English.")

	get_viewport().set_input_as_handled()
