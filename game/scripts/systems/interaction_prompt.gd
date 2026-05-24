extends Control
class_name InteractionPrompt

# Variáveis exportadas
@export var key_text: String = "[E]"
@export var default_action_text: String = "Interagir"

@export var key_label_path: NodePath = NodePath("PanelContainer/MarginContainer/HBoxContainer/KeyLabel")
@export var action_label_path: NodePath = NodePath("PanelContainer/MarginContainer/HBoxContainer/ActionLabel")

@onready var key_label: Label = get_node_or_null(key_label_path)
@onready var action_label: Label = get_node_or_null(action_label_path)

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	hide_prompt()


func show_prompt(action_text: String = "") -> void:
	if key_label != null:
		key_label.text = key_text

	if action_label != null:
		if action_text.strip_edges().is_empty():
			action_label.text = default_action_text
		else:
			action_label.text = action_text

	visible = true


func hide_prompt() -> void:
	visible = false


func set_key_text(new_key_text: String) -> void:
	key_text = new_key_text

	if key_label != null:
		key_label.text = key_text


func set_action_text(new_action_text: String) -> void:
	if action_label != null:
		action_label.text = new_action_text
