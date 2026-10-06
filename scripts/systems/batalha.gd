extends Node2D

var enemy_hp: int = 3
var player_perto: bool = false
var battle_active: bool = false

var perguntas: Array[Dictionary] = [
	{
		"prompt": "A book is a _____.",
		"answers": ["A) livro", "B) caneta", "C) cadeira", "D) mesa"],
		"correct": 0,
		"wrong_feedback": "Wrong! The enemy attacks you! -1 HP"
	},
	{
		"prompt": "A pen is a _____.",
		"answers": ["A) porta", "B) livro", "C) caneta", "D) água"],
		"correct": 2,
		"wrong_feedback": "Wrong! The enemy attacks you! -1 HP"
	},
	{
		"prompt": "The opposite of hot is _____.",
		"answers": ["A) warm", "B) cold", "C) fast", "D) high"],
		"correct": 1,
		"wrong_feedback": "Wrong! The enemy attacks you! -1 HP"
	}
]

@onready var enemy_hp_label: Label = $EnemyHPLabel
@onready var interaction_label: Label = $InteractionLabel
@onready var enemy: Sprite2D = $Inimigo

func _ready() -> void:
	_hide_legacy_battle_ui()
	enemy_hp_label.hide()
	interaction_label.text = "[E] Falar"
	interaction_label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.55, 1.0))
	interaction_label.hide()

func _hide_legacy_battle_ui() -> void:
	var legacy_names: Array[StringName] = [
		&"PlayerHPLabel",
		&"StartBattlePanel",
		&"QuestionPanel",
		&"AnswerInput",
		&"AttackButton",
		&"ResultLabel",
		&"YesButton",
		&"NoButton"
	]
	for name_index in range(legacy_names.size()):
		var node_name: StringName = legacy_names[name_index]
		var legacy_node: CanvasItem = get_node_or_null(NodePath(String(node_name))) as CanvasItem
		if legacy_node != null:
			legacy_node.hide()

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_perto = true
		if not battle_active and not DialogueUI.is_open():
			interaction_label.show()

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_perto = false
		interaction_label.hide()

func _unhandled_input(event: InputEvent) -> void:
	if not player_perto or battle_active or DialogueUI.is_open():
		return
	if not event.is_action_pressed("interact"):
		return

	interaction_label.hide()
	var options: Array[String] = ["YES", "NO"]
	DialogueUI.show_choice(
		"Esqueleto",
		"Hello! Are you ready to battle?",
		options,
		Callable(self, "_on_battle_choice")
	)
	get_viewport().set_input_as_handled()

func _on_battle_choice(selected_index: int) -> void:
	if selected_index == 0:
		_start_battle()
		return
	if player_perto:
		interaction_label.show()

func _start_battle() -> void:
	battle_active = true
	enemy_hp = 3
	enemy_hp_label.text = "Enemy HP: " + str(enemy_hp)
	enemy_hp_label.show()
	DialogueUI.show_quiz(
		"Esqueleto",
		perguntas,
		Callable(self, "_on_battle_answer"),
		Callable(self, "_on_battle_finished"),
		"You won!"
	)

func _on_battle_answer(_question_index: int, is_correct: bool) -> void:
	if is_correct:
		enemy_hp -= 1
		enemy_hp_label.text = "Enemy HP: " + str(maxi(enemy_hp, 0))
		return

	var remaining_hp: int = GameState.damage_player(1)
	if remaining_hp <= 0:
		DialogueUI.close()
		battle_active = false
		_handle_defeat()

func _handle_defeat() -> void:
	await get_tree().create_timer(0.35).timeout
	GameState.return_to_city01_after_defeat()

func _on_battle_finished() -> void:
	battle_active = false
	enemy_hp_label.hide()
	interaction_label.hide()
	enemy.hide()

# Compatibilidade com conexões antigas da cena; a interface legada permanece oculta.
func _on_attack_button_pressed() -> void:
	pass

func _on_yes_button_pressed() -> void:
	pass

func _on_no_button_pressed() -> void:
	pass
