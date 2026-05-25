# Entity Systems — Complete Guide

## SECTION 1: What Is This & Why Do You Need It?

### What It Does
**Entity systems** are reusable components you attach to any game object. Instead of writing all the behavior for a goblin in one giant script, you write a small focused `HealthSystem`, a small focused `MovementSystem`, and snap them together like building blocks.

### Real Example

```
testGoblin scene:
├── HealthSystem  → handles damage, death, HP
├── MovementSystem → moves toward the player
└── LootSystem    → drops items when it dies

testChest scene:
├── HealthSystem  → can be destroyed
└── LootSystem    → drops items when opened
```

Both objects share the same `HealthSystem` and `LootSystem` scripts — written once, used everywhere.

### Why This Exists
If you put health logic, movement logic, and loot logic all in one script, you have to copy-paste or rewrite it for every new entity. With separate systems, you write it once and attach it to anything.

---

## SECTION 2: Complete Guide (0 to 100%)

### Part A: The Interactable System (Already Built)

The one entity system that exists right now is `Interactable`, which makes any entity talkable.

See [01-dialogue.md](01-dialogue.md) for the full guide.

Short version: attach `entities/shared/interactable.gd` to any entity's root node and set the `Dialogue Path` in the Inspector.

---

### Part B: Create a Health System

This system tracks HP, handles damage, and signals when the entity dies.

#### Step 1: Create the Script

1. Go to `entities/shared/`
2. Right-click → "Create New" → "Script"
3. Name it: `healthSystem.gd`
4. Paste:

```gdscript
extends Node
class_name HealthSystem

@export var max_health: int = 100

var current_health: int

signal health_changed(current: int, maximum: int)
signal died

func _ready() -> void:
	current_health = max_health

func take_damage(amount: int) -> void:
	current_health = max(0, current_health - amount)
	health_changed.emit(current_health, max_health)
	
	if current_health <= 0:
		died.emit()

func heal(amount: int) -> void:
	current_health = min(max_health, current_health + amount)
	health_changed.emit(current_health, max_health)

func get_percentage() -> float:
	return float(current_health) / float(max_health)

func is_alive() -> bool:
	return current_health > 0
```

#### Step 2: Attach to an Entity Scene

You can attach this to any entity in two ways:

**Way 1: In the scene editor**

1. Open your entity scene (e.g., `entities/enemies/testEnemy/testEnemy.tscn`)
2. In the scene tree, right-click the root node → "Create Child Node"
3. Type "Node" and create it
4. Name it: `HealthSystem`
5. In Inspector → Script → click folder icon → select `entities/shared/healthSystem.gd`
6. Set `Max Health` in Inspector (e.g., 50)

**Way 2: From a script**

```gdscript
# In testEnemy.gd
var _health: HealthSystem

func _ready() -> void:
	_health = HealthSystem.new()
	_health.max_health = 50
	_health.died.connect(_on_died)
	add_child(_health)

func take_damage(amount: int) -> void:
	_health.take_damage(amount)

func _on_died() -> void:
	print("testEnemy died!")
	queue_free()
```

---

### Part C: Create a Movement System

This system moves an entity toward a target (usually the player).

#### Step 1: Create the Script

Create `entities/shared/movementSystem.gd`:

```gdscript
extends Node
class_name MovementSystem

@export var speed: float = 3.0
@export var stop_distance: float = 1.5

var target: Node3D

func _process(delta: float) -> void:
	if not target or not get_parent():
		return
	
	var parent = get_parent() as Node3D
	if not parent:
		return
	
	var distance = parent.global_position.distance_to(target.global_position)
	if distance <= stop_distance:
		return
	
	var direction = (target.global_position - parent.global_position).normalized()
	parent.global_position += direction * speed * delta
```

#### Step 2: Use It

```gdscript
# In testEnemy.gd
var _movement: MovementSystem

func _ready() -> void:
	_movement = MovementSystem.new()
	_movement.speed = 3.0
	_movement.target = get_tree().root.get_node_or_null("World/Player/CharacterBody3D")
	add_child(_movement)
```

---

### Part D: Create a Loot System

This system drops items at a location when called.

#### Step 1: Create the Script

Create `entities/shared/lootSystem.gd`:

