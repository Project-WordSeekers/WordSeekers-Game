extends Sprite2D
## Indica exclusivamente as entradas para interiores; a Area2D original faz o transporte.
## A sequência começa com a seta no alto, desce até a ponta amarela e sobe novamente.
@export_range(2.0, 20.0, 0.5) var frames_per_second: float = 7.0
var _elapsed: float = 0.0

func _ready() -> void:
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    hframes = 6
    vframes = 1
    frame = 0
    centered = true
    z_index = 8

func _process(delta: float) -> void:
    _elapsed += delta
    frame = int(_elapsed * frames_per_second) % 6
