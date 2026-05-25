extends Control

@onready var _label: RichTextLabel = $Panel/RichTextLabel

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	hide()

func set_prompt(action: String, target: String) -> void:
	_label.text = "[color=#ffd700][b][ E ][/b][/color]   %s   ·   %s" % [action, target]
