extends Area2D
@export var challenge_id: String
@export var challenge_title: String
@export var difficulty: String
@export var board_size: int = 8
@export var vocabulary: Array[String]

var nearby: bool = false
@onready var prompt: Label = $Prompt

func _ready() -> void:
	body_entered.connect(func(body: Node2D) -> void:
		if body.is_in_group("player"):
			nearby = true
			prompt.show()
	)
	body_exited.connect(func(body: Node2D) -> void:
		if body.is_in_group("player"):
			nearby = false
			prompt.hide()
	)
	prompt.hide()

func _unhandled_input(event: InputEvent) -> void:
	if nearby and event.is_action_pressed("interact") and not event.is_echo() and not WordSearchUI.opened:
		if challenge_id.is_empty():
			WordSearchUI.open_book()
		else:
			WordSearchUI.open_book(challenge_id, challenge_title, difficulty, board_size, vocabulary)
		get_viewport().set_input_as_handled()
