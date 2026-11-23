extends CanvasLayer

@onready var panel: Panel = $Panel

func _ready() -> void:
	panel.hide()

func show_dialogue(speaker_name: String, dialogue_text: String) -> void:
	DialogueUI.show_dialogue(speaker_name, dialogue_text)
