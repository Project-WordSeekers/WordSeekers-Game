extends CanvasLayer
## Atualiza o progresso de Oxford sem afetar as cenas de Birmingham.
@onready var estado: Label = $Estado

func _ready() -> void:
    CityQuests.inventario_atualizado.connect(_atualizar)
    _atualizar()

func _atualizar() -> void:
    var segredo: String = "descoberta" if CityQuests.segredo_radcliffe_descoberto else "a descobrir"
    var item: String = "coletado" if CityQuests.manuscrito_oxford_coletado else "pendente"
    var key03: String = "coletada" if CityQuests.tem_key_03 else "pendente"
    var porta: String = "aberta" if CityQuests.porta_secreta_radcliffe_aberta else "trancada"
    estado.text = "KEY 03: %s  |  Porta: %s  |  Radcliffe: %s  |  Manuscrito: %s" % [key03, porta, segredo, item]
