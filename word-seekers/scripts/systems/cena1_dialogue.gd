extends CanvasLayer

@onready var box: Panel = $Panel
@onready var name_label: Label = $Panel/Name
@onready var text_label: Label = $Panel/Text

func _ready() -> void:
    add_to_group("dialogue")
    box.visible = false

func show_dialogue(who: String, text: String) -> void:
    name_label.text = who
    text_label.text = text
    box.visible = true

func _unhandled_input(event: InputEvent) -> void:
    if box.visible and event is InputEventKey and event.pressed and event.keycode == KEY_E:
        box.visible = false
        var npc = get_tree().get_first_node_in_group("npc")
        if npc:
            npc.talking = false
