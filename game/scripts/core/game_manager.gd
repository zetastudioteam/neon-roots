# Responsabilidades
# - conectar HUD;
# - conectar PuzzleSystem;
# - controlar estado geral do jogo;
# - atualizar energia;
# - atualizar objetivo;
# - mostrar mensagens;
# - detectar fim do primeiro loop jogável.

extends Node
class_name GameManager

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
var fragment_already_found: bool = false

@onready var echo: Node = get_node_or_null(echo_path)
@onready var hud: Node = get_node_or_null(hud_path)
@onready var puzzle_system: Node = get_node_or_null(puzzle_system_path)


func _ready() -> void:
	add_to_group("game_manager")

	current_energy = clampf(start_energy, 0.0, max_energy)

	_connect_hud()
	_connect_puzzle_system()

	change_state(GameState.AWAKENING)
	_update_energy_ui()
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
	game_state_changed.emit(current_state)

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
			demo_finished.emit()


func start_gameplay() -> void:
	change_state(GameState.GAMEPLAY)
	_show_message("Movimento restaurado. Use W, A, S, D para andar.")


func enter_puzzle_state() -> void:
	change_state(GameState.PUZZLE)
	_show_message("Sistema da porta sem energia. Procure um fusível.")
	_set_objective(puzzle_objective)


func change_energy(amount: float) -> void:
	current_energy = clampf(current_energy + amount, 0.0, max_energy)
	_update_energy_ui()

	if current_energy <= 0.0:
		_on_energy_depleted()
	elif current_energy <= critical_energy_threshold:
		if hud != null and hud.has_method("set_warning_visible"):
			hud.set_warning_visible(true)
	else:
		if hud != null and hud.has_method("set_warning_visible"):
			hud.set_warning_visible(false)


func set_energy(value: float) -> void:
	current_energy = clampf(value, 0.0, max_energy)
	_update_energy_ui()


func restore_energy(amount: float) -> void:
	change_energy(absf(amount))
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
	if fragment_already_found:
		return

	fragment_already_found = true

	print("GameManager: notify_fragment_found chamado.")

	change_state(GameState.FRAGMENT_FOUND)
	set_energy(max_energy)
	_show_message("Fragmento recuperado. Sinal vital orgânico detectado.")
	_set_objective(end_objective)

	var ending_cutscene: Node = get_tree().get_first_node_in_group("ending_cutscene")

	if ending_cutscene == null:
		push_warning("GameManager: EndingCutscene não encontrada no grupo ending_cutscene.")
		finish_demo()
		return

	print("GameManager: EndingCutscene encontrada -> ", ending_cutscene.name)

	if ending_cutscene.has_signal("cutscene_finished"):
		var finished_callable: Callable = Callable(self, "_on_ending_cutscene_finished")

		if not ending_cutscene.cutscene_finished.is_connected(finished_callable):
			ending_cutscene.cutscene_finished.connect(finished_callable)

	if ending_cutscene.has_method("play"):
		print("GameManager: iniciando EndingCutscene.")
		ending_cutscene.play()
	else:
		push_warning("GameManager: EndingCutscene não tem método play().")
		finish_demo()


func _on_ending_cutscene_finished() -> void:
	print("GameManager: EndingCutscene finalizada.")
	finish_demo()


func finish_demo() -> void:
	if current_state == GameState.END:
		return

	change_state(GameState.END)
	_show_message("Demo concluída: 1/17 fragmentos recuperado.")


func _connect_hud() -> void:
	if hud == null:
		return

	var energy_callable: Callable = Callable(hud, "set_energy")
	if hud.has_method("set_energy") and not energy_changed.is_connected(energy_callable):
		energy_changed.connect(energy_callable)

	var objective_callable: Callable = Callable(hud, "set_objective")
	if hud.has_method("set_objective") and not objective_changed.is_connected(objective_callable):
		objective_changed.connect(objective_callable)

	var message_callable: Callable = Callable(hud, "show_message")
	if hud.has_method("show_message") and not message_requested.is_connected(message_callable):
		message_requested.connect(message_callable)

	_update_energy_ui()


func _connect_puzzle_system() -> void:
	if puzzle_system == null:
		puzzle_system = get_tree().get_first_node_in_group("puzzle_system")

	if puzzle_system == null:
		push_warning("GameManager: PuzzleSystem não encontrado.")
		return

	_safe_connect_puzzle_signal("fuse_registered", "_on_puzzle_fuse_registered")
	_safe_connect_puzzle_signal("terminal_activated", "_on_puzzle_terminal_activated")
	_safe_connect_puzzle_signal("power_terminal_activated", "_on_puzzle_terminal_activated")
	_safe_connect_puzzle_signal("door_opened", "_on_puzzle_door_opened")
	_safe_connect_puzzle_signal("puzzle_completed", "_on_puzzle_completed")
	_safe_connect_puzzle_signal("puzzle_message_requested", "_on_puzzle_message_requested")


func _safe_connect_puzzle_signal(signal_name: StringName, method_name: StringName) -> void:
	if puzzle_system == null:
		return

	if not puzzle_system.has_signal(signal_name):
		return

	var signal_object: Signal = Signal(puzzle_system, signal_name)
	var callable: Callable = Callable(self, method_name)

	if not signal_object.is_connected(callable):
		signal_object.connect(callable)


func _on_puzzle_fuse_registered(_fuse_id: StringName) -> void:
	notify_fuse_collected()


func _on_puzzle_terminal_activated() -> void:
	notify_terminal_activated()


func _on_puzzle_door_opened() -> void:
	notify_door_opened()


func _on_puzzle_completed() -> void:
	change_state(GameState.GAMEPLAY)
	_set_objective(fragment_objective)


func _on_puzzle_message_requested(message: String) -> void:
	_show_message(message)


func _on_energy_depleted() -> void:
	_show_message("Energia esgotada. Echo-7 entrou em modo de segurança.")

	if hud != null and hud.has_method("set_warning_visible"):
		hud.set_warning_visible(true)


func _update_energy_ui() -> void:
	energy_changed.emit(current_energy, max_energy)

	if hud != null and hud.has_method("set_energy"):
		hud.set_energy(current_energy, max_energy)


func _show_message(message_text: String) -> void:
	message_requested.emit(message_text)

	if hud != null and hud.has_method("show_message"):
		hud.show_message(message_text)


func _set_objective(objective_text: String) -> void:
	objective_changed.emit(objective_text)

	if hud != null and hud.has_method("set_objective"):
		hud.set_objective(objective_text)
