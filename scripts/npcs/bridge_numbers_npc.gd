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
	new_dialogue_icon.scale = Vector2(0.33, 0.33)
	new_dialogue_icon.position = Vector2(0, -68)
	new_dialogue_icon.z_index = 30
	add_child(new_dialogue_icon)
	var float_tween := create_tween()
	float_tween.set_loops()
	float_tween.tween_property(new_dialogue_icon, "position:y", -72.0, 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	float_tween.tween_property(new_dialogue_icon, "position:y", -68.0, 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _get_npc_id() -> String:
	if npc_id.strip_edges() != "":
		return npc_id.strip_edges()
	var scene_id: String = scene_file_path.get_file().get_basename() if scene_file_path != "" else "runtime"
	return "%s::%s" % [scene_id, get_path()]

func _refresh_new_dialogue_icon() -> void:
	_ensure_new_dialogue_icon()
	new_dialogue_icon.visible = not GameState.has_talked_to_npc(_get_npc_id())


var lesson: Array[String] = [
	"Hello! Welcome to Mathematical Bridge!",
	"Let's learn numbers in English! 1 is ONE, 2 is TWO, and 3 is THREE.",
	"4 is FOUR, 5 is FIVE, 6 is SIX, 7 is SEVEN, 8 is EIGHT, 9 is NINE, and 10 is TEN.",
	"Remember: eleven, twelve, thirteen, fourteen, fifteen, sixteen, seventeen, eighteen, nineteen, twenty!",
	"Quick challenge: how do you say the number 7 in English? Think: S-E-V-E-N! Great job practicing!"
]

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") as Node2D
	prompt.text = "[E] Learn numbers"
	prompt.hide()
	_ensure_new_dialogue_icon()
	_refresh_new_dialogue_icon()

func _process(_delta: float) -> void:
	if player == null:
		player = get_tree().get_first_node_in_group("player") as Node2D
		return
	var close := global_position.distance_to(player.global_position) < 85.0
	prompt.visible = close and not talking and not DialogueUI.is_open()

func _unhandled_input(event: InputEvent) -> void:
	if player == null or talking or DialogueUI.is_open():
		return
	if not event.is_action_pressed("interact"):
		return
	if global_position.distance_to(player.global_position) >= 85.0:
		return
	talking = true
	prompt.hide()
	DialogueUI.show_sequence("Bridge Guide", lesson, Callable(self, "_on_lesson_finished"))
	get_viewport().set_input_as_handled()

func _on_lesson_finished() -> void:
	GameState.register_npc_talked(_get_npc_id(), String(GameState.world_map_point_name))
	_refresh_new_dialogue_icon()
	talking = false
