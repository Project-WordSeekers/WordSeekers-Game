extends Node2D

@export var start_point: Area2D
@export var speed: float = 180.0
@export var animation_fps: float = 8.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var arrow_up: Sprite2D = $DirectionIndicators/ArrowUp
@onready var arrow_down: Sprite2D = $DirectionIndicators/ArrowDown
@onready var arrow_left: Sprite2D = $DirectionIndicators/ArrowLeft
@onready var arrow_right: Sprite2D = $DirectionIndicators/ArrowRight

var current_point: Area2D
var target_point: Area2D
var moving := false

var animation_row := 0
var animation_frame := 0
var animation_time := 0.0

func _ready() -> void:
	ensure_input_actions()
	restore_world_position()
	set_idle_frame()
	update_direction_indicators()

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
	elif Input.is_action_just_pressed("interact"):
		try_enter_location()

func start_move(point: Area2D, row: int) -> void:
	hide_direction_indicators()
	target_point = point
	animation_row = row
	animation_frame = 0
	animation_time = 0.0
	moving = true

func move_between_points(delta: float) -> void:
	global_position = global_position.move_toward(target_point.global_position, speed * delta)
	animate_walk(delta)

	if global_position.distance_to(target_point.global_position) <= 1.0:
		global_position = target_point.global_position
		current_point = target_point
		target_point = null
		moving = false
		set_idle_frame()
		update_direction_indicators()

func animate_walk(delta: float) -> void:
	animation_time += delta
	if animation_time >= 1.0 / animation_fps:
		animation_time = 0.0
		animation_frame = (animation_frame + 1) % 4
		sprite.frame_coords = Vector2i(animation_frame, animation_row)

func set_idle_frame() -> void:
	animation_frame = 0
	sprite.frame_coords = Vector2i(0, animation_row)

func update_direction_indicators() -> void:
	if current_point == null:
		hide_direction_indicators()
		return

	arrow_up.visible = current_point.up != null
	arrow_down.visible = current_point.down != null
	arrow_left.visible = current_point.left != null
	arrow_right.visible = current_point.right != null

func hide_direction_indicators() -> void:
	arrow_up.visible = false
	arrow_down.visible = false
	arrow_left.visible = false
	arrow_right.visible = false

func can_enter_current_point() -> bool:
	return current_point != null and current_point.destination_scene != null

func try_enter_location() -> void:
	if not can_enter_current_point():
		return

	GameState.world_map_point_name = current_point.name
	SceneTransition.change_scene_to_packed(current_point.destination_scene)

func ensure_input_actions() -> void:
	if InputMap.has_action("interact"):
		return

	InputMap.add_action("interact")
	var interact_key := InputEventKey.new()
	interact_key.physical_keycode = KEY_E
	InputMap.action_add_event("interact", interact_key)

func restore_world_position() -> void:
	var points := get_parent().get_node_or_null("Points")
	var saved_point: Area2D = null

	if points != null:
		saved_point = points.get_node_or_null(String(GameState.world_map_point_name)) as Area2D

	current_point = saved_point if saved_point != null else start_point
	if current_point != null:
		global_position = current_point.global_position
