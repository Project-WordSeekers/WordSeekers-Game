extends CanvasLayer

enum Mode {
	NONE,
	DIALOGUE,
	SEQUENCE,
	CHOICE,
	QUIZ
}

@onready var panel: PanelContainer = $Panel
@onready var name_label: Label = $Panel/Margin/VBox/Name
@onready var text_label: Label = $Panel/Margin/VBox/Text
@onready var choices_box: VBoxContainer = $Panel/Margin/VBox/Choices
@onready var choice_1: Label = $Panel/Margin/VBox/Choices/Choice1
@onready var choice_2: Label = $Panel/Margin/VBox/Choices/Choice2
@onready var choice_3: Label = $Panel/Margin/VBox/Choices/Choice3
@onready var choice_4: Label = $Panel/Margin/VBox/Choices/Choice4
@onready var status_label: Label = $Panel/Margin/VBox/Status
@onready var help_label: Label = $Panel/Margin/VBox/Help

var mode: int = Mode.NONE
var selected_index: int = 0
var current_choices: Array[String] = []
var sequence_lines: Array[String] = []
var sequence_index: int = 0
var quiz_questions: Array[Dictionary] = []
var quiz_index: int = 0
var dictionary_revealed_index: int = -1

var finish_callback: Callable = Callable()
var choice_callback: Callable = Callable()
var quiz_answer_callback: Callable = Callable()
var quiz_finished_callback: Callable = Callable()
var quiz_completion_text: String = "Muito bem! Quiz concluído."

func _ready() -> void:
	_ensure_interact_action()
	panel.hide()
	_clear_callbacks()

func is_open() -> bool:
	return panel.visible

func is_quiz_active() -> bool:
	return panel.visible and mode == Mode.QUIZ

func show_dialogue(speaker_name: String, dialogue_text: String, on_closed: Callable = Callable()) -> void:
	_reset_state()
	mode = Mode.DIALOGUE
	finish_callback = on_closed
	name_label.text = speaker_name
	text_label.text = dialogue_text
	help_label.text = "E para fechar"
	panel.show()

func show_sequence(speaker_name: String, lines: Array[String], on_finished: Callable = Callable()) -> void:
	_reset_state()
	mode = Mode.SEQUENCE
	finish_callback = on_finished
	sequence_lines = lines.duplicate()
	sequence_index = 0
	name_label.text = speaker_name
	if sequence_lines.is_empty():
		_close_and_finish()
		return
	text_label.text = sequence_lines[0]
	help_label.text = "E para continuar"
	panel.show()

func show_choice(speaker_name: String, prompt: String, options: Array[String], on_selected: Callable) -> void:
	_reset_state()
	mode = Mode.CHOICE
	choice_callback = on_selected
	name_label.text = speaker_name
	text_label.text = prompt
	current_choices = options.duplicate()
	selected_index = 0
	choices_box.show()
	help_label.text = "↑/↓ para escolher   E para confirmar"
	_render_choices()
	panel.show()

func show_quiz(
	speaker_name: String,
	questions: Array[Dictionary],
	on_answer: Callable = Callable(),
	on_finished: Callable = Callable(),
	completion_text: String = "Muito bem! Quiz concluído."
) -> void:
	_reset_state()
	mode = Mode.QUIZ
	name_label.text = speaker_name
	quiz_questions = questions.duplicate(true)
	quiz_index = 0
	quiz_answer_callback = on_answer
	quiz_finished_callback = on_finished
	quiz_completion_text = completion_text
	choices_box.show()
	_update_quiz_help()
	panel.show()
	_show_quiz_question()

func close() -> void:
	panel.hide()
	mode = Mode.NONE
	_clear_callbacks()

func _unhandled_input(event: InputEvent) -> void:
	if not panel.visible:
		return
	if GameHUD.is_modal_open():
		return

	if mode == Mode.QUIZ and event.is_action_pressed("translate"):
		_use_dictionary_on_quiz()
		get_viewport().set_input_as_handled()
		return

	if mode == Mode.CHOICE or mode == Mode.QUIZ:
		if event.is_action_pressed("ui_up"):
			_move_selection(-1)
			get_viewport().set_input_as_handled()
			return
		if event.is_action_pressed("ui_down"):
			_move_selection(1)
			get_viewport().set_input_as_handled()
			return

	if not event.is_action_pressed("interact"):
		return

	match mode:
		Mode.DIALOGUE:
			_close_and_finish()
		Mode.SEQUENCE:
			_advance_sequence()
		Mode.CHOICE:
			_confirm_choice()
		Mode.QUIZ:
			_confirm_quiz_answer()
		_:
			close()

	get_viewport().set_input_as_handled()

func _move_selection(direction: int) -> void:
	if current_choices.is_empty():
		return
	selected_index = wrapi(selected_index + direction, 0, current_choices.size())
	if dictionary_revealed_index < 0:
		status_label.text = ""
	_render_choices()

