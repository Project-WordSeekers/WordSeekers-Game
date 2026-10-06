extends CanvasLayer

@onready var box: Panel = $Panel

func _ready() -> void:
	box.hide()

func show_dialogue(who: String, text: String) -> void:
	DialogueUI.show_dialogue(who, text)
