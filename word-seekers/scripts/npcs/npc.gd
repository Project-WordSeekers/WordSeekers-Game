extends StaticBody3D

@export var grid_tile := Vector2i(5, 5)
@export var tile_spacing := 2.0
@export var greeting := "oi"

@onready var speech: Label3D = $Speech
var player_was_adjacent := false

func _ready() -> void:
	global_position = Vector3(grid_tile.x * tile_spacing, 0.75, grid_tile.y * tile_spacing)
	speech.visible = false

func on_player_tile_changed(player_tile: Vector2i) -> void:
	# Considera os 8 quadrados ao redor como adjacentes.
	var delta := player_tile - grid_tile
	var adjacent := max(abs(delta.x), abs(delta.y)) == 1

	if adjacent and not player_was_adjacent:
		say(greeting)

	player_was_adjacent = adjacent

func say(text: String) -> void:
	speech.text = text
	speech.visible = true
	var tween := create_tween()
	tween.tween_interval(1.5)
	tween.tween_callback(func(): speech.visible = false)
