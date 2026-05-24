extends Control
class_name EchoHUD

# Variáveis exportadas
@export var energy_bar_path: NodePath = NodePath("EnergyBar")
@export var energy_label_path: NodePath = NodePath("EnergyLabel")
@export var objective_label_path: NodePath = NodePath("ObjectiveLabel")
@export var message_label_path: NodePath = NodePath("MessageLabel")
@export var warning_label_path: NodePath = NodePath("WarningLabel")

@export var message_duration: float = 3.0
@export var warning_text: String = "ENERGIA CRÍTICA"

var message_timer: float = 0.0

@onready var energy_bar: ProgressBar = get_node_or_null(energy_bar_path)
@onready var energy_label: Label = get_node_or_null(energy_label_path)
@onready var objective_label: Label = get_node_or_null(objective_label_path)
@onready var message_label: Label = get_node_or_null(message_label_path)
@onready var warning_label: Label = get_node_or_null(warning_label_path)

func _ready() -> void:
	if message_label != null:
		message_label.text = ""
		message_label.visible = false

	if warning_label != null:
		warning_label.text = warning_text
		warning_label.visible = false

	set_energy(0.0, 100.0)
	set_objective("Inicializando...")


func _process(delta: float) -> void:
	if message_timer > 0.0:
		message_timer -= delta

		if message_timer <= 0.0:
			_hide_message()


func set_energy(current_energy: float, max_energy: float) -> void:
	var safe_max: float = maxf(max_energy, 1.0)
	var clamped_energy: float = clampf(current_energy, 0.0, safe_max)

	if energy_bar != null:
		energy_bar.min_value = 0.0
		energy_bar.max_value = safe_max
		energy_bar.value = clamped_energy

	if energy_label != null:
		var percent: int = int(round((clamped_energy / safe_max) * 100.0))
		energy_label.text = "Energia: %d%%" % percent


func set_objective(objective_text: String) -> void:
	if objective_label != null:
		objective_label.text = objective_text


func show_message(message_text: String) -> void:
	if message_label == null:
		return

	message_label.text = message_text
	message_label.visible = true
	message_timer = message_duration


func clear_message() -> void:
	message_timer = 0.0
	_hide_message()


func set_warning_visible(value: bool) -> void:
	if warning_label != null:
		warning_label.visible = value


func _hide_message() -> void:
	if message_label != null:
		message_label.visible = false
		message_label.text = ""
