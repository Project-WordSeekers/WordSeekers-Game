extends CharacterBody2D

var player_nearby: bool = false
var dialogue_index: int = 0
var question_index: int = 0

@onready var interaction_label: Control = get_node("../UI/InteractionLabel") as Control
@onready var dialogue_panel: Control = get_node("../UI/DialoguePanel") as Control
@onready var dialogue_name: Label = get_node("../UI/DialoguePanel/Name") as Label
@onready var dialogue_label: Label = get_node("../UI/DialoguePanel/Text") as Label
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
	"This is the first town\nwhere you will study English.",
	"Here, we will learn the basics\nin a simple way.",
	"We will practice the alphabet,\nintroductions, pronouns and questions.",
	"You will also learn words\nfor things in the classroom.",
	"These words will help you\non your next adventures.",
	"Are you ready for a short challenge?",
	"Great!\nLet's start!"
]

var questions: Array[Dictionary] = [
	{"prompt": "Which word begins with the /b/ sound?", "answers": ["A) Book", "B) Apple", "C) Chair", "D) Desk"], "correct": 0},
	{"prompt": "How do you say 'Olá' when greeting someone?", "answers": ["A) Goodbye", "B) Hello", "C) Thanks", "D) Sorry"], "correct": 1},
	{"prompt": "Which pronoun means 'eu'?", "answers": ["A) You", "B) He", "C) I", "D) They"], "correct": 2},
	{"prompt": "What is the best answer to 'How are you?'", "answers": ["A) I'm fine, thank you!", "B) My name is Ana.", "C) I'm twelve.", "D) I'm from Brazil."], "correct": 0},
	{"prompt": "What is the correct answer to 'What's your name?'", "answers": ["A) I'm fine.", "B) I'm from Brazil.", "C) My name is Lucas.", "D) Good morning."], "correct": 2},
	{"prompt": "Which word is a classroom object?", "answers": ["A) Pencil", "B) Run", "C) Happy", "D) Speak"], "correct": 0},
	{"prompt": "Which word has the /d/ sound at the beginning?", "answers": ["A) Book", "B) Apple", "C) Desk", "D) Pen"], "correct": 2},
	{"prompt": "Which pronoun means 'eles/elas'?", "answers": ["A) We", "B) They", "C) She", "D) It"], "correct": 1},
	{"prompt": "What does 'Where are you from?' ask about?", "answers": ["A) Your name", "B) Your age", "C) Your favorite color", "D) Your place of origin"], "correct": 3},
	{"prompt": "Which classroom object do you use to write?", "answers": ["A) Pencil", "B) Chair", "C) Door", "D) Window"], "correct": 0}
]

func _ready() -> void:
	interaction_label.hide()
	dialogue_panel.hide()
	quiz_panel.hide()
	victory_label.hide()

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true
		if not dialogue_panel.visible and not quiz_panel.visible:
			interaction_label.show()

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
		interaction_label.hide()
		dialogue_panel.hide()
		quiz_panel.hide()
		_unlock_player()

func _unhandled_input(event: InputEvent) -> void:
	if not player_nearby or not event.is_action_pressed("interact"):
		return

	interaction_label.hide()

	if quiz_panel.visible:
		return

	_lock_player()

	if dialogue_index < dialogue_lines.size():
		dialogue_panel.show()
		dialogue_name.text = "Mr. John"
		dialogue_label.text = dialogue_lines[dialogue_index]
		dialogue_index += 1
		get_viewport().set_input_as_handled()
		return

	dialogue_panel.hide()
	quiz_panel.show()
	_show_question()
	get_viewport().set_input_as_handled()

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

func _lock_player() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("set_input_locked"):
		player.set_input_locked(true)

func _unlock_player() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("set_input_locked"):
		player.set_input_locked(false)

func _on_answer_button_1_pressed() -> void:
	_select_answer(0)

func _on_answer_button_2_pressed() -> void:
	_select_answer(1)

func _on_answer_button_3_pressed() -> void:
	_select_answer(2)

func _on_answer_button_4_pressed() -> void:
	_select_answer(3)
