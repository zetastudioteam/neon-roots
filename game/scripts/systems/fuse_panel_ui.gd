extends CanvasLayer
class_name FusePanelUI

signal fuse_panel_completed()

@export var root_path: NodePath = NodePath("Root")
@export var background_overlay_path: NodePath = NodePath("Root/BackgroundOverlay")
@export var empty_panel_image_path: NodePath = NodePath("Root/PanelWindow/MarginContainer/VBoxContainer/PanelDisplay/EmptyPanelImage")
@export var fuse_icon_path: NodePath = NodePath("Root/PanelWindow/MarginContainer/VBoxContainer/PanelDisplay/FuseIcon")
@export var feedback_label_path: NodePath = NodePath("Root/PanelWindow/MarginContainer/VBoxContainer/FeedbackLabel")
@export var install_button_path: NodePath = NodePath("Root/PanelWindow/MarginContainer/VBoxContainer/InstallFuseButton")
@export var close_button_path: NodePath = NodePath("Root/PanelWindow/MarginContainer/VBoxContainer/CloseButton")

@export var required_terminal_id: StringName = &"power_terminal_01"
@export var pause_game_while_open: bool = true

var puzzle_system: Node = null
var completed: bool = false

@onready var root: Control = get_node_or_null(root_path)
@onready var background_overlay: Control = get_node_or_null(background_overlay_path)
@onready var empty_panel_image: CanvasItem = get_node_or_null(empty_panel_image_path)
@onready var fuse_icon: CanvasItem = get_node_or_null(fuse_icon_path)
@onready var feedback_label: Label = get_node_or_null(feedback_label_path)
@onready var install_button: Button = get_node_or_null(install_button_path)
@onready var close_button: Button = get_node_or_null(close_button_path)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 20

	_force_process_always(self)

	if root != null:
		root.visible = false
		root.mouse_filter = Control.MOUSE_FILTER_PASS

	if background_overlay != null:
		background_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if install_button != null:
		install_button.mouse_filter = Control.MOUSE_FILTER_STOP
		install_button.focus_mode = Control.FOCUS_ALL

		if not install_button.pressed.is_connected(_on_install_button_pressed):
			install_button.pressed.connect(_on_install_button_pressed)
	else:
		push_warning("FusePanelUI: InstallFuseButton não encontrado.")

	if close_button != null:
		close_button.mouse_filter = Control.MOUSE_FILTER_STOP
		close_button.focus_mode = Control.FOCUS_ALL
		close_button.disabled = false

		if not close_button.pressed.is_connected(close_panel):
			close_button.pressed.connect(close_panel)
	else:
		push_warning("FusePanelUI: CloseButton não encontrado.")

	hide_panel_without_unpausing()


func _force_process_always(node: Node) -> void:
	node.process_mode = Node.PROCESS_MODE_ALWAYS

	for child in node.get_children():
		_force_process_always(child)


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("ui_cancel"):
		close_panel()


func open_panel(current_puzzle_system: Node) -> void:
	puzzle_system = current_puzzle_system

	if puzzle_system == null:
		puzzle_system = get_tree().get_first_node_in_group("puzzle_system")

	visible = true

	if root != null:
		root.visible = true

	if pause_game_while_open:
		get_tree().paused = true

	_refresh_visual_state()


func close_panel() -> void:
	if root != null:
		root.visible = false

	visible = false
	get_tree().paused = false


func hide_panel_without_unpausing() -> void:
	if root != null:
		root.visible = false

	visible = false


func _refresh_visual_state() -> void:
	completed = _is_panel_completed()

	if empty_panel_image != null:
		empty_panel_image.visible = true

	if close_button != null:
		close_button.visible = true
		close_button.disabled = false
		close_button.text = "Fechar"

	if completed:
		_show_completed_state()
		return

	_show_empty_state()

	if _has_fuse():
		if feedback_label != null:
			feedback_label.text = "Fusível disponível. Instale no slot."

		if install_button != null:
			install_button.visible = true
			install_button.text = "Instalar fusível"
			install_button.disabled = false
	else:
		if feedback_label != null:
			feedback_label.text = "Slot vazio. Fusível ausente."

		if install_button != null:
			install_button.visible = true
			install_button.text = "Fusível ausente"
			install_button.disabled = true


