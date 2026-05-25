# Inventory System Guide

## Overview
A 3×3 grid-based inventory UI positioned at the bottom-right of the screen. Displays 9 item slots with labels. Simple, extensible system for managing items.

---

## Files
- `inventoryUI.gd` — Script handling slot data and label updates
- `inventoryUI.tscn` — UI scene (3×3 grid layout)

---

## How to Add Items to Inventory

### Method 1: Direct Script Access
```gdscript
# Get reference to InventoryUI
var inventory = get_tree().root.get_node("World/InventoryUI")

# Set item name in slot (0-8)
inventory.setItemName(0, "Iron Sword")
inventory.setItemName(1, "Health Potion")
inventory.setItemName(2, "Gold Coin")
```

### Method 2: Create a InventoryManager
```gdscript
# res://core/autoloads/inventoryManager.gd
extends Node
class_name InventoryManager

var _inventory_ui: Control
var _items: Array[String] = ["", "", "", "", "", "", "", "", ""]

func _ready() -> void:
	_inventory_ui = get_tree().root.get_node_or_null("World/InventoryUI")

func add_item(item_name: String) -> bool:
	for i in range(9):
		if _items[i] == "":
			_items[i] = item_name
			if _inventory_ui:
				_inventory_ui.setItemName(i, item_name)
			return true
	return false  # Inventory full

func remove_item(slot_index: int) -> void:
	_items[slot_index] = ""
	if _inventory_ui:
		_inventory_ui.setItemName(slot_index, "")

func get_item(slot_index: int) -> String:
	return _items[slot_index]
```

Then register in `project.godot`:
```ini
[autoload]
InventoryManager="*res://core/autoloads/inventoryManager.gd"
```

---

## How to Edit Inventory

### Change Grid Size (not 3x3)
Edit `inventoryUI.tscn` → Panel → GridContainer:
- Change `columns` property (e.g., 4 for 4×2 grid)
- Change each Slot's `custom_minimum_size` to maintain aspect

### Change Slot Size
Edit each Slot node in `inventoryUI.tscn`:
```
Panel/GridContainer/Slot1 → custom_minimum_size = Vector2(100, 100)  # Larger slots
```

### Change Position
Edit `inventoryUI.tscn` → InventoryPanel:
```
offset_left = -240.0     # Move left (more negative = further right)
offset_top = -240.0      # Move up (more negative = further up)
offset_right = -8.0      # Right margin
offset_bottom = -8.0     # Bottom margin (keep at -8 to align with skill UI)
```

### Add Item Icons/Models
Currently uses text labels. To add icons:

```gdscript
# inventoryUI.gd - Add this to each slot
func _ready() -> void:
	# For each slot, add a TextureRect child:
	for i in range(9):
		var texture_rect = TextureRect.new()
		texture_rect.texture = load("res://assets/sprites/items/sword.png")
		_labels[i].get_parent().add_child(texture_rect)
```

---

## Node Structure

```
World (Node3D)
├── ... other nodes
└── InventoryUI (Control, bottom-right)
    └── InventoryPanel (PanelContainer, dark bg)
        └── GridContainer (3 columns, 9 slots)
            ├── Slot1 (PanelContainer, 70×70)
            │   └── Label (RichTextLabel, text "1")
            ├── Slot2 (PanelContainer, 70×70)
            │   └── Label (RichTextLabel, text "2")
            ... (Slot3-9 follow same pattern)
```

---

## How It Looks When Implemented

**Bottom-right corner:**
```
                           ┌─────┬─────┬─────┐
                           │ Swrd│ Pot │     │
                           ├─────┼─────┼─────┤
                           │ Coin│     │     │
                           ├─────┼─────┼─────┤
                           │     │     │     │
                           └─────┴─────┴─────┘
```

Each slot is 70×70 pixels. Text displays item name (or number if empty).

---

## API Reference

### inventoryUI.gd

```gdscript
# Set item name in specific slot
func setItemName(slotIndex: int, name: String) -> void

# Get item name from slot
func getItemName(slotIndex: int) -> String

# Example usage:
setItemName(0, "Iron Sword")    # Slot 1 shows "Iron Sword"
setItemName(1, "Health Potion") # Slot 2 shows "Health Potion"
var item = getItemName(0)       # Returns "Iron Sword"
```

---

## Complete Example: Add Item on Pickup

```gdscript
# res://entities/loot/item_pickup.gd
extends Area3D

@export var item_name: String = "Item"

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area3D) -> void:
	if area.name == "CollisionShape3D" and area.get_parent().name == "CharacterBody3D":
		# Player picked up item
		var inventory = get_tree().root.get_node_or_null("World/InventoryUI")
		if inventory:
			# Find empty slot
			for i in range(9):
				if inventory.getItemName(i) == "":
					inventory.setItemName(i, item_name)
					queue_free()  # Remove item from world
					return
```

---

## Extending with Item Data

Store more than just names:

```gdscript
# res://core/inventory/itemData.gd
class_name ItemData

var name: String
var description: String
var icon_path: String
var quantity: int = 1

func _init(p_name: String, p_desc: String, p_icon: String, p_qty: int = 1):
	name = p_name
	description = p_desc
	icon_path = p_icon
	quantity = p_qty
```

Then modify InventoryManager:
```gdscript
var _item_data: Array[ItemData] = [null, null, null, null, null, null, null, null, null]

func add_item(item: ItemData) -> bool:
	for i in range(9):
		if _item_data[i] == null:
			_item_data[i] = item
			_inventory_ui.setItemName(i, item.name)
			return true
	return false
```

---

## Troubleshooting

**Slots showing wrong numbers:**
- Check each Slot's Label text property (should be "1"-"9")

**Items not appearing:**
- Ensure InventoryUI is added to world scene
- Check setItemName() is being called with correct slot index (0-8)

**Layout broken:**
- Check GridContainer has `columns = 3`
- Check each Slot has `custom_minimum_size = Vector2(70, 70)`
