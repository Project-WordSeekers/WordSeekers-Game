extends Area2D

var jogador_perto := false
@onready var dica: Label = get_node("../Interface/Dica")

func _ready() -> void:
    body_entered.connect(_ao_entrar)
    body_exited.connect(_ao_sair)
    if CityQuests.enigma_resolvido and not CityQuests.tem_reliquia:
        aparecer()
    else:
        esconder()

func aparecer() -> void:
    if CityQuests.tem_reliquia:
        return
    visible = true
    set_deferred("monitoring", true)

func esconder() -> void:
    visible = false
    set_deferred("monitoring", false)

func _ao_entrar(body: Node2D) -> void:
    if body.is_in_group("player") and CityQuests.enigma_resolvido and not CityQuests.tem_reliquia:
        jogador_perto = true
        dica.text = "E — Coletar Relíquia das Cavernas"
        dica.visible = true

func _ao_sair(body: Node2D) -> void:
    if body.is_in_group("player"):
        jogador_perto = false
        if dica.text == "E — Coletar Relíquia das Cavernas":
            dica.visible = false

func _unhandled_input(event: InputEvent) -> void:
    if jogador_perto and event.is_action_pressed("interact") and not event.is_echo():
        if CityQuests.pegar_reliquia():
            esconder()
            dica.text = "Relíquia coletada! Você concluiu o Santuário Esquecido."
            dica.visible = true
            get_node("../Interface/Resultado").text = "Missão concluída: Relíquia das Cavernas!"
        get_viewport().set_input_as_handled()
