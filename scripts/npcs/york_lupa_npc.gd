extends "res://scripts/npcs/simple_dialogue_npc.gd"

func _on_dialogue_closed() -> void:
	GameState.grant_magnifier()
	super._on_dialogue_closed()
