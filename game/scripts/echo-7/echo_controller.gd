# Responsabilidades
# - ler move_up, move_down, move_left, move_right;
# - mover em 4 direções;
# - aplicar move_and_slide();
# - atualizar direção atual;
# - chamar animação correspondente;
# - não cuidar de puzzle, HUD ou porta.

extends CharacterBody2D
class_name EchoController

# Sinal
signal direction_changed(direction: Vector2)
signal started_moving()
signal stopped_moving()


# Variáveis exportadas
@export_category("Movimento")
@export var move_speed: float = 85.0
@export var acceleration: float = 900.0
@export var friction: float = 1200.0
@export var allow_diagonal_movement: bool = true

@export_category("Nós Visuais")
@export var visual_root_path: NodePath = NodePath("VisualRoot")
@export var animation_player_path: NodePath = NodePath("AnimationPlayer")
@export var direction_marker_path: NodePath = NodePath("VisualRoot/DirectionMarker")

var facing_direction: Vector2 = Vector2.DOWN
var is_moving: bool = false

@onready var visual_root: Node2D = get_node_or_null(visual_root_path)
@onready var animation_player: AnimationPlayer = get_node_or_null(animation_player_path)
@onready var direction_marker: Marker2D = get_node_or_null(direction_marker_path)

func _ready() -> void:
	_update_direction_marker()

	if animation_player != null and animation_player.has_animation("idle_down"):
		animation_player.play("idle_down")


func _physics_process(delta: float) -> void:
	var input_vector: Vector2 = _get_input_vector()

	if input_vector != Vector2.ZERO:
		if not is_moving:
			is_moving = true
			started_moving.emit()

		facing_direction = input_vector
		direction_changed.emit(facing_direction)
		velocity = velocity.move_toward(input_vector * move_speed, acceleration * delta)
	else:
		if is_moving:
			is_moving = false
			stopped_moving.emit()

		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	move_and_slide()

	_update_direction_marker()
	_update_animation(input_vector)


func _get_input_vector() -> Vector2:
	var input_vector := Vector2.ZERO

	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

	if not allow_diagonal_movement:
		if abs(input_vector.x) > abs(input_vector.y):
			input_vector.y = 0.0
		else:
			input_vector.x = 0.0

	return input_vector.normalized()


func _update_animation(input_vector: Vector2) -> void:
	if animation_player == null:
		return

	var prefix := "idle"

	if input_vector != Vector2.ZERO:
		prefix = "walk"

	var suffix := _get_direction_suffix()
	var animation_name := "%s_%s" % [prefix, suffix]

	if animation_player.has_animation(animation_name):
		if animation_player.current_animation != animation_name:
			animation_player.play(animation_name)


func _get_direction_suffix() -> String:
	if abs(facing_direction.x) > abs(facing_direction.y):
		if facing_direction.x > 0.0:
			return "right"
		return "left"

	if facing_direction.y > 0.0:
		return "down"

	return "up"


func _update_direction_marker() -> void:
	if direction_marker == null:
		return

	direction_marker.position = facing_direction.normalized() * 16.0


func get_facing_direction() -> Vector2:
	return facing_direction


func lock_movement() -> void:
	set_physics_process(false)
	velocity = Vector2.ZERO


func unlock_movement() -> void:
	set_physics_process(true)
