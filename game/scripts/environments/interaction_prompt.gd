extends Label

func _ready() -> void:
	hide_prompt()


func show_prompt(action_text: String) -> void:
	text = "[E] " + action_text
	visible = true


func hide_prompt() -> void:
	visible = false
