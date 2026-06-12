extends Camera2D

@export var target_path: NodePath
@export var follow_smoothing: float = 8.0

@onready var target: Node2D = get_node_or_null(target_path)


func _ready() -> void:
	make_current()

	if target != null:
		global_position = target.global_position


func _process(delta: float) -> void:
	if target == null:
		return

	global_position = global_position.lerp(target.global_position, follow_smoothing * delta)
