extends CharacterBody2D

var player: Node2D
var talking := false
@onready var prompt: Label = $Prompt

func _ready() -> void:
    player = get_tree().get_first_node_in_group("player")
    add_to_group("npc")
    prompt.visible = false

func _process(_delta: float) -> void:
    if player == null:
        player = get_tree().get_first_node_in_group("player")
        return
    var close := global_position.distance_to(player.global_position) < 90.0
    prompt.visible = close and not talking
    if close and Input.is_key_pressed(KEY_E) and not talking:
        talking = true
        prompt.visible = false
        var ui = get_tree().get_first_node_in_group("dialogue")
        if ui:
            ui.show_dialogue("Morador", "Olá! Bem-vindo à vila!\nUse WASD ou as setas para andar.\nChegue perto de mim e aperte E para conversar.")
