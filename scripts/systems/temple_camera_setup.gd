extends Node2D

# Mantem o zoom fixo apenas dentro do templo compartilhado.
# A camera do player normalmente calcula o zoom conforme a area do mapa.
func _ready() -> void:
    var player := get_node_or_null("TileMapLayer/Player")
    if player == null:
        return
    var camera := player.get_node_or_null("Camera2D") as Camera2D
    if camera == null:
        return
    camera.set("min_zoom", 0.75)
    camera.set("max_zoom", 0.75)
    camera.zoom = Vector2(0.75, 0.75)
