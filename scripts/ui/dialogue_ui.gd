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
var quiz_pending_advance: bool = false
var quiz_explanation: String = ""
var choice_5: Label
var dictionary_widget: VBoxContainer
var dictionary_button: Button
var dictionary_shortcut: Label
var quiz_wrong_indices: Array[int] = []
var quiz_correct_index: int = -1
var correct_feedback_frame: PanelContainer
var correct_feedback_explanation: Label

var finish_callback: Callable = Callable()
var choice_callback: Callable = Callable()
var quiz_answer_callback: Callable = Callable()
var quiz_finished_callback: Callable = Callable()
var quiz_completion_text: String = "Muito bem! Quiz concluído."

func _ready() -> void:
	choice_5 = Label.new()
	choice_5.name = "Choice5"
	choice_5.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	for label in [choice_1, choice_2, choice_3, choice_4, status_label, text_label]:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	choices_box.add_child(choice_5)
	_ensure_interact_action()
	_create_dictionary_button()
	_create_correct_feedback_frame()
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
	quiz_pending_advance = false
	quiz_answer_callback = on_answer
	quiz_finished_callback = on_finished
	quiz_completion_text = completion_text
	choices_box.show()
	_update_quiz_help()
	panel.show()
	_show_quiz_question()
	_fit_battle_quiz_panel.call_deferred()

func close() -> void:
	panel.hide()
	mode = Mode.NONE
	_clear_callbacks()

# Recebe E antes dos Control nodes consumirem o evento, inclusive no mapa-mundi.
func _input(event: InputEvent) -> void:
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
	# Ignora repeticao automatica da tecla mantida pressionada.
	if event is InputEventKey and event.is_echo():
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
	if quiz_pending_advance or current_choices.is_empty():
		return
	selected_index = wrapi(selected_index + direction, 0, current_choices.size())
	if dictionary_revealed_index < 0:
		status_label.text = ""
	_render_choices()

func _render_choices() -> void:
	var labels: Array[Label] = [choice_1, choice_2, choice_3, choice_4, choice_5]
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
		# Feedback sempre tem prioridade sobre o destaque da selecao.
		if mode == Mode.QUIZ and index == quiz_correct_index:
			font_color = Color("60e88c") # Acerto: verde
		elif mode == Mode.QUIZ and index in quiz_wrong_indices:
			font_color = Color("ff6969") # Erro: vermelho
		elif is_revealed:
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
	quiz_correct_index = -1
	quiz_wrong_indices.clear()
	text_label.text = String(question.get("prompt", ""))
	status_label.text = ""
	_reset_success_style()
	_update_quiz_help()
	_render_choices()
	_fit_battle_quiz_panel.call_deferred()

func _confirm_quiz_answer() -> void:
	if quiz_pending_advance:
		quiz_pending_advance = false
		quiz_index += 1
		_show_quiz_question()
		return
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
		_reset_success_style()
		if not selected_index in quiz_wrong_indices:
			quiz_wrong_indices.append(selected_index)
		_render_choices()
		status_label.text = String(question.get("wrong_feedback", "Not quite! Try again.")) + "\n" + String(question.get("explanation", ""))
		_fit_battle_quiz_panel.call_deferred()
		return
	quiz_pending_advance = true
	quiz_correct_index = correct_index
	_render_choices()
	status_label.text = ""
	status_label.hide()
	correct_feedback_explanation.text = String(question.get("explanation", ""))
	correct_feedback_frame.show()
	_fit_battle_quiz_panel.call_deferred()

func _use_dictionary_on_quiz() -> void:
	if quiz_pending_advance:
		return
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
	_reset_success_style()
	text_label.text = quiz_completion_text
	help_label.text = "E para fechar"
	finish_callback = quiz_finished_callback
	dictionary_revealed_index = -1

func _close_and_finish() -> void:
	if mode == Mode.DIALOGUE or mode == Mode.SEQUENCE:
		var current_scene: Node = get_tree().current_scene
		if current_scene != null and "/locations/" in current_scene.scene_file_path:
			GameState.register_npc_dialogue_completed(String(GameState.world_map_point_name))
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
	quiz_pending_advance = false
	dictionary_revealed_index = -1
	quiz_correct_index = -1
	quiz_wrong_indices.clear()
	status_label.text = ""
	_reset_success_style()
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

# O painel de quiz é centralizado no topo e limitado ao viewport.
# A largura reserva margens para telas pequenas e permite quebra de texto.
func _fit_battle_quiz_panel() -> void:
	if not panel.visible or mode != Mode.QUIZ:
		return
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var panel_width: float = minf(650.0, maxf(200.0, viewport_size.x - 32.0))
	panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	panel.custom_minimum_size = Vector2(panel_width, 0.0)
	panel.size = Vector2(panel_width, 0.0)
	panel.reset_size()
	panel.position = Vector2(maxf(8.0, (viewport_size.x - panel_width) * 0.5), 12.0)

