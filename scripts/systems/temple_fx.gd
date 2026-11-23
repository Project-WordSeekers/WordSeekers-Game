extends Node2D
# Reusable flame frames and gentle glow pulse for every temple instance.
@onready var left_flame: Sprite2D = $LeftFlame
@onready var right_flame: Sprite2D = $RightFlame
@onready var left_glow: PointLight2D = $LeftGlow
@onready var right_glow: PointLight2D = $RightGlow
@onready var chalice_glow: PointLight2D = get_node("../ChaliceVisualHalf/ChaliceGlow")
var elapsed: float = 0.0
func _process(delta: float) -> void:
    elapsed += delta
    left_flame.frame = int(elapsed * 10.0) % 8
    right_flame.frame = (int(elapsed * 10.0) + 4) % 8
    left_glow.energy = 0.85 + 0.17 * sin(elapsed * 8.0)
    right_glow.energy = 0.85 + 0.17 * sin(elapsed * 7.1 + 1.5)
    chalice_glow.energy = 1.15 + 0.28 * sin(elapsed * 2.3)
