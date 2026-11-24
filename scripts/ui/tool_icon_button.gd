extends Button
## Mantém ícone e legenda em áreas distintas dentro do botão clicável.

var caption := Label.new()

func _init(texture: Texture2D) -> void:
	custom_minimum_size = Vector2(148, 70)
	var stack := VBoxContainer.new()
	add_child(stack)
	stack.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	stack.alignment = BoxContainer.ALIGNMENT_CENTER
	stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_theme_constant_override("separation", 4)

	var picture := TextureRect.new()
	picture.texture = texture
	picture.custom_minimum_size = Vector2(32, 32)
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_child(picture)

	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	caption.add_theme_font_size_override("font_size", 14)
	stack.add_child(caption)