# Caixa especial de confirmacao inserida no VBox do quiz.
# Oculta nas falas comuns; aparece apenas ao acertar uma pergunta.
func _create_correct_feedback_frame() -> void:
	var content: VBoxContainer = $Panel/Margin/VBox
	correct_feedback_frame = PanelContainer.new()
	correct_feedback_frame.name = "CorrectAnswerFrame"
	var frame_style: StyleBoxFlat = StyleBoxFlat.new()
	frame_style.bg_color = Color("143527")
	frame_style.border_color = Color("7cde9d")
	frame_style.set_border_width_all(3)
	frame_style.set_corner_radius_all(10)
	frame_style.content_margin_left = 14.0
	frame_style.content_margin_right = 14.0
	frame_style.content_margin_top = 10.0
	frame_style.content_margin_bottom = 12.0
	correct_feedback_frame.add_theme_stylebox_override("panel", frame_style)
	content.add_child(correct_feedback_frame)
	content.move_child(correct_feedback_frame, status_label.get_index() + 1)
	var feedback_column: VBoxContainer = VBoxContainer.new()
	feedback_column.add_theme_constant_override("separation", 6)
	correct_feedback_frame.add_child(feedback_column)
	var title_row: HBoxContainer = HBoxContainer.new()
	title_row.add_theme_constant_override("separation", 10)
	feedback_column.add_child(title_row)
	var check_icon: TextureRect = TextureRect.new()
	check_icon.texture = load("res://assets/ui/correct_check.svg") as Texture2D
	check_icon.custom_minimum_size = Vector2(30.0, 30.0)
	check_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	check_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	title_row.add_child(check_icon)
	var heading: Label = Label.new()
	heading.text = "RESPOSTA CORRETA!"
	heading.add_theme_font_size_override("font_size", 23)
	heading.add_theme_color_override("font_color", Color("6df0a0"))
	heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_row.add_child(heading)
	correct_feedback_explanation = Label.new()
	correct_feedback_explanation.name = "Explanation"
	correct_feedback_explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	correct_feedback_explanation.add_theme_font_size_override("font_size", 18)
	correct_feedback_explanation.add_theme_color_override("font_color", Color("f1fff4"))
	feedback_column.add_child(correct_feedback_explanation)
	var next_hint: Label = Label.new()
	next_hint.text = "[E] Próxima pergunta"
	next_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	next_hint.add_theme_font_size_override("font_size", 14)
	next_hint.add_theme_color_override("font_color", Color("c2e9cb"))
	feedback_column.add_child(next_hint)
	correct_feedback_frame.hide()

func _reset_success_style() -> void:
	status_label.show()
	status_label.remove_theme_font_size_override("font_size")
	status_label.remove_theme_color_override("font_color")
	if correct_feedback_frame != null:
		correct_feedback_frame.hide()

# Atalho visual opcional: usa a mesma rotina da tecla T.
func _create_dictionary_button() -> void:
	dictionary_widget = VBoxContainer.new()
	dictionary_widget.name = "DictionaryWidget"
	dictionary_widget.add_theme_constant_override("separation", 5)
	add_child(dictionary_widget)
	dictionary_button = Button.new()
	dictionary_button.name = "UseDictionary"
	dictionary_button.text = "Usar Dicionário"
	dictionary_button.icon = load("res://assets/ui/open_book.svg") as Texture2D
	dictionary_button.expand_icon = true
	dictionary_button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dictionary_button.custom_minimum_size = Vector2(148, 58)
	dictionary_button.add_theme_font_size_override("font_size", 14)
	dictionary_button.pressed.connect(_on_dictionary_button_pressed)
	dictionary_widget.add_child(dictionary_button)
	dictionary_shortcut = Label.new()
	dictionary_shortcut.name = "Shortcut"
	dictionary_shortcut.text = "Clicar 'T'"
	dictionary_shortcut.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dictionary_shortcut.add_theme_font_size_override("font_size", 14)
	dictionary_widget.add_child(dictionary_shortcut)
	dictionary_widget.hide()

func _process(_delta: float) -> void:
	if dictionary_widget == null:
		return
	var active: bool = panel.visible and mode == Mode.QUIZ
	dictionary_widget.visible = active
	if not active:
		return
	var screen_size: Vector2 = get_viewport().get_visible_rect().size
	# O HUD do jogador ocupa o canto superior esquerdo (x=16..316, y=16..188).
	# Deixe o Dicionario abaixo dessa regiao, sem encostar no quiz.
	var button_size: Vector2 = Vector2(148.0, 94.0)
	var left_x: float = panel.position.x - button_size.x - 12.0
	var bottom_space: float = screen_size.y - panel.position.y - panel.size.y
	if left_x >= 8.0 and screen_size.y >= 340.0:
		dictionary_widget.position = Vector2(
			left_x,
			clampf(maxf(200.0, panel.position.y + 12.0), 8.0, maxf(8.0, screen_size.y - button_size.y - 8.0))
		)
	elif bottom_space >= button_size.y + 12.0:
		# Resolucao menor: centralizado abaixo do painel, sem o HUD.
		dictionary_widget.position = Vector2(
			clampf(panel.position.x + (panel.size.x - button_size.x) * 0.5, 8.0, maxf(8.0, screen_size.x - button_size.x - 8.0)),
			panel.position.y + panel.size.y + 12.0
		)
	else:
		# Sem area lateral ou inferior: canto inferior direito.
		dictionary_widget.position = Vector2(
			maxf(8.0, screen_size.x - button_size.x - 12.0),
			maxf(8.0, screen_size.y - button_size.y - 12.0)
		)

func _on_dictionary_button_pressed() -> void:
	if not is_quiz_active() or GameHUD.is_modal_open():
		return
	_use_dictionary_on_quiz()
	_fit_battle_quiz_panel.call_deferred()
