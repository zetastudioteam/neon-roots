# Responsabilidades
# - ler move_up, move_down, move_left, move_right;
# - mover em 4 direções;
# - aplicar move_and_slide();
# - atualizar direção atual;
# - chamar animação correspondente;
# - não cuidar de puzzle, HUD ou porta.

extends CharacterBody2D
class_name EchoController

# Variáveis exportadas
@export var move_speed: float = 85.0
@export var acceleration: float = 900.0
@export var friction: float = 1200.0

var facing_direction: Vector2 = Vector2.DOWN

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	_play_animation("idle_down")


func _physics_process(delta: float) -> void:
	var input_vector: Vector2 = Vector2.ZERO

	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

	input_vector = input_vector.normalized()

	if input_vector != Vector2.ZERO:
		facing_direction = input_vector
		velocity = velocity.move_toward(input_vector * move_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	move_and_slide()
	_update_animation(input_vector)


func _update_animation(input_vector: Vector2) -> void:
	var animation_prefix: String = "idle"

	if input_vector != Vector2.ZERO:
		animation_prefix = "walk"

	var direction_suffix: String = _get_direction_suffix()
	var animation_name: String = "%s_%s" % [animation_prefix, direction_suffix]

	_play_animation(animation_name)


func _get_direction_suffix() -> String:
	if abs(facing_direction.x) > abs(facing_direction.y):
		if facing_direction.x > 0.0:
			return "right"
		else:
			return "left"

	if facing_direction.y > 0.0:
		return "down"
	else:
		return "up"


func _play_animation(animation_name: String) -> void:
	if animated_sprite == null:
		return

	if not animated_sprite.sprite_frames.has_animation(animation_name):
		return

	if animated_sprite.animation != animation_name:
		animated_sprite.play(animation_name)
