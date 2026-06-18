extends CanvasLayer
class_name MainMenu

signal play_pressed()

@export var root_path: NodePath = NodePath("Root")
@export var play_button_path: NodePath = NodePath("Root/CenterBox/PlayButton")
@export var quit_button_path: NodePath = NodePath("Root/CenterBox/QuitButton")

@onready var root: Control = get_node_or_null(root_path)
@onready var play_button: Button = get_node_or_null(play_button_path)
@onready var quit_button: Button = get_node_or_null(quit_button_path)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	if play_button != null:
		if not play_button.pressed.is_connected(_on_play_pressed):
			play_button.pressed.connect(_on_play_pressed)

	if quit_button != null:
		if not quit_button.pressed.is_connected(_on_quit_pressed):
			quit_button.pressed.connect(_on_quit_pressed)

	show_menu()


func show_menu() -> void:
	visible = true

	if root != null:
		root.visible = true

	get_tree().paused = true


func hide_menu() -> void:
	if root != null:
		root.visible = false

	visible = false
	visible = false

	if root != null:
		root.visible = false


func _on_play_pressed() -> void:
	hide_menu()
	get_tree().paused = false

	var intro_cutscene: Node = get_tree().get_first_node_in_group("intro_cutscene")

	if intro_cutscene != null and intro_cutscene.has_method("play"):
		intro_cutscene.play()

	play_pressed.emit()
	hide_menu()
	get_tree().paused = false

	if intro_cutscene != null and intro_cutscene.has_method("play"):
		intro_cutscene.play()

	play_pressed.emit()


func _on_quit_pressed() -> void:
	get_tree().quit()
