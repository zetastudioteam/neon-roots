extends CanvasLayer
class_name CutscenePlayer

signal cutscene_finished()

@export var play_on_ready: bool = false
@export var pause_game_while_playing: bool = true
@export var hide_when_finished: bool = true

@export var titles: PackedStringArray = []
@export var texts: PackedStringArray = []
@export var images: Array[Texture2D] = []

@export var root_path: NodePath = NodePath("Root")
@export var background_image_path: NodePath = NodePath("Root/BackgroundImage")
@export var title_label_path: NodePath = NodePath("Root/TextPanel/MarginContainer/VBoxContainer/TitleLabel")
@export var body_label_path: NodePath = NodePath("Root/TextPanel/MarginContainer/VBoxContainer/BodyLabel")
@export var next_button_path: NodePath = NodePath("Root/TextPanel/MarginContainer/VBoxContainer/ButtonRow/NextButton")
@export var skip_button_path: NodePath = NodePath("Root/TextPanel/MarginContainer/VBoxContainer/ButtonRow/SkipButton")

var current_index: int = 0
var playing: bool = false

@onready var root: Control = get_node_or_null(root_path)
@onready var background_image: TextureRect = get_node_or_null(background_image_path)
@onready var title_label: Label = get_node_or_null(title_label_path)
@onready var body_label: Label = get_node_or_null(body_label_path)
@onready var next_button: Button = get_node_or_null(next_button_path)
@onready var skip_button: Button = get_node_or_null(skip_button_path)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	if next_button != null:
		if not next_button.pressed.is_connected(_on_next_pressed):
			next_button.pressed.connect(_on_next_pressed)

	if skip_button != null:
		if not skip_button.pressed.is_connected(finish_cutscene):
			skip_button.pressed.connect(finish_cutscene)

	if play_on_ready:
		play()
	else:
		hide_cutscene()


func play() -> void:
	current_index = 0
	playing = true

	visible = true

	if root != null:
		root.visible = true

	if pause_game_while_playing:
		get_tree().paused = true

	_show_current_slide()


func hide_cutscene() -> void:
	playing = false

	if root != null:
		root.visible = false
		root.modulate = Color(1, 1, 1, 1)

	visible = false


func finish_cutscene() -> void:
	playing = false

	get_tree().paused = false

	if hide_when_finished:
		hide_cutscene()
	else:
		if root != null:
			root.visible = false
		visible = false

	cutscene_finished.emit()


func _on_next_pressed() -> void:
	if not playing:
		return

	current_index += 1

	if current_index >= _get_slide_count():
		finish_cutscene()
		return

	_show_current_slide()


func _show_current_slide() -> void:
	var slide_count: int = _get_slide_count()

	if slide_count <= 0:
		finish_cutscene()
		return

	if background_image != null:
		if current_index < images.size():
			background_image.texture = images[current_index]

	if title_label != null:
		if current_index < titles.size():
			title_label.text = titles[current_index]
		else:
			title_label.text = ""

	if body_label != null:
		if current_index < texts.size():
			body_label.text = texts[current_index]
		else:
			body_label.text = ""

	if next_button != null:
		if current_index >= slide_count - 1:
			next_button.text = "Finalizar"
		else:
			next_button.text = "Continuar"


func _get_slide_count() -> int:
	return max(images.size(), texts.size(), titles.size())
