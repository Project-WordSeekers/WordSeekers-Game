extends Camera2D

## Percentual aproximado da area da cena que deve ficar visivel na tela.
## 0.30 = cerca de 30% da area total.
@export_range(0.10, 1.0, 0.05) var visible_scene_fraction: float = 0.30
@export var min_zoom: float = 0.75
@export var max_zoom: float = 4.0
@export var use_scene_limits: bool = true
@export var smoothing_speed: float = 6.0

var _scene_bounds := Rect2()

func _ready() -> void:
	position_smoothing_enabled = true
	position_smoothing_speed = smoothing_speed
	make_current()
	configure_for_current_scene()

	var viewport := get_viewport()
	if viewport != null and not viewport.size_changed.is_connected(_on_viewport_size_changed):
		viewport.size_changed.connect(_on_viewport_size_changed)

func _on_viewport_size_changed() -> void:
	configure_for_current_scene()

func configure_for_current_scene() -> void:
	_scene_bounds = _find_largest_scene_visual_bounds()
	if _scene_bounds.size.x <= 0.0 or _scene_bounds.size.y <= 0.0:
		return

	_apply_zoom_for_fraction(_scene_bounds)
	if use_scene_limits:
		_apply_limits(_scene_bounds)

func _apply_zoom_for_fraction(bounds: Rect2) -> void:
	var viewport_size := get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return

	var scene_area := bounds.size.x * bounds.size.y
	var viewport_area := viewport_size.x * viewport_size.y
	var desired_world_area := scene_area * visible_scene_fraction
	if desired_world_area <= 0.0:
		return

	# Como Camera2D usa zoom uniforme, a area visivel varia com 1 / zoom^2.
	var calculated_zoom := sqrt(viewport_area / desired_world_area)
	calculated_zoom = clampf(calculated_zoom, min_zoom, max_zoom)
	zoom = Vector2(calculated_zoom, calculated_zoom)

func _apply_limits(bounds: Rect2) -> void:
	limit_left = floori(bounds.position.x)
	limit_top = floori(bounds.position.y)
	limit_right = ceili(bounds.end.x)
	limit_bottom = ceili(bounds.end.y)
	limit_smoothed = true

func _find_largest_scene_visual_bounds() -> Rect2:
	var root := get_tree().current_scene
	if root == null:
		return Rect2()

	var best_bounds := Rect2()
	var best_area := 0.0
	var camera_owner := get_parent()
	var stack: Array[Node] = [root]

	while not stack.is_empty():
		var node: Node = stack.pop_back() as Node
		if node == null:
			continue

		# Ignora o proprio player e seus filhos para que o sprite do personagem
		# nunca seja confundido com os limites do mapa.
		var belongs_to_player: bool = camera_owner != null and (node == camera_owner or camera_owner.is_ancestor_of(node))
		if not belongs_to_player and node is Sprite2D:
			var sprite := node as Sprite2D
			var bounds := _sprite_global_bounds(sprite)
			var area := bounds.size.x * bounds.size.y
			if area > best_area:
				best_area = area
				best_bounds = bounds

		for child in node.get_children():
			var child_node: Node = child as Node
			if child_node != null:
				stack.push_back(child_node)

	return best_bounds

func _sprite_global_bounds(sprite: Sprite2D) -> Rect2:
	if sprite.texture == null:
		return Rect2()

	var local_size := sprite.texture.get_size()
	if sprite.region_enabled:
		local_size = sprite.region_rect.size

	var scale_abs := Vector2(absf(sprite.global_scale.x), absf(sprite.global_scale.y))
	var size := local_size * scale_abs
	var top_left := sprite.global_position

	if sprite.centered:
		top_left -= size * 0.5

	# Offset do Sprite2D tambem participa da area visual.
	top_left += sprite.offset * scale_abs
	return Rect2(top_left, size)
