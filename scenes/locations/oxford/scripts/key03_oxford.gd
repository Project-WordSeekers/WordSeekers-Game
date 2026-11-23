extends Area2D
## KEY 03: colecionavel unico no salao principal da Radcliffe Camera.
var jogador_perto: bool = false
@onready var dica: Label = get_node("../Interface/Dica")
@onready var painel: Panel = get_node("../Interface/Info")
@onready var mensagem: Label = get_node("../Interface/Info/Mensagem")

func _ready() -> void:
    body_entered.connect(_ao_entrar)
    body_exited.connect(_ao_sair)
    if CityQuests.tem_key_03:
        $Visual.hide()
        set_deferred("monitoring", false)

func _ao_entrar(corpo: Node2D) -> void:
    if corpo.is_in_group("player") and not CityQuests.tem_key_03:
        jogador_perto = true
        dica.text = "E — Coletar KEY 03"
        dica.show()

func _ao_sair(corpo: Node2D) -> void:
    if corpo.is_in_group("player"):
        jogador_perto = false
        if dica.text == "E — Coletar KEY 03":
            dica.hide()

func _unhandled_input(event: InputEvent) -> void:
    if not jogador_perto or not event.is_action_pressed("interact") or event.is_echo():
        return
    if CityQuests.pegar_chave_03():
        $Visual.hide()
        set_deferred("monitoring", false)
        jogador_perto = false
        mensagem.text = "RADCLIFFE CAMERA\nKEY 03 adquirida! A terceira chave foi adicionada ao inventario."
        painel.show()
        dica.hide()
    get_viewport().set_input_as_handled()
