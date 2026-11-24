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

func _setup_npc_indicator() -> void:
	npc_indicator = NPC_INDICATOR_SCRIPT.new()
	add_child(npc_indicator)
	npc_indicator.setup(self, npc_id)


var dialogue_lines: Array[String] = ["Olá! Boas-vindas à nossa biblioteca.", "Sou o professor John e ensino inglês. Em inglês, biblioteca é library, professor é teacher e livro é book.", "Hoje tenho algumas perguntas para você. Se errar, aproveite para aprender com a resposta.", "Vamos começar o desafio!"]

var questions: Array[Dictionary] = [
	{
		"prompt": "Qual é a tradução de \"library\"?",
		"answers": ["A) Escola", "B) Biblioteca", "C) Professor", "D) Livro"],
		"correct": 1
	},
	{
		"prompt": "Qual é a tradução de \"teacher\"?",
		"answers": ["A) Aluno", "B) Professor", "C) Livro", "D) Amigo"],
		"correct": 1
	},
	{
		"prompt": "Qual é a tradução de \"book\"?",
		"answers": ["A) Caderno", "B) Escola", "C) Livro", "D) Mesa"],
		"correct": 2
	},
	{
		"prompt": "O que significa \"Good morning\"?",
		"answers": ["A) Boa noite", "B) Boa tarde", "C) Bom dia", "D) Até amanhã"],
		"correct": 2
	},
	{
		"prompt": "O que significa \"What is your name?\"?",
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
		"Professor John",
		dialogue_lines,
		Callable(self, "_start_quiz")
	)
	get_viewport().set_input_as_handled()

func _start_quiz() -> void:
	DialogueUI.show_quiz(
		"Professor John",
		questions,
		Callable(self, "_on_quiz_answer"),
		Callable(self, "_on_quiz_finished"),
		"Muito bem! Você concluiu o desafio."
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
