extends "res://scripts/systems/scene_portal.gd"

func can_cross() -> bool:
	if not CityQuests.tem_key_02:
		DialogueUI.show_dialogue("Passagem secreta", "A porta está trancada. Encontre a KEY 02 na City of Caves.", Callable())
		return false
	CityQuests.passagem_desbloqueada = true
	return true
