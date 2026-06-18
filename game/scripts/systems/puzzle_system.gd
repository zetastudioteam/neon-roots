extends Node
class_name PuzzleSystem

signal fuse_registered(fuse_id: StringName)
signal terminal_activated()
signal power_terminal_activated()
signal door_opened()
signal puzzle_completed()
signal puzzle_message_requested(message: String)

@export var required_fuse_id: StringName = &"archive_fuse_01"
@export var required_power_terminal_id: StringName = &"power_terminal_01"
@export var requires_wire_panel: bool = false
@export var auto_open_door: bool = true
@export var target_door_path: NodePath

var has_fuse: bool = false
var power_terminal_active: bool = false
var completed: bool = false

@onready var target_door: Node = get_node_or_null(target_door_path)


func _ready() -> void:
	add_to_group("puzzle_system")

	if target_door == null:
		target_door = get_tree().get_first_node_in_group("puzzle_door")

	if target_door == null:
		push_warning("PuzzleSystem: nenhuma porta configurada. Use target_door_path ou grupo puzzle_door.")


func request_message(message: String) -> void:
	puzzle_message_requested.emit(message)
	print("PuzzleSystem message: ", message)


func register_fuse(fuse_id: StringName) -> void:
	print("PuzzleSystem: register_fuse chamado com ", fuse_id)

	if fuse_id != required_fuse_id:
		push_warning("PuzzleSystem: fusível incorreto. Recebi %s, esperava %s" % [str(fuse_id), str(required_fuse_id)])
		return

	if has_fuse:
		return

	has_fuse = true
	fuse_registered.emit(fuse_id)
	request_message("Fusível obtido.")


func activate_power_terminal(terminal_id: StringName = &"") -> void:
	print("PuzzleSystem: activate_power_terminal chamado com ", terminal_id)

	if completed:
		return

	if terminal_id != StringName("") and terminal_id != required_power_terminal_id:
		push_warning("PuzzleSystem: terminal incorreto. Recebi %s, esperava %s" % [str(terminal_id), str(required_power_terminal_id)])
		request_message("Terminal incorreto.")
		return

	if not has_fuse:
		request_message("Falta um fusível.")
		return

	if power_terminal_active:
		request_message("Painel de fusível já está energizado.")
		return

	power_terminal_active = true

	power_terminal_activated.emit()
	terminal_activated.emit()

	request_message("Fusível instalado. Energia restaurada.")

	_try_complete_puzzle()


func activate_terminal(terminal_id: StringName = &"") -> void:
	activate_power_terminal(terminal_id)


func has_required_fuse() -> bool:
	return has_fuse


func is_power_terminal_active() -> bool:
	return power_terminal_active


func is_completed() -> bool:
	return completed


func _try_complete_puzzle() -> void:
	if completed:
		return

	if not power_terminal_active:
		return

	if requires_wire_panel:
		request_message("Ainda falta estabilizar o painel de fios.")
		return

	completed = true

	var door: Node = _get_target_door()

	if door != null:
		if door.has_method("unlock"):
			door.unlock()

		if auto_open_door and door.has_method("open"):
			door.open()
			door_opened.emit()
	else:
		push_warning("PuzzleSystem: puzzle completo, mas porta não encontrada.")

	puzzle_completed.emit()
	request_message("Porta liberada.")


func _get_target_door() -> Node:
	if target_door != null:
		return target_door

	if target_door_path != NodePath(""):
		target_door = get_node_or_null(target_door_path)

	if target_door == null:
		target_door = get_tree().get_first_node_in_group("puzzle_door")

	return target_door
