extends Area2D
class_name FuseItem

@export var fuse_id: StringName = &"archive_fuse_01"
@export var interaction_text: String = "Pegar fusível"

var collected: bool = false
var puzzle_system: Node = null


func _ready() -> void:
	puzzle_system = get_tree().get_first_node_in_group("puzzle_system")

	if puzzle_system == null:
		push_warning("FuseItem: PuzzleSystem não encontrado no grupo puzzle_system.")


func get_interaction_text() -> String:
	return interaction_text


func can_interact(_actor: Node) -> bool:
	return not collected


func interact(_actor: Node) -> void:
	if collected:
		return

	collected = true

	if puzzle_system == null:
		puzzle_system = get_tree().get_first_node_in_group("puzzle_system")

	if puzzle_system == null:
		push_warning("FuseItem: não consegui registrar o fusível porque PuzzleSystem é null.")
		return

	if puzzle_system.has_method("register_fuse"):
		puzzle_system.register_fuse(fuse_id)
		print("FuseItem: fusível registrado -> ", fuse_id)
	else:
		push_warning("FuseItem: PuzzleSystem não tem register_fuse().")

	visible = false
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
