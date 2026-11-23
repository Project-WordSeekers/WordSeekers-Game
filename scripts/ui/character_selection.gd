extends Control

const WORLD_MAP_SCENE: String = "res://scenes/world/world_map.tscn"

@onready var instruction: Label = $Center/VBox/Instruction
@onready var panels: Array[Node] = [
 $Center/VBox/Options/Option0,
 $Center/VBox/Options/Option1,
 $Center/VBox/Options/Option2,
 $Center/VBox/Options/Option3
]

var selected_appearance: int = GameState.APPEARANCE_MALE
var confirmed: bool = false

func _ready() -> void:
 update_selection()

func _unhandled_input(event: InputEvent) -> void:
 if confirmed:
  return
 if event.is_action_pressed("ui_left"):
  selected_appearance = posmod(selected_appearance - 1, 4)
  update_selection()
  get_viewport().set_input_as_handled()
 elif event.is_action_pressed("ui_right"):
  selected_appearance = (selected_appearance + 1) % 4
  update_selection()
  get_viewport().set_input_as_handled()
 elif event.is_action_pressed("interact"):
  confirmed = true
  GameState.set_player_appearance(selected_appearance)
  GameState.world_map_point_name = &"Point01"
  GameState.restore_full_health()
  GameState.reset_inventory()
  instruction.text = "Personagem escolhido!"
  SceneTransition.change_scene_to_file(WORLD_MAP_SCENE)
  get_viewport().set_input_as_handled()

func update_selection() -> void:
 for i in range(panels.size()):
  var panel: Panel = panels[i] as Panel
  var active: bool = i == selected_appearance
  panel.modulate = Color.WHITE if active else Color(0.45, 0.45, 0.45, 1.0)
  var marker: Label = panel.get_node("Content/Marker") as Label
  marker.visible = active
