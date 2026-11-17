extends Node2D
# Interior inspirado nas galerias de arenito da City of Caves.
# A arte de fundo e as colisões podem ser refinadas independentemente.
@onready var player: CharacterBody2D = $Player
var aviso: Label

func _ready() -> void:
    player.position = Vector2(480, 555)
    var camera: Camera2D = player.get_node("Camera2D")
    camera.zoom = Vector2.ONE
    camera.limit_left = 0
    camera.limit_top = 0
    camera.limit_right = 960
    camera.limit_bottom = 640
    # Barreiras do perímetro; abertura inferior para o retorno.
    bloquear(Rect2(0, 0, 960, 100))
    bloquear(Rect2(0, 0, 65, 640))
    bloquear(Rect2(895, 0, 65, 640))
    bloquear(Rect2(0, 615, 390, 25))
    bloquear(Rect2(570, 615, 390, 25))
    # Maciços rochosos e estruturas elevadas fora do percurso inferior.
    bloquear(Rect2(65, 110, 175, 240))
    bloquear(Rect2(745, 110, 150, 250))
    bloquear(Rect2(245, 110, 175, 125))
    bloquear(Rect2(555, 110, 180, 120))
    bloquear(Rect2(65, 355, 110, 100))
    bloquear(Rect2(800, 365, 95, 95))
    aviso = Label.new()
    aviso.text = "Passe pela saída para voltar a Nottingham"
    aviso.position = Vector2(355, 594)
    aviso.add_theme_font_size_override("font_size", 20)
    aviso.add_theme_color_override("font_color", Color(1.0, 0.9, 0.65))
    aviso.z_index = 20
    add_child(aviso)

func bloquear(area: Rect2) -> void:
    var corpo := StaticBody2D.new()
    corpo.collision_layer = 1
    var shape := CollisionShape2D.new()
    var rect := RectangleShape2D.new()
    rect.size = area.size
    shape.shape = rect
    corpo.position = area.position + area.size / 2.0
    corpo.add_child(shape)
    add_child(corpo)

func _process(_delta: float) -> void:
    # A Area2D ReturnToNottingham controla automaticamente a saída.
    aviso.visible = player.position.distance_to(Vector2(480, 600)) < 130.0
