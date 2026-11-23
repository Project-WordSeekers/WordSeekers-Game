extends Area2D
## Interacao contextual para os marcos de Birmingham.
## "estudar" registra a primeira aula no GameState; "informacao" exibe uma descricao.
@export var prompt: String = "E — Interagir"
@export_multiline var texto: String = ""
@export_enum("informacao", "estudar") var acao: String = "informacao"

var player_nearby: bool = false
@onready var hint: Label = get_node("../Interface/Dica")
@onready var info: Panel = get_node("../Interface/Info")
@onready var mensagem: Label = get_node("../Interface/Info/Mensagem")

func _ready() -> void:
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        player_nearby = true
        hint.text = prompt
        if not info.visible:
            hint.show()

func _on_body_exited(body: Node2D) -> void:
    if body.is_in_group("player"):
        player_nearby = false
        if hint.text == prompt:
            hint.hide()
        info.hide()

func _unhandled_input(event: InputEvent) -> void:
    if info.visible and event.is_action_pressed("ui_cancel") and not event.is_echo():
        info.hide()
        if player_nearby:
            hint.show()
        get_viewport().set_input_as_handled()
        return
    if not player_nearby or not event.is_action_pressed("interact") or event.is_echo():
        return
    if info.visible:
        info.hide()
        hint.show()
    else:
        if acao == "estudar":
            if not CityQuests.estudo_birmingham_concluido:
                CityQuests.estudo_birmingham_concluido = true
                mensagem.text = "BIBLIOTECA / ESCOLA\nAula concluida! Voce estudou na Library of Birmingham. O progresso fica registrado no GameState enquanto o jogo estiver aberto."
            else:
                mensagem.text = "BIBLIOTECA / ESCOLA\nVoce ja realizou a atividade de estudo! Volte as estantes para consultar o acervo ou explore Birmingham."
        else:
            mensagem.text = texto.replace("\\n", "\n")
        info.show()
        hint.hide()
    get_viewport().set_input_as_handled()
