extends Node2D
# Pequenos pontos de luz dourada que flutuam e orbitam o calice.
# Desenhados abaixo do jogador (z_index = 1).
@export var particle_count: int = 34
@export var radius: float = 115.0
var particles: Array[Dictionary] = []
var clock: float = 0.0
var rng := RandomNumberGenerator.new()

func _ready() -> void:
    rng.randomize()
    for i in range(particle_count):
        particles.append({
            "angle": rng.randf_range(0.0, TAU),
            "distance": sqrt(rng.randf()) * radius,
            "speed": rng.randf_range(0.18, 0.65) * (1.0 if i % 2 == 0 else -1.0),
            "phase": rng.randf_range(0.0, TAU),
            "size": rng.randf_range(1.1, 2.7),
            "height": rng.randf_range(-20.0, 20.0)
        })

func _process(delta: float) -> void:
    clock += delta
    queue_redraw()

func _draw() -> void:
    for p in particles:
        var a: float = p["angle"] + clock * p["speed"]
        var d: float = p["distance"] + 8.0 * sin(clock * 1.2 + p["phase"])
        var pos := Vector2(cos(a) * d, sin(a) * d * 0.48 + p["height"] + 9.0 * sin(clock * 1.5 + p["phase"]))
        var pulse: float = 0.55 + 0.45 * sin(clock * 2.4 + p["phase"])
        var r: float = p["size"]
        draw_circle(pos, r * 4.0, Color(1.0, 0.62, 0.15, 0.035 + 0.045 * pulse))
        draw_circle(pos, r * 2.1, Color(1.0, 0.79, 0.32, 0.09 + 0.11 * pulse))
        draw_circle(pos, r, Color(1.0, 0.92, 0.58, 0.45 + 0.5 * pulse))
