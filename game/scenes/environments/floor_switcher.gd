extends Node2D

#Variáveis exportadas
@export var ground_floor_path: NodePath
@export var upper_floor_path: NodePath
@export var basement_floor_path: NodePath

@export var ground_alpha_when_upper_visible: float = 0.25

@onready var ground_floor: Node2D = get_node_or_null(ground_floor_path)
@onready var upper_floor: Node2D = get_node_or_null(upper_floor_path)
@onready var basement_floor: Node2D = get_node_or_null(basement_floor_path)

func _ready() -> void:
	show_ground_floor()


func show_ground_floor() -> void:
	if ground_floor != null:
		ground_floor.visible = true
		ground_floor.modulate.a = 1.0

	if upper_floor != null:
		upper_floor.visible = false

	if basement_floor != null:
		basement_floor.visible = false


func show_upper_floor() -> void:
	if ground_floor != null:
		ground_floor.visible = true
		ground_floor.modulate.a = ground_alpha_when_upper_visible

	if upper_floor != null:
		upper_floor.visible = true
		upper_floor.modulate.a = 1.0

	if basement_floor != null:
		basement_floor.visible = false


func show_basement_floor() -> void:
	if ground_floor != null:
		ground_floor.visible = false

	if upper_floor != null:
		upper_floor.visible = false

	if basement_floor != null:
		basement_floor.visible = true
		basement_floor.modulate.a = 1.0
