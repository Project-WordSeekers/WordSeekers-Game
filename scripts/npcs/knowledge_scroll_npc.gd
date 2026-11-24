extends "res://scripts/npcs/simple_dialogue_npc.gd"

func _on_dialogue_closed() -> void:
	GameState.knowledge_scroll_owned = true
	super._on_dialogue_closed()
	GameState.save_progress()
