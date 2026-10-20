extends CharacterBody2D

var player: Node2D = null
var talking: bool = false
@onready var prompt: Label = $Prompt

var lesson: Array[String] = [
	"Hello! Welcome to Mathematical Bridge!",
	"Let's learn numbers in English! 1 is ONE, 2 is TWO, and 3 is THREE.",
	"4 is FOUR, 5 is FIVE, 6 is SIX, 7 is SEVEN, 8 is EIGHT, 9 is NINE, and 10 is TEN.",
	"Remember: eleven, twelve, thirteen, fourteen, fifteen, sixteen, seventeen, eighteen, nineteen, twenty!",
	"Quick challenge: how do you say the number 7 in English? Think: S-E-V-E-N! Great job practicing!"
]

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") as Node2D
	prompt.text = "[E] Learn numbers"
	prompt.hide()

func _process(_delta: float) -> void:
	if player == null:
		player = get_tree().get_first_node_in_group("player") as Node2D
		return
	var close := global_position.distance_to(player.global_position) < 85.0
	prompt.visible = close and not talking and not DialogueUI.is_open()

func _unhandled_input(event: InputEvent) -> void:
	if player == null or talking or DialogueUI.is_open():
		return
	if not event.is_action_pressed("interact"):
		return
	if global_position.distance_to(player.global_position) >= 85.0:
		return
	talking = true
	prompt.hide()
	DialogueUI.show_sequence("Bridge Guide", lesson, Callable(self, "_on_lesson_finished"))
	get_viewport().set_input_as_handled()

func _on_lesson_finished() -> void:
	talking = false
