extends Area2D

# Variáveis exportadas
@export_enum("ground", "upper", "basement") var source_floor: String = "ground"
@export_enum("ground", "upper", "basement") var target_floor: String = "upper"

@export var floor_switcher_path: NodePath
@export var prompt_path: NodePath

@export var require_interact_button: bool = true
@export var interact_action: StringName = &"interact"
@export var interaction_text: String = "Usar escada"

var player_inside: CharacterBody2D = null

@onready var floor_switcher: Node = get_node_or_null(floor_switcher_path)
@onready var prompt: Node = get_node_or_null(prompt_path)

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	if floor_switcher == null:
		push_warning("FloorTrigger: floor_switcher_path não configurado.")

	if prompt == null:
		push_warning("FloorTrigger: prompt_path não configurado.")


func _process(_delta: float) -> void:
	if not require_interact_button:
		return

	if player_inside == null:
		return

	if not _can_use_this_trigger_now():
		_hide_prompt()
		return

	_show_prompt()

	if Input.is_action_just_pressed(interact_action):
		_try_change_floor()


func _on_body_entered(body: Node) -> void:
	if not body is CharacterBody2D:
		return

	if not body.name.to_lower().contains("echo"):
		return

	player_inside = body

	if _can_use_this_trigger_now():
		_show_prompt()

	if not require_interact_button:
		_try_change_floor()


func _on_body_exited(body: Node) -> void:
	if body == player_inside:
		player_inside = null
		_hide_prompt()


func _try_change_floor() -> void:
	if floor_switcher == null:
		return

	if floor_switcher.has_method("is_busy"):
		if floor_switcher.is_busy():
			return

	if not _can_use_this_trigger_now():
		return

	_hide_prompt()

	if floor_switcher.has_method("change_floor"):
		floor_switcher.change_floor(target_floor)


func _can_use_this_trigger_now() -> bool:
	if floor_switcher == null:
		return false

	if floor_switcher.has_method("get_current_floor"):
		return floor_switcher.get_current_floor() == source_floor

	return true


func _show_prompt() -> void:
	if prompt == null:
		return

	if prompt.has_method("show_prompt"):
		prompt.show_prompt(interaction_text)
	elif prompt is Label:
		prompt.text = "[E] " + interaction_text
		prompt.visible = true


func _hide_prompt() -> void:
	if prompt == null:
		return

	if prompt.has_method("hide_prompt"):
		prompt.hide_prompt()
	elif prompt is CanvasItem:
		prompt.visible = false
