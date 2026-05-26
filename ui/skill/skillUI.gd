extends Control

const HIGHLIGHT_COLOR := Color(1.5, 1.5, 1.5, 1.0)
const HIGHLIGHT_DURATION := 0.12

@onready var _slots: Array[Control] = [
	$SkillPanel/HBoxContainer/Slot1,
	$SkillPanel/HBoxContainer/Slot2,
	$SkillPanel/HBoxContainer/Slot3,
	$SkillPanel/HBoxContainer/Slot4,
	$SkillPanel/HBoxContainer/Slot5,
]

@onready var _name_labels: Array[Label] = [
	$SkillPanel/HBoxContainer/Slot1/Layout/SkillName,
	$SkillPanel/HBoxContainer/Slot2/Layout/SkillName,
	$SkillPanel/HBoxContainer/Slot3/Layout/SkillName,
	$SkillPanel/HBoxContainer/Slot4/Layout/SkillName,
	$SkillPanel/HBoxContainer/Slot5/Layout/SkillName,
]

var _handler: ClassHandler

func _ready() -> void:
	_handler = get_parent().get_node_or_null("ClassHandler") as ClassHandler
	if not _handler:
		return
	_handler.class_loaded.connect(_on_class_loaded)
	_handler.slot_changed.connect(_refresh_slot)
	_handler.skill_activated.connect(_on_skill_activated)

func _on_class_loaded() -> void:
	for i in _name_labels.size():
		_refresh_slot(i)

func _refresh_slot(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= _name_labels.size():
		return
	var skill := _handler.get_skill(slot_index)
	_name_labels[slot_index].text = skill.display_name if skill else ""

func _on_skill_activated(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= _slots.size():
		return
	var slot := _slots[slot_index]
	var tween := create_tween()
	tween.tween_property(slot, "modulate", HIGHLIGHT_COLOR, 0.0)
	tween.tween_property(slot, "modulate", Color.WHITE, HIGHLIGHT_DURATION)
