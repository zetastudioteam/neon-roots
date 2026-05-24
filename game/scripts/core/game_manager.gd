# Responsabilidades
# - posicionar Echo no PlayerSpawn;
# - conectar Echo ao HUD;
# - conectar InteractionSystem ao InteractionPrompt;
# - conectar Fuse, Door e TerminalPuzzle ao PuzzleSystem;
# - atualizar objetivo atual da HUD;
# - detectar fim do primeiro loop jogável.

extends Node
class_name GameManager

# Sinais
signal game_state_changed(new_state: GameState)
signal energy_changed(current_energy: float, max_energy: float)
signal objective_changed(objective_text: String)
signal message_requested(message_text: String)
signal demo_finished()

enum GameState {
	MENU,
	AWAKENING,
	GAMEPLAY,
	PUZZLE,
	FRAGMENT_FOUND,
	END
}

# Variáveis exportadas
@export_category("Referências da Cena")
@export var echo_path: NodePath
@export var hud_path: NodePath
@export var puzzle_system_path: NodePath

@export_category("Energia da Echo")
@export var max_energy: float = 100.0
@export var start_energy: float = 35.0
@export var critical_energy_threshold: float = 15.0
@export var energy_drain_enabled: bool = false
@export var energy_drain_per_second: float = 1.0

@export_category("Objetivos")
@export var awakening_objective: String = "Levante e encontre uma fonte de energia."
@export var gameplay_objective: String = "Explore o prédio de arquivos."
@export var puzzle_objective: String = "Encontre um fusível para restaurar a energia da porta."
@export var terminal_objective: String = "Leve o fusível até o terminal."
@export var fragment_objective: String = "A porta abriu. Encontre o fragmento."
@export var end_objective: String = "Fragmento recuperado. Neo despertou."

var current_state: GameState = GameState.AWAKENING
var current_energy: float = 0.0
var has_started: bool = false

@onready var echo: Node = get_node_or_null(echo_path)
@onready var hud: Node = get_node_or_null(hud_path)
@onready var puzzle_system: Node = get_node_or_null(puzzle_system_path)

func _ready() -> void:
	current_energy = clamp(start_energy, 0.0, max_energy)

	_connect_hud()
	_connect_puzzle_system()

	change_state(GameState.AWAKENING)
	emit_signal("energy_changed", current_energy, max_energy)
	_show_message("Echo-7 reiniciada. Energia crítica detectada.")
	_set_objective(awakening_objective)

	has_started = true


func _process(delta: float) -> void:
	if not has_started:
		return

	if current_state == GameState.END:
		return

	if energy_drain_enabled:
		change_energy(-energy_drain_per_second * delta)


func change_state(new_state: GameState) -> void:
	if current_state == new_state:
		return

	current_state = new_state
	emit_signal("game_state_changed", current_state)

	match current_state:
		GameState.MENU:
			_set_objective("Menu inicial.")
		GameState.AWAKENING:
			_set_objective(awakening_objective)
		GameState.GAMEPLAY:
			_set_objective(gameplay_objective)
		GameState.PUZZLE:
			_set_objective(puzzle_objective)
		GameState.FRAGMENT_FOUND:
			_set_objective(end_objective)
		GameState.END:
			_set_objective(end_objective)
			emit_signal("demo_finished")


func start_gameplay() -> void:
	change_state(GameState.GAMEPLAY)
	_show_message("Movimento restaurado. Use W, A, S, D para andar.")


func enter_puzzle_state() -> void:
	change_state(GameState.PUZZLE)
	_show_message("Sistema da porta sem energia. Procure um fusível.")
	_set_objective(puzzle_objective)


func change_energy(amount: float) -> void:
	current_energy = clamp(current_energy + amount, 0.0, max_energy)
	emit_signal("energy_changed", current_energy, max_energy)

	if hud != null and hud.has_method("set_energy"):
		hud.set_energy(current_energy, max_energy)

	if current_energy <= 0.0:
		_on_energy_depleted()
	elif current_energy <= critical_energy_threshold:
		if hud != null and hud.has_method("set_warning_visible"):
			hud.set_warning_visible(true)
	else:
		if hud != null and hud.has_method("set_warning_visible"):
			hud.set_warning_visible(false)


func set_energy(value: float) -> void:
	current_energy = clamp(value, 0.0, max_energy)
	emit_signal("energy_changed", current_energy, max_energy)

	if hud != null and hud.has_method("set_energy"):
		hud.set_energy(current_energy, max_energy)


func restore_energy(amount: float) -> void:
	change_energy(abs(amount))
	_show_message("Energia restaurada parcialmente.")


func notify_fuse_collected() -> void:
	_show_message("Fusível obtido.")
	_set_objective(terminal_objective)


func notify_terminal_activated() -> void:
	_show_message("Terminal reativado. Energia redirecionada para a porta.")


func notify_door_opened() -> void:
	_show_message("Porta destravada.")
	_set_objective(fragment_objective)


func notify_fragment_found() -> void:
	change_state(GameState.FRAGMENT_FOUND)
	restore_energy(max_energy)
	_show_message("Fragmento recuperado. Sinal vital orgânico detectado.")
	finish_demo()


func finish_demo() -> void:
	change_state(GameState.END)
	_show_message("Demo concluída: 1/17 fragmentos recuperado.")


func _connect_hud() -> void:
	if hud == null:
		push_warning("GameManager: hud_path não foi configurado.")
		return

	if hud.has_method("set_energy"):
		hud.set_energy(current_energy, max_energy)

	if hud.has_method("show_message"):
		message_requested.connect(hud.show_message)

	if hud.has_method("set_objective"):
		objective_changed.connect(hud.set_objective)


func _connect_puzzle_system() -> void:
	if puzzle_system == null:
		push_warning("GameManager: puzzle_system_path não foi configurado.")
		return

	if puzzle_system.has_signal("fuse_registered"):
		puzzle_system.fuse_registered.connect(_on_puzzle_fuse_registered)

	if puzzle_system.has_signal("terminal_activated"):
		puzzle_system.terminal_activated.connect(_on_puzzle_terminal_activated)

	if puzzle_system.has_signal("door_opened"):
		puzzle_system.door_opened.connect(_on_puzzle_door_opened)

	if puzzle_system.has_signal("puzzle_completed"):
		puzzle_system.puzzle_completed.connect(_on_puzzle_completed)


func _on_puzzle_fuse_registered(_fuse_id: StringName) -> void:
	notify_fuse_collected()


func _on_puzzle_terminal_activated() -> void:
	notify_terminal_activated()


func _on_puzzle_door_opened() -> void:
	notify_door_opened()


func _on_puzzle_completed() -> void:
	change_state(GameState.GAMEPLAY)


func _on_energy_depleted() -> void:
	_show_message("Energia esgotada. Echo-7 entrou em modo de segurança.")
	if hud != null and hud.has_method("set_warning_visible"):
		hud.set_warning_visible(true)


func _show_message(message_text: String) -> void:
	emit_signal("message_requested", message_text)

	if hud != null and hud.has_method("show_message"):
		hud.show_message(message_text)


func _set_objective(objective_text: String) -> void:
	emit_signal("objective_changed", objective_text)

	if hud != null and hud.has_method("set_objective"):
		hud.set_objective(objective_text)
