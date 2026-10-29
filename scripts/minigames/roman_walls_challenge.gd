extends Area2D
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
	if nearby and event.is_action_pressed("interact") and not WordSearchUI.opened:
		WordSearchUI.open_book()
		get_viewport().set_input_as_handled()