func _on_install_button_pressed() -> void:
	print("FusePanelUI: botão Instalar foi pressionado.")

	if puzzle_system == null:
		puzzle_system = get_tree().get_first_node_in_group("puzzle_system")

	if puzzle_system == null:
		print("FusePanelUI ERRO: PuzzleSystem não encontrado.")
		if feedback_label != null:
			feedback_label.text = "Sistema do puzzle não encontrado."
		return

	print("FusePanelUI: PuzzleSystem encontrado -> ", puzzle_system.name)

	if not _has_fuse():
		print("FusePanelUI: jogador ainda não tem fusível.")
		if feedback_label != null:
			feedback_label.text = "Você ainda não possui o fusível."
		return

	print("FusePanelUI: jogador tem fusível. Completando painel.")
	_complete_panel()


func _complete_panel() -> void:
	print("FusePanelUI: _complete_panel chamado.")

	completed = true

	if puzzle_system == null:
		puzzle_system = get_tree().get_first_node_in_group("puzzle_system")

	if puzzle_system == null:
		print("FusePanelUI ERRO: PuzzleSystem null dentro de _complete_panel.")
		return

	if puzzle_system.has_method("activate_power_terminal"):
		print("FusePanelUI: chamando activate_power_terminal com ID: ", required_terminal_id)
		puzzle_system.activate_power_terminal(required_terminal_id)
	elif puzzle_system.has_method("activate_terminal"):
		print("FusePanelUI: chamando activate_terminal com ID: ", required_terminal_id)
		puzzle_system.activate_terminal(required_terminal_id)
	else:
		print("FusePanelUI ERRO: PuzzleSystem não tem activate_power_terminal nem activate_terminal.")

	_show_completed_state()
	fuse_panel_completed.emit()
	completed = true

	if puzzle_system == null:
		puzzle_system = get_tree().get_first_node_in_group("puzzle_system")

	if puzzle_system != null:
		if puzzle_system.has_method("activate_power_terminal"):
			puzzle_system.activate_power_terminal(required_terminal_id)
		elif puzzle_system.has_method("activate_terminal"):
			puzzle_system.activate_terminal(required_terminal_id)
		else:
			push_warning("FusePanelUI: PuzzleSystem não tem função de ativar terminal.")
	else:
		push_warning("FusePanelUI: PuzzleSystem não encontrado.")

	_show_completed_state()
	fuse_panel_completed.emit()
	completed = true

	if puzzle_system != null:
		if puzzle_system.has_method("activate_power_terminal"):
			puzzle_system.activate_power_terminal(required_terminal_id)
		elif puzzle_system.has_method("activate_terminal"):
			puzzle_system.activate_terminal(required_terminal_id)

	_show_completed_state()
	fuse_panel_completed.emit()


func _show_empty_state() -> void:
	if fuse_icon != null:
		fuse_icon.visible = false


func _show_completed_state() -> void:
	if fuse_icon != null:
		fuse_icon.visible = true

	if feedback_label != null:
		feedback_label.text = "Fusível instalado. Energia restaurada."

	if install_button != null:
		install_button.visible = true
		install_button.text = "Instalado"
		install_button.disabled = true

	if close_button != null:
		close_button.visible = true
		close_button.disabled = false
		close_button.text = "Fechar"


func _has_fuse() -> bool:
	if puzzle_system == null:
		puzzle_system = get_tree().get_first_node_in_group("puzzle_system")

	if puzzle_system == null:
		return false

	if puzzle_system.has_method("has_required_fuse"):
		return puzzle_system.has_required_fuse()

	return false


func _is_panel_completed() -> bool:
	if puzzle_system == null:
		puzzle_system = get_tree().get_first_node_in_group("puzzle_system")

	if puzzle_system == null:
		return completed

	if puzzle_system.has_method("is_power_terminal_active"):
		return puzzle_system.is_power_terminal_active()

	return completed
