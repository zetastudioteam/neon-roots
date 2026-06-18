extends Control
class_name InteractionPrompt

# Variáveis exportadas
@export var key_label_path: NodePath = NodePath("PanelContainer/MarginContainer/HBoxContainer/KeyLabel")
@export var action_label_path: NodePath = NodePath("PanelContainer/MarginContainer/HBoxContainer/ActionLabel")

@onready var key_label: Label = get_node_or_null(key_label_path)
@onready var action_label: Label = get_node_or_null(action_label_path)

func _ready() -> void:
	hide_prompt()


func show_prompt(action_text: String = "Interagir") -> void:
	if key_label != null:
		key_label.text = "[E]"

	if action_label != null:
		action_label.text = action_text

	visible = true


func hide_prompt() -> void:
	visible = false
