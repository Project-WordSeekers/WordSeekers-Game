extends "res://scripts/systems/batalha.gd"

const BOSS_NAME := "The Vocabullary Eater"
const BOSS_HP := 10
const MEDIUM: Array[Dictionary] = [
	{"prompt":"Complete: She ___ a teacher.", "answers":["am","are","is","be","have"], "correct":2, "explanation":"Com she, use is."},
	{"prompt":"Qual frase pede permissão?", "answers":["I can swim.","Can I come in?","I am swimming.","She can sing.","We swim every day."], "correct":1, "explanation":"Can I come in? significa Posso entrar?"},
	{"prompt":"Complete: How ___ apples are in the basket?", "answers":["much","some","any","many","a little"], "correct":3, "explanation":"Use many para itens contáveis no plural."},
	{"prompt":"Qual frase descreve uma ação acontecendo agora?", "answers":["They walk every day.","They can walk.","They are walking.","Are they students?","They live here."], "correct":2, "explanation":"Are walking é o presente contínuo."},
]
const HARD: Array[Dictionary] = [
	{"prompt":"No aviso «The shop is actually closed», o que actually significa?", "answers":["atualmente","às vezes","em breve","na verdade","novamente"], "correct":3, "explanation":"Actually é um falso cognato. Aqui significa na verdade."},
	{"prompt":"Bilhete: Bristol after ten. Tabela: Star — York — 10:00; Rose — Bristol — 11:00; Oak — Bristol — 09:00. Qual navio atende ao bilhete?", "answers":["Star","Rose","Oak","Os três","Nenhum"], "correct":1, "explanation":"O Rose vai a Bristol e sai depois das dez."},
	{"prompt":"Leia: «The rooms contain coins, tools and pots. Together, they show how Roman families lived.» Qual é a ideia principal?", "answers":["Preços de ferramentas","Horários do museu","A vida cotidiana das famílias romanas","A fabricação de moedas modernas","Como chegar às salas"], "correct":2, "explanation":"O skimming ajuda a captar o assunto geral: como as famílias romanas viviam."},
	{"prompt":"Complete a revisão do mapa: «First, find the gate. Then, follow the river. ___, stop at the bridge.»", "answers":["Because","Finally","But","Although","Or"], "correct":1, "explanation":"Finally indica a última etapa de uma sequência."},
]
const SPELLS := [
	["You", "can't", "silence", "the", "voice", "of", "the", "people", "!"],
	["I", "am", "bringing", "back", "the", "Words", "you", "ate", "!"],
	["Our", "voices", "will", "be", "heard", "all", "across", "the", "land...", "Goodbye", "!"],
]
const HINTS := [
	"Você não pode calar a voz do povo!",
	"Estou trazendo de volta as palavras que você devorou!",
	"Nossas vozes serão ouvidas por todo o reino... Adeus!",
]

var spell_index := 0
var selected_words: Array[String] = []
var word_tiles: HFlowContainer
var sentence: Label
var spell_feedback: Label
var spell_layer: CanvasLayer
var spell_panel: PanelContainer

func _ready() -> void:
	battle_active = true
	_setup_battle_actors()
	enemy.texture = load("res://assets/characters/enemies/vocabullary_eater.png")
	_position_battle_actors()
	_hide_legacy_battle_ui()
	interaction_label.hide()
	enemy_hp_label.hide()
	enemy_hp = BOSS_HP
	enemy_hp_bar.max_value = BOSS_HP
	enemy_hp_bar.show_percentage = false
	enemy_hp_bar.show()
	_update_enemy_hp_color()
	DialogueUI.show_dialogue(BOSS_NAME, "You found the fragments. Now prove that you can put them together!", _start_medium)

func _update_enemy_hp_color() -> void:
	enemy_hp_bar.value = enemy_hp
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#a05de2")
	style.set_corner_radius_all(4)
	enemy_hp_bar.add_theme_stylebox_override("fill", style)
	var caption: Label = enemy_hp_bar.get_node_or_null("HP")
	if caption == null:
		caption = Label.new()
		caption.name = "HP"
		enemy_hp_bar.add_child(caption)
		caption.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.text = "%d / %d HP" % [enemy_hp, BOSS_HP]

