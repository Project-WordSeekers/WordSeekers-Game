extends Node2D

func _ready() -> void:
    $OfficeEntrance.body_entered.connect(_on_office_entrance)
    $WorldMapExit.body_entered.connect(_on_world_exit)

func _on_office_entrance(body: Node2D) -> void:
    if body.is_in_group("player"):
        SceneTransition.change_scene_to_file("res://scenes/locations/liverpool/royal_albert_office.tscn")

func _on_world_exit(body: Node2D) -> void:
    if body.is_in_group("player"):
        SceneTransition.change_scene_to_file("res://scenes/world/world_map.tscn")
