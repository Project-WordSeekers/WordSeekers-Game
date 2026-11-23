extends Node2D

var enemy_hp: int = 3
var player_perto: bool = false
var battle_active: bool = false

var perguntas: Array[Dictionary] = []
var selected_quiz: Dictionary = {}

@onready var enemy_hp_label: Label = $EnemyHPLabel
@onready var enemy_hp_bar: ProgressBar = $EnemyHPHud/EnemyHPBar
@onready var interaction_label: Label = $InteractionLabel
@onready var enemy: Sprite2D = $Inimigo
@onready var player: CharacterBody2D = $Player
@onready var player_damage_sound: AudioStreamPlayer = $PlayerDamageSound
@onready var monster_damage_sound: AudioStreamPlayer = $MonsterDamageSound

const ENEMY_TEXTURES: Array[String] = [
    "res://assets/characters/enemies/Code_Generated_Image(1).webp",
    "res://assets/characters/enemies/Code_Generated_Image(2).webp",
    "res://assets/characters/enemies/Code_Generated_Image(3).webp",
    "res://assets/characters/enemies/Code_Generated_Image(4).webp",
    "res://assets/characters/enemies/dragao_equipe_1.webp",
    "res://assets/characters/enemies/dragao_equipe_2.webp",
    "res://assets/characters/enemies/dragao_equipe_3.webp",
    "res://assets/characters/enemies/monster5.webp",
    "res://assets/characters/enemies/monster6.webp",
    "res://assets/characters/enemies/monster7.webp",
    "res://assets/characters/enemies/skeleton_archer.webp",
    "res://assets/characters/enemies/skeleton_berserker.webp",
    "res://assets/characters/enemies/skeleton_mage.webp",
    "res://assets/characters/enemies/skeleton_warrior.webp",
]

func _setup_battle_actors() -> void:
    # A camera do player deve permanecer desativada para que o fundo ocupe a tela inteira.
    var camera: Camera2D = player.get_node_or_null("Camera2D") as Camera2D
    if camera != null:
        camera.enabled = false
    player.set_physics_process(false)
    player.set_process_unhandled_input(false)
    player.set_process_input(false)
    var player_sprite: Sprite2D = player.get_node_or_null("Sprite2D") as Sprite2D
    if player_sprite != null:
        player_sprite.frame = 1
    var rng := RandomNumberGenerator.new()
    rng.randomize()
    enemy.texture = load(ENEMY_TEXTURES[rng.randi_range(0, ENEMY_TEXTURES.size() - 1)]) as Texture2D
    enemy.scale = Vector2.ONE
    enemy.centered = true
    _position_battle_actors()
    get_viewport().size_changed.connect(_position_battle_actors)

func _position_battle_actors() -> void:
    var view_size: Vector2 = get_viewport_rect().size
    var baseline_y: float = view_size.y * 0.88
    var target_height: float = minf(view_size.y * 0.30, 220.0)
    var max_actor_width: float = view_size.x * 0.27
    var player_sprite: Sprite2D = player.get_node_or_null("Sprite2D") as Sprite2D
    if player_sprite != null and player_sprite.texture != null:
        var frame_size: Vector2 = player_sprite.texture.get_size() / Vector2(
            maxf(1.0, float(player_sprite.hframes)),
            maxf(1.0, float(player_sprite.vframes))
        )
        var player_factor: float = minf(
            target_height / maxf(1.0, frame_size.y),
            max_actor_width / maxf(1.0, frame_size.x)
        )
        player.scale = Vector2.ONE
        player_sprite.scale = Vector2.ONE * player_factor
        # Bottom of visible frame, not the center, lands on baseline_y.
        player_sprite.position = Vector2(0.0, -frame_size.y * player_factor * 0.5)
    player.position = Vector2(view_size.x * 0.24, baseline_y)
    if enemy.texture != null:
        var enemy_size: Vector2 = enemy.texture.get_size()
        var enemy_factor: float = minf(
            target_height / maxf(1.0, enemy_size.y),
            max_actor_width / maxf(1.0, enemy_size.x)
        )
        enemy.scale = Vector2.ONE * enemy_factor
        # Both characters have feet on the same global Y baseline.
        enemy.position = Vector2(view_size.x * 0.76, baseline_y - enemy_size.y * enemy_factor * 0.5)
        var top_y: float = enemy.position.y - enemy_size.y * enemy_factor * 0.5
        var bar_width: float = clampf(enemy_size.x * enemy_factor, 120.0, 200.0)
        enemy_hp_bar.size = Vector2(bar_width, 20.0)
        enemy_hp_bar.position = Vector2(
            clampf(enemy.position.x - bar_width * 0.5, 8.0, maxf(8.0, view_size.x - bar_width - 8.0)),
            clampf(top_y - 32.0, 8.0, maxf(8.0, view_size.y - 28.0))
        )

func _ready() -> void:
    _setup_battle_actors()
    _hide_legacy_battle_ui()
    enemy_hp_label.hide()
    enemy_hp_bar.min_value = 0.0
    enemy_hp_bar.max_value = 3.0
    enemy_hp_bar.value = 3.0
    _update_enemy_hp_color()
    enemy_hp_bar.show_percentage = false
    enemy_hp_bar.hide()
    interaction_label.text = "[E] Falar"
    interaction_label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.55, 1.0))
    interaction_label.hide()
    if GameState.random_encounter_active:
        _start_battle()

