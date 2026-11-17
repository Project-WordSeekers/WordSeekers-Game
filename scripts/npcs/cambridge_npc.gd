extends CharacterBody2D

var player: Node2D = null
var talking: bool = false
@onready var prompt: Label = $Prompt

@export var npc_id: String = ""
const NEW_DIALOGUE_ICON_TEXTURE: Texture2D = preload("res://assets/ui/icons/npc_new_dialogue_exclamation.png")
var new_dialogue_icon: Sprite2D

func _ensure_new_dialogue_icon() -> void:
	if new_dialogue_icon != null:
		return
	new_dialogue_icon = Sprite2D.new()
	new_dialogue_icon.name = "NewDialogueIcon"
	new_dialogue_icon.texture = NEW_DIALOGUE_ICON_TEXTURE
	new_dialogue_icon.centered = true
	new_dialogue_icon.scale = Vector2(0.03, 0.03)
	new_dialogue_icon.position = Vector2(0, -80)
	new_dialogue_icon.z_index = 30
	add_child(new_dialogue_icon)
	var float_tween := create_tween()
	float_tween.set_loops()
	float_tween.tween_property(new_dialogue_icon, "position:y", -84.0, 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	float_tween.tween_property(new_dialogue_icon, "position:y", -80.0, 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _get_npc_id() -> String:
	if npc_id.strip_edges() != "":
		return npc_id.strip_edges()
	var scene_id: String = scene_file_path.get_file().get_basename() if scene_file_path != "" else "runtime"
	return "%s::%s" % [scene_id, get_path()]

func _refresh_new_dialogue_icon() -> void:
	_ensure_new_dialogue_icon()
	new_dialogue_icon.visible = not GameState.has_talked_to_npc(_get_npc_id())


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") as Node2D
	add_to_group("npc")
	prompt.text = "[E] Falar"
	prompt.add_theme_color_override("font_color", Color(1.0, 0.92, 0.55, 1.0))
	prompt.hide()
	_ensure_new_dialogue_icon()
	_refresh_new_dialogue_icon()

func _process(_delta: float) -> void:
	if player == null:
		player = get_tree().get_first_node_in_group("player") as Node2D
		return
	var close: bool = global_position.distance_to(player.global_position) < 90.0
	prompt.visible = close and not talking and not DialogueUI.is_open()

func _unhandled_input(event: InputEvent) -> void:
	if player == null or talking or DialogueUI.is_open():
		return
	if not event.is_action_pressed("interact"):
		return
	if global_position.distance_to(player.global_position) >= 90.0:
		return

	talking = true
	prompt.hide()
	DialogueUI.show_dialogue(
		"Morador",
		"Olá! Bem-vindo à vila!\nUse WASD ou as setas para andar.\nChegue perto de mim e aperte E para conversar.",
		Callable(self, "_on_dialogue_closed")
	)
	get_viewport().set_input_as_handled()

func _on_dialogue_closed() -> void:
	GameState.register_npc_talked(_get_npc_id(), String(GameState.world_map_point_name))
	_refresh_new_dialogue_icon()
	talking = false
