# Creating Levels — Complete Guide

## SECTION 1: What Is This & Why Do You Need It?

### What It Does
A **level** is a self-contained game world — a `.tscn` scene file that holds the ground, lighting, player spawn, enemies, NPCs, items, and UI. When the game loads a level, everything in that scene appears at once.

### Real Example

```
levels/
├── test/world.tscn        ← The level you play right now
├── testLevel1/world.tscn  ← Your first new level
└── testLevel2/world.tscn  ← Another level
```

Each `world.tscn` is independent. Walking from level 1 to level 2 means loading a different scene file.

### Why This Exists
Without organized levels:
1. Everything would be in one giant scene that gets harder to manage
2. You couldn't load different worlds as the game progresses
3. You couldn't reuse NPCs, enemies, or items across different levels

**With this system:** Each level is a clean scene. You drag in pre-built entities (NPCs, enemies, items) and position them. The level is ready.

---

## SECTION 2: Complete Guide (0 to 100%)

### Part A: Understanding the Test Level

Before creating a new level, understand what's already in `levels/test/world.tscn`. Open it in Godot and look at the scene tree:

```
World (Node3D)                   ← Root of the level
├── Player (instance)            ← The player scene, instanced here
├── Ground (StaticBody3D)        ← The floor the player stands on
│   ├── CollisionShape3D         ← Makes the ground solid
│   └── MeshInstance3D           ← Makes the ground visible
├── DirectionalLight3D           ← Sunlight
├── WorldEnvironment             ← Sky and ambient light
└── UI (CanvasLayer)             ← All on-screen UI
    ├── HUD                      ← Debug display
    ├── SkillUI                  ← Skill bar
    └── InventoryUI              ← Inventory grid
```

A new level needs the same structure.

---

### Part B: Create a New Level from Scratch

#### Step 1: Create the Level Folder and Scene

1. In the file browser, right-click `levels/`
2. Create folder: `testLevel1`
3. Right-click inside `levels/testLevel1/` → "New Scene"
4. Root node type: **Node3D**
5. Name the root node: `World`
6. Save as: `levels/testLevel1/world.tscn`

You now have an empty level open in Godot.

#### Step 2: Add Lighting

Without lighting, everything appears black.

1. Right-click `World` → "Create Child Node"
2. Type "DirectionalLight3D" → Create

Select `DirectionalLight3D` in the scene tree:
- In Inspector → Transform → Rotation → set X to `-45`, Y to `0`, Z to `0`
  (This points the light diagonally downward like a sun)
- Inspector → Light Energy → set to `1.5`
- Inspector → Shadow → Enable shadows: check "Shadow Enabled"

#### Step 3: Add a Sky

1. Right-click `World` → "Create Child Node"
2. Type "WorldEnvironment" → Create

Select `WorldEnvironment`:
- In Inspector → Environment → click the empty slot → "New Environment"
- In the Environment resource that appears:
  - Background Mode → "Sky"
  - Sky → click empty slot → "New Sky"
  - In the Sky resource → Sky Material → "New ProceduralSkyMaterial"
- Set Ambient Light Energy to `0.5`

You should now see a blue sky in the viewport.

#### Step 4: Add the Ground

1. Right-click `World` → "Create Child Node"
2. Type "StaticBody3D" → Create
3. Name it: `Ground`

Right-click `Ground` → "Create Child Node":
- Add: `CollisionShape3D`
- Select it → Inspector → Shape → "New WorldBoundaryShape3D"
  (This is an infinite flat plane that acts as the floor)

Right-click `Ground` → "Create Child Node":
- Add: `MeshInstance3D`
- Select it → Inspector → Mesh → "New PlaneMesh"
- Inspector → Mesh → Size → set to `Vector2(200, 200)` (big visible floor)

The ground is now solid and visible.

#### Step 5: Add the Player

1. In the file browser at the bottom, navigate to `entities/player/`
2. Find `player.tscn`
3. Drag it from the file browser into the scene tree under `World`

The player appears at the origin. Move it up slightly:
- Select `Player` in the scene tree
- Inspector → Transform → Position → set Y to `2` (so it spawns above the ground)

#### Step 6: Add the UI

The UI (inventory, skills, HUD) needs to be in a `CanvasLayer`.

1. Right-click `World` → "Create Child Node"
2. Type "CanvasLayer" → Create
3. Name it: `UI`
4. In Inspector → Layer → set to `10`

Now drag these scenes from the file browser into the `UI` node:
- `ui/hud/hud.tscn`
- `ui/skill/skillUI.tscn`
- `ui/inventory/inventoryUI.tscn`

Note: Do **not** add `dialogueUI.tscn` — the DialogueManager autoload spawns it automatically when needed.

#### Step 7: Save

Press **Ctrl+S** to save `world.tscn`.

---

### Part C: Test the New Level

#### Option A: Set as Main Scene

1. Go to **Project** (top menu) → **Project Settings**
2. Application → Run → Main Scene → change to `res://levels/testLevel1/world.tscn`
3. Press Play

The game will start in your new level.

#### Option B: Load it from code

If you have a trigger (button, trigger zone, etc.) that should load this level:

```gdscript
func _on_level_transition() -> void:
	get_tree().change_scene_to_file("res://levels/testLevel1/world.tscn")
```

---

