extends Node3D

const GRID_WIDTH := 10
const GRID_HEIGHT := 10
const TILE_SPACING := 2.0

@onready var player = $Player
@onready var npc = $NPC

func _ready() -> void:
	_build_floor()
	player.grid_size = Vector2i(GRID_WIDTH, GRID_HEIGHT)
	player.tile_spacing = TILE_SPACING
	player.blocked_tiles = [npc.grid_tile]
	player.tile_changed.connect(npc.on_player_tile_changed)
	# O sinal inicial do Player pode ocorrer antes da conexão acima.
	npc.on_player_tile_changed(player.current_tile)

func _build_floor() -> void:
	var floor_root := $Floor
	for z in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			var tile := MeshInstance3D.new()
			var mesh := BoxMesh.new()
			mesh.size = Vector3(1.92, 0.12, 1.92)
			tile.mesh = mesh
			tile.position = Vector3(x * TILE_SPACING, 0.0, z * TILE_SPACING)

			var material := StandardMaterial3D.new()
			var light_square := (x + z) % 2 == 0
			material.albedo_color = Color("#6f6a58") if light_square else Color("#5d594a")
			material.roughness = 1.0
			tile.material_override = material
			floor_root.add_child(tile)
