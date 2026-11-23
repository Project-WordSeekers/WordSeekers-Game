extends Area2D
# Narradora de Bath: conta a história da cidade, ensina os substantivos do banheiro
# e aplica um quiz que junta o vocabulário novo com o que o jogo já ensinou
# (saudações, números, artigos a/an, plural e verbo to be).

@export var speaker_name: String = "Sister Abigail"
@export var prompt_text: String = "[E] Falar"
@export var npc_id: String = "bath_storyteller"

const INDICATOR = preload("res://scripts/npcs/npc_dialogue_indicator.gd")

const HISTORY_LINES: Array[String] = [
	"Olá, WordSeeker! Sou a Irmã Abigail, cronista de Bath.",
	"Os romanos encontraram água quente saindo do chão. Em inglês, água quente é hot water.",
	"Eles construíram termas e um templo. Chamaram a cidade de Aquae Sulis, as águas de Sulis.",
	"As pessoas iam às termas para se lavar, relaxar e encontrar amigos. Hoje, você pode visitar as termas ao lado da abadia.",
	"Na fachada da Abadia de Bath, repare nos anjos que sobem pelas escadas. Anjos são angels e escadas de mão são ladders.",
	"No século XVIII, famílias ricas construíram o Royal Crescent e o Circus com a pedra dourada da cidade.",
	"A escritora Jane Austen também morou aqui. Em inglês, escritora é writer.",
]

const VOCABULARY_LINES: Array[String] = [
	"O nome Bath lembra a palavra bath, que significa banho. Vamos conhecer objetos do banheiro, ou bathroom.",
	"Bathtub é banheira e shower é chuveiro. I take a bath in the bathtub significa Tomo banho na banheira.",
	"Soap é sabonete, shampoo é xampu e towel é toalha. I use soap and a towel significa Uso sabonete e uma toalha.",
	"Sink é pia, mirror é espelho e toilet é vaso sanitário.",
	"Toothbrush é escova de dentes, toothpaste é pasta de dentes e comb é pente.",
	"I wash my face in the sink significa Lavo o rosto na pia. After the shower, I use a towel significa Depois do banho, uso uma toalha.",
	"Agora, vamos praticar o vocabulário e relembrar a história de Bath.",
]

const QUIZ: Array[Dictionary] = [
	{
		"prompt": "O que os romanos encontraram em Bath?",
		"answers": ["A) Hot water", "B) Gold", "C) Snow", "D) Old books"],
		"correct": 0,
		"explanation": "Os romanos encontraram ÁGUA QUENTE (hot water) saindo do chão. Por isso construíram as termas.",
	},
	{
		"prompt": "Qual era o nome romano de Bath?",
		"answers": ["A) Royal Crescent", "B) Aquae Sulis", "C) Roman Walls", "D) Mathematical Bridge"],
		"correct": 1,
		"explanation": "AQUAE SULIS quer dizer \"as águas de Sulis\", a deusa Sulis Minerva.",
	},
	{
		"prompt": "Você saiu do banho e precisa se secar. Qual objeto você usa?",
		"answers": ["A) A comb", "B) A mirror", "C) A towel", "D) A toothbrush"],
		"correct": 2,
		"explanation": "Depois do banho, usamos uma TOWEL (toalha) para secar o corpo.",
	},
	{
		"prompt": "Por que as pessoas iam às termas? Complete em inglês.\nPeople come here to ___.",
		"answers": ["A) wash and relax", "B) buy shoes", "C) read in the library", "D) cross the river"],
		"correct": 0,
		"explanation": "Os romanos iam às termas para se lavar e relaxar: to wash and to relax.",
	},
	{
		"prompt": "O que você pode ver nas escadas da fachada da Abadia de Bath?",
		"answers": ["A) Roman soldiers", "B) Angels", "C) Towels", "D) Dragons"],
		"correct": 1,
		"explanation": "A fachada da Abadia de Bath tem ANJOS (angels) subindo escadas (ladders) de pedra.",
	},
	{
		"prompt": "O que as famílias ricas construíram com a pedra dourada no século XVIII?",
		"answers": ["A) The Roman Baths", "B) The Royal Crescent", "C) Colchester Castle", "D) The Mathematical Bridge"],
		"correct": 1,
		"explanation": "No século XVIII foram construídos o ROYAL CRESCENT e o Circus, com a pedra dourada de Bath.",
	},
	{
		"prompt": "Você vai escovar os dentes. O que usa junto com a escova?",
		"answers": ["A) shampoo", "B) a towel", "C) toothpaste", "D) the toilet"],
		"correct": 2,
		"explanation": "Escovamos os dentes com TOOTHBRUSH (escova) e TOOTHPASTE (pasta de dente).",
	},
	{
		"prompt": "Jane Austen morou em Bath. Qual era a profissão dela?",
		"answers": ["A) teacher", "B) writer", "C) goddess", "D) Roman soldier"],
		"correct": 1,
		"explanation": "Jane Austen é uma escritora (WRITER) inglesa famosa. Ela morou em Bath de 1801 a 1806.",
	},
]

var new_dialogue_icon = INDICATOR.new()
var player_nearby: bool = false
var busy: bool = false

@onready var prompt: Label = $Prompt

func _ready() -> void:
	prompt.text = prompt_text
	prompt.hide()
	add_child(new_dialogue_icon)
	new_dialogue_icon.setup(self, npc_id)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _unhandled_input(event: InputEvent) -> void:
	if not player_nearby or busy or DialogueUI.is_open():
		return
	if not event.is_action_pressed("interact"):
		return
	get_viewport().set_input_as_handled()
	busy = true
	prompt.hide()
	if GameState.has_talked_to_npc(npc_id):
		# Na volta: o jogador escolhe o que quer rever.
		DialogueUI.show_choice(
			speaker_name,
			"Que bom que voltou! O que você quer fazer?",
			["Ouvir a história de Bath", "Revisar o vocabulário", "Fazer o quiz", "Tchau!"],
			Callable(self, "_on_menu")
		)
	else:
		_start_history()

func _on_menu(index: int) -> void:
	match index:
		0:
			_start_history()
		1:
			DialogueUI.show_sequence(speaker_name, VOCABULARY_LINES, Callable(self, "_start_quiz"))
		2:
			_start_quiz()
		_:
			_finish()

func _start_history() -> void:
	DialogueUI.show_sequence(speaker_name, HISTORY_LINES, Callable(self, "_start_vocabulary"))

func _start_vocabulary() -> void:
	DialogueUI.show_sequence(speaker_name, VOCABULARY_LINES, Callable(self, "_start_quiz"))

func _start_quiz() -> void:
	DialogueUI.show_quiz(
		speaker_name,
		QUIZ,
		Callable(),
		Callable(self, "_on_quiz_finished"),
		"Muito bem! Você revisou a história de Bath e o vocabulário do banheiro."
	)

func _on_quiz_finished() -> void:
	GameState.register_npc_talked(npc_id, String(GameState.world_map_point_name))
	_finish()

func _finish() -> void:
	new_dialogue_icon.refresh()
	busy = false
	if player_nearby:
		prompt.show()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true
		if not DialogueUI.is_open() and not busy:
			prompt.show()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
		prompt.hide()
