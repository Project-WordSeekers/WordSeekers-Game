extends Area2D

@export var speaker_name: String = "NPC"
@export_multiline var dialogue_text: String = "Hello!"
@export var prompt_text: String = "[E] Falar"

@export var npc_id: String = ""
const NPC_INDICATOR_SCRIPT: Script = preload("res://scripts/npcs/npc_dialogue_indicator.gd")
var npc_indicator

<<<<<<< HEAD
func _setup_npc_indicator() -> void:
	npc_indicator = NPC_INDICATOR_SCRIPT.new()
	add_child(npc_indicator)
	npc_indicator.setup(self, npc_id)
=======
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
>>>>>>> d177ccc02db95598f2d303153582984d643d6959


@onready var prompt: Label = $Prompt
var player_nearby: bool = false

func _ready() -> void:
	prompt.text = prompt_text
	prompt.hide()
	_setup_npc_indicator()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _unhandled_input(event: InputEvent) -> void:
	if not player_nearby or not event.is_action_pressed("interact"):
		return
	if DialogueUI.is_open():
		return

	prompt.hide()
	DialogueUI.show_dialogue(
		speaker_name,
		dialogue_text,
		Callable(self, "_on_dialogue_closed")
	)
	get_viewport().set_input_as_handled()

func _on_dialogue_closed() -> void:
	npc_indicator.mark_talked(String(GameState.world_map_point_name))
	if player_nearby:
		prompt.show()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true
		if not DialogueUI.is_open():
			prompt.show()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
		prompt.hide()
