extends Control

@onready var _slots: Array[PanelContainer] = [
	$SkillPanel/HBoxContainer/Slot1,
	$SkillPanel/HBoxContainer/Slot2,
	$SkillPanel/HBoxContainer/Slot3,
	$SkillPanel/HBoxContainer/Slot4,
	$SkillPanel/HBoxContainer/Slot5
]

@onready var _labels: Array[RichTextLabel] = [
	$SkillPanel/HBoxContainer/Slot1/Label,
	$SkillPanel/HBoxContainer/Slot2/Label,
	$SkillPanel/HBoxContainer/Slot3/Label,
	$SkillPanel/HBoxContainer/Slot4/Label,
	$SkillPanel/HBoxContainer/Slot5/Label
]

func _ready() -> void:
	print("Skill system loaded with %d slots" % _slots.size())

func setSkillName(slotIndex: int, name: String) -> void:
	if slotIndex < 0 or slotIndex >= _labels.size():
		return
	_labels[slotIndex].text = name

func getSkillName(slotIndex: int) -> String:
	if slotIndex < 0 or slotIndex >= _labels.size():
		return ""
	return _labels[slotIndex].text
