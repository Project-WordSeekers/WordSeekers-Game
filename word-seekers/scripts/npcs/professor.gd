extends CharacterBody2D

var player_nearby: bool = false
var dialogue_index: int = 0
var question_index: int = 0

@onready var interaction_label: Control = get_node("../UI/InteractionLabel") as Control
@onready var dialogue_panel: Control = get_node("../UI/DialoguePanel") as Control
@onready var dialogue_label: Label = get_node("../UI/DialoguePanel/DialogueLabel") as Label
@onready var quiz_panel: Control = get_node("../UI/QuizPanel") as Control
@onready var question_label: Label = get_node("../UI/QuizPanel/QuestionLabel") as Label
@onready var answer_button_1: Button = get_node("../UI/QuizPanel/AnswerButton1") as Button
@onready var answer_button_2: Button = get_node("../UI/QuizPanel/AnswerButton2") as Button
@onready var answer_button_3: Button = get_node("../UI/QuizPanel/AnswerButton3") as Button
@onready var answer_button_4: Button = get_node("../UI/QuizPanel/AnswerButton4") as Button
@onready var victory_label: Label = get_node("../UI/QuizPanel/victoryLabel") as Label

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

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true
		interaction_label.show()

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
		interaction_label.hide()
		dialogue_panel.hide()
		quiz_panel.hide()

func _unhandled_input(event: InputEvent) -> void:
	if not player_nearby or not event.is_action_pressed("interact"):
		return

	interaction_label.hide()
	if dialogue_index < dialogue_lines.size():
		dialogue_panel.show()
		dialogue_label.text = dialogue_lines[dialogue_index]
		dialogue_index += 1
		return

	dialogue_panel.hide()
	quiz_panel.show()
	_show_question()

func _show_question() -> void:
	if question_index >= questions.size():
		_show_victory()
		return

	var question: Dictionary = questions[question_index]
	var answers: Array = question["answers"] as Array
	question_label.text = String(question["prompt"])
	answer_button_1.text = String(answers[0])
	answer_button_2.text = String(answers[1])
	answer_button_3.text = String(answers[2])
	answer_button_4.text = String(answers[3])
	question_label.show()
	answer_button_1.show()
	answer_button_2.show()
	answer_button_3.show()
	answer_button_4.show()
	victory_label.hide()

func _select_answer(answer_index: int) -> void:
	if question_index >= questions.size():
		return

	var question: Dictionary = questions[question_index]
	var correct_index: int = int(question["correct"])
	if answer_index != correct_index:
		question_label.text = "Try again!"
		return

	question_index += 1
	_show_question()

func _show_victory() -> void:
	question_label.hide()
	answer_button_1.hide()
	answer_button_2.hide()
	answer_button_3.hide()
	answer_button_4.hide()
	victory_label.show()

func _on_answer_button_1_pressed() -> void:
	_select_answer(0)

func _on_answer_button_2_pressed() -> void:
	_select_answer(1)

func _on_answer_button_3_pressed() -> void:
	_select_answer(2)

func _on_answer_button_4_pressed() -> void:
	_select_answer(3)
