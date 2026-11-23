extends Node2D

@export var temple_zoom: float = 0.75

# Mantem o zoom fixo apenas dentro do templo compartilhado.
# A camera do player normalmente calcula o zoom conforme a area do mapa.
func _ready() -> void:
    var player := get_node_or_null("TileMapLayer/Player")
    if player == null:
        return
    var camera := player.get_node_or_null("Camera2D") as Camera2D
    if camera == null:
        return
    camera.set("min_zoom", temple_zoom)
    camera.set("max_zoom", temple_zoom)
    camera.zoom = Vector2.ONE * temple_zoom
