extends Node2D
class_name SimpleDoor

signal door_opened()
signal door_closed()

@export var starts_open: bool = false
@export var allow_manual_close: bool = true

@export var open_text: String = "Abrir porta"
@export var close_text: String = "Fechar porta"
@export var opened_text: String = "Porta aberta"

@export var animated_sprite_path: NodePath = NodePath("AnimatedSprite2D")
@export var collision_shape_path: NodePath = NodePath("StaticBody2D/CollisionShape2D")

var opened: bool = false
var is_animating: bool = false

@onready var animated_sprite: AnimatedSprite2D = get_node_or_null(animated_sprite_path)
@onready var collision_shape: CollisionShape2D = get_node_or_null(collision_shape_path)


func _ready() -> void:
	opened = starts_open

	if animated_sprite != null:
		if not animated_sprite.animation_finished.is_connected(_on_animation_finished):
			animated_sprite.animation_finished.connect(_on_animation_finished)

	_apply_state_immediate()


func get_interaction_text() -> String:
	if is_animating:
		return "Aguarde"

	if opened:
		if allow_manual_close:
			return close_text

		return opened_text

	return open_text


func can_interact(_actor: Node) -> bool:
	if is_animating:
		return false

	if opened and not allow_manual_close:
		return false

	return true


func interact(_actor: Node) -> void:
	if not can_interact(_actor):
		return

	if opened:
		close()
	else:
		open()


func open() -> void:
	if opened:
		return

	opened = true
	is_animating = true
	_set_collision_enabled(false)

	if animated_sprite != null and animated_sprite.sprite_frames.has_animation("open"):
		animated_sprite.play("open")
	else:
		_finish_open()


func close() -> void:
	if not opened:
		return

	opened = false
	is_animating = true

	if animated_sprite != null and animated_sprite.sprite_frames.has_animation("close"):
		animated_sprite.play("close")
	else:
		_finish_close()


func _on_animation_finished() -> void:
	if animated_sprite == null:
		return

	if animated_sprite.animation == "open":
		_finish_open()
	elif animated_sprite.animation == "close":
		_finish_close()


func _finish_open() -> void:
	is_animating = false
	opened = true
	_set_collision_enabled(false)

	if animated_sprite != null:
		if animated_sprite.sprite_frames.has_animation("open"):
			var frame_count: int = animated_sprite.sprite_frames.get_frame_count("open")
			if frame_count > 0:
				animated_sprite.animation = "open"
				animated_sprite.frame = frame_count - 1

	door_opened.emit()


func _finish_close() -> void:
	is_animating = false
	opened = false
	_set_collision_enabled(true)

	if animated_sprite != null:
		if animated_sprite.sprite_frames.has_animation("closed"):
			animated_sprite.play("closed")
		elif animated_sprite.sprite_frames.has_animation("close"):
			var frame_count: int = animated_sprite.sprite_frames.get_frame_count("close")
			if frame_count > 0:
				animated_sprite.animation = "close"
				animated_sprite.frame = frame_count - 1

	door_closed.emit()


func _apply_state_immediate() -> void:
	if opened:
		_set_collision_enabled(false)

		if animated_sprite != null:
			if animated_sprite.sprite_frames.has_animation("open"):
				var frame_count: int = animated_sprite.sprite_frames.get_frame_count("open")
				animated_sprite.animation = "open"
				animated_sprite.frame = max(frame_count - 1, 0)
	else:
		_set_collision_enabled(true)

		if animated_sprite != null:
			if animated_sprite.sprite_frames.has_animation("closed"):
				animated_sprite.play("closed")


func _set_collision_enabled(enabled: bool) -> void:
	var static_body: StaticBody2D = get_node_or_null("StaticBody2D")

	if static_body != null:
		static_body.collision_layer = 1 if enabled else 0
		static_body.collision_mask = 1 if enabled else 0

		for child: Node in static_body.get_children():
			if child is CollisionShape2D:
				child.set_deferred("disabled", not enabled)
			elif child is CollisionPolygon2D:
				child.set_deferred("disabled", not enabled)

	if collision_shape != null:
		collision_shape.set_deferred("disabled", not enabled)
