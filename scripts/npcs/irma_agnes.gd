extends Area2D

@onready var prompt: Label = $Prompt
var player_nearby: bool = false

var dialogue_lines: Array[String] = [
    "O Priorado de St Botolph foi fundado no início do século XII, em Colchester, por cônegos agostinianos.",
    "Sua igreja foi uma das primeiras grandes construções da Inglaterra a utilizar tijolos romanos reaproveitados. Suas ruínas ainda mostram os belos arcos normandos.",
    "Durante a Dissolução dos Mosteiros, no século XVI, o priorado foi fechado. Mais tarde, sofreu grandes danos na Guerra Civil Inglesa, em 1648, mas suas ruínas continuam contando nossa história."
]

func _ready() -> void:
    prompt.text = "[E] Falar"
    prompt.hide()
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

func _unhandled_input(event: InputEvent) -> void:
    if not player_nearby or not event.is_action_pressed("interact"):
        return
    if DialogueUI.is_open():
        return
    prompt.hide()
    DialogueUI.show_sequence("Irmã Agnes", dialogue_lines, Callable(self, "_on_dialogue_closed"))
    get_viewport().set_input_as_handled()

func _on_dialogue_closed() -> void:
    if player_nearby:
        prompt.show()

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        player_nearby = true
        if not DialogueUI.is_open():
            prompt.show()

func _on_body_exited(body: Node2D) -> void:
    if body.is_in_group("player"):
        player_nearby = false
        prompt.hide()
