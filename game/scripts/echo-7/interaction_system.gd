# Responsabilidades
# - guardar lista de interativos próximos;
# - selecionar o melhor alvo;
# - mostrar prompt;
# - esconder prompt;
# - chamar interact(actor) no alvo;
# - não saber regra de puzzle.

extends Area2D
class_name EchoInteractionSystem

# Sinal
signal interactable_focused(interactable: Node)
signal interactable_unfocused()
signal interaction_performed(interactable: Node)

# Variáveis exportadas
@export var prompt_path: NodePath
@export var interact_action: StringName = &"interact"
@export var actor_path: NodePath = NodePath("..")
@export var auto_show_prompt: bool = true

var nearby_interactables: Array[Node] = []
var current_interactable: Node = null

@onready var prompt: Control = get_node_or_null(prompt_path)
@onready var actor: Node = get_node_or_null(actor_path)

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

	if actor == null:
		actor = owner

	if prompt == null and auto_show_prompt:
		push_warning("InteractionSystem: prompt_path não foi configurado.")

	if prompt != null and prompt.has_method("hide_prompt"):
		prompt.hide_prompt()


func _process(_delta: float) -> void:
	_refresh_current_interactable()

	if current_interactable == null:
		return

	if Input.is_action_just_pressed(interact_action):
		if _can_interact_with(current_interactable):
			current_interactable.interact(actor)
			interaction_performed.emit(current_interactable)
			_refresh_current_interactable()


func _on_area_entered(area: Area2D) -> void:
	if _is_valid_interactable(area):
		if not nearby_interactables.has(area):
			nearby_interactables.append(area)


func _on_area_exited(area: Area2D) -> void:
	if nearby_interactables.has(area):
		nearby_interactables.erase(area)

	if current_interactable == area:
		current_interactable = null
		_hide_prompt()
		interactable_unfocused.emit()


func _refresh_current_interactable() -> void:
	nearby_interactables = nearby_interactables.filter(func(item: Node) -> bool:
		return is_instance_valid(item) and _is_valid_interactable(item)
	)

	if nearby_interactables.is_empty():
		if current_interactable != null:
			current_interactable = null
			interactable_unfocused.emit()
		_hide_prompt()
		return

	var best_interactable := _get_closest_interactable()

	if best_interactable != current_interactable:
		current_interactable = best_interactable

		if current_interactable != null:
			interactable_focused.emit(current_interactable)

	if current_interactable != null and _can_interact_with(current_interactable):
		_show_prompt(_get_interaction_text(current_interactable))
	else:
		_hide_prompt()


func _get_closest_interactable() -> Node:
	var closest: Node = null
	var closest_distance := INF

	for item in nearby_interactables:
		var item_position := Vector2.ZERO

		if item is Node2D:
			item_position = item.global_position
		else:
			continue

		var distance := global_position.distance_to(item_position)

		if distance < closest_distance:
			closest_distance = distance
			closest = item

	return closest


func _is_valid_interactable(node: Node) -> bool:
	if node == null:
		return false

	return node.has_method("interact") and node.has_method("can_interact") and node.has_method("get_interaction_text")


func _can_interact_with(node: Node) -> bool:
	if not _is_valid_interactable(node):
		return false

	return node.can_interact(actor)


func _get_interaction_text(node: Node) -> String:
	if not _is_valid_interactable(node):
		return "Interagir"

	return node.get_interaction_text()


func _show_prompt(text: String) -> void:
	if not auto_show_prompt:
		return

	if prompt != null and prompt.has_method("show_prompt"):
		prompt.show_prompt(text)


func _hide_prompt() -> void:
	if not auto_show_prompt:
		return

	if prompt != null and prompt.has_method("hide_prompt"):
		prompt.hide_prompt()
