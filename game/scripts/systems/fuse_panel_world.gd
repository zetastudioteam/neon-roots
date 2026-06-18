extends Area2D
class_name FusePanelWorld

@export var interaction_text: String = "Usar painel de fusível"

var panel_ui: Node = null
var puzzle_system: Node = null


func _ready() -> void:
	panel_ui = get_tree().get_first_node_in_group("fuse_panel_ui")
	puzzle_system = get_tree().get_first_node_in_group("puzzle_system")


func get_interaction_text() -> String:
	if _is_panel_completed():
		return "Painel energizado"

	return interaction_text


func can_interact(_actor: Node) -> bool:
	return not _is_panel_completed()


func interact(_actor: Node) -> void:
	if panel_ui == null:
		panel_ui = get_tree().get_first_node_in_group("fuse_panel_ui")

	if puzzle_system == null:
		puzzle_system = get_tree().get_first_node_in_group("puzzle_system")

	if panel_ui == null:
		push_warning("FusePanelWorld: FusePanelUI não encontrada no grupo fuse_panel_ui.")
		return

	if panel_ui.has_method("open_panel"):
		panel_ui.open_panel(puzzle_system)


func _is_panel_completed() -> bool:
	if puzzle_system == null:
		puzzle_system = get_tree().get_first_node_in_group("puzzle_system")

	if puzzle_system == null:
		return false

	if puzzle_system.has_method("is_power_terminal_active"):
		return puzzle_system.is_power_terminal_active()

	return false
