extends Camera2D
class_name CameraFollow

# Variáveis exportadas
@export var target_path: NodePath
@export var follow_speed: float = 8.0
@export var use_smooth_follow: bool = true

@export_category("Limites do Mapa")
@export var use_limits: bool = true
@export var limit_left_value: int = -10000000
@export var limit_top_value: int = -10000000
@export var limit_right_value: int = 10000000
@export var limit_bottom_value: int = 10000000

@onready var target: Node2D = get_node_or_null(target_path)

func _ready() -> void:
	enabled = true
	make_current()
	
	print("Camera target encontrado: ", target)

	if use_limits:
		limit_left = limit_left_value
		limit_top = limit_top_value
		limit_right = limit_right_value
		limit_bottom = limit_bottom_value

	if target == null:
		push_warning("CameraFollow: target_path não encontrou nenhum Node2D. Confira o caminho até a Echo.")
		return
	
	global_position = target.global_position


func _process(delta: float) -> void:
	if target == null:
		return

	if use_smooth_follow:
		global_position = global_position.lerp(target.global_position, follow_speed * delta)
	else:
		global_position = target.global_position
