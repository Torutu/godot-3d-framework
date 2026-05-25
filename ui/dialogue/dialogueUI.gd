extends Control

signal option_confirmed(index: int)

@onready var _speaker_label: Label = $Panel/VBoxContainer/SpeakerLabel
@onready var _text_label: RichTextLabel = $Panel/VBoxContainer/TextLabel
@onready var _options_container: VBoxContainer = $Panel/VBoxContainer/OptionsContainer
@onready var _hint_label: Label = $Panel/VBoxContainer/HintLabel

var _focused_index: int = 0

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_PASS
	hide()

func display(speaker: String, text: String, options: Array) -> void:
	_speaker_label.text = speaker
	_text_label.text = text
	_focused_index = 0

	for child in _options_container.get_children():
		child.queue_free()

	if options.is_empty():
		_hint_label.visible = true
		return

	_hint_label.visible = false
	for i in range(options.size()):
		var btn := Button.new()
		btn.text = "[%d]  %s" % [i + 1, options[i].text]
		btn.custom_minimum_size = Vector2(500, 36)
		btn.focus_mode = Control.FOCUS_ALL
		var idx := i
		btn.pressed.connect(func() -> void: option_confirmed.emit(idx))
		_options_container.add_child(btn)

	await get_tree().process_frame
	if _options_container.get_child_count() > 0:
		_options_container.get_child(0).grab_focus()

func navigate(dir: int) -> void:
	var buttons := _options_container.get_children()
	if buttons.is_empty():
		return
	_focused_index = (_focused_index + dir + buttons.size()) % buttons.size()
	buttons[_focused_index].grab_focus()

func confirm() -> void:
	var buttons := _options_container.get_children()
	if not buttons.is_empty() and _focused_index < buttons.size():
		buttons[_focused_index].emit_signal("pressed")
