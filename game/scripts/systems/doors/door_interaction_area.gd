extends Area2D

@export var door_path: NodePath = NodePath("..")

@onready var door: Node = get_node_or_null(door_path)

func get_interaction_text() -> String:
	if door != null and door.has_method("get_interaction_text"):
		return door.get_interaction_text()

	return "Interagir"


func can_interact(actor: Node) -> bool:
	if door != null and door.has_method("can_interact"):
		return door.can_interact(actor)

	return false


func interact(actor: Node) -> void:
	if door != null and door.has_method("interact"):
		door.interact(actor)
