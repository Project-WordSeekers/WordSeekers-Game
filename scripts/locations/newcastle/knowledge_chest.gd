extends Area2D
# Baú de conhecimento: abre um pergaminho estilizado e a tradução na caixa de diálogo do jogo.
const MESSAGE: String = "The most valuable treasure of all is knowledge! Keep your studies."
const TRANSLATION: String = "O tesouro mais valioso de todos é o conhecimento! Continue seus estudos."
var _near: bool = false
var _parchment: CanvasLayer

func _ready() -> void:
    body_entered.connect(_on_enter)
    body_exited.connect(_on_exit)
    input_pickable = true

func _on_enter(body: Node2D) -> void:
    if body.is_in_group("player"):
        _near = true
        $Prompt.show()

func _on_exit(body: Node2D) -> void:
    if body.is_in_group("player"):
        _near = false
        $Prompt.hide()

func _unhandled_input(event: InputEvent) -> void:
    if _near and event.is_action_pressed("interact") and not DialogueUI.is_open():
        _open()
        get_viewport().set_input_as_handled()

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and _near and not DialogueUI.is_open():
        _open()
        get_viewport().set_input_as_handled()

func _open() -> void:
    if is_instance_valid(_parchment):
        return
    $Prompt.hide()
    _parchment = CanvasLayer.new()
    _parchment.layer = 90
    _parchment.name = "KnowledgeParchment"
    get_tree().current_scene.add_child(_parchment)

    var panel := PanelContainer.new()
    panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
    panel.anchor_left = 0.5
    panel.anchor_right = 0.5
    panel.offset_left = -385
    panel.offset_right = 385
    panel.offset_top = 90
    panel.offset_bottom = 345
    panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var paper := StyleBoxFlat.new()
    paper.bg_color = Color("#ead4a2")
    paper.border_color = Color("#865027")
    paper.set_border_width_all(8)
    paper.set_corner_radius_all(18)
    paper.shadow_color = Color(0, 0, 0, 0.5)
    paper.shadow_size = 12
    panel.add_theme_stylebox_override("panel", paper)
    _parchment.add_child(panel)

    var margin := MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 38)
    margin.add_theme_constant_override("margin_right", 38)
    margin.add_theme_constant_override("margin_top", 30)
    margin.add_theme_constant_override("margin_bottom", 30)
    panel.add_child(margin)
    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation", 20)
    margin.add_child(column)

    var heading := Label.new()
    heading.text = "✦  A Treasure of Knowledge  ✦"
    heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    heading.add_theme_color_override("font_color", Color("#78441f"))
    heading.add_theme_font_size_override("font_size", 26)
    column.add_child(heading)

    var writing := Label.new()
    writing.text = MESSAGE
    writing.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    writing.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    writing.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    writing.custom_minimum_size = Vector2(640, 95)
    writing.add_theme_color_override("font_color", Color("#48280e"))
    writing.add_theme_font_size_override("font_size", 28)
    column.add_child(writing)

    DialogueUI.show_dialogue("Tradução do pergaminho", TRANSLATION, Callable(self, "_close_parchment"))

func _close_parchment() -> void:
    if is_instance_valid(_parchment):
        _parchment.queue_free()
    _parchment = null
    if _near:
        $Prompt.show()
