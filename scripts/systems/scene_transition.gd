extends CanvasLayer

@export var fade_duration: float = 0.35

var _fade_rect: ColorRect
var _transitioning := false

func _ready() -> void:
	layer = 100
	_fade_rect = ColorRect.new()
	_fade_rect.name = "Fade"
	_fade_rect.color = Color.BLACK
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_fade_rect)
	call_deferred("fade_in")

func change_scene_to_packed(scene: PackedScene) -> void:
	if scene == null or _transitioning:
		return

	_transitioning = true
	await fade_out()
	var error := get_tree().change_scene_to_packed(scene)
	if error != OK:
		push_error("Não foi possível trocar de cena. Código: %s" % error)
		await fade_in()
		_transitioning = false
		return

	await get_tree().process_frame
	await fade_in()
	_transitioning = false

func change_scene_to_file(scene_path: String) -> void:
	if scene_path.is_empty() or _transitioning:
		return

	_transitioning = true
	await fade_out()
	var error := get_tree().change_scene_to_file(scene_path)
	if error != OK:
		push_error("Não foi possível carregar: %s" % scene_path)
		await fade_in()
		_transitioning = false
		return

	await get_tree().process_frame
	await fade_in()
	_transitioning = false

func fade_out() -> void:
	_fade_rect.visible = true
	var tween := create_tween()
	tween.tween_property(_fade_rect, "color:a", 1.0, fade_duration)
	await tween.finished

func fade_in() -> void:
	if _fade_rect == null:
		return

	_fade_rect.visible = true
	var tween := create_tween()
	tween.tween_property(_fade_rect, "color:a", 0.0, fade_duration)
	await tween.finished
	_fade_rect.visible = false
