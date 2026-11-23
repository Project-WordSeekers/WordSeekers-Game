extends "res://scripts/npcs/simple_dialogue_npc.gd"

@export_multiline var review_text: String

var reviewing := false

func _on_dialogue_closed() -> void:
	if not reviewing:
		reviewing = true
		DialogueUI.show_dialogue(speaker_name, review_text, _on_dialogue_closed)
		return
	reviewing = false
	super._on_dialogue_closed()
