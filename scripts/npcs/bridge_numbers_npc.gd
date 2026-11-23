extends CharacterBody2D

var player: Node2D = null
var talking: bool = false
@onready var prompt: Label = $Prompt

@export var npc_id: String = ""
const NPC_INDICATOR_SCRIPT: Script = preload("res://scripts/npcs/npc_dialogue_indicator.gd")
var npc_indicator

func _setup_npc_indicator() -> void:
	npc_indicator = NPC_INDICATOR_SCRIPT.new()
	add_child(npc_indicator)
	npc_indicator.setup(self, npc_id)


@export var speaker_name: String
@export var lesson: Array[String]
@export_multiline var question: String
@export var answers: Array[String]
@export var correct_answer: int
@export var explanation: String

const TALK_DISTANCE := 52.0

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") as Node2D
	prompt.text = "[E] Falar"
	prompt.hide()
	_setup_npc_indicator()

func _process(_delta: float) -> void:
	if player == null:
		player = get_tree().get_first_node_in_group("player") as Node2D
		return
	var close := global_position.distance_to(player.global_position) < TALK_DISTANCE
	prompt.visible = close and not talking and not DialogueUI.is_open()

func _unhandled_input(event: InputEvent) -> void:
	if player == null or talking or DialogueUI.is_open() or GameHUD.is_modal_open():
		return
	if not event.is_action_pressed("interact") or event.is_echo():
		return
	if global_position.distance_to(player.global_position) >= TALK_DISTANCE:
		return
	talking = true
	prompt.hide()
	DialogueUI.show_sequence(speaker_name, lesson, _show_question)
	get_viewport().set_input_as_handled()

func _show_question() -> void:
	DialogueUI.show_quiz(
		speaker_name,
		[{"prompt": question, "answers": answers, "correct": correct_answer, "explanation": explanation}],
		Callable(),
		_on_lesson_finished,
		"Lição concluída!"
	)

func _on_lesson_finished() -> void:
	npc_indicator.mark_talked(String(GameState.world_map_point_name))
	talking = false
