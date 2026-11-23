extends Area2D

signal ativado(id: int)
@export_range(0, 2) var cristal_id: int = 0
@export var nome_cristal: String = "Cristal"
var jogador_perto := false
@onready var dica: Label = get_node("../../Interface/Dica")

func _ready() -> void:
    body_entered.connect(_ao_entrar)
    body_exited.connect(_ao_sair)

func _ao_entrar(body: Node2D) -> void:
    if body.is_in_group("player"):
        jogador_perto = true
        if not CityQuests.enigma_resolvido:
            dica.text = "E — Ativar cristal " + nome_cristal
            dica.visible = true

func _ao_sair(body: Node2D) -> void:
    if body.is_in_group("player"):
        jogador_perto = false
        if dica.text == "E — Ativar cristal " + nome_cristal:
            dica.visible = false

func _unhandled_input(event: InputEvent) -> void:
    if jogador_perto and not CityQuests.enigma_resolvido and event.is_action_pressed("interact") and not event.is_echo():
        ativado.emit(cristal_id)
        get_viewport().set_input_as_handled()

func atualizar_visual(ativo: bool) -> void:
    $Visual/Brilho.visible = ativo
    $Visual/Gema.modulate = Color(1.4, 1.4, 1.4, 1.0) if ativo else Color.WHITE
