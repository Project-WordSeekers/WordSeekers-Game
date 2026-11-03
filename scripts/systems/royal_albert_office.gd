extends Node2D

func _ready() -> void:
    $PortaDeSaida.body_entered.connect(_on_saida)

func _on_saida(body: Node2D) -> void:
    if body.is_in_group("player"):
        SceneTransition.change_scene_to_file("res://scenes/locations/liverpool/royal_albert_dock.tscn")