func _hide_legacy_battle_ui() -> void:
    var legacy_names: Array[StringName] = [
        &"PlayerHPLabel",
        &"StartBattlePanel",
        &"QuestionPanel",
        &"AnswerInput",
        &"AttackButton",
        &"ResultLabel",
        &"YesButton",
        &"NoButton"
    ]
    for name_index in range(legacy_names.size()):
        var node_name: StringName = legacy_names[name_index]
        var legacy_node: CanvasItem = get_node_or_null(NodePath(String(node_name))) as CanvasItem
        if legacy_node != null:
            legacy_node.hide()

func _on_interaction_area_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        player_perto = true
        if not battle_active and not DialogueUI.is_open():
            interaction_label.show()

func _on_interaction_area_body_exited(body: Node2D) -> void:
    if body.is_in_group("player"):
        player_perto = false
        interaction_label.hide()

func _unhandled_input(event: InputEvent) -> void:
    if not player_perto or battle_active or DialogueUI.is_open():
        return
    if not event.is_action_pressed("interact"):
        return

    interaction_label.hide()
    var options: Array[String] = ["YES", "NO"]
    DialogueUI.show_choice(
        "Esqueleto",
        "Hello! Are you ready to battle?",
        options,
        Callable(self, "_on_battle_choice")
    )
    get_viewport().set_input_as_handled()

func _on_battle_choice(selected_index: int) -> void:
    if selected_index == 0:
        _start_battle()
        return
    if player_perto:
        interaction_label.show()

func _start_battle() -> void:
    selected_quiz = GameState.reserve_random_quiz()
    if selected_quiz.is_empty():
        GameState.random_encounter_active = false
        SceneTransition.change_scene_to_file("res://scenes/world/world_map.tscn")
        return
    perguntas.clear()
    for q in selected_quiz.get("questoes", []):
        var options: Array[String] = []
        for letter in ["A", "B", "C", "D", "E"]:
            options.append(letter + ") " + String(q.get("opcoes", {}).get(letter, "")))
        perguntas.append({"prompt":String(q.get("pergunta", "")), "answers":options,
            "correct":["A", "B", "C", "D", "E"].find(String(q.get("resposta_correta", ""))),
            "explanation":String(q.get("explicacao", "")),
            "wrong_feedback":String(selected_quiz.get("fala_erro", "Not quite!"))})
    battle_active = true
    enemy_hp = 3
    enemy_hp_bar.max_value = 3.0
    enemy_hp_bar.value = float(enemy_hp)
    _update_enemy_hp_color()
    enemy_hp_bar.show()
    enemy_hp_label.hide()
    DialogueUI.show_sequence("Monster", [String(selected_quiz.get("fala_inicial", "Ready for a challenge?"))], Callable(self, "_show_battle_quiz"))

func _show_battle_quiz() -> void:
    DialogueUI.show_quiz("Monster", perguntas, Callable(self, "_on_battle_answer"), Callable(self, "_on_battle_finished"), "You won!")

func _on_battle_answer(_question_index: int, is_correct: bool) -> void:
    if is_correct:
        monster_damage_sound.play()
        enemy_hp -= 1
        enemy_hp_bar.value = float(maxi(enemy_hp, 0))
        _update_enemy_hp_color()
        return

    player_damage_sound.play()
    var remaining_hp: int = GameState.damage_player(1)
    if remaining_hp <= 0:
        DialogueUI.close()
        battle_active = false
        _handle_defeat()

func _handle_defeat() -> void:
    await get_tree().create_timer(0.85).timeout
    GameState.return_to_city01_after_defeat()

func _on_battle_finished() -> void:
    battle_active = false
    enemy_hp_bar.hide()
    enemy_hp_label.hide()
    interaction_label.hide()
    DialogueUI.show_dialogue("Monster", String(selected_quiz.get("fala_vitoria", "Great effort! I'm running away!")), Callable(self, "_monster_flees"))

func _monster_flees() -> void:
    enemy.hide()
    GameState.random_encounter_active = false
    await get_tree().create_timer(0.35).timeout
    SceneTransition.change_scene_to_file("res://scenes/world/world_map.tscn")

# Compatibilidade com conexões antigas da cena; a interface legada permanece oculta.
func _on_attack_button_pressed() -> void:
    pass

func _on_yes_button_pressed() -> void:
    pass

func _on_no_button_pressed() -> void:
    pass

# A cor da barra representa a vida atual do monstro.
func _update_enemy_hp_color() -> void:
    var hp_color: Color
    match enemy_hp:
        3:
            hp_color = Color("287bff") # Azul: 3 HP
        2:
            hp_color = Color("ffd33d") # Amarelo: 2 HP
        1:
            hp_color = Color("ed4444") # Vermelho: 1 HP
        _:
            hp_color = Color("ed4444") # Barra vazia ao chegar a 0 HP
    var fill_style := StyleBoxFlat.new()
    fill_style.bg_color = hp_color
    fill_style.set_corner_radius_all(4)
    enemy_hp_bar.add_theme_stylebox_override("fill", fill_style)
