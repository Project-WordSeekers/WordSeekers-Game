extends AudioStreamPlayer

@export var loop_enabled: bool = true

func _ready() -> void:
	finished.connect(_on_finished)

func _on_finished() -> void:
	if loop_enabled:
		play()
