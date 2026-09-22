extends Node2D

@export var player_path: NodePath = NodePath("Player")
@export var spawn_points_path: NodePath = NodePath("SpawnPoints")

func _ready() -> void:
	if GameState.pending_spawn_name == &"":
		return

	var player: Node2D = get_node_or_null(player_path) as Node2D
	var spawn_points: Node = get_node_or_null(spawn_points_path)
	if player == null or spawn_points == null:
		GameState.pending_spawn_name = &""
		return

	var marker: Marker2D = spawn_points.get_node_or_null(String(GameState.pending_spawn_name)) as Marker2D
	if marker != null:
		player.global_position = marker.global_position

	GameState.pending_spawn_name = &""