### Part D: Add NPCs to the Level

NPCs live in their own scene files. You drag them into the level.

1. First create the NPC following [01-dialogue.md](01-dialogue.md)
2. Open your level scene (`levels/testLevel1/world.tscn`)
3. In the file browser, navigate to `entities/npcs/testNpc/`
4. Drag `testNpc.tscn` into the scene tree under `World`
5. Select the `TestNpc` node
6. In Inspector → Position → set a position near where the player spawns (e.g., X: 5, Y: 2, Z: 0)

---

### Part E: Add Enemies to the Level

Same process as NPCs — enemies are separate scenes that get instanced into levels.

Once you have an enemy scene (e.g., `entities/enemies/testEnemy/testEnemy.tscn`):

```
1. Open the level scene
2. Drag testEnemy.tscn into the scene tree under World
3. Position it away from the player spawn
4. Repeat for multiple enemies
```

Or spawn them from a script attached to the World node:

```gdscript
# levels/testLevel1/world.gd
extends Node3D

func _ready() -> void:
	_spawn_enemies()

func _spawn_enemies() -> void:
	var spawn_positions = [
		Vector3(10, 2, 5),
		Vector3(-10, 2, -5),
		Vector3(0, 2, 15),
	]
	
	for pos in spawn_positions:
		var enemy = load("res://entities/enemies/testEnemy/testEnemy.tscn").instantiate()
		enemy.global_position = pos
		add_child(enemy)
```

---

### Part F: Add Items to the Level

Items work the same way — separate scenes dragged into the level.

```
1. Open the level scene
2. Drag testItem.tscn into the scene tree under World
3. Position it somewhere in the level
4. Set the item_name property in Inspector
```

Or from a script:

```gdscript
func _setup_items() -> void:
	var positions = [Vector3(3, 1, 3), Vector3(-5, 1, 8)]
	var names = ["testGold", "testPotion"]
	
	for i in range(positions.size()):
		var item = load("res://entities/loot/testItem/testItem.tscn").instantiate()
		item.global_position = positions[i]
		item.item_name = names[i]
		add_child(item)
```

---

### Part G: Move Between Levels

To go from one level to another, use a trigger zone or a script call.

#### Trigger Zone Example

Create a small Area3D at the exit point of the level. When the player walks into it, the next level loads:

```gdscript
# entities/shared/levelExit.gd
extends Area3D

@export_file("*.tscn") var next_level: String = ""

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body.name == "CharacterBody3D" and next_level != "":
		get_tree().change_scene_to_file(next_level)
```

Attach this to an Area3D + CollisionShape3D placed at the level exit. Set `Next Level` in Inspector to `res://levels/testLevel2/world.tscn`.

---

## SECTION 3: Quick Reference

### Minimum Level Structure

```
World (Node3D)
├── DirectionalLight3D (rotation X=-45, energy=1.5)
├── WorldEnvironment (ProceduralSkyMaterial)
├── Ground (StaticBody3D)
│   ├── CollisionShape3D (WorldBoundaryShape3D)
│   └── MeshInstance3D (PlaneMesh, 200x200)
├── Player (instance of entities/player/player.tscn, Y=2)
└── UI (CanvasLayer, layer=10)
    ├── hud.tscn
    ├── skillUI.tscn
    └── inventoryUI.tscn
    # dialogueUI is NOT added here — DialogueManager spawns it automatically
```

### Load a Level

```gdscript
get_tree().change_scene_to_file("res://levels/testLevel1/world.tscn")
```

### Level Progression

```gdscript
# core/autoloads/levelManager.gd
extends Node

var levels: Array[String] = [
	"res://levels/test/world.tscn",
	"res://levels/testLevel1/world.tscn",
	"res://levels/testLevel2/world.tscn",
]

var current: int = 0

func next_level() -> void:
	current += 1
	if current < levels.size():
		get_tree().change_scene_to_file(levels[current])
```

### File Location Pattern

```
levels/
└── testLevel1/
    ├── world.tscn       ← the scene
    └── world.gd         ← optional script for spawning logic
```

---

## Troubleshooting

**Player falls through the ground:**
- Make sure `Ground` has a `CollisionShape3D` with a valid shape
- `WorldBoundaryShape3D` works as an infinite flat floor
- `BoxShape3D` works for a finite platform (must be large enough)

**Screen is completely black:**
- Add `DirectionalLight3D` with energy > 0
- Add `WorldEnvironment` with a sky or ambient light

**UI doesn't show:**
- Make sure UI is inside a `CanvasLayer` node
- Set the CanvasLayer's `layer` to 10 or higher
- Check that each UI scene has `visible = true`

**Dialogue doesn't work in new level:**
- `DialogueManager` is an autoload — it spawns the UI automatically — no setup needed in the level
- Check the NPC has `interactable.gd` attached and a dialogue file set in Inspector
- Check the player has `InteractionArea` under `CharacterBody3D`

**Enemy doesn't spawn:**
- Add a `print()` in `_ready()` to verify the script runs
- Check the scene path in `load()` is correct (typos will silently fail)

---

## See Also
- [01-dialogue.md](01-dialogue.md) — Adding NPCs to levels
- [04-player.md](04-player.md) — Player setup
- [08-entities.md](08-entities.md) — Entity systems for enemies/items
