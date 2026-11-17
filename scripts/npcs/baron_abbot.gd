extends Area2D

@onready var prompt: Label = $Prompt

var player_nearby: bool = false
var interaction_active: bool = false

@export var npc_id: String = ""
const NPC_INDICATOR_SCRIPT: Script = preload("res://scripts/npcs/npc_dialogue_indicator.gd")
var npc_indicator

<<<<<<< HEAD
func _setup_npc_indicator() -> void:
	npc_indicator = NPC_INDICATOR_SCRIPT.new()
	add_child(npc_indicator)
	npc_indicator.setup(self, npc_id)
=======
func _ensure_new_dialogue_icon() -> void:
	if new_dialogue_icon != null:
		return
	new_dialogue_icon = Sprite2D.new()
	new_dialogue_icon.name = "NewDialogueIcon"
	new_dialogue_icon.texture = NEW_DIALOGUE_ICON_TEXTURE
	new_dialogue_icon.centered = true
	new_dialogue_icon.scale = Vector2(0.03, 0.03)
	new_dialogue_icon.position = Vector2(0, -80)
	new_dialogue_icon.z_index = 30
	add_child(new_dialogue_icon)
	var float_tween := create_tween()
	float_tween.set_loops()
	float_tween.tween_property(new_dialogue_icon, "position:y", -84.0, 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	float_tween.tween_property(new_dialogue_icon, "position:y", -80.0, 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _get_npc_id() -> String:
	if npc_id.strip_edges() != "":
		return npc_id.strip_edges()
	var scene_id: String = scene_file_path.get_file().get_basename() if scene_file_path != "" else "runtime"
	return "%s::%s" % [scene_id, get_path()]

func _refresh_new_dialogue_icon() -> void:
	_ensure_new_dialogue_icon()
	new_dialogue_icon.visible = not GameState.has_talked_to_npc(_get_npc_id())
>>>>>>> d177ccc02db95598f2d303153582984d643d6959


var first_dialogue_lines: Array[String] = [
	"Olá, WordSeeker. Meu nome é Charles Abbot, 1º Barão de Colchester.",
	"Você chegou em tempos estranhos. Após uma grande tempestade, criaturas mágicas surgiram por toda a Grã-Bretanha.",
	"Desde então, algo ainda mais inquietante vem acontecendo: as pessoas estão esquecendo o idioma inglês!",
	"Foi por isso que chamamos você. Um WordSeeker — um desbravador de palavras.",
	"Sua missão é redescobrir o idioma e trazer a magia das palavras de volta ao povo.",
	"Converse com as pessoas em todas as cidades que visitar. Cada morador guarda palavras, histórias e conhecimentos que podem nos ajudar a reconstruir o inglês.",
	"Antes de partir, preciso explicar como se movimentar por este mundo.",
	"Use WASD ou as setas do teclado para caminhar. Pressione E para interagir com pessoas e objetos, avançar diálogos e confirmar escolhas.",
	"Antes de seguir viagem, quero lhe confiar uma ferramenta importante: O Dicionário.",
	"Este grimório possui 3 usos durante quizzes. Quando precisar de ajuda, pressione T — de Translate — para revelar a resposta correta da pergunta atual.",
	"Use esses três auxílios com sabedoria. Mesmo depois que os usos acabarem, o Dicionário continuará guardado em sua mochila.",
	"Boa sorte, WordSeeker. Que você redescubra o idioma e devolva à Grã-Bretanha a magia das palavras."
]

var repeat_dialogue_lines: Array[String] = [
	"WordSeeker, não se esqueça de sua missão: redescobrir o inglês e devolver ao povo a magia das palavras.",
	"Visite todas as cidades e converse com seus moradores. Cada conversa ajuda a reunir o conhecimento perdido e abre caminho para continuar sua jornada.",
	"WASD ou setas movem você e E permite conversar e interagir.",
	"Durante quizzes, pressione T para usar O Dicionário enquanto ainda houver usos disponíveis.",
	"Boa sorte em sua jornada."
]

func _ready() -> void:
	prompt.text = "[E] Falar"
	prompt.hide()
	_setup_npc_indicator()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _unhandled_input(event: InputEvent) -> void:
	if not player_nearby or interaction_active or DialogueUI.is_open() or GameHUD.is_modal_open():
		return
	if not event.is_action_pressed("interact"):
		return

	interaction_active = true
	prompt.hide()
	var lines: Array[String] = repeat_dialogue_lines if GameState.dictionary_owned else first_dialogue_lines
	DialogueUI.show_sequence(
		"Charles Abbot",
		lines,
		Callable(self, "_on_dialogue_finished")
	)
	get_viewport().set_input_as_handled()

func _on_dialogue_finished() -> void:
	if not GameState.dictionary_owned:
		var granted: bool = GameState.grant_dictionary()
		if granted:
			DialogueUI.show_dialogue(
				"Item recebido",
				"O Dicionário\n\n%s\n\nUsos: %d/%d\nDurante quizzes, pressione T (Translate) para usar." % [
					GameState.DICTIONARY_DESCRIPTION,
					GameState.dictionary_uses,
					GameState.DICTIONARY_MAX_USES
				],
				Callable(self, "_finish_interaction")
			)
			return
	_finish_interaction()

func _finish_interaction() -> void:
	npc_indicator.mark_talked(String(GameState.world_map_point_name))
	interaction_active = false
	if player_nearby and not DialogueUI.is_open():
		prompt.show()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true
		if not DialogueUI.is_open() and not GameHUD.is_modal_open():
			prompt.show()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
		prompt.hide()
