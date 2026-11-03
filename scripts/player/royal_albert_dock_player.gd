extends CharacterBody2D

@export var speed: float = 125.0
@export var animation_fps: float = 8.0
@onready var sprite: Sprite2D = $Sprite2D
var facing_row: int = 0
var anim_time: float = 0.0

func _ready() -> void:
    add_to_group("player")
    sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    sprite.frame = 0

func _physics_process(delta: float) -> void:
    var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    velocity = direction * speed
    if direction.length_squared() > 0.0:
        if abs(direction.x) > abs(direction.y):
            facing_row = 2 if direction.x < 0.0 else 3
        else:
            facing_row = 1 if direction.y < 0.0 else 0
        anim_time += delta
        sprite.frame = facing_row * 3 + 1 + (int(anim_time * animation_fps) % 2)
    else:
        anim_time = 0.0
        sprite.frame = facing_row * 3
    move_and_slide()
