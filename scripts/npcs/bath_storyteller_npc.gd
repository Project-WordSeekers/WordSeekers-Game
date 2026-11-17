extends Area2D
# Narradora de Bath: conta a história da cidade, ensina os substantivos do banheiro
# e aplica um quiz que junta o vocabulário novo com o que o jogo já ensinou
# (saudações, números, artigos a/an, plural e verbo to be).

@export var speaker_name: String = "Sister Abigail"
@export var prompt_text: String = "[E] Falar"
@export var npc_id: String = "bath_storyteller"

const NEW_DIALOGUE_ICON_TEXTURE: Texture2D = preload("res://assets/ui/icons/npc_new_dialogue_exclamation.png")

const HISTORY_LINES: Array[String] = [
	"Hello, WordSeeker! My name is Sister Abigail.\nI am the storyteller of Bath.",
	"A long time ago, the Romans came to this valley.\nThey found HOT WATER coming out of the ground!\n(Água quente saindo do chão!)",
	"The Romans built big baths and a temple here.\nThey called the town AQUAE SULIS,\nthe waters of the goddess Sulis Minerva.",
	"People came to wash, to relax and to meet friends.\nYou can still see the Roman Baths today,\nnext to the Abbey.",
	"Many years later, the people built Bath Abbey\nin the middle of the city.\nLook at the angels on the ladders of its front!",
	"In the 1700s, Bath was very fashionable.\nRich families built the Royal Crescent and the Circus\nwith this beautiful golden stone.",
	"The writer Jane Austen lived here, too.\nToday, Bath is a World Heritage Site.\n(Patrimônio Mundial da UNESCO)",
]

const VOCABULARY_LINES: Array[String] = [
	"The name of the city is BATH...\nlike the BATH in your house!\nSo let's learn the things in a BATHROOM (banheiro).",
	"BATHTUB = banheira\nSHOWER = chuveiro\n\"I take a bath in the bathtub.\"",
	"SOAP = sabonete\nSHAMPOO = xampu\nTOWEL = toalha\n\"I use soap and a towel.\"",
	"SINK = pia\nMIRROR = espelho\nTOILET = vaso sanitário",
	"TOOTHBRUSH = escova de dente\nTOOTHPASTE = pasta de dente\nCOMB = pente",
	"In the morning, I go to the bathroom.\nI wash my face in the sink\nand I look in the mirror.",
	"Then I brush my teeth with my toothbrush\nand toothpaste. After the shower,\nI use a towel and my comb.",
	"The Romans did not have a shower...\nbut they had big, warm baths!\nThey used oil and a special tool to clean the skin.",
	"Now, let's see what you know!\nAre you ready? Let's start the quiz!",
]

const QUIZ: Array[Dictionary] = [
	{
		"prompt": "Good morning, WordSeeker!\nThe Romans found something special in Bath.\nWhat was it?",
		"answers": ["A) Hot water", "B) Gold", "C) Snow", "D) Old books"],
		"correct": 0,
		"explanation": "Os romanos encontraram ÁGUA QUENTE (hot water) saindo do chão. Por isso construíram as termas.",
	},
	{
		"prompt": "What is the Roman name of Bath?",
		"answers": ["A) Royal Crescent", "B) Aquae Sulis", "C) Roman Walls", "D) Mathematical Bridge"],
		"correct": 1,
		"explanation": "AQUAE SULIS quer dizer \"as águas de Sulis\", a deusa Sulis Minerva.",
	},
	{
		"prompt": "You are at the Roman Baths.\nYou are wet after the bath.\nWhat do you need?",
		"answers": ["A) A comb", "B) A mirror", "C) A towel", "D) A toothbrush"],
		"correct": 2,
		"explanation": "Depois do banho, usamos uma TOWEL (toalha) para secar o corpo.",
	},
	{
		"prompt": "Why do people come to the Roman Baths?\n\"People come here to ___.\"",
		"answers": ["A) wash and relax", "B) buy shoes", "C) read in the library", "D) cross the river"],
		"correct": 0,
		"explanation": "Os romanos iam às termas para se lavar e relaxar: to wash and to relax.",
	},
	{
		"prompt": "Look at the front of Bath Abbey.\nWhat can you see on the ladders?",
		"answers": ["A) Roman soldiers", "B) Angels", "C) Towels", "D) Dragons"],
		"correct": 1,
		"explanation": "A fachada da Abadia de Bath tem ANJOS (angels) subindo escadas (ladders) de pedra.",
	},
	{
		"prompt": "In the 1700s, rich families came to Bath.\nWhat did they build with the golden stone?",
		"answers": ["A) The Roman Baths", "B) The Royal Crescent", "C) Colchester Castle", "D) The Mathematical Bridge"],
		"correct": 1,
		"explanation": "No século XVIII foram construídos o ROYAL CRESCENT e o Circus, com a pedra dourada de Bath.",
	},
	{
		"prompt": "It is night. You want clean teeth.\nYou use your toothbrush and...",
		"answers": ["A) shampoo", "B) a towel", "C) toothpaste", "D) the toilet"],
		"correct": 2,
		"explanation": "Escovamos os dentes com TOOTHBRUSH (escova) e TOOTHPASTE (pasta de dente).",
	},
	{
		"prompt": "Jane Austen lived in Bath.\nShe is a famous...",
		"answers": ["A) teacher", "B) writer", "C) goddess", "D) Roman soldier"],
		"correct": 1,
		"explanation": "Jane Austen é uma escritora (WRITER) inglesa famosa. Ela morou em Bath de 1801 a 1806.",
	},
]

var new_dialogue_icon: Sprite2D
var player_nearby: bool = false
var busy: bool = false

@onready var prompt: Label = $Prompt

func _ready() -> void:
	prompt.text = prompt_text
	prompt.hide()
	_ensure_new_dialogue_icon()
	_refresh_new_dialogue_icon()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _ensure_new_dialogue_icon() -> void:
	if new_dialogue_icon != null:
		return
	new_dialogue_icon = Sprite2D.new()
	new_dialogue_icon.name = "NewDialogueIcon"
	new_dialogue_icon.texture = NEW_DIALOGUE_ICON_TEXTURE
	new_dialogue_icon.scale = Vector2(0.03, 0.03)
	new_dialogue_icon.position = Vector2(0, -80)
	new_dialogue_icon.z_index = 30
	add_child(new_dialogue_icon)
	var float_tween := create_tween()
	float_tween.set_loops()
	float_tween.tween_property(new_dialogue_icon, "position:y", -84.0, 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	float_tween.tween_property(new_dialogue_icon, "position:y", -80.0, 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _refresh_new_dialogue_icon() -> void:
	_ensure_new_dialogue_icon()
	new_dialogue_icon.visible = not GameState.has_talked_to_npc(npc_id)

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
			"Welcome back, WordSeeker!\nWhat do you want to do?",
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
		"Wonderful, WordSeeker!\nYou know the story of Bath\nand the words of the bathroom!"
	)

func _on_quiz_finished() -> void:
	GameState.register_npc_talked(npc_id, String(GameState.world_map_point_name))
	_finish()

func _finish() -> void:
	_refresh_new_dialogue_icon()
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
