extends Node2D

# Variáveis exportadas
@export var echo_path: NodePath
@export var player_spawn_path: NodePath

@onready var echo: Node2D = get_node_or_null(echo_path)
@onready var player_spawn: Marker2D = get_node_or_null(player_spawn_path)

func _ready() -> void:
	if echo == null:
		push_warning("MainSpawn: echo_path não configurado.")
		return

	if player_spawn == null:
		push_warning("MainSpawn: player_spawn_path não configurado.")
		return

	echo.global_position = player_spawn.global_position
