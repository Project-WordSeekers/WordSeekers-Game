extends CharacterBody3D

signal tile_changed(tile: Vector2i)

@export var grid_size := Vector2i(10, 10)
@export var tile_spacing := 2.0
@export var move_duration := 0.16
@export var start_tile := Vector2i(1, 1)

var current_tile: Vector2i
var blocked_tiles: Array[Vector2i] = []
var moving := false

func _ready() -> void:
	current_tile = start_tile
	global_position = _tile_to_world(current_tile)
	tile_changed.emit(current_tile)

func _unhandled_input(event: InputEvent) -> void:
	if moving:
		return

	if not event is InputEventKey or not event.pressed or event.echo:
		return

	var direction := Vector2i.ZERO
	match event.physical_keycode:
		KEY_W, KEY_UP:
			direction = Vector2i(0, -1)
		KEY_S, KEY_DOWN:
			direction = Vector2i(0, 1)
		KEY_A, KEY_LEFT:
			direction = Vector2i(-1, 0)
		KEY_D, KEY_RIGHT:
			direction = Vector2i(1, 0)

	if direction != Vector2i.ZERO:
		try_move(direction)

func try_move(direction: Vector2i) -> void:
	var target := current_tile + direction
	if not _is_inside_grid(target) or target in blocked_tiles:
		return

	moving = true
	current_tile = target
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "global_position", _tile_to_world(current_tile), move_duration)
	await tween.finished
	moving = false
	tile_changed.emit(current_tile)

func _is_inside_grid(tile: Vector2i) -> bool:
	return tile.x >= 0 and tile.y >= 0 and tile.x < grid_size.x and tile.y < grid_size.y

func _tile_to_world(tile: Vector2i) -> Vector3:
	return Vector3(tile.x * tile_spacing, 0.7, tile.y * tile_spacing)
