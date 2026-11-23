extends CharacterBody2D

const CHARACTER_TEXTURES: Array[Texture2D] = [
	preload("res://assets/characters/player/overworld/player_walk.png"),
	preload("res://assets/characters/player/female/player_female.png"),
	preload("res://assets/characters/player/extra/garota_azul.png"),
	preload("res://assets/characters/player/extra/garoto_ruivo.png")
]

@export var speed: float = 150.0
@onready var sprite: Sprite2D = $Sprite2D

var facing_row: int = 0
var anim_timer: float = 0.0

func _ready() -> void:
	apply_selected_appearance()
	sprite.hframes = 3
	sprite.vframes = 4
	sprite.frame = 0
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_to_group("player")

func apply_selected_appearance() -> void:
	sprite.texture = CHARACTER_TEXTURES[clampi(GameState.player_appearance, 0, 3)]
	sprite.hframes = 3
	sprite.vframes = 4
	sprite.scale = Vector2(0.34, 0.34)
	sprite.position = Vector2(0, -19)

func _physics_process(delta: float) -> void:
	if DialogueUI.is_open() or GameHUD.is_modal_open():
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var x: float = 0.0
	var y: float = 0.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		y += 1.0

	var direction: Vector2 = Vector2(x, y).normalized()
	velocity = direction * speed

	if direction != Vector2.ZERO:
		if abs(direction.x) > abs(direction.y):
			facing_row = 2 if direction.x < 0.0 else 3
		else:
			facing_row = 1 if direction.y < 0.0 else 0
		anim_timer += delta
		var column: int = 1 + int(anim_timer * 8.0) % 2
		sprite.frame = facing_row * 3 + column
	else:
		anim_timer = 0.0
		sprite.frame = facing_row * 3

	move_and_slide()
