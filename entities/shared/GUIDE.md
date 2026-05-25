# Shared Entity Systems Guide

## Overview
Reusable scripts and systems that can be attached to any entity. Currently includes the Interactable system for dialogue interactions.

---

## Files
- `interactable.gd` — Script to add dialogue interactions to any entity

---

## Interactable System

### How to Use
Attach `interactable.gd` to any entity (NPC, object, etc.):

```gdscript
# In your entity's _ready()
extends Node3D

func _ready() -> void:
	var interactable = Interactable.new()
	interactable.dialogue_resource = load("res://assets/dialogue/my_dialogue.gd").new()
	add_child(interactable)
```

Or in the scene editor:
1. Select entity root node
2. Add script: `res://entities/shared/interactable.gd`
3. Set dialogue_resource in Inspector

### How It Works
- Creates an Area3D child automatically (interaction radius)
- Stores reference to dialogue resource
- DialogueManager detects this entity when player presses E

See `core/dialogue/GUIDE.md` for dialogue system details.

---

## How to Create Shared Systems

### Step 1: Design the System
Think about what multiple entities need:
- Inventory system (for NPCs or containers)
- Health system (for enemies, player, objects)
- Quest system (for NPCs, objects)

### Step 2: Create Base Script
Create in `res://entities/shared/`:

```gdscript
# res://entities/shared/healthSystem.gd
extends Node
class_name HealthSystem

var max_health: int = 100
var current_health: int = 100

signal health_changed(new_health: int)
signal died

func take_damage(amount: int) -> void:
	current_health -= amount
	health_changed.emit(current_health)
	
	if current_health <= 0:
		died.emit()
		get_parent().queue_free()

func heal(amount: int) -> void:
	current_health = min(current_health + amount, max_health)
	health_changed.emit(current_health)

func get_health_percentage() -> float:
	return float(current_health) / float(max_health)
```

### Step 3: Attach to Entities
```gdscript
# In any entity
extends Node3D

func _ready() -> void:
	var health = HealthSystem.new()
	health.max_health = 50
	health.current_health = 50
	health.died.connect(_on_died)
	add_child(health)

func _on_died() -> void:
	print("Entity died!")
	queue_free()
```

---

## Shared System Examples

### Health System
```gdscript
# res://entities/shared/healthSystem.gd
extends Node
class_name HealthSystem

@export var max_health: int = 100
var current_health: int

signal health_changed
signal died

func _ready() -> void:
	current_health = max_health

func take_damage(amount: int) -> void:
	current_health -= amount
	health_changed.emit()
	if current_health <= 0:
		died.emit()
```

### Loot System
```gdscript
# res://entities/shared/lootSystem.gd
extends Node
class_name LootSystem

@export var loot_table: Array[String] = ["Gold", "Health Potion"]
@export var drop_chance: float = 0.8

func roll_loot() -> Array[String]:
	var drops: Array[String] = []
	
	for item in loot_table:
		if randf() < drop_chance:
			drops.append(item)
	
	return drops

func drop_at_location(location: Vector3) -> void:
	var drops = roll_loot()
	for item in drops:
		# Spawn item at location
		var item_scene = load("res://entities/loot/itemPickup.tscn").instantiate()
		item_scene.item_name = item
		item_scene.global_position = location
		get_tree().root.add_child(item_scene)
```

### Movement System
```gdscript
# res://entities/shared/movementSystem.gd
extends Node
class_name MovementSystem

@export var speed: float = 5.0
@export var target: Node3D

func _process(delta: float) -> void:
	if not target:
		return
	
	var direction = (target.global_position - get_parent().global_position).normalized()
	get_parent().global_position += direction * speed * delta
```

---

## Best Practices

### 1. Keep Systems Modular
Each system should handle one responsibility:
- HealthSystem: Health management only
- LootSystem: Loot generation only
- MovementSystem: Movement only

### 2. Use Signals for Communication
```gdscript
class_name HealthSystem extends Node

signal health_changed(new_health: int)
signal died

# Other scripts connect to these signals:
# entity.get_node("HealthSystem").died.connect(_on_enemy_died)
```

### 3. Make Systems Reusable
```gdscript
# Good: Works on any entity
class_name DamageSystem extends Node

@export var damage: int = 10

func hit(target: Node) -> void:
	if target.has_node("HealthSystem"):
		target.get_node("HealthSystem").take_damage(damage)
```

### 4. Cache References
```gdscript
# In _ready()
func _ready() -> void:
	_parent_node = get_parent()  # Cache reference
	_health_system = get_parent().get_node("HealthSystem")
```

---

## Node Structure with Shared Systems

```
MyEnemy (Node3D)
├── HealthSystem (script)
├── LootSystem (script)
├── MovementSystem (script)
├── StaticBody3D
│   ├── CollisionShape3D
│   └── MeshInstance3D
└── InteractionArea (Area3D)
    └── CollisionShape3D
```

---

## Complete Example: Full Enemy

```gdscript
# res://entities/enemies/goblin.gd
extends Node3D

var _health_system: HealthSystem
var _loot_system: LootSystem
var _movement_system: MovementSystem

func _ready() -> void:
	_setup_health()
	_setup_loot()
	_setup_movement()
	_setup_appearance()

func _setup_health() -> void:
	_health_system = HealthSystem.new()
	_health_system.max_health = 30
	_health_system.current_health = 30
	_health_system.died.connect(_on_died)
	add_child(_health_system)

func _setup_loot() -> void:
	_loot_system = LootSystem.new()
	_loot_system.loot_table = ["Gold Coin", "Health Potion", "Iron Dagger"]
	add_child(_loot_system)

func _setup_movement() -> void:
	_movement_system = MovementSystem.new()
	_movement_system.speed = 3.0
	_movement_system.target = get_tree().root.get_node("World/Player/CharacterBody3D")
	add_child(_movement_system)

func _setup_appearance() -> void:
	var mesh = MeshInstance3D.new()
	mesh.mesh = BoxMesh.new()
	add_child(mesh)

func _on_died() -> void:
	print("Goblin defeated!")
	_loot_system.drop_at_location(global_position)
	queue_free()
```

And the scene:
```
Goblin (Node3D)
├── HealthSystem (HealthSystem.gd)
├── LootSystem (LootSystem.gd)
├── MovementSystem (MovementSystem.gd)
└── MeshInstance3D (visual)
```

---

## Testing Shared Systems

Create a test scene:

```gdscript
# res://tests/test_healthSystem.gd
extends Node3D

func _ready() -> void:
	var entity = Node3D.new()
	
	var health = HealthSystem.new()
	health.max_health = 100
	health.current_health = 100
	health.died.connect(_on_died)
	entity.add_child(health)
	
	# Test damage
	health.take_damage(30)
	assert(health.current_health == 70, "Damage not applied correctly")
	
	# Test death
	health.take_damage(70)
	assert(health.current_health <= 0, "Death condition not triggered")
	
	print("All tests passed!")

func _on_died() -> void:
	print("Death signal received")
```

---

## Troubleshooting

**System not being called:**
- Check system is added as child: `add_child(system)`
- Check _ready() and _process() are being called
- Enable script in inspector (checkbox)

**Signals not received:**
- Verify signal exists in system class
- Check connection is made: `system.signal_name.connect(callback)`
- Ensure callback function exists

**Multiple systems conflicting:**
- Each system should have unique responsibility
- Use signals to communicate between systems
- Avoid direct script references if possible
