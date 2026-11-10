extends PointLight2D
# Pulso suave da luz do cálice (mesma curva usada em temple_fx.gd no templo novo).

var elapsed: float = 0.0

func _process(delta: float) -> void:
	elapsed += delta
	energy = 1.15 + 0.28 * sin(elapsed * 2.3)
