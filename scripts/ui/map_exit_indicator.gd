extends Node2D

# Marcador exclusivo das SAÍDAS para o mapa-múndi.
# O portal de saída continua responsável pelo teleporte automático.
const PROXIMITY_RADIUS: float = 155.0
const FLOAT_RANGE: float = 5.0
const FLOAT_DURATION: float = 0.65

@onready var icon: Sprite2D = $Icon
@onready var near_label: Label = $NearLabel
var _player: Node2D

func _ready() -> void:
    near_label.hide()
    # Usa o centro real da área, mesmo quando o CollisionShape2D tem offset.
    var portal: Area2D = get_parent() as Area2D
    if portal != null:
        var exit_shape: CollisionShape2D = portal.get_node_or_null("CollisionShape2D") as CollisionShape2D
        if exit_shape != null:
            position = exit_shape.position
    _player = get_tree().get_first_node_in_group("player") as Node2D
    var bob: Tween = create_tween()
    bob.set_loops()
    bob.tween_property(icon, "position:y", -30.0 - FLOAT_RANGE, FLOAT_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    bob.tween_property(icon, "position:y", -30.0 + FLOAT_RANGE, FLOAT_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _process(_delta: float) -> void:
    if not is_instance_valid(_player):
        _player = get_tree().get_first_node_in_group("player") as Node2D
    if _player == null:
        near_label.hide()
        return
    near_label.visible = global_position.distance_to(_player.global_position) <= PROXIMITY_RADIUS
