extends Area2D
## Pontos de informacao e atividade academica em Oxford.
@export var prompt: String = "E — Interagir"
@export_multiline var texto: String = ""
@export_enum("informacao", "estudar") var acao: String = "informacao"

var jogador_perto: bool = false
@onready var dica: Label = get_node("../Interface/Dica")
@onready var painel: Panel = get_node("../Interface/Info")
@onready var mensagem: Label = get_node("../Interface/Info/Mensagem")

func _ready() -> void:
    body_entered.connect(_ao_entrar)
    body_exited.connect(_ao_sair)

func _ao_entrar(corpo: Node2D) -> void:
    if corpo.is_in_group("player"):
        jogador_perto = true
        dica.text = prompt
        if not painel.visible:
            dica.show()

func _ao_sair(corpo: Node2D) -> void:
    if corpo.is_in_group("player"):
        jogador_perto = false
        if dica.text == prompt:
            dica.hide()
        painel.hide()

func _unhandled_input(event: InputEvent) -> void:
    if painel.visible and event.is_action_pressed("ui_cancel") and not event.is_echo():
        painel.hide()
        if jogador_perto:
            dica.show()
        get_viewport().set_input_as_handled()
        return
    if not jogador_perto or not event.is_action_pressed("interact") or event.is_echo():
        return
    if painel.visible:
        painel.hide()
        dica.show()
    else:
        if acao == "estudar":
            if CityQuests.concluir_estudo_oxford():
                mensagem.text = "UNIVERSIDADE DE OXFORD\nAtividade academica concluida! Seu progresso esta registrado enquanto o jogo estiver aberto."
            else:
                mensagem.text = "UNIVERSIDADE DE OXFORD\nVoce ja concluiu o estudo. Explore as outras salas e marcos da cidade."
        else:
            mensagem.text = texto.replace("\\n", "\n")
        painel.show()
        dica.hide()
    get_viewport().set_input_as_handled()
