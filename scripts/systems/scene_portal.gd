extends Area2D

const WORLD_MAP_SCENE: String = "res://scenes/world/world_map.tscn"

@export_file("*.tscn") var target_scene_path: String
@export var target_spawn_name: StringName = &""
@export var temple_entrance: bool = false
@export var temple_exit: bool = false
@export var temple_return_spawn: StringName = &"FromTemple"
@export var salvar_cidade: bool = false

var _transition_started: bool = false
# Corpos que já estavam dentro do portal quando a cena abriu (ex.: jogador que volta na porta).
var _ignorados: Array[Node2D] = []
var _armado: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	for i in 3:
		await get_tree().physics_frame
	for b in get_overlapping_bodies():
		_ignorados.append(b)
	_armado = true

func _on_body_exited(body: Node2D) -> void:
	_ignorados.erase(body)

func _on_body_entered(body: Node2D) -> void:
	if _transition_started or not _armado or body in _ignorados or not body.is_in_group("player"):
		return

	var destination: String = target_scene_path
	var spawn_name: StringName = target_spawn_name
	if temple_exit:
		# Volta para a última cidade em que o jogador esteve; o spawn salvo só vale se for dela.
		destination = GameState.cidade if not GameState.cidade.is_empty() else GameState.temple_return_scene
		spawn_name = GameState.temple_return_spawn if destination == GameState.temple_return_scene else &""
	elif temple_entrance:
		var city_scene: String = get_tree().current_scene.scene_file_path
		if city_scene.is_empty():
			push_warning("Entrada de templo sem cena de cidade: %s" % get_path())
			return
		GameState.register_temple_origin(city_scene, temple_return_spawn)
	elif destination.is_empty():
		# Sem destino fixo: volta para a última cidade registrada.
		destination = GameState.cidade

	if destination.is_empty() and GameState.e_templo(get_tree().current_scene.scene_file_path):
		# Templo sem cidade de origem conhecida (ex.: aberto direto): sai para o mapa-múndi.
		push_warning("Templo sem cidade de origem; voltando ao mapa-múndi: %s" % get_path())
		destination = WORLD_MAP_SCENE
	if destination.is_empty():
		push_warning("ScenePortal sem cena de destino: %s" % get_path())
		return
	if not ResourceLoader.exists(destination):
		push_error("ScenePortal: cena inexistente: %s" % destination)
		return

	_transition_started = true
	var cena_atual: String = get_tree().current_scene.scene_file_path
	if salvar_cidade:
		GameState.cidade = cena_atual
	if GameState.e_templo(destination) and not GameState.e_templo(cena_atual):
		# Entrando num templo: lembra a cidade e a porta para voltar depois.
		GameState.cidade = cena_atual
		GameState.cidade_porta = body.global_position
	elif GameState.e_templo(cena_atual) and destination == GameState.cidade:
		GameState.voltando_do_templo = true
	GameState.pending_spawn_name = spawn_name
	SceneTransition.change_scene_to_file(destination)
