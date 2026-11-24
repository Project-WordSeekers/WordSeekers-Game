extends Control

const THANK_YOU_MUSIC := preload("res://assets/audio/music/ultima_luz_do_reino.ogg")
const TEAM_PORTRAITS := preload("res://assets/ui/credits/programadores.jpg")
const TEAM := [
	"Deivis Aldren Eberhardt",
	"Joana de Souza Fagundes",
	"Guilherme Kaua de Oliveira Antunes",
	"Jady de Paula Honorato",
	"Murilo Xavier Lopes",
]
const PORTRAIT_LEFT := [72, 365, 659, 953, 1247]
const GOLD := Color("#efc97d")
const PAPER := Color("#f5ead6")
const THANK_YOU_SECONDS := 30.0

func _ready() -> void:
	var background := ColorRect.new()
	background.color = Color("#171326")
	add_child(background)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var roll := CenterContainer.new()
	add_child(roll)
	roll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var credits := VBoxContainer.new()
	credits.add_theme_constant_override("separation", 22)
	roll.add_child(credits)
	credits.add_child(_label("WordSeekers", 58, GOLD))
	credits.add_child(_label("Desenvolvimento", 24, GOLD))
	for member in TEAM:
		credits.add_child(_label(member, 30, PAPER))

	_position_roll(0.0, roll)
	var scroll := create_tween()
	scroll.tween_method(_position_roll.bind(roll), 0.0, 1.0, 12.0)
	await scroll.finished
	roll.queue_free()
	_show_thanks()
	var music := AudioStreamPlayer.new()
	music.stream = THANK_YOU_MUSIC
	music.volume_db = -6.0
	add_child(music)
	music.play()
	await get_tree().create_timer(THANK_YOU_SECONDS).timeout
	SceneTransition.change_scene_to_file("res://scenes/world/world_map.tscn")

func _position_roll(progress: float, roll: CenterContainer) -> void:
	var travel := size.y + 60.0
	var offset := lerpf(travel, -travel, progress)
	roll.offset_top = offset
	roll.offset_bottom = offset

func _show_thanks() -> void:
	var center := CenterContainer.new()
	add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 24)
	center.add_child(content)
	content.add_child(_label("Obrigado por jogar WordSeekers!", 48, GOLD))

	var message := _label(
		"Criamos este jogo para que aprender inglês fosse uma aventura. Obrigado por conversar com os habitantes, encarar os desafios e tentar de novo quando uma palavra parecia difícil. A jornada pelo reino termina aqui, mas o inglês que você aprendeu vai com você.",
		24, PAPER
	)
	message.custom_minimum_size.x = 820
	message.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(message)

	var portraits := HBoxContainer.new()
	portraits.alignment = BoxContainer.ALIGNMENT_CENTER
	portraits.add_theme_constant_override("separation", 16)
	content.add_child(portraits)
	for index in TEAM.size():
		var card := VBoxContainer.new()
		card.add_theme_constant_override("separation", 8)
		portraits.add_child(card)
		var portrait := TextureRect.new()
		var crop := AtlasTexture.new()
		crop.atlas = TEAM_PORTRAITS
		crop.region = Rect2(PORTRAIT_LEFT[index], 43, 273, 210)
		portrait.texture = crop
		portrait.custom_minimum_size = Vector2(168, 129)
		portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		card.add_child(portrait)
		var caption := _label(TEAM[index], 19, PAPER)
		caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		card.add_child(caption)

	content.add_child(_label("Com carinho, a equipe WordSeekers", 23, GOLD))
	content.modulate.a = 0.0
	create_tween().tween_property(content, "modulate:a", 1.0, 0.6)

func _label(caption: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = caption
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label
