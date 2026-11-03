extends Node2D

const CASTELO := "res://scenes/locations/nottingham/castle.tscn"
const CAVERNAS := "res://scenes/locations/nottingham/caves.tscn"
@onready var player: CharacterBody2D = get_parent().get_node("Player")
var aviso: Label

func _ready() -> void:
    aviso = Label.new()
    aviso.add_theme_font_size_override("font_size", 16)
    aviso.add_theme_color_override("font_color", Color(1, 0.94, 0.68))
    aviso.z_index = 20
    add_child(aviso)

func _process(_delta: float) -> void:
    var pos := player.global_position
    var castle := pos.distance_to(Vector2(391, 341)) < 65.0
    var caves := pos.distance_to(Vector2(1302, 831)) < 65.0
    aviso.visible = castle or caves
    if castle:
        aviso.text = "[E] Entrar no Nottingham Castle"
    elif caves:
        aviso.text = "[E] Entrar na City of Caves"
    aviso.global_position = pos + Vector2(-125, -57)
    if Input.is_action_just_pressed("interact"):
        if castle:
            SceneTransition.change_scene_to_file(CASTELO)
        elif caves:
            SceneTransition.change_scene_to_file(CAVERNAS)
