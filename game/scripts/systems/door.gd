# Responsabilidades
# - bloquear passagem enquanto fechada;
# - abrir quando PuzzleSystem mandar;
# - dar feddback se Echo tentar abrir antes;
# - não saber como o fusível foi coletado;
# - não controlar o puzzle inteiro.

extends Node2D
class_name Door

# Sinais
signal door_unlocked(door_id: StringName)
signal door_opened(door_id: StringName)
signal door_closed(door_id: StringName)
signal door_locked_interaction(door_id: StringName)

# Variáveis exportadas
@export var door_id: StringName = &"archive_main_door"
@export var starts_open: bool = false
@export var starts_unlocked: bool = false
@export var requires_puzzle: bool = true

@export_category("Textos")
@export var locked_text: String = "Porta sem energia"
@export var open_text: String = "Abrir porta"
@export var opened_text: String = "Porta aberta"

@export_category("Nós")
@export var collision_shape_path: NodePath = NodePath("StaticBody2D/CollisionShape2D")
@export var static_body_path: NodePath = NodePath("StaticBody2D")
@export var interaction_area_path: NodePath = NodePath("InteractionArea")
@export var animation_player_path: NodePath = NodePath("AnimationPlayer")

var opened: bool = false
var unlocked: bool = false

@onready var collision_shape: CollisionShape2D = get_node_or_null(collision_shape_path)
@onready var static_body: StaticBody2D = get_node_or_null(static_body_path)
@onready var interaction_area: Area2D = get_node_or_null(interaction_area_path)
@onready var animation_player: AnimationPlayer = get_node_or_null(animation_player_path)

func _ready() -> void:
	opened = starts_open
	unlocked = starts_unlocked or starts_open or not requires_puzzle
	_apply_state()


func get_interaction_text() -> String:
	if opened:
		return opened_text

	if unlocked:
		return open_text

	return locked_text


func can_interact(_actor: Node) -> bool:
	return not opened


func interact(_actor: Node) -> void:
	if opened:
		return

	if unlocked:
		open()
	else:
		door_locked_interaction.emit(door_id)

		if animation_player != null and animation_player.has_animation("locked_feedback"):
			animation_player.play("locked_feedback")


func unlock() -> void:
	if unlocked:
		return

	unlocked = true
	door_unlocked.emit(door_id)

	if animation_player != null and animation_player.has_animation("unlock"):
		animation_player.play("unlock")


func open() -> void:
	if opened:
		return

	opened = true
	unlocked = true
	_apply_state()
	door_opened.emit(door_id)


func close() -> void:
	if not opened:
		return

	opened = false
	_apply_state()
	door_closed.emit(door_id)


func lock() -> void:
	if opened:
		close()

	unlocked = false


func is_open() -> bool:
	return opened


func is_unlocked() -> bool:
	return unlocked


func _apply_state() -> void:
	if collision_shape != null:
		collision_shape.set_deferred("disabled", opened)

	if interaction_area != null:
		interaction_area.set_deferred("monitoring", not opened)
		interaction_area.set_deferred("monitorable", not opened)

	if animation_player != null:
		if opened and animation_player.has_animation("open"):
			animation_player.play("open")
		elif not opened and animation_player.has_animation("close"):
			animation_player.play("close")
