# Responsabilidades
# - permitir interação;
# - emitir sinal quando coletado;
# - desativar interação depois;
# não abrir porta diretamente.

extends Area2D
class_name Fuse

# Sinal
signal fuse_collected(fuse_id: StringName)

# Variáveis exportadas
@export var fuse_id: StringName = &"archive_fuse_01"
@export var interaction_text: String = "Pegar fusível"
@export var collected_message: String = "Fusível coletado."
@export var disable_after_collect: bool = true
@export var hide_after_collect: bool = true
@export var puzzle_system_path: NodePath

@export_category("Nós")
@export var animation_player_path: NodePath = NodePath("AnimationPlayer")

var collected: bool = false

@onready var animation_player: AnimationPlayer = get_node_or_null(animation_player_path)
@onready var puzzle_system: Node = get_node_or_null(puzzle_system_path)

func _ready() -> void:
	monitoring = true
	monitorable = true

	if animation_player != null and animation_player.has_animation("idle"):
		animation_player.play("idle")


func get_interaction_text() -> String:
	return interaction_text


func can_interact(_actor: Node) -> bool:
	return not collected


func interact(_actor: Node) -> void:
	if collected:
		return

	collect()


func collect() -> void:
	collected = true

	if animation_player != null and animation_player.has_animation("collected"):
		animation_player.play("collected")

	fuse_collected.emit(fuse_id)

	if puzzle_system != null and puzzle_system.has_method("register_fuse"):
		puzzle_system.register_fuse(fuse_id)

	if hide_after_collect:
		visible = false

	if disable_after_collect:
		set_deferred("monitoring", false)
		set_deferred("monitorable", false)


func reset_fuse() -> void:
	collected = false
	visible = true
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)

	if animation_player != null and animation_player.has_animation("idle"):
		animation_player.play("idle")
