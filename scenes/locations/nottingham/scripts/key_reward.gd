extends Area2D

# Historia do mercado e coleta explicita da Key 01 com E.
@export var raio_interacao: float = 125.0
@onready var jogador: CharacterBody2D = get_node("../Player")
var perto := false
var painel: PanelContainer
var mensagem: Label

func _ready() -> void:
    collision_layer = 0
    collision_mask = 2
    if CityQuests.tem_key_01:
        $Visual.visible = false
    var canvas := CanvasLayer.new()
    canvas.name = "InterfaceHistoriaKey01"
    canvas.layer = 15
    add_child(canvas)
    painel = PanelContainer.new()
    painel.anchor_left = 0.5
    painel.anchor_right = 0.5
    painel.anchor_top = 1.0
    painel.anchor_bottom = 1.0
    painel.offset_left = -370.0
    painel.offset_right = 370.0
    painel.offset_top = -205.0
    painel.offset_bottom = -42.0
    painel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var estilo := StyleBoxFlat.new()
    estilo.bg_color = Color(0.10, 0.08, 0.07, 0.96)
    estilo.border_color = Color(0.91, 0.70, 0.34)
    estilo.set_border_width_all(2)
    estilo.set_corner_radius_all(10)
    painel.add_theme_stylebox_override("panel", estilo)
    mensagem = Label.new()
    mensagem.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    mensagem.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    mensagem.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    mensagem.add_theme_font_size_override("font_size", 18)
    mensagem.add_theme_color_override("font_color", Color(1, 0.94, 0.79))
    painel.add_child(mensagem)
    canvas.add_child(painel)
    painel.visible = false
    _atualizar_texto()

func _atualizar_texto() -> void:
    if CityQuests.tem_key_01:
        mensagem.text = "OLD MARKET SQUARE\nKey 01 ja coletada e guardada no inventario."
    else:
        mensagem.text = "OLD MARKET SQUARE — O ANTIGO MERCADO\nDurante seculos, esta praca foi um ponto de comercio e encontros em Nottingham.\nExplore sua historia e encontre a primeira chave da cidade.\n\n[E] Coletar KEY 01"

func _process(_delta: float) -> void:
    if not is_instance_valid(jogador):
        return
    perto = global_position.distance_to(jogador.global_position) <= raio_interacao
    painel.visible = perto

func _unhandled_input(event: InputEvent) -> void:
    if perto and not CityQuests.tem_key_01 and event.is_action_pressed("interact") and not event.is_echo():
        if CityQuests.pegar_chave():
            $Visual.visible = false
            _atualizar_texto()
        get_viewport().set_input_as_handled()
