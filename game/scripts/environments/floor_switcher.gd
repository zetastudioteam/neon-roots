extends Node2D

# Sinal
signal floor_changed(new_floor: String)

# Variáveis exportadas
@export var ground_floor_path: NodePath
@export var upper_floor_path: NodePath
@export var basement_floor_path: NodePath

@export_enum("ground", "upper", "basement") var initial_floor: String = "ground"
@export var fade_duration: float = 0.35

var current_floor: String = ""
var is_transitioning: bool = false
var active_tween: Tween = null

@onready var ground_floor: Node2D = get_node_or_null(ground_floor_path)
@onready var upper_floor: Node2D = get_node_or_null(upper_floor_path)
@onready var basement_floor: Node2D = get_node_or_null(basement_floor_path)

func _ready() -> void:
	change_floor_instant(initial_floor)


func change_floor(target_floor: String) -> void:
	if is_transitioning:
		return

	if target_floor == current_floor:
		return

	var old_floor: Node2D = _get_floor_node(current_floor)
	var new_floor: Node2D = _get_floor_node(target_floor)

	if new_floor == null:
		push_warning("FloorSwitcher: andar inválido: " + target_floor)
		return

	is_transitioning = true

	if old_floor != null:
		_set_floor_collision(old_floor, false)

	_set_floor_collision(new_floor, true)

	new_floor.visible = true
	new_floor.modulate.a = 0.0

	if active_tween != null:
		active_tween.kill()

	active_tween = create_tween()
	active_tween.set_parallel(true)

	if old_floor != null:
		active_tween.tween_property(old_floor, "modulate:a", 0.0, fade_duration)

	active_tween.tween_property(new_floor, "modulate:a", 1.0, fade_duration)

	active_tween.set_parallel(false)
	active_tween.tween_callback(_finish_transition.bind(old_floor, new_floor, target_floor))


func change_floor_instant(target_floor: String) -> void:
	current_floor = target_floor
	is_transitioning = false

	_set_floor_state(ground_floor, target_floor == "ground")
	_set_floor_state(upper_floor, target_floor == "upper")
	_set_floor_state(basement_floor, target_floor == "basement")

	floor_changed.emit(current_floor)


func show_ground_floor() -> void:
	change_floor("ground")


func show_upper_floor() -> void:
	change_floor("upper")


func show_basement_floor() -> void:
	change_floor("basement")


func get_current_floor() -> String:
	return current_floor


func is_busy() -> bool:
	return is_transitioning


func _finish_transition(old_floor: Node2D, new_floor: Node2D, target_floor: String) -> void:
	if old_floor != null:
		old_floor.visible = false
		old_floor.modulate.a = 0.0

	new_floor.visible = true
	new_floor.modulate.a = 1.0

	current_floor = target_floor
	is_transitioning = false
	floor_changed.emit(current_floor)


func _set_floor_state(floor_node: Node2D, enabled: bool) -> void:
	if floor_node == null:
		return

	floor_node.visible = enabled
	floor_node.modulate.a = 1.0 if enabled else 0.0
	_set_floor_collision(floor_node, enabled)


func _get_floor_node(floor_name: String) -> Node2D:
	if floor_name == "ground":
		return ground_floor

	if floor_name == "upper":
		return upper_floor

	if floor_name == "basement":
		return basement_floor

	return null


func _set_floor_collision(root: Node, enabled: bool) -> void:
	if root == null:
		return

	if root is TileMapLayer:
		root.collision_enabled = enabled

	if root is CollisionShape2D:
		root.set_deferred("disabled", not enabled)

	if root is CollisionPolygon2D:
		root.set_deferred("disabled", not enabled)

	for child: Node in root.get_children():
		_set_floor_collision(child, enabled)
