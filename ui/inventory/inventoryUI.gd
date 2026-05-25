extends Control

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
	print("Inventory: 9 slots loaded")

func setItemName(slotIndex: int, itemName: String) -> void:
	if slotIndex >= 0 and slotIndex < _labels.size():
		_labels[slotIndex].text = itemName

func getItemName(slotIndex: int) -> String:
	if slotIndex >= 0 and slotIndex < _labels.size():
		return _labels[slotIndex].text
	return ""
