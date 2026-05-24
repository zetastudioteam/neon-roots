extends Area2D
class_name InteractionArea

# Variáveis exportadas
@export var target_path: NodePath = NodePath("..")
@export var fallback_interaction_text: String = "Interagir"
@export var enabled: bool = true

@onready var target: Node = get_node_or_null(target_path)

func _ready() -> void:
	if target == null:
		push_warning("InteractionArea: target_path não foi configurado ou não foi encontrado.")


func get_interaction_text() -> String:
	if not enabled:
		return ""

	if target != null and target.has_method("get_interaction_text"):
		return target.get_interaction_text()

	return fallback_interaction_text


func can_interact(actor: Node) -> bool:
	if not enabled:
		return false

	if target != null and target.has_method("can_interact"):
		return target.can_interact(actor)

	return target != null


func interact(actor: Node) -> void:
	if not enabled:
		return

	if target != null and target.has_method("interact"):
		target.interact(actor)


func set_enabled(value: bool) -> void:
	enabled = value
	set_deferred("monitoring", value)
	set_deferred("monitorable", value)
