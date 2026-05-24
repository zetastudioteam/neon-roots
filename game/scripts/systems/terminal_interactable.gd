# Responsabilidades
# - permitir interação com [E];
# - chamar puzzle_system.active_terminal();
# - mostrar feedback se falta fusível;
# - não abrir porta diretamente.

extends Area2D
class_name TerminalInteractable

# Sinal
signal terminal_used()
signal terminal_failed(reason: String)

# Variáveis exportadas
@export var terminal_id: StringName = &"archive_terminal_01"
@export var interaction_text: String = "Ativar terminal"
@export var already_active_text: String = "Terminal já ativado"
@export var missing_fuse_text: String = "Falta um fusível"
@export var requires_fuse_first: bool = true
@export var puzzle_system_path: NodePath

@export_category("Nós")
@export var animation_player_path: NodePath = NodePath("AnimationPlayer")

var activated: bool = false

@onready var puzzle_system: Node = get_node_or_null(puzzle_system_path)
@onready var animation_player: AnimationPlayer = get_node_or_null(animation_player_path)

func _ready() -> void:
	monitoring = true
	monitorable = true

	if animation_player != null and animation_player.has_animation("idle"):
		animation_player.play("idle")


func get_interaction_text() -> String:
	if activated:
		return already_active_text

	if requires_fuse_first and not _puzzle_has_fuse():
		return missing_fuse_text

	return interaction_text


func can_interact(_actor: Node) -> bool:
	if activated:
		return false

	if puzzle_system == null:
		return false

	return true


func interact(_actor: Node) -> void:
	if activated:
		return

	if puzzle_system == null:
		terminal_failed.emit("PuzzleSystem não configurado.")
		return

	if requires_fuse_first and not _puzzle_has_fuse():
		terminal_failed.emit("Fusível ausente.")

		if animation_player != null and animation_player.has_animation("failed"):
			animation_player.play("failed")

		return

	activate_terminal()


func activate_terminal() -> void:
	activated = true

	if animation_player != null and animation_player.has_animation("activated"):
		animation_player.play("activated")

	if puzzle_system != null and puzzle_system.has_method("activate_terminal"):
		puzzle_system.activate_terminal(terminal_id)

	terminal_used.emit()


func reset_terminal() -> void:
	activated = false

	if animation_player != null and animation_player.has_animation("idle"):
		animation_player.play("idle")


func _puzzle_has_fuse() -> bool:
	if puzzle_system == null:
		return false

	if puzzle_system.has_method("has_required_fuse"):
		return puzzle_system.has_required_fuse()

	return false
