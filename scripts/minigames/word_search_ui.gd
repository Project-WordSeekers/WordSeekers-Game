extends CanvasLayer

const Generator = preload("res://scripts/minigames/word_search_generator.gd")
const WORDS: Array[String] = ["CASTLE","CITY","WALLS","LEARN"]
# Versão 3: nova grade com direções obrigatórias, sem importar o tabuleiro anterior.
# O progresso novo continua sendo salvo entre sessões normalmente.
const SAVE_PATH: String = "user://word_search_progress_v3.cfg"
const CHALLENGE: String = "colchester_roman_walls"
var board: Array = []
var placements: Dictionary = {}
var found: Array[String] = []
var hint_cell: Vector2i = Vector2i(-1,-1)
var selecting: bool = false
var start_cell: Vector2i = Vector2i(-1,-1)
var last_cell: Vector2i = Vector2i(-1,-1)
var buttons: Dictionary = {}
var overlay: ColorRect
var status: Label
var word_label: Label
var hint_button: Button
var opened: bool = false

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
	panel.custom_minimum_size = Vector2(540,610)
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
	content.add_theme_constant_override("separation",12)
	margin.add_child(content)
	var title := Label.new()
	title.text = "DIÁRIO DE EXPLORAÇÃO"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color",Color("#53391e"))
	title.add_theme_font_size_override("font_size",25)
	content.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "Colchester • Roman Walls  |  Fácil • 8×8"
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
	var grid := GridContainer.new()
	grid.columns = 8
	grid.add_theme_constant_override("h_separation",3)
	grid.add_theme_constant_override("v_separation",3)
	board_center.add_child(grid)
	for y in range(8):
		for x in range(8):
			var pos := Vector2i(x,y)
			var cell := Button.new()
			cell.custom_minimum_size = Vector2(43,43)
			cell.add_theme_font_size_override("font_size",19)
			cell.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			cell.button_down.connect(_begin_selection.bind(pos))
			cell.mouse_entered.connect(_hover_cell.bind(pos))
			cell.button_up.connect(_finish_selection.bind(pos))
			grid.add_child(cell)
			buttons[pos] = cell
	word_label = Label.new()
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
	hint_button = Button.new()
	hint_button.text = "🔎 LUPA (indisponível)"
	hint_button.disabled = true
	hint_button.tooltip_text = "A Lupa será um item do inventário. Ainda não implementada."
	actions.add_child(hint_button)
	var close := Button.new()
	close.text = "Fechar diário (Esc)"
	close.pressed.connect(close_book)
	actions.add_child(close)
	overlay.hide()

func open_book() -> void:
	if opened:
		return
	if DialogueUI.is_open() or GameHUD.is_modal_open():
		return
	_load_progress()
	if board.is_empty():
		var generated: Dictionary = Generator.generate(WORDS, int(Time.get_unix_time_from_system()))
		if generated.is_empty():
			push_error("Não foi possível gerar o caça-palavras.")
			return
		board = generated["grid"]
		placements = generated["placements"]
		_save_progress()
	opened = true
	overlay.show()
	_refresh()

func close_book() -> void:
	opened = false
	selecting = false
	overlay.hide()

func _input(event: InputEvent) -> void:
	if opened and event.is_action_pressed("ui_cancel"):
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
	for word in WORDS:
		if found.has(word):
			continue
		var positions: Array = placements.get(word,[])
		if selected == positions or selected == _reversed(positions):
			found.append(word)
			hint_cell = Vector2i(-1,-1)
			_save_progress()
			status.text = "Encontrou: " + word + "!"
			if found.size() == WORDS.size():
				status.text = "Parabéns! Desafio das Roman Walls concluído."
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

func _refresh() -> void:
	var selected: Array = _line_cells(start_cell,last_cell) if selecting else []
	for pos in buttons:
		var button: Button = buttons[pos]
		button.text = str(board[pos.y][pos.x])
		var highlighted := false
		for word in found:
			if (placements[word] as Array).has(pos):
				highlighted = true
		button.modulate = Color("#8cbf84") if highlighted else (Color("#f1cc75") if selected.has(pos) else (Color("#f7e17e") if pos == hint_cell else Color.WHITE))
	var labels: Array[String] = []
	for word in WORDS:
		labels.append("✓ "+word if found.has(word) else word)
	word_label.text = "   •   ".join(labels)
	if found.size() == WORDS.size():
		status.text = "Parabéns! Desafio das Roman Walls concluído."
	elif status.text.is_empty():
		status.text = "%d / %d palavras" % [found.size(),WORDS.size()]

func _save_progress() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value(CHALLENGE,"grid",board)
	cfg.set_value(CHALLENGE,"placements",placements)
	cfg.set_value(CHALLENGE,"found",found)
	var err := cfg.save(SAVE_PATH)
	if err != OK:
		push_warning("Não foi possível salvar caça-palavras: %s" % err)

func _load_progress() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	board = cfg.get_value(CHALLENGE,"grid",[])
	placements = cfg.get_value(CHALLENGE,"placements",{})
	found.clear()
	for word in cfg.get_value(CHALLENGE,"found",[]):
		if WORDS.has(str(word)):
			found.append(str(word))
	if board.size() != 8 or placements.size() != WORDS.size():
		board = []
		placements = {}
		found.clear()
