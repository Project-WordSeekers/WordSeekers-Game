extends CanvasLayer

@onready var hud_root: Control = $HUD
@onready var hp_bar: ProgressBar = $HUD/Panel/Margin/VBox/HPBar
@onready var hp_label: Label = $HUD/Panel/Margin/VBox/HPLabel
@onready var dictionary_row: HBoxContainer = $HUD/Panel/Margin/VBox/DictionaryRow
@onready var dictionary_bar: ProgressBar = $HUD/Panel/Margin/VBox/DictionaryRow/DictionaryInfo/DictionaryBar
@onready var dictionary_label: Label = $HUD/Panel/Margin/VBox/DictionaryRow/DictionaryInfo/DictionaryLabel
@onready var help_overlay: Control = $HUD/HelpOverlay
@onready var inventory_overlay: Control = $HUD/InventoryOverlay
@onready var inventory_header: HBoxContainer = $HUD/InventoryOverlay/Panel/Margin/VBox/ItemHeader
@onready var inventory_content: Label = $HUD/InventoryOverlay/Panel/Margin/VBox/Content

var _last_scene_path: String = ""

func _ready() -> void:
	layer = 90
	GameState.health_changed.connect(_on_health_changed)
	GameState.dictionary_changed.connect(_on_dictionary_changed)
	_on_health_changed(GameState.player_health, GameState.MAX_HEALTH)
	_on_dictionary_changed(
		GameState.dictionary_owned,
		GameState.dictionary_uses,
		GameState.DICTIONARY_MAX_USES
	)
	help_overlay.hide()
	inventory_overlay.hide()
	_update_visibility_for_scene()

func _process(_delta: float) -> void:
	var current_scene: Node = get_tree().current_scene
	var scene_path: String = ""
	if current_scene != null:
		scene_path = current_scene.scene_file_path
	if scene_path != _last_scene_path:
		_last_scene_path = scene_path
		_update_visibility_for_scene()

	_update_dictionary_quiz_bar()

func _unhandled_input(event: InputEvent) -> void:
	if not hud_root.visible:
		return

	if event.is_action_pressed("help"):
		_toggle_help()
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("inventory"):
		_toggle_inventory()
		get_viewport().set_input_as_handled()
		return

	if is_modal_open():
		if (
			event.is_action_pressed("ui_up")
			or event.is_action_pressed("ui_down")
			or event.is_action_pressed("ui_left")
			or event.is_action_pressed("ui_right")
			or event.is_action_pressed("interact")
			or event.is_action_pressed("translate")
		):
			get_viewport().set_input_as_handled()

func is_modal_open() -> bool:
	return help_overlay.visible or inventory_overlay.visible

func _toggle_help() -> void:
	var should_open: bool = not help_overlay.visible
	inventory_overlay.hide()
	help_overlay.visible = should_open

func _toggle_inventory() -> void:
	var should_open: bool = not inventory_overlay.visible
	help_overlay.hide()
	inventory_overlay.visible = should_open
	if should_open:
		_refresh_inventory_text()

func _refresh_inventory_text() -> void:
	inventory_header.visible = GameState.dictionary_owned
	if not GameState.dictionary_owned:
		inventory_content.text = "Mochila vazia."
		return

	inventory_content.text = "%s\n\n%s\n\nUsos durante quizzes: %d/%d\nPressione T (Translate) durante um quiz para usar." % [
		GameState.DICTIONARY_NAME,
		GameState.DICTIONARY_DESCRIPTION,
		GameState.dictionary_uses,
		GameState.DICTIONARY_MAX_USES
	]

func _on_health_changed(current_hp: int, max_hp: int) -> void:
	hp_bar.max_value = max_hp
	hp_bar.value = current_hp
	hp_label.text = "HP %d / %d" % [current_hp, max_hp]

func _on_dictionary_changed(owned: bool, uses: int, max_uses: int) -> void:
	dictionary_bar.max_value = max_uses
	dictionary_bar.value = uses
	dictionary_label.text = "Dicionário %d / %d" % [uses, max_uses]
	if inventory_overlay.visible:
		_refresh_inventory_text()
	if not owned:
		dictionary_row.hide()

func _update_dictionary_quiz_bar() -> void:
	var dialogue_ui: Node = get_node_or_null("/root/DialogueUI")
	var quiz_active: bool = false
	if dialogue_ui != null and dialogue_ui.has_method("is_quiz_active"):
		quiz_active = bool(dialogue_ui.call("is_quiz_active"))
	dictionary_row.visible = GameState.dictionary_owned and quiz_active

func _update_visibility_for_scene() -> void:
	var current_scene: Node = get_tree().current_scene
	if current_scene == null:
		hud_root.visible = false
		return

	var scene_path: String = current_scene.scene_file_path
	var is_non_gameplay: bool = (
		scene_path == "res://scenes/ui/intro/intro.tscn"
		or scene_path == "res://scenes/ui/character_selection/character_selection.tscn"
	)
	hud_root.visible = not is_non_gameplay
	if is_non_gameplay:
		help_overlay.hide()
		inventory_overlay.hide()
