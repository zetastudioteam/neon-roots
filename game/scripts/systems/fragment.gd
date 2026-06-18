extends Area2D
class_name Fragment

@export var interaction_text: String = "Coletar fragmento"

var collected: bool = false


func get_interaction_text() -> String:
	return interaction_text


func can_interact(_actor: Node) -> bool:
	return not collected


func interact(_actor: Node) -> void:
	if collected:
		return

	collected = true
	print("Fragment: fragmento coletado.")

	var game_manager: Node = get_tree().get_first_node_in_group("game_manager")

	if game_manager == null:
		push_warning("Fragment: GameManager não encontrado no grupo game_manager.")
	else:
		print("Fragment: GameManager encontrado -> ", game_manager.name)

		if game_manager.has_method("notify_fragment_found"):
			print("Fragment: chamando notify_fragment_found().")
			game_manager.notify_fragment_found()
		else:
			push_warning("Fragment: GameManager não tem notify_fragment_found().")

	visible = false
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
