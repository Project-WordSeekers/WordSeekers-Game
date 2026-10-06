extends Area2D

@onready var prompt: Label = $Prompt

var player_nearby: bool = false
var interaction_active: bool = false

var first_dialogue_lines: Array[String] = [
	"Olá, WordSeeker. Meu nome é Charles Abbot, 1º Barão de Colchester.",
	"Você chegou em tempos estranhos. Após uma grande tempestade, criaturas mágicas surgiram por toda a Grã-Bretanha.",
	"Desde então, algo ainda mais inquietante vem acontecendo: as pessoas estão esquecendo o idioma inglês!",
	"Foi por isso que chamamos você. Um WordSeeker — um desbravador de palavras.",
	"Sua missão é redescobrir o idioma e trazer a magia das palavras de volta ao povo.",
	"Antes de partir, preciso explicar como se movimentar por este mundo.",
	"Use WASD ou as setas do teclado para caminhar. Pressione E para interagir com pessoas e objetos, avançar diálogos e confirmar escolhas.",
	"No canto superior esquerdo da tela está sua barra de HP — seus Health Points. Você começa com 10 pontos de vida.",
	"Durante uma batalha, cada resposta errada em um quiz faz você perder 1 HP. Se chegar a zero, você retornará à Cidade 01.",
	"Pressione H a qualquer momento para abrir a Ajuda. Pressione I para abrir sua Mochila.",
	"Antes de seguir viagem, quero lhe confiar uma ferramenta importante: O Dicionário.",
	"Este grimório possui 3 usos durante quizzes. Quando precisar de ajuda, pressione T — de Translate — para revelar a resposta correta da pergunta atual.",
	"Use esses três auxílios com sabedoria. Mesmo depois que os usos acabarem, o Dicionário continuará guardado em sua mochila.",
	"Boa sorte, WordSeeker. Que você redescubra o idioma e devolva à Grã-Bretanha a magia das palavras."
]

var repeat_dialogue_lines: Array[String] = [
	"WordSeeker, não se esqueça de sua missão: redescobrir o inglês e devolver ao povo a magia das palavras.",
	"WASD ou setas movem você; E interage; H abre a Ajuda; I abre a Mochila.",
	"Durante quizzes, pressione T para usar O Dicionário enquanto ainda houver usos disponíveis.",
	"Boa sorte em sua jornada."
]

func _ready() -> void:
	prompt.text = "[E] Falar"
	prompt.hide()
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
