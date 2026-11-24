extends CanvasLayer

const ToolIconButton = preload("res://scripts/ui/tool_icon_button.gd")
const Generator = preload("res://scripts/minigames/word_search_generator.gd")
const WORDS: Array[String] = ["CASTLE","CITY","WALLS","LEARN"]
# Versão 3: nova grade com direções obrigatórias, sem importar o tabuleiro anterior.
# O progresso novo continua sendo salvo entre sessões normalmente.
const SAVE_PATH: String = "user://word_search_progress_v3.cfg"
const CHALLENGE: String = "colchester_roman_walls"
var challenge_id: String
var words: Array[String]
var board_size: int
var grid: GridContainer
var subtitle: Label
var board: Array = []
var placements: Dictionary = {}
var found: Array[String] = []
var hinted_word: String = ""
var hint_cell: Vector2i = Vector2i(-1,-1)
var selecting: bool = false
var start_cell: Vector2i = Vector2i(-1,-1)
var last_cell: Vector2i = Vector2i(-1,-1)
var buttons: Dictionary = {}
var overlay: ColorRect
var status: Label
var word_label: Label
var hint_button: ToolIconButton
var opened: bool = false
var completion_callback: Callable
var close_button: Button

func _ready() -> void:
	layer = 80
	overlay = ColorRect.new()
	overlay.color = Color(0.04,0.03,0.02,0.80)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(540,0)
	center.add_child(panel)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#ead6a4")
	style.border_color = Color("#79502c")
	style.set_border_width_all(5)
	style.set_corner_radius_all(13)
	panel.add_theme_stylebox_override("panel",style)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left",24)
	margin.add_theme_constant_override("margin_right",24)
	margin.add_theme_constant_override("margin_top",18)
	margin.add_theme_constant_override("margin_bottom",18)
	panel.add_child(margin)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation",8)
	margin.add_child(content)
	var title := Label.new()
	title.text = "DIÁRIO DE EXPLORAÇÃO"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color",Color("#53391e"))
	title.add_theme_font_size_override("font_size",25)
	content.add_child(title)
	subtitle = Label.new()
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_color_override("font_color",Color("#53391e"))
	content.add_child(subtitle)
	var instruction := Label.new()
	instruction.text = "Arraste entre a primeira e a última letra de cada palavra."
	instruction.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	instruction.add_theme_color_override("font_color",Color("#53391e"))
	content.add_child(instruction)
	var board_center := CenterContainer.new()
	content.add_child(board_center)
	grid = GridContainer.new()
	grid.columns = 8
	grid.add_theme_constant_override("h_separation",3)
	grid.add_theme_constant_override("v_separation",2)
	board_center.add_child(grid)
	word_label = Label.new()
	word_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	word_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	word_label.add_theme_color_override("font_color",Color("#53391e"))
	content.add_child(word_label)
	status = Label.new()
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status.add_theme_color_override("font_color",Color("#53391e"))
	content.add_child(status)
	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_child(actions)
	hint_button = ToolIconButton.new(load("res://assets/ui/magnifier.svg") as Texture2D)
	hint_button.pressed.connect(_use_magnifier)
	actions.add_child(hint_button)
	close_button = Button.new()
	close_button.text = "Fechar diário (Esc)"
	close_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	close_button.pressed.connect(close_book)
	actions.add_child(close_button)
	overlay.hide()

func _build_grid() -> void:
	for child in grid.get_children():
		grid.remove_child(child)
		child.queue_free()
	buttons.clear()
	grid.columns = board_size
	var cell_size := mini(43, int(352.0 / board_size))
	var cell_style := StyleBoxFlat.new()
	cell_style.bg_color = Color("#443b36")
	cell_style.set_corner_radius_all(3)
	for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		cell_style.set_content_margin(side, 1)
	var hover_style := cell_style.duplicate() as StyleBoxFlat
	hover_style.bg_color = Color("#63554b")
	for y in range(board_size):
		for x in range(board_size):
			var pos := Vector2i(x,y)
			var cell := Button.new()
			cell.add_theme_stylebox_override("normal", cell_style)
			cell.add_theme_stylebox_override("hover", hover_style)
			cell.add_theme_stylebox_override("pressed", hover_style)
			cell.focus_mode = Control.FOCUS_NONE
			cell.custom_minimum_size = Vector2.ONE * cell_size
			cell.add_theme_font_size_override("font_size",mini(19, cell_size - 8))
			cell.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			cell.button_down.connect(_begin_selection.bind(pos))
			cell.mouse_entered.connect(_hover_cell.bind(pos))
			cell.button_up.connect(_finish_selection.bind(pos))
			grid.add_child(cell)
			buttons[pos] = cell

func open_book(id: String = CHALLENGE, title: String = "Colchester · Roman Walls", difficulty: String = "Fácil", size: int = 8, vocabulary: Array[String] = WORDS, on_completed: Callable = Callable()) -> void:
	if opened:
		return
	if DialogueUI.is_open() or GameHUD.is_modal_open():
		return
	completion_callback = on_completed
	close_button.visible = not on_completed.is_valid()
	challenge_id = id
	words = vocabulary
	board_size = size
	subtitle.text = "%s  |  %s · %d×%d" % [title, difficulty, size, size]
	status.text = ""
	_load_progress()
	if completion_callback.is_valid():
		board = []
		placements = {}
		found.clear()
		hinted_word = ""
		hint_cell = Vector2i(-1, -1)
	if board.is_empty():
		var generated: Dictionary = Generator.generate(words, int(Time.get_unix_time_from_system()), size, id == CHALLENGE, size == 16)
		if generated.is_empty():
			push_error("Não foi possível gerar o caça-palavras.")
			return
		board = generated["grid"]
		placements = generated["placements"]
		_save_progress()
	_build_grid()
	opened = true
	overlay.show()
	_refresh()

