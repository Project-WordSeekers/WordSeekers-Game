extends Area2D
## Chave exclusiva da City of Caves, independente da Key 01 do mercado.
var jogador_perto := false
@onready var dica: Label = get_node("../Interface/Dica")

func _ready() -> void:
    body_entered.connect(_ao_entrar)
    body_exited.connect(_ao_sair)
    if CityQuests.tem_key_02:
        $Visual.visible = false
        set_deferred("monitoring", false)

func _ao_entrar(body: Node2D) -> void:
    if body.is_in_group("player") and not CityQuests.tem_key_02:
        jogador_perto = true
        dica.text = "E — Coletar Key 02"
        dica.visible = true

func _ao_sair(body: Node2D) -> void:
    if body.is_in_group("player"):
        jogador_perto = false
        if dica.text.begins_with("E — Coletar Key 02"):
            dica.visible = false

func _unhandled_input(event: InputEvent) -> void:
    if jogador_perto and not CityQuests.tem_key_02 and event.is_action_pressed("interact") and not event.is_echo():
        if CityQuests.pegar_chave_02():
            $Visual.visible = false
            set_deferred("monitoring", false)
            dica.text = "Key 02 coletada! Procure a porta roxa."
            dica.visible = true
        get_viewport().set_input_as_handled()
