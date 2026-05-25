extends Control

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

func _on_class_loaded() -> void:
	for i in _name_labels.size():
		_refresh_slot(i)

func _refresh_slot(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= _name_labels.size():
		return
	var skill := _handler.get_skill(slot_index)
	_name_labels[slot_index].text = skill.display_name if skill else ""
