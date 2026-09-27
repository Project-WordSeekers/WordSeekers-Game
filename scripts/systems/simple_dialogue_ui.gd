extends CanvasLayer

@onready var panel: Panel = $Panel
@onready var name_label: Label = $Panel/Name
@onready var text_label: Label = $Panel/Text

func _ready() -> void:
	add_to_group("simple_dialogue")
	panel.visible = false

func show_dialogue(speaker_name: String, dialogue_text: String) -> void:
	name_label.text = speaker_name
	text_label.text = dialogue_text
	panel.visible = true

func _unhandled_input(event: InputEvent) -> void:
	if panel.visible and event.is_action_pressed("interact"):
		panel.visible = false
		get_viewport().set_input_as_handled()
