extends Node2D

const CHARACTER_TEXTURES: Array[Texture2D] = [
	preload("res://assets/characters/player/overworld/player_walk.png"),
	preload("res://assets/characters/player/female/player_female.png"),
	preload("res://assets/characters/player/extra/garota_azul.png"),
	preload("res://assets/characters/player/extra/garoto_ruivo.png")
]

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
var moving: bool = false
# Evita que o mesmo E feche e reabra imediatamente o aviso.
var _wait_interact_release: bool = false

const RANDOM_BATTLE_SCENE: String = "res://scenes/minigames/battle.tscn"
var encounter_rng: RandomNumberGenerator = RandomNumberGenerator.new()

var animation_row: int = 0
var animation_frame: int = 0
var animation_time: float = 0.0
var walk_frame_count: int = 4

func _ready() -> void:
	encounter_rng.randomize()
	ensure_input_actions()
	apply_selected_appearance()
	restore_world_position()
	update_city_name()
	set_idle_frame()
	update_direction_indicators()

func apply_selected_appearance() -> void:
	sprite.texture = CHARACTER_TEXTURES[clampi(GameState.player_appearance, 0, 3)]
	sprite.hframes = 3
	sprite.vframes = 4
	sprite.scale = Vector2(0.34, 0.34)
	walk_frame_count = 3
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

var endgame_cinematic := false

func _begin_endgame() -> void:
	endgame_cinematic = true
	var viewport := get_viewport()
	var original := viewport.canvas_transform
	for frame in range(18):
		var shake := original
		shake.origin += Vector2(randf_range(-9, 9), randf_range(-7, 7)) * (1.0 - frame / 18.0)
		viewport.canvas_transform = shake
		await get_tree().create_timer(0.045).timeout
	viewport.canvas_transform = original
	SceneTransition.change_scene_to_file("res://scenes/minigames/vocabullary_eater.tscn")

func _process(delta: float) -> void:
	if endgame_cinematic:
		return
	if not moving and not GameHUD.is_modal_open() and not DialogueUI.is_open() and GameState.endgame_ready():
		_begin_endgame()
		return
	if _wait_interact_release and not Input.is_action_pressed("interact"):
		_wait_interact_release = false
	if moving:
		move_between_points(delta)
	else:
		check_input()

func check_input() -> void:
	if GameHUD.is_modal_open() or DialogueUI.is_open():
		return
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
	elif Input.is_action_just_pressed("interact") and not _wait_interact_release:
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
		update_city_name()
		target_point = null
		moving = false
		set_idle_frame()
		update_direction_indicators()
		# Uma rolagem por viagem: 5%, 10%, 15%, 20%... ate ocorrer batalha.
		# O ponto de chegada ja esta salvo, permitindo retomar a viagem apos vencer.
		var battle_started: bool = GameState.has_unused_quizzes() and encounter_rng.randf() < GameState.get_next_battle_chance()
		GameState.register_travel_battle_roll(battle_started)
		if battle_started:
			GameState.world_map_point_name = current_point.name
			GameState.random_encounter_active = true
			SceneTransition.change_scene_to_file(RANDOM_BATTLE_SCENE)

func animate_walk(delta: float) -> void:
	animation_time += delta
	if animation_time >= 1.0 / animation_fps:
		animation_time = 0.0
		animation_frame = (animation_frame + 1) % walk_frame_count
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
	if current_point == null:
		return
	var city_name: String = String(current_point.name)
	# Verificar o nivel antes da existencia da cena, para todos os MapPoints.
	if not GameState.can_enter_city(city_name):
		_wait_interact_release = true
		DialogueUI.show_dialogue(
			"Cidade bloqueada",
			"Cidade bloqueada, explore outras cidades para liberar",
			Callable(self, "_on_map_warning_closed")
		)
		return
	if current_point.destination_scene == null:
		_wait_interact_release = true
		DialogueUI.show_dialogue(
			"Mapa-múndi",
			"Esta cidade ainda não está disponível.",
			Callable(self, "_on_map_warning_closed")
		)
		return
	GameState.world_map_point_name = current_point.name
	SceneTransition.change_scene_to_packed(current_point.destination_scene)

# O E usado para fechar o aviso nunca deve reabrir o mesmo aviso no mesmo frame.
# Volta a aceitar interacao somente depois que o jogador soltar a tecla.
func _on_map_warning_closed() -> void:
	_wait_interact_release = true

func ensure_input_actions() -> void:
	if InputMap.has_action("interact"):
		return

	InputMap.add_action("interact")
	var interact_key: InputEventKey = InputEventKey.new()
	interact_key.physical_keycode = KEY_E
	InputMap.action_add_event("interact", interact_key)

func restore_world_position() -> void:
	var points: Node = get_parent().get_node_or_null("Points")
	var saved_point: Area2D = null

	if points != null:
		saved_point = points.get_node_or_null(String(GameState.world_map_point_name)) as Area2D

	current_point = saved_point if saved_point != null else start_point
	if current_point != null:
		global_position = current_point.global_position

func update_city_name() -> void:
	var panel := get_parent().get_node_or_null("CityNameHUD/CityNamePanel") as PanelContainer
	if panel == null:
		return
	panel.visible = current_point != null
	if current_point == null:
		return

	var city := String(current_point.name)
	# Colchester é o tutorial e usa a indicação visual do nível fácil.
	var level := int(GameState.CITY_LEVELS.get(city, 1))
	var level_names := ["Fácil", "Médio", "Difícil"]
	var backgrounds := [Color("#225b36"), Color("#f6ce63"), Color("#8b2937")]
	var text_color := Color("#2b210b") if level == 2 else Color.WHITE

	var city_label := panel.get_node("Labels/CityNameLabel") as Label
	var level_label := panel.get_node("Labels/CityLevelLabel") as Label
	var style := panel.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	style.bg_color = backgrounds[level - 1]
	panel.add_theme_stylebox_override("panel", style)
	city_label.text = city.replace("_", " ")
	level_label.text = "Nível: " + level_names[level - 1]
	city_label.add_theme_color_override("font_color", text_color)
	level_label.add_theme_color_override("font_color", text_color)
