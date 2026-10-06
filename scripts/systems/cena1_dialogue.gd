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

	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("set_input_locked"):
		player.set_input_locked(true)

func _input(event: InputEvent) -> void:
	if not box.visible:
		return

	if not event.is_action_pressed("interact"):
		return

	box.visible = false

	var npc = get_tree().get_first_node_in_group("npc")
	if npc:
		npc.talking = false

	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("set_input_locked"):
		player.set_input_locked(false)

	get_viewport().set_input_as_handled()
