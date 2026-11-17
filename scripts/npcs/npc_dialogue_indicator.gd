extends Sprite2D
## Indicador compartilhado para NPCs ainda não conversados.
## Tamanho, posição e animação ficam definidos apenas neste arquivo.

const TEXTURE: Texture2D = preload("res://assets/ui/icons/npc_new_dialogue_exclamation.png")
const HEIGHT_OFFSET: float = -26.0
const FLOAT_AMPLITUDE: float = 4.0
const HALF_CYCLE_SECONDS: float = 0.55
const ICON_SCALE: Vector2 = Vector2.ONE

var _npc: Node2D
var _identity: String = ""

func setup(npc: Node2D, configured_id: String = "") -> void:
    _npc = npc
    _identity = _resolve_identity(configured_id)
    name = "NewDialogueIcon"
    texture = TEXTURE
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    centered = true
    scale = ICON_SCALE
    position = Vector2(0.0, HEIGHT_OFFSET)
    z_index = 30
    refresh()
    var float_tween: Tween = create_tween()
    float_tween.set_loops()
    float_tween.tween_property(self, "position:y", HEIGHT_OFFSET - FLOAT_AMPLITUDE, HALF_CYCLE_SECONDS).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    float_tween.tween_property(self, "position:y", HEIGHT_OFFSET, HALF_CYCLE_SECONDS).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _resolve_identity(configured_id: String) -> String:
    if configured_id.strip_edges() != "":
        return configured_id.strip_edges()
    # Compatibilidade com os IDs utilizados nas versões anteriores.
    var scene_id: String = _npc.scene_file_path.get_file().get_basename() if _npc.scene_file_path != "" else "runtime"
    return "%s::%s" % [scene_id, _npc.get_path()]

func refresh() -> void:
    visible = not GameState.has_talked_to_npc(_identity)

func mark_talked(city: String) -> void:
    GameState.register_npc_talked(_identity, city)
    refresh()
