extends Node2D

@export var start_point: Area2D
@export var speed: float = 180.0
@export var animation_fps: float = 8.0

@onready var sprite: Sprite2D = $Sprite2D

var current_point
var target_point
var moving := false

var animation_row := 0
var animation_frame := 0
var animation_time := 0.0


func _ready() -> void:
	if start_point != null:
		current_point = start_point
		global_position = current_point.global_position

	set_idle_frame()


func _process(delta: float) -> void:
	if moving:
		move_between_points(delta)
	else:
		check_input()


func check_input() -> void:
	if current_point == null:
		return

	if Input.is_action_just_pressed("ui_up") and current_point.up != null:
		start_move(current_point.up, 1)

	elif Input.is_action_just_pressed("ui_down") and current_point.down != null:
		start_move(current_point.down, 0)

	elif Input.is_action_just_pressed("ui_left") and current_point.left != null:
		start_move(current_point.left, 2)

	elif Input.is_action_just_pressed("ui_right") and current_point.right != null:
		start_move(current_point.right, 3)


func start_move(point, row: int) -> void:
	target_point = point
	animation_row = row
	animation_frame = 0
	animation_time = 0.0
	moving = true


func move_between_points(delta: float) -> void:
	global_position = global_position.move_toward(
		target_point.global_position,
		speed * delta
	)

	animate_walk(delta)

	if global_position.distance_to(target_point.global_position) <= 1.0:
		global_position = target_point.global_position
		current_point = target_point
		target_point = null
		moving = false
		set_idle_frame()


func animate_walk(delta: float) -> void:
	animation_time += delta

	if animation_time >= 1.0 / animation_fps:
		animation_time = 0.0
		animation_frame = (animation_frame + 1) % 4
		sprite.frame_coords = Vector2i(animation_frame, animation_row)


func set_idle_frame() -> void:
	animation_frame = 0
	sprite.frame_coords = Vector2i(0, animation_row)
