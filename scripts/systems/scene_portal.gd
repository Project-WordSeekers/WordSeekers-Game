extends Area2D

@export_file("*.tscn") var target_scene_path: String
@export var target_spawn_name: StringName = &""
@export var temple_entrance: bool = false
@export var temple_exit: bool = false
@export var temple_return_spawn: StringName = &"FromTemple"

var _transition_started: bool = false
var _armed: bool = false
var _ignored_on_arrival: Array[Node2D] = []

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	for frame in 3:
		await get_tree().physics_frame
		if not is_inside_tree():
			return
	for body in get_overlapping_bodies():
		_ignored_on_arrival.append(body)
	_armed = true

func _on_body_exited(body: Node2D) -> void:
	_ignored_on_arrival.erase(body)

func _on_body_entered(body: Node2D) -> void:
	if _transition_started or not _armed or body in _ignored_on_arrival or not body.is_in_group("player"):
		return

	if not can_cross():
		return

	var destination: String = target_scene_path
	var spawn_name: StringName = target_spawn_name
	if temple_exit:
		destination = GameState.temple_return_scene
		spawn_name = GameState.temple_return_spawn
		if destination.is_empty():
			push_warning("Templo sem origem: retornando ao mapa-múndi.")
			destination = "res://scenes/world/world_map.tscn"
			spawn_name = &""
	elif temple_entrance:
		var city_scene: String = get_tree().current_scene.scene_file_path
		if city_scene.is_empty():
			push_warning("Entrada de templo sem cena de cidade: %s" % get_path())
			return
		GameState.register_temple_origin(city_scene, temple_return_spawn)

	if destination.is_empty():
		push_warning("ScenePortal sem cena de destino: %s" % get_path())
		return
	if not ResourceLoader.exists(destination):
		push_error("ScenePortal: cena inexistente: %s" % destination)
		return

	_transition_started = true
	GameState.pending_spawn_name = spawn_name
	SceneTransition.change_scene_to_file(destination)

func can_cross() -> bool:
	return true
