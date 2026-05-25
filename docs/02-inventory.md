# Inventory System — Complete Guide

## SECTION 1: What Is This & Why Do You Need It?

### What It Does
The **inventory system** is a 3×3 grid of item slots shown in the bottom-right corner of the screen. Each slot can hold one item name. The player can see what they're carrying at all times.

### Real Example

```
Player walks over a potion → potion name appears in slot 0 (first empty slot)
Player walks over a key   → key name appears in slot 1
Player opens inventory    → sees 9 slots, 2 filled, 7 empty
```

Visual layout (bottom-right of screen):
```
            ┌──────────┬──────────┬──────────┐
            │ testItem │ testKey  │          │
            ├──────────┼──────────┼──────────┤
            │          │          │          │
            ├──────────┼──────────┼──────────┤
            │          │          │          │
            └──────────┴──────────┴──────────┘
```

### Why This Exists
Without this system, you'd have to:
1. Create a visual grid from scratch
2. Manage which slot holds which item
3. Update the display every time something changes

**With this system:** You call one function and the slot updates automatically.

---

## SECTION 2: Complete Guide (0 to 100%)

### Part A: Understanding the Files

Two files make the inventory work:

1. **`ui/inventory/inventoryUI.gd`**
   - The script that controls the inventory panel
   - Has two functions: `setItemName()` and `getItemName()`
   - You call these from other scripts

2. **`ui/inventory/inventoryUI.tscn`**
   - The visual scene (the actual grid you see on screen)
   - Already placed inside `levels/test/world.tscn`
   - You don't need to create this — it already exists

---

### Part B: How to Put an Item in a Slot

This is the only thing you need to know to use the inventory.

#### From any script, anywhere in the game:

```gdscript
# Get the inventory
var inventory = get_tree().root.get_node("World/InventoryUI")

# Put "testItem" in slot 0 (first slot, top-left)
inventory.setItemName(0, "testItem")

# Put "testKey" in slot 1 (second slot, top-center)
inventory.setItemName(1, "testKey")

# Remove item from slot 0 (make it empty)
inventory.setItemName(0, "")
```

**Slot numbers (0 to 8):**
```
┌───┬───┬───┐
│ 0 │ 1 │ 2 │  ← Top row
├───┼───┼───┤
│ 3 │ 4 │ 5 │  ← Middle row
├───┼───┼───┤
│ 6 │ 7 │ 8 │  ← Bottom row
└───┴───┴───┘
```

---

### Part C: Create an Item That Gets Picked Up

This example creates a world item. When the player walks over it, it appears in the inventory.

#### Step 1: Create the Item Scene

1. In the file browser, go to `entities/loot/`
2. Right-click → "New Scene"
3. Choose root node type: **Area3D**
4. Name the root node: `TestItem`
5. Save as: `entities/loot/testItem/testItem.tscn`

#### Step 2: Add a Visible Shape

1. Right-click `TestItem` → "Create Child Node"
2. Add: `CollisionShape3D`
3. Select `CollisionShape3D` in the scene tree
4. In Inspector → Shape → "New SphereShape3D"

1. Right-click `TestItem` → "Create Child Node"
2. Add: `MeshInstance3D`
3. In Inspector → Mesh → "New SphereMesh"

You now see a small sphere in the viewport. That is your item.

#### Step 3: Create the Item Script

1. Right-click `TestItem` (root) → "Attach Script"
2. Save as: `entities/loot/testItem/testItem.gd`
3. Paste this code:

```gdscript
extends Area3D

@export var item_name: String = "testItem"

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body.name == "CharacterBody3D":
		var inventory = get_tree().root.get_node_or_null("World/InventoryUI")
		if inventory:
			inventory.setItemName(_find_empty_slot(inventory), item_name)
		queue_free()

func _find_empty_slot(inventory) -> int:
	for i in range(9):
		if inventory.getItemName(i) == "":
			return i
	return 0
```

**What this code does:**
- When the player's `CharacterBody3D` enters the item's area, it runs `_on_body_entered`
- It finds the first empty slot in the inventory
- It puts `item_name` into that slot
- It removes itself from the world (`queue_free()`)

#### Step 4: Set the Item Name

1. Select `TestItem` (root) in the scene tree
2. In Inspector, find **"Item Name"** under the script section
3. Change it to whatever this item is called: `"testPotion"`, `"testKey"`, etc.

#### Step 5: Save

Press **Ctrl+S** to save `testItem.tscn`.

---

### Part D: Add the Item to the Level

1. Open `levels/test/world.tscn`
2. In the file browser, navigate to `entities/loot/testItem/`
3. Drag `testItem.tscn` into the scene tree under the "World" node
4. Select the `TestItem` in the scene tree
5. In Inspector → Transform → Position, set a position near the player spawn, example: X: 3, Y: 2, Z: 0

---

### Part E: Test It

1. Press **Play**
2. Walk toward the sphere
3. Walk into it
4. Check the inventory grid at the bottom-right — the item name should appear

**Nothing happened? Check:**
- Is `TestItem` an `Area3D` (not `StaticBody3D`)? Area3D detects overlaps; StaticBody3D does not
- Does `testItem.gd` have `body_entered.connect(_on_body_entered)` in `_ready()`?
- Is `InventoryUI` in the scene? (Check world.tscn scene tree)
- Is the player walking **through** the item, not just near it?

---

### Part F: Read What's in a Slot (Optional)

If you need to check what's in a slot before doing something:

```gdscript
var inventory = get_tree().root.get_node("World/InventoryUI")
var slot_0_item = inventory.getItemName(0)

if slot_0_item == "testKey":
	print("Player has the key!")
```

---

### Part G: Clear All Items (Optional)

To remove everything from the inventory:

```gdscript
var inventory = get_tree().root.get_node("World/InventoryUI")
for i in range(9):
	inventory.setItemName(i, "")
```

---

## SECTION 3: Quick Reference

### The Two Functions

```gdscript
# Put item in a slot
inventoryUI.setItemName(slot: int, name: String) -> void

# Read what's in a slot
inventoryUI.getItemName(slot: int) -> String
```

### Slot Numbers

```
┌───┬───┬───┐
│ 0 │ 1 │ 2 │
├───┼───┼───┤
│ 3 │ 4 │ 5 │
├───┼───┼───┤
│ 6 │ 7 │ 8 │
└───┴───┴───┘
```

### Get the Inventory from Anywhere

```gdscript
var inventory = get_tree().root.get_node("World/InventoryUI")
```

### Item Pickup Script Template

```gdscript
extends Area3D

@export var item_name: String = "testItem"

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body.name == "CharacterBody3D":
		var inv = get_tree().root.get_node_or_null("World/InventoryUI")
		if inv:
			for i in range(9):
				if inv.getItemName(i) == "":
					inv.setItemName(i, item_name)
					break
		queue_free()
```

---

## See Also
- [07-ui.md](07-ui.md) — How UI works in general
- [09-levels.md](09-levels.md) — Placing items in levels
