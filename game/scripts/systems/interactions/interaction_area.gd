extends Area2D
class_name InteractionArea

signal interacted(actor: Node)

@export var interaction_text: String = "Interagir"
@export var enabled: bool = true

# Se quiser que essa área repasse a interação para outro nó,
# use target_path. Exemplo: ".." para o pai.
@export var target_path: NodePath = NodePath("..")

@onready var target: Node = get_node_or_null(target_path)


func get_interaction_text() -> String:
	if target != null and target != self and target.has_method("get_interaction_text"):
		return target.get_interaction_text()

	return interaction_text


func can_interact(actor: Node) -> bool:
	if not enabled:
		return false

	if target != null and target != self and target.has_method("can_interact"):
		return target.can_interact(actor)

	return true


func interact(actor: Node) -> void:
	if not can_interact(actor):
		return

	if target != null and target != self and target.has_method("interact"):
		target.interact(actor)
		return

	interacted.emit(actor)


func set_enabled(value: bool) -> void:
	enabled = value
	set_deferred("monitoring", value)
	set_deferred("monitorable", value)
