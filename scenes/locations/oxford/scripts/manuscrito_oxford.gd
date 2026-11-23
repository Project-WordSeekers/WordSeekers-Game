extends Area2D
## Item unico da sala secreta da Radcliffe Camera.
var jogador_perto: bool = false
@onready var dica: Label = get_node("../Interface/Dica")
@onready var painel: Panel = get_node("../Interface/Info")
@onready var mensagem: Label = get_node("../Interface/Info/Mensagem")

func _ready() -> void:
    body_entered.connect(_ao_entrar)
    body_exited.connect(_ao_sair)
    if CityQuests.manuscrito_oxford_coletado:
        $Selo.hide()
        set_deferred("monitoring", false)

func _ao_entrar(corpo: Node2D) -> void:
    if corpo.is_in_group("player") and not CityQuests.manuscrito_oxford_coletado:
        jogador_perto = true
        dica.text = "E — Coletar o Manuscrito de Oxford"
        dica.show()

func _ao_sair(corpo: Node2D) -> void:
    if corpo.is_in_group("player"):
        jogador_perto = false
        if dica.text == "E — Coletar o Manuscrito de Oxford":
            dica.hide()

func _unhandled_input(event: InputEvent) -> void:
    if not jogador_perto or not event.is_action_pressed("interact") or event.is_echo():
        return
    if CityQuests.coletar_manuscrito_oxford():
        $Selo.hide()
        set_deferred("monitoring", false)
        jogador_perto = false
        mensagem.text = "AREA SECRETA DA RADCLIFFE CAMERA\nVoce encontrou o Manuscrito de Oxford! O segredo foi descoberto e o item foi adicionado ao progresso da cidade."
        painel.show()
        dica.hide()
    get_viewport().set_input_as_handled()
