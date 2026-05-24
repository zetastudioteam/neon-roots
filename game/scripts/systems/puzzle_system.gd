# Responsabilidades
# - saber se o fusível foi coletado;
# - saber se o terminal foi ativado;
# - liberar a porta quando condições forem cumpridas;
# - emitir sinais para HUD/GameManager;
# - permitir reaproveitar a mesma lógica com outros IDs depois.

extends Node
class_name PuzzleSystem

# Sinais
signal fuse_registered(fuse_id: StringName)
signal terminal_activated()
signal door_opened()
signal puzzle_completed()

# Variáveis exportadas
@export var required_fuse_id: StringName = &"archive_fuse_01"
@export var required_terminal_id: StringName = &"archive_terminal_01"
@export var target_door_path: NodePath
@export var auto_open_door: bool = true

var collected_fuses: Array[StringName] = []
var has_fuse: bool = false
var is_terminal_activated: bool = false
var completed: bool = false

@onready var target_door: Node = get_node_or_null(target_door_path)

func _ready() -> void:
	if target_door == null:
		push_warning("PuzzleSystem: target_door_path não foi configurado.")


func register_fuse(fuse_id: StringName) -> void:
	if not collected_fuses.has(fuse_id):
		collected_fuses.append(fuse_id)

	if fuse_id == required_fuse_id:
		has_fuse = true
		fuse_registered.emit(fuse_id)

	_try_complete_puzzle()


func activate_terminal(terminal_id: StringName = &"") -> void:
	if completed:
		return

	if terminal_id != StringName("") and terminal_id != required_terminal_id:
		return

	if not has_fuse:
		return

	is_terminal_activated = true
	terminal_activated.emit()

	_try_complete_puzzle()


func has_required_fuse() -> bool:
	return has_fuse


func is_completed() -> bool:
	return completed


func reset_puzzle() -> void:
	collected_fuses.clear()
	has_fuse = false
	is_terminal_activated = false
	completed = false

	if target_door != null and target_door.has_method("lock"):
		target_door.lock()


func _try_complete_puzzle() -> void:
	if completed:
		return

	if not has_fuse:
		return

	if not is_terminal_activated:
		return

	completed = true

	if target_door != null:
		if target_door.has_method("unlock"):
			target_door.unlock()

		if auto_open_door and target_door.has_method("open"):
			target_door.open()
			door_opened.emit()

	puzzle_completed.emit()
