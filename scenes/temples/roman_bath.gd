extends "res://scripts/systems/temple_camera_setup.gd"

## Banhos romanos de Bath (substituem o templo padrão nesta cidade).
## Entrar em uma das piscinas restaura toda a vida do jogador e mostra uma
## mensagem temporária. Se a vida já estiver cheia, nada acontece.

const MESSAGE_VISIBLE_SECONDS: float = 2.5
const MESSAGE_FADE_SECONDS: float = 0.6

@onready var _pools: Array[Area2D] = [
	$TileMapLayer/Room/LeftPool,
	$TileMapLayer/Room/RightPool,
]
@onready var _message_label: Label = $HealMessage/Label

var _message_tween: Tween

func _ready() -> void:
	super._ready()
	_message_label.modulate.a = 0.0
	for pool in _pools:
		pool.body_entered.connect(_on_pool_body_entered)

func _on_pool_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if GameState.player_health >= GameState.MAX_HEALTH:
		return

	GameState.restore_full_health()
	_show_message(
		"The warm spring water restores your strength!\n(A água termal restaurou sua vida: %d/%d)"
		% [GameState.player_health, GameState.MAX_HEALTH]
	)

func _show_message(text: String) -> void:
	_message_label.text = text
	if _message_tween != null and _message_tween.is_valid():
		_message_tween.kill()
	_message_label.modulate.a = 1.0
	_message_tween = create_tween()
	_message_tween.tween_interval(MESSAGE_VISIBLE_SECONDS)
	_message_tween.tween_property(_message_label, "modulate:a", 0.0, MESSAGE_FADE_SECONDS)
