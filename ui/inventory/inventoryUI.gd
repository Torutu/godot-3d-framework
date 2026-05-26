extends Control

const HIGHLIGHT_COLOR := Color(1.5, 1.5, 1.5, 1.0)
const HIGHLIGHT_DURATION := 0.12

@onready var _slots: Array[Control] = [
	$InventoryPanel/GridContainer/Slot1,
	$InventoryPanel/GridContainer/Slot2,
	$InventoryPanel/GridContainer/Slot3,
	$InventoryPanel/GridContainer/Slot4,
	$InventoryPanel/GridContainer/Slot5,
	$InventoryPanel/GridContainer/Slot6,
	$InventoryPanel/GridContainer/Slot7,
	$InventoryPanel/GridContainer/Slot8,
	$InventoryPanel/GridContainer/Slot9,
]

@onready var _labels: Array[RichTextLabel] = [
	$InventoryPanel/GridContainer/Slot1/Label,
	$InventoryPanel/GridContainer/Slot2/Label,
	$InventoryPanel/GridContainer/Slot3/Label,
	$InventoryPanel/GridContainer/Slot4/Label,
	$InventoryPanel/GridContainer/Slot5/Label,
	$InventoryPanel/GridContainer/Slot6/Label,
	$InventoryPanel/GridContainer/Slot7/Label,
	$InventoryPanel/GridContainer/Slot8/Label,
	$InventoryPanel/GridContainer/Slot9/Label,
]

func _ready() -> void:
	DebugManager.log("[InventoryUI] 9 slots loaded")

func highlight_slot(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= _slots.size():
		return
	var slot := _slots[slot_index]
	var tween := create_tween()
	tween.tween_property(slot, "modulate", HIGHLIGHT_COLOR, 0.0)
	tween.tween_property(slot, "modulate", Color.WHITE, HIGHLIGHT_DURATION)

func set_item_name(slot_index: int, item_name: String) -> void:
	if slot_index >= 0 and slot_index < _labels.size():
		_labels[slot_index].text = item_name

func get_item_name(slot_index: int) -> String:
	if slot_index >= 0 and slot_index < _labels.size():
		return _labels[slot_index].text
	return ""
