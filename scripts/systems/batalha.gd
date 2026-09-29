extends Node2D

var player_hp: int = 3
var enemy_hp: int = 3
var player_perto: bool = false
var pergunta_atual: int = 0

var perguntas: Array[String] = [
	"A book is a _____.",
	"A Pen is a _____.",
	"The opposite of hot is _____."
]

var respostas: Array[String] = [
	"livro",
	"caneta",
	"cold"
]

@onready var player_hp_label: Label = $PlayerHPLabel
@onready var enemy_hp_label: Label = $EnemyHPLabel
@onready var interaction_label: Label = $InteractionLabel
@onready var yes_button: Button = $YesButton
@onready var no_button: Button = $NoButton
@onready var question_panel: Panel = $QuestionPanel
@onready var question_label: Label = $QuestionPanel/QuestionLabel
@onready var answer_input: LineEdit = $AnswerInput
@onready var attack_button: Button = $AttackButton
@onready var result_label: Label = $ResultLabel
@onready var enemy: Sprite2D = $Inimigo

func _ready() -> void:
	player_hp_label.text = "Player HP: " + str(player_hp)
	enemy_hp_label.text = "Enemy HP: " + str(enemy_hp)
	interaction_label.hide()
	yes_button.hide()
	no_button.hide()
	question_panel.hide()
	answer_input.hide()
	attack_button.hide()
	result_label.hide()

func _on_attack_button_pressed() -> void:
	if pergunta_atual < 0 or pergunta_atual >= respostas.size():
		return

	var resposta: String = answer_input.text.to_lower().strip_edges()

	if resposta == respostas[pergunta_atual]:
		enemy_hp -= 1
		enemy_hp_label.text = "Enemy HP: " + str(enemy_hp)
		result_label.text = "Correct! You attacked the enemy!"
		result_label.show()

		if enemy_hp <= 0:
			await _finish_battle()
			return

		pergunta_atual += 1
		if pergunta_atual < perguntas.size():
			question_label.text = perguntas[pergunta_atual]
			answer_input.clear()

		await get_tree().create_timer(1.5).timeout
		result_label.hide()
	else:
		player_hp -= 1
		player_hp_label.text = "Player HP: " + str(player_hp)
		result_label.text = "Wrong! The enemy attacks you!"
		result_label.show()

		await get_tree().create_timer(1.5).timeout
		result_label.hide()

func _finish_battle() -> void:
	result_label.text = "You won!"
	result_label.show()
	question_panel.hide()
	answer_input.hide()
	attack_button.hide()

	await get_tree().create_timer(2.0).timeout

	result_label.hide()
	enemy_hp_label.hide()
	player_hp_label.hide()
	interaction_label.hide()
	enemy.hide()

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_perto = true
		interaction_label.text = "Press E para falar"
		interaction_label.show()

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_perto = false
		interaction_label.hide()
		yes_button.hide()
		no_button.hide()

func _unhandled_input(event: InputEvent) -> void:
	if not player_perto:
		return

	if event.is_action_pressed("interact"):
		interaction_label.text = "Hello! Are you ready to battle?"
		yes_button.show()
		no_button.show()
		get_viewport().set_input_as_handled()

func _on_yes_button_pressed() -> void:
	yes_button.hide()
	no_button.hide()
	interaction_label.hide()

	player_hp_label.show()
	enemy_hp_label.show()
	question_panel.show()
	answer_input.show()
	attack_button.show()

	pergunta_atual = 0
	question_label.text = perguntas[pergunta_atual]
	answer_input.clear()
	answer_input.grab_focus()

func _on_no_button_pressed() -> void:
	yes_button.hide()
	no_button.hide()
	interaction_label.text = "Press E para falar"
