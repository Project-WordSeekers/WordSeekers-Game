extends Control

const WORLD_MAP_SCENE: String = "res://scenes/world/world_map.tscn"

@onready var male_panel: Panel = $Center/VBox/Options/MalePanel
@onready var female_panel: Panel = $Center/VBox/Options/FemalePanel
@onready var male_marker: Label = $Center/VBox/Options/MalePanel/Content/Marker
@onready var female_marker: Label = $Center/VBox/Options/FemalePanel/Content/Marker
@onready var instruction: Label = $Center/VBox/Instruction

var selected_appearance: int = GameState.APPEARANCE_MALE
var confirmed: bool = false

func _ready() -> void:
	update_selection()

func _unhandled_input(event: InputEvent) -> void:
	if confirmed:
		return

	if event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right"):
		selected_appearance = (
			GameState.APPEARANCE_FEMALE
			if selected_appearance == GameState.APPEARANCE_MALE
			else GameState.APPEARANCE_MALE
		)
		update_selection()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("interact"):
		confirmed = true
		GameState.set_player_appearance(selected_appearance)
		instruction.text = "Aparência escolhida!"
		SceneTransition.change_scene_to_file(WORLD_MAP_SCENE)
		get_viewport().set_input_as_handled()

func update_selection() -> void:
	var male_selected: bool = selected_appearance == GameState.APPEARANCE_MALE
	male_panel.modulate = Color(1.0, 1.0, 1.0, 1.0) if male_selected else Color(0.45, 0.45, 0.45, 1.0)
	female_panel.modulate = Color(1.0, 1.0, 1.0, 1.0) if not male_selected else Color(0.45, 0.45, 0.45, 1.0)
	male_marker.visible = male_selected
	female_marker.visible = not male_selected
