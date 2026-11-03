extends Node2D

@export_enum("Castelo", "Cavernas") var ambiente: int = 0
var player: CharacterBody2D
var label: Label
const TAM := Vector2(960, 640)

func _ready() -> void:
    player = get_node("Player")
    player.position = Vector2(480, 545)
    player.get_node("Camera2D").zoom = Vector2(1, 1)
    player.get_node("Camera2D").limit_right = 960
    player.get_node("Camera2D").limit_bottom = 640
    label = Label.new()
    label.position = Vector2(350, 595)
    label.add_theme_font_size_override("font_size", 18)
    label.add_theme_color_override("font_color", Color(1, 0.92, 0.65))
    label.text = "[E] Voltar para Nottingham"
    add_child(label)
    criar_colisoes()
    queue_redraw()

func parede(x: float, y: float, w: float, h: float) -> void:
    var corpo := StaticBody2D.new()
    corpo.collision_layer = 1
    corpo.collision_mask = 0
    var forma := CollisionShape2D.new()
    var ret := RectangleShape2D.new()
    ret.size = Vector2(w, h)
    forma.shape = ret
    corpo.position = Vector2(x + w / 2, y + h / 2)
    corpo.add_child(forma)
    add_child(corpo)

func criar_colisoes() -> void:
    parede(0, 0, 960, 65)
    parede(0, 0, 60, 640)
    parede(900, 0, 60, 640)
    parede(0, 620, 410, 20)
    parede(550, 620, 410, 20)
    if ambiente == 0:
        for x in [230, 730]:
            for y in [205, 385]:
                parede(x - 24, y - 24, 48, 48)
        parede(95, 105, 120, 70)
        parede(745, 105, 120, 70)
        parede(350, 110, 260, 70)
        parede(60, 260, 100, 100)
        parede(800, 260, 100, 100)
    else:
        parede(60, 140, 265, 75)
        parede(635, 140, 265, 75)
        parede(300, 260, 80, 160)
        parede(580, 260, 80, 160)
        parede(80, 445, 230, 75)
        parede(650, 445, 230, 75)
        parede(430, 185, 100, 65)

func _process(_delta: float) -> void:
    var saida := player.position.distance_to(Vector2(480, 565)) < 80
    label.visible = saida
    if saida and Input.is_action_just_pressed("interact"):
        GameState.pending_spawn_name = &"FromCastle"
        SceneTransition.change_scene_to_file("res://scenes/locations/nottingham/nottingham.tscn")

func _draw() -> void:
    var piso := Color("776047") if ambiente == 0 else Color("3a3430")
    var parede_cor := Color("45434c") if ambiente == 0 else Color("272322")
    draw_rect(Rect2(Vector2.ZERO, TAM), piso)
    for x in range(60, 900, 40):
        for y in range(65, 620, 40):
            if ambiente == 0:
                draw_rect(Rect2(x, y, 38, 38), Color("89745b") if (x+y) % 80 == 0 else Color("806b52"))
            else:
                draw_circle(Vector2(x+18, y+18), 4, Color("51483e"))
    draw_rect(Rect2(0, 0, 960, 65), parede_cor)
    draw_rect(Rect2(0, 0, 60, 640), parede_cor)
    draw_rect(Rect2(900, 0, 60, 640), parede_cor)
    draw_rect(Rect2(0, 620, 410, 20), parede_cor)
    draw_rect(Rect2(550, 620, 410, 20), parede_cor)
    if ambiente == 0:
        for x in [230, 730]:
            for y in [205, 385]:
                draw_circle(Vector2(x, y), 28, Color("35313a"))
                draw_circle(Vector2(x, y), 20, Color("99918a"))
        for r in [Rect2(95,105,120,70), Rect2(745,105,120,70), Rect2(350,110,260,70), Rect2(60,260,100,100), Rect2(800,260,100,100)]:
            draw_rect(r, Color("4e3c31"))
            draw_rect(r.grow(-8), Color("a28259"))
        draw_rect(Rect2(410, 280, 140, 95), Color("ad2735"))
        draw_rect(Rect2(425, 295, 110, 65), Color("c54b4d"))
        draw_string(ThemeDB.fallback_font, Vector2(350, 90), "SALAO PRINCIPAL DO CASTELO", HORIZONTAL_ALIGNMENT_LEFT, -1, 21, Color("ffe2a1"))
    else:
        for r in [Rect2(60,140,265,75),Rect2(635,140,265,75),Rect2(300,260,80,160),Rect2(580,260,80,160),Rect2(80,445,230,75),Rect2(650,445,230,75),Rect2(430,185,100,65)]:
            draw_rect(r, Color("25211f"))
            draw_rect(r.grow(-12), Color("5a4b3d"))
        for pos in [Vector2(190,330),Vector2(755,325),Vector2(470,100)]:
            draw_circle(pos, 24, Color("156a79"))
            draw_circle(pos, 16, Color("258e9d"))
        draw_string(ThemeDB.fallback_font, Vector2(385, 90), "CITY OF CAVES", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("e6cf9b"))
    draw_rect(Rect2(410, 620, 140, 20), Color("c49c65"))