```gdscript
extends Node
class_name LootSystem

@export var loot_items: Array[String] = []
@export var drop_chance: float = 0.75

func drop_loot_at(location: Vector3) -> void:
	var inventory = get_tree().root.get_node_or_null("World/InventoryUI")
	if not inventory:
		return
	
	for item in loot_items:
		if randf() <= drop_chance:
			for i in range(9):
				if inventory.getItemName(i) == "":
					inventory.setItemName(i, item)
					break
```

#### Step 2: Use It

```gdscript
# In testEnemy.gd
var _loot: LootSystem

func _ready() -> void:
	_loot = LootSystem.new()
	_loot.loot_items = ["testGold", "testPotion"]
	_loot.drop_chance = 0.8
	add_child(_loot)

func _on_died() -> void:
	_loot.drop_loot_at(global_position)
	queue_free()
```

---

### Part E: Complete Example — testEnemy with All Three Systems

#### Scene Structure

```
testEnemy (Node3D)
├── MeshInstance3D  ← visible box or model
├── StaticBody3D
│   └── CollisionShape3D
├── HealthSystem (Node + healthSystem.gd)
├── MovementSystem (Node + movementSystem.gd)
└── LootSystem (Node + lootSystem.gd)
```

#### Script: testEnemy.gd

```gdscript
extends Node3D

var _health: HealthSystem
var _movement: MovementSystem
var _loot: LootSystem

func _ready() -> void:
	# Health
	_health = HealthSystem.new()
	_health.max_health = 30
	_health.died.connect(_on_died)
	add_child(_health)
	
	# Movement toward player
	_movement = MovementSystem.new()
	_movement.speed = 2.5
	_movement.target = get_tree().root.get_node_or_null("World/Player/CharacterBody3D")
	add_child(_movement)
	
	# Loot drops
	_loot = LootSystem.new()
	_loot.loot_items = ["testGold", "testPotion"]
	add_child(_loot)

func take_damage(amount: int) -> void:
	_health.take_damage(amount)

func _on_died() -> void:
	_loot.drop_loot_at(global_position)
	queue_free()
```

---

### Part F: How to Add a System to Any Existing Entity

Suppose you have a chest scene and want it to have health:

1. Open the chest scene
2. In the scene tree, right-click the root → "Create Child Node" → "Node"
3. Name it `HealthSystem`
4. In Inspector → Script → select `entities/shared/healthSystem.gd`
5. In the chest's own script:

```gdscript
@onready var _health: HealthSystem = $HealthSystem

func _ready() -> void:
	_health.max_health = 20
	_health.died.connect(_on_destroyed)

func _on_destroyed() -> void:
	print("Chest destroyed!")
	queue_free()
```

---

## SECTION 3: Quick Reference

### Available Shared Systems

| Script | Class Name | What It Does |
|--------|------------|--------------|
| `entities/shared/interactable.gd` | `Interactable` | Dialogue interaction on E key |
| `entities/shared/healthSystem.gd` | `HealthSystem` | HP, damage, death signal |
| `entities/shared/movementSystem.gd` | `MovementSystem` | Moves toward a target |
| `entities/shared/lootSystem.gd` | `LootSystem` | Drops items on death |

### HealthSystem API

```gdscript
_health.take_damage(10)   # Deal damage
_health.heal(5)           # Restore HP
_health.get_percentage()  # → float 0.0–1.0
_health.is_alive()        # → bool
_health.died              # Signal — connect to death handler
_health.health_changed    # Signal — connect to HP bar update
```

### Node Structure Pattern

```
EntityRoot (Node3D)
├── MeshInstance3D       ← visual
├── CollisionShape3D     ← physical shape
├── HealthSystem (Node)  ← behavior
├── MovementSystem (Node)
└── LootSystem (Node)
```

---

## Troubleshooting

**System not running:**
- Make sure `add_child()` is called in `_ready()`
- Check `process_mode` is not set to `PROCESS_MODE_DISABLED`

**Signal not received:**
- Connect the signal before the event happens (in `_ready()`)
- Check the function name matches exactly (`_on_died` vs `on_died`)

**Movement not working:**
- Make sure `target` is set to a valid `Node3D`
- Check that the parent is a `Node3D` (not a plain `Node`)

**Systems conflicting:**
- Each system should do one thing only
- Use signals to communicate between systems, not direct references

---

## See Also
- [01-dialogue.md](01-dialogue.md) — Interactable system
- [04-player.md](04-player.md) — Player entity
- [09-levels.md](09-levels.md) — Adding entities to levels
