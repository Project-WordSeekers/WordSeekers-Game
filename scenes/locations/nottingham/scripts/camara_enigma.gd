extends "res://scripts/systems/scene_spawn.gd"

const NOMES := ["Azul", "Roxo", "Verde"]
@onready var progresso: Label = $Interface/Progresso
@onready var resultado: Label = $Interface/Resultado
@onready var dica: Label = $Interface/Dica

func _ready() -> void:
    super._ready()
    for cristal in $Cristais.get_children():
        cristal.ativado.connect(_ativar_cristal)
    _atualizar_visual()
    if CityQuests.tem_reliquia:
        resultado.text = "Relíquia das Cavernas coletada!"
    elif CityQuests.enigma_resolvido:
        resultado.text = "Enigma resolvido! Procure a relíquia no altar."
    else:
        resultado.text = "Escolha a ordem de ativação dos três cristais."

func _ativar_cristal(id: int) -> void:
    var estado: String = CityQuests.registrar_cristal(id)
    match estado:
        "registrado":
            resultado.text = "Cristal " + NOMES[id] + " ativado."
        "repetido":
            resultado.text = "Esse cristal já foi escolhido. Selecione outro."
        "incorreto":
            resultado.text = "Sequência incorreta. Os cristais foram reiniciados."
        "correto":
            resultado.text = "Sequência correta! A relíquia foi revelada."
            dica.visible = false
            $Reliquia.aparecer()
        "concluido":
            resultado.text = "O enigma já foi resolvido."
    _atualizar_visual()

func _atualizar_visual() -> void:
    var nomes_escolhidos := PackedStringArray()
    for id in CityQuests.tentativa:
        nomes_escolhidos.append(NOMES[id])
    if CityQuests.enigma_resolvido:
        progresso.text = "Enigma concluído — 3/3"
    else:
        progresso.text = "Sequência: " + (" → ".join(nomes_escolhidos) if not nomes_escolhidos.is_empty() else "—") + "   (%d/3)" % CityQuests.tentativa.size()
    for cristal in $Cristais.get_children():
        cristal.atualizar_visual(CityQuests.enigma_resolvido or CityQuests.tentativa.has(cristal.cristal_id))
