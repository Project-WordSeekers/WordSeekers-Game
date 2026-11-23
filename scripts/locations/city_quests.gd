extends Node
## Estado da missao compartilhado entre as cenas.
## A combinacao e fixa, mas o jogador nao recebe nenhuma dica sobre ela.
signal inventario_atualizado
signal enigma_atualizado

var tem_key_01: bool = false
var tem_key_02: bool = false
var passagem_desbloqueada: bool = false
var enigma_resolvido: bool = false
var tem_reliquia: bool = false
var tentativa: Array[int] = []

const ORDEM_CORRETA: Array[int] = [2, 0, 1] # IDs: 0 azul, 1 roxo, 2 verde

func pegar_chave() -> bool:
    if tem_key_01:
        return false
    tem_key_01 = true
    inventario_atualizado.emit()
    return true

func pegar_chave_02() -> bool:
    if tem_key_02:
        return false
    tem_key_02 = true
    inventario_atualizado.emit()
    return true

func registrar_cristal(id: int) -> String:
    if enigma_resolvido:
        return "concluido"
    if tentativa.has(id):
        return "repetido"
    tentativa.append(id)
    enigma_atualizado.emit()
    if tentativa.size() < 3:
        return "registrado"
    if tentativa == ORDEM_CORRETA:
        enigma_resolvido = true
        enigma_atualizado.emit()
        return "correto"
    tentativa.clear()
    enigma_atualizado.emit()
    return "incorreto"

func pegar_reliquia() -> bool:
    if not enigma_resolvido or tem_reliquia:
        return false
    tem_reliquia = true
    inventario_atualizado.emit()
    return true

# Progresso simples da atividade biblioteca/escola em Birmingham.
var estudo_birmingham_concluido: bool = false

# Oxford — progresso independente das missoes de Birmingham/Nottingham.
var estudo_oxford_concluido: bool = false
var segredo_radcliffe_descoberto: bool = false
var manuscrito_oxford_coletado: bool = false

func concluir_estudo_oxford() -> bool:
    if estudo_oxford_concluido:
        return false
    estudo_oxford_concluido = true
    inventario_atualizado.emit()
    return true

func descobrir_segredo_radcliffe() -> void:
    if not segredo_radcliffe_descoberto:
        segredo_radcliffe_descoberto = true
        inventario_atualizado.emit()

func coletar_manuscrito_oxford() -> bool:
    if manuscrito_oxford_coletado:
        return false
    manuscrito_oxford_coletado = true
    inventario_atualizado.emit()
    return true

# A terceira chave e coletada no interior principal da Radcliffe Camera.
var tem_key_03: bool = false

func pegar_chave_03() -> bool:
    if tem_key_03:
        return false
    tem_key_03 = true
    inventario_atualizado.emit()
    return true

# Porta interna da Radcliffe Camera: somente a KEY 03 permite destranca-la.
# O destrancamento permanece ativo enquanto esta partida estiver aberta.
var porta_secreta_radcliffe_aberta: bool = false

func destrancar_porta_radcliffe() -> bool:
    if not tem_key_03 or porta_secreta_radcliffe_aberta:
        return false
    porta_secreta_radcliffe_aberta = true
    inventario_atualizado.emit()
    return true
