extends Node2D

# Variáveis exportadas
@export var echo_path: NodePath
@export var player_spawn_path: NodePath

@onready var echo: Node2D = get_node_or_null(echo_path)
@onready var player_spawn: Marker2D = get_node_or_null(player_spawn_path)

func _ready() -> void:
	# Espera 1 frame para garantir que mapa, Echo e filhos já entraram na cena.
	await get_tree().process_frame

	echo = get_node_or_null(echo_path)
	player_spawn = get_node_or_null(player_spawn_path)

	if echo == null:
		push_warning("MainSpawn: echo_path não configurado ou Echo não encontrada.")
		return

	if player_spawn == null:
		push_warning("MainSpawn: player_spawn_path não configurado ou PlayerSpawn não encontrado.")
		return

	echo.global_position = player_spawn.global_position