func _render_choices() -> void:
	var labels: Array[Label] = [choice_1, choice_2, choice_3, choice_4]
	for index in range(labels.size()):
		var label: Label = labels[index]
		if index >= current_choices.size():
			label.hide()
			continue
		label.show()
		var is_selected: bool = index == selected_index
		var is_revealed: bool = mode == Mode.QUIZ and index == dictionary_revealed_index
		var marker: String = "▶ " if is_selected else "   "
		if is_revealed:
			marker = "[T] " + marker
		label.text = marker + current_choices[index]
		var font_color: Color = Color(1.0, 1.0, 1.0, 1.0)
		if is_revealed:
			font_color = Color(0.45, 1.0, 0.62, 1.0)
		elif is_selected:
			font_color = Color(1.0, 0.92, 0.55, 1.0)
		label.add_theme_color_override("font_color", font_color)

func _advance_sequence() -> void:
	sequence_index += 1
	if sequence_index >= sequence_lines.size():
		_close_and_finish()
		return
	text_label.text = sequence_lines[sequence_index]

func _confirm_choice() -> void:
	if current_choices.is_empty():
		return
	var callback: Callable = choice_callback
	panel.hide()
	mode = Mode.NONE
	_clear_callbacks()
	if callback.is_valid():
		callback.call(selected_index)

func _show_quiz_question() -> void:
	if quiz_index >= quiz_questions.size():
		_show_quiz_completion()
		return

	var question: Dictionary = quiz_questions[quiz_index]
	var answers: Array = question.get("answers", []) as Array
	current_choices.clear()
	for answer_index in range(answers.size()):
		var answer_value: Variant = answers[answer_index]
		current_choices.append(String(answer_value))
	selected_index = 0
	dictionary_revealed_index = -1
	text_label.text = String(question.get("prompt", ""))
	status_label.text = ""
	_update_quiz_help()
	_render_choices()

func _confirm_quiz_answer() -> void:
	if quiz_index < 0 or quiz_index >= quiz_questions.size():
		return

	var question: Dictionary = quiz_questions[quiz_index]
	var correct_index: int = int(question.get("correct", -1))
	var is_correct: bool = selected_index == correct_index

	if quiz_answer_callback.is_valid():
		quiz_answer_callback.call(quiz_index, is_correct)

	if not panel.visible or mode != Mode.QUIZ:
		return

	if not is_correct:
		status_label.text = String(question.get("wrong_feedback", "Resposta incorreta. Tente novamente!"))
		return

	quiz_index += 1
	_show_quiz_question()

func _use_dictionary_on_quiz() -> void:
	if not GameState.dictionary_owned:
		status_label.text = "Você ainda não possui O Dicionário."
		return
	if GameState.dictionary_uses <= 0:
		status_label.text = "O Dicionário não possui mais usos."
		return
	if dictionary_revealed_index >= 0:
		status_label.text = "O Dicionário já foi usado nesta pergunta."
		return
	if quiz_index < 0 or quiz_index >= quiz_questions.size():
		return

	var question: Dictionary = quiz_questions[quiz_index]
	var correct_index: int = int(question.get("correct", -1))
	if correct_index < 0 or correct_index >= current_choices.size():
		status_label.text = "O Dicionário não conseguiu decifrar esta pergunta."
		return

	var used: bool = GameState.use_dictionary()
	if not used:
		return
	dictionary_revealed_index = correct_index
	status_label.text = "O Dicionário revela a resposta correta. Usos restantes: %d/%d" % [
		GameState.dictionary_uses,
		GameState.DICTIONARY_MAX_USES
	]
	_render_choices()

func _update_quiz_help() -> void:
	if GameState.dictionary_owned:
		help_label.text = "↑/↓ escolher   E confirmar   T usar Dicionário"
	else:
		help_label.text = "↑/↓ para escolher   E para confirmar"

func _show_quiz_completion() -> void:
	mode = Mode.DIALOGUE
	choices_box.hide()
	status_label.text = ""
	text_label.text = quiz_completion_text
	help_label.text = "E para fechar"
	finish_callback = quiz_finished_callback
	dictionary_revealed_index = -1

func _close_and_finish() -> void:
	var callback: Callable = finish_callback
	panel.hide()
	mode = Mode.NONE
	_clear_callbacks()
	if callback.is_valid():
		callback.call()

func _reset_state() -> void:
	panel.hide()
	mode = Mode.NONE
	selected_index = 0
	current_choices.clear()
	sequence_lines.clear()
	sequence_index = 0
	quiz_questions.clear()
	quiz_index = 0
	dictionary_revealed_index = -1
	status_label.text = ""
	choices_box.hide()
	_clear_callbacks()

func _clear_callbacks() -> void:
	finish_callback = Callable()
	choice_callback = Callable()
	quiz_answer_callback = Callable()
	quiz_finished_callback = Callable()

func _ensure_interact_action() -> void:
	if InputMap.has_action("interact"):
		return
	InputMap.add_action("interact")
	var interact_key: InputEventKey = InputEventKey.new()
	interact_key.physical_keycode = KEY_E
	InputMap.action_add_event("interact", interact_key)
