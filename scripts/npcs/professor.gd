extends CharacterBody2D

var player_nearby: bool = false
var interaction_active: bool = false

@onready var interaction_label: Control = get_node("../UI/InteractionLabel") as Control
@onready var interaction_text: Label = get_node("../UI/InteractionLabel/Label") as Label
@onready var legacy_dialogue_panel: Control = get_node("../UI/DialoguePanel") as Control
@onready var legacy_quiz_panel: Control = get_node("../UI/QuizPanel") as Control

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


var dialogue_lines: Array[String] = [
	"Hello!\nWelcome to our library!",
	"My name is Mr. John.\nI am the English teacher.",
	"I have some questions\nfor you today.",
	"Don't worry!\nThey are not too difficult.",
	"You can use what you know\nabout English to answer them.",
	"If you make a mistake, that's okay.\nYou can learn from it!",
	"Are you ready\nto test your English?",
	"Great!\nLet's start the challenge!"
]

var questions: Array[Dictionary] = [
	{
		"prompt": "What is the correct translation of \"library\"?",
		"answers": ["A) Escola", "B) Biblioteca", "C) Professor", "D) Livro"],
		"correct": 1
	},
	{
		"prompt": "What is the correct translation of \"teacher\"?",
		"answers": ["A) Aluno", "B) Professor", "C) Livro", "D) Amigo"],
		"correct": 1
	},
	{
		"prompt": "What is the correct translation of \"book\"?",
		"answers": ["A) Caderno", "B) Escola", "C) Livro", "D) Mesa"],
		"correct": 2
	},
	{
		"prompt": "What does \"Good morning\" mean?",
		"answers": ["A) Boa noite", "B) Boa tarde", "C) Bom dia", "D) Até amanhã"],
		"correct": 2
	},
	{
		"prompt": "What does \"What is your name?\" mean?",
		"answers": ["A) Qual é o seu nome?", "B) Onde você mora?", "C) Quantos anos você tem?", "D) Como você está?"],
		"correct": 0
	}
]

func _ready() -> void:
	interaction_text.text = "[E] Falar"
	interaction_text.add_theme_color_override("font_color", Color(1.0, 0.92, 0.55, 1.0))
	interaction_label.hide()
	legacy_dialogue_panel.hide()
	legacy_quiz_panel.hide()
	_setup_npc_indicator()

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true
		if not DialogueUI.is_open():
			interaction_label.show()

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
		interaction_label.hide()

func _unhandled_input(event: InputEvent) -> void:
	if not player_nearby or interaction_active or DialogueUI.is_open():
		return
	if not event.is_action_pressed("interact"):
		return

	interaction_active = true
	interaction_label.hide()
	DialogueUI.show_sequence(
		"Mr. John",
		dialogue_lines,
		Callable(self, "_start_quiz")
	)
	get_viewport().set_input_as_handled()

func _start_quiz() -> void:
	DialogueUI.show_quiz(
		"Mr. John",
		questions,
		Callable(self, "_on_quiz_answer"),
		Callable(self, "_on_quiz_finished"),
		"You won! Great job!\nYou answered correctly!"
	)

func _on_quiz_answer(_question_index: int, _is_correct: bool) -> void:
	pass

func _on_quiz_finished() -> void:
	npc_indicator.mark_talked(String(GameState.world_map_point_name))
	interaction_active = false
	if player_nearby:
		interaction_label.show()

# Compatibilidade com as conexões antigas da cena. Os botões legados ficam ocultos.
func _on_answer_button_1_pressed() -> void:
	pass

func _on_answer_button_2_pressed() -> void:
	pass

func _on_answer_button_3_pressed() -> void:
	pass

func _on_answer_button_4_pressed() -> void:
	pass
