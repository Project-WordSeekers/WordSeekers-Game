extends "res://scripts/systems/scene_portal.gd"

func _ready() -> void:
	$"../PortaSecretaVisual/PortaFechada".visible = not CityQuests.porta_secreta_radcliffe_aberta
	$"../PortaSecretaVisual/PortaAberta".visible = CityQuests.porta_secreta_radcliffe_aberta
	super._ready()

func can_cross() -> bool:
	if not CityQuests.tem_key_03:
		DialogueUI.show_dialogue("Passagem secreta", "A porta está trancada. Encontre a KEY 03 na Radcliffe Camera.", Callable())
		return false
	CityQuests.destrancar_porta_radcliffe()
	CityQuests.descobrir_segredo_radcliffe()
	$"../PortaSecretaVisual/PortaFechada".hide()
	$"../PortaSecretaVisual/PortaAberta".show()
	return true