func close_book() -> void:
	opened = false
	selecting = false
	overlay.hide()

func _input(event: InputEvent) -> void:
	if opened and not completion_callback.is_valid() and event.is_action_pressed("ui_cancel"):
		close_book()
		get_viewport().set_input_as_handled()
	if opened and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed and selecting:
		for pos in buttons:
			if (buttons[pos] as Button).get_global_rect().has_point(event.position):
				last_cell = pos
				break
		_commit_selection()
		get_viewport().set_input_as_handled()

func _begin_selection(pos: Vector2i) -> void:
	start_cell = pos
	last_cell = pos
	selecting = true
	_refresh()

func _hover_cell(pos: Vector2i) -> void:
	if selecting and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		last_cell = pos
		_refresh()

func _finish_selection(pos: Vector2i) -> void:
	if selecting:
		last_cell = pos
		_commit_selection()

func _commit_selection() -> void:
	selecting = false
	var selected := _line_cells(start_cell,last_cell)
	if selected.is_empty():
		_refresh()
		return
	for word in words:
		if found.has(word):
			continue
		var positions: Array = placements.get(word,[])
		if selected == positions or selected == _reversed(positions):
			found.append(word)
			if word == hinted_word:
				hinted_word = ""
				hint_cell = Vector2i(-1,-1)
			_save_progress()
			status.text = "Encontrou: " + word + "!"
			if found.size() == words.size():
				status.text = "Parabéns! Caça-palavras concluído."
				if completion_callback.is_valid():
					var finished := completion_callback
					completion_callback = Callable()
					close_book()
					finished.call_deferred()
					return
			_refresh()
			return
	status.text = "Tente outra sequência."
	_refresh()

func _line_cells(a: Vector2i,b: Vector2i) -> Array:
	var dx := b.x-a.x
	var dy := b.y-a.y
	if dx == 0 and dy == 0:
		return []
	if not (dx == 0 or dy == 0 or abs(dx) == abs(dy)):
		return []
	var length: int = maxi(abs(dx),abs(dy))+1
	var direction := Vector2i(signi(dx),signi(dy))
	var result: Array = []
	for i in range(length):
		result.append(a+direction*i)
	return result

func _reversed(values: Array) -> Array:
	var result := values.duplicate()
	result.reverse()
	return result

func _use_magnifier() -> void:
	if not opened or not hinted_word.is_empty():
		return
	for word in words:
		var positions: Array = placements.get(word, [])
		if found.has(word) or positions.is_empty():
			continue
		if GameState.use_magnifier():
			hinted_word = word
			hint_cell = positions[0]
			_save_progress()
			status.text = "A Lupa destacou a primeira letra de " + word + "."
			_refresh()
		return

func _refresh() -> void:
	var uses := GameState.magnifier_uses
	hint_button.caption.text = "Usar Lupa (%d/%d)" % [maxi(uses, 0), GameState.MAGNIFIER_MAX_USES]
	hint_button.disabled = uses <= 0 or not hinted_word.is_empty() or found.size() == words.size()
	hint_button.tooltip_text = "Fale com o Guardião de York para receber a Lupa." if uses < 0 else "Destaca a primeira letra de uma palavra ainda não encontrada."
	var selected: Array = _line_cells(start_cell,last_cell) if selecting else []
	for pos in buttons:
		var button: Button = buttons[pos]
		button.text = str(board[pos.y][pos.x])
		var highlighted := false
		for word in found:
			if (placements[word] as Array).has(pos):
				highlighted = true
		button.modulate = Color("#f7e17e") if pos == hint_cell else (Color("#8cbf84") if highlighted else (Color("#f1cc75") if selected.has(pos) else Color.WHITE))
	var labels: Array[String] = []
	for word in words:
		labels.append("✓ "+word if found.has(word) else word)
	word_label.text = "   •   ".join(labels)
	if found.size() == words.size():
		status.text = "Parabéns! Caça-palavras concluído."
	elif status.text.is_empty():
		status.text = "%d / %d palavras" % [found.size(),words.size()]

func _save_progress() -> void:
	if completion_callback.is_valid():
		return
	var cfg := ConfigFile.new()
	cfg.load(SAVE_PATH)
	cfg.set_value(challenge_id,"hinted_word",hinted_word)
	cfg.set_value(challenge_id,"grid",board)
	cfg.set_value(challenge_id,"placements",placements)
	cfg.set_value(challenge_id,"found",found)
	var err := cfg.save(SAVE_PATH)
	if err != OK:
		push_warning("Não foi possível salvar caça-palavras: %s" % err)

func _load_progress() -> void:
	board = []
	placements = {}
	found.clear()
	hinted_word = ""
	hint_cell = Vector2i(-1,-1)
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	board = cfg.get_value(challenge_id,"grid",[])
	placements = cfg.get_value(challenge_id,"placements",{})
	found.clear()
	for word in cfg.get_value(challenge_id,"found",[]):
		if words.has(str(word)):
			found.append(str(word))
	if board.size() != board_size or placements.size() != words.size():
		board = []
		placements = {}
		found.clear()
		return
	var saved_hint: String = cfg.get_value(challenge_id, "hinted_word", "")
	if words.has(saved_hint) and not found.has(saved_hint) and placements.has(saved_hint):
		hinted_word = saved_hint
		hint_cell = placements[saved_hint][0]