func _start_medium() -> void:
	DialogueUI.show_quiz(BOSS_NAME, MEDIUM, _on_battle_answer, _start_word_search, "Primeira etapa concluída. Pressione E para o caça-palavras.")

func _start_word_search() -> void:
	var vocabulary: Array[String] = ["KNOWLEDGE", "FRAGMENT", "LANGUAGE", "SENTENCE", "MEANING", "COURAGE", "LIBRARY", "JOURNEY"]
	WordSearchUI.open_book("boss_vocabulary", "O Desafio dos Fragmentos", "Difícil", 16, vocabulary, _word_search_won)

func _word_search_won() -> void:
	_damage_boss()
	DialogueUI.show_quiz(BOSS_NAME, HARD, _on_battle_answer, _create_spell, "Segunda etapa concluída. Pressione E para o Feitiço das Palavras.")

func _on_battle_answer(index: int, correct: bool) -> void:
	if correct:
		_damage_boss()
	else:
		super._on_battle_answer(index, false)

func _damage_boss() -> void:
	monster_damage_sound.play()
	enemy_hp -= 1
	_update_enemy_hp_color()

func _create_spell() -> void:
	spell_layer = CanvasLayer.new()
	spell_layer.layer = 85
	add_child(spell_layer)
	var center := CenterContainer.new()
	spell_layer.add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	spell_panel = PanelContainer.new()
	spell_panel.custom_minimum_size.x = 550
	center.add_child(spell_panel)
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 18)
	spell_panel.add_child(margin)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	margin.add_child(content)
	var title := Label.new()
	title.text = "O Feitiço das Palavras"
	title.add_theme_font_size_override("font_size", 22)
	content.add_child(title)
	spell_feedback = Label.new()
	content.add_child(spell_feedback)
	sentence = Label.new()
	sentence.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(sentence)
	word_tiles = HFlowContainer.new()
	content.add_child(word_tiles)
	var actions := HBoxContainer.new()
	content.add_child(actions)
	var reset := Button.new()
	reset.text = "Refazer bloco"
	reset.pressed.connect(_shuffle_spell)
	actions.add_child(reset)
	var confirm := Button.new()
	confirm.text = "Confirmar ordem"
	confirm.pressed.connect(_confirm_spell)
	actions.add_child(confirm)
	_shuffle_spell()

func _shuffle_spell() -> void:
	selected_words.clear()
	sentence.text = "Escolha as palavras na ordem correta."
	spell_feedback.text = "Bloco %d/3 — %s" % [spell_index + 1, HINTS[spell_index]]
	for node in word_tiles.get_children():
		word_tiles.remove_child(node)
		node.queue_free()
	var shuffled: Array = SPELLS[spell_index].duplicate()
	shuffled.shuffle()
	if shuffled == SPELLS[spell_index]:
		shuffled.reverse()
	for word in shuffled:
		var tile := Button.new()
		tile.text = word
		tile.pressed.connect(_choose_word.bind(tile))
		word_tiles.add_child(tile)

func _choose_word(tile: Button) -> void:
	tile.disabled = true
	selected_words.append(tile.text)
	sentence.text = " ".join(selected_words)

func _confirm_spell() -> void:
	if spell_index >= SPELLS.size():
		return
	if " ".join(selected_words) != " ".join(SPELLS[spell_index]):
		spell_feedback.text = "A ordem ainda não está certa. Use Refazer bloco e tente novamente."
		return
	spell_index += 1
	if spell_index < SPELLS.size():
		_shuffle_spell()
		return
	_damage_boss()
	spell_layer.hide()
	spell_layer.queue_free()
	GameState.boss_defeated = true
	GameState.save_progress()
	DialogueUI.show_sequence(BOSS_NAME, [
		"Você me venceu, WordSeeker. Em cada cidade, você ouviu alguém que tinha algo a ensinar.",
		"Aprendeu a fazer perguntas, a entender novas respostas e a juntar palavras até conseguir dizer o que queria. Quando errou, tentou de novo.",
		"Foi assim que você devolveu a voz a este reino. As palavras estão livres. Agora, o que você vai dizer com elas?",
	], _show_credits)

func _show_credits() -> void:
	SceneTransition.change_scene_to_file("res://scenes/ui/end_credits.tscn")
