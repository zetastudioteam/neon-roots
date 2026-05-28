extends Area2D

#Variáveis exportadas
@export_enum("ground", "upper", "basement") var target_floor: String = "ground"
@export var floor_switcher_path: NodePath

@onready var floor_switcher: Node = get_node_or_null(floor_switcher_path)

func _ready() -> void:
	body_entered.connect(_on_body_entered)

	if floor_switcher == null:
		push_warning("FloorTrigger: floor_switcher_path não configurado.")


func _on_body_entered(body: Node) -> void:
	if not body is CharacterBody2D:
		return

	if not body.name.to_lower().contains("echo"):
		return

	if floor_switcher == null:
		return

	if target_floor == "ground" and floor_switcher.has_method("show_ground_floor"):
		floor_switcher.show_ground_floor()

	if target_floor == "upper" and floor_switcher.has_method("show_upper_floor"):
		floor_switcher.show_upper_floor()

	if target_floor == "basement" and floor_switcher.has_method("show_basement_floor"):
		floor_switcher.show_basement_floor()
