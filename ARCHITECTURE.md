# Attack on Goblins — Architecture & Guide

## Quick Start

Each major system has its own **GUIDE.md** in its folder:

| System | Guide | Purpose |
|--------|-------|---------|
| **Dialogue** | `core/dialogue/GUIDE.md` | Add NPC conversations & interactions |
| **Inventory** | `ui/inventory/GUIDE.md` | Manage items (3×3 grid) |
| **Skills** | `ui/skill/GUIDE.md` | Quick-access ability bar (5 slots) |
| **Player** | `entities/player/GUIDE.md` | First-person controller & movement |
| **Physics** | `core/physics/GUIDE.md` | Gravity & physics bodies |
| **Autoloads** | `core/autoloads/GUIDE.md` | Global singleton systems |
| **UI** | `ui/GUIDE.md` | General UI patterns & creation |
| **Entities** | `entities/shared/GUIDE.md` | Reusable entity components |
| **Levels** | `levels/GUIDE.md` | Create new game levels |

---

## Project Structure

```
attack-on-goblins/
│
├── assets/               (Art, audio, fonts)
│   ├── sprites/
│   ├── audio/
│   │   ├── sfx/
│   │   └── music/
│   ├── fonts/
│   └── dialogue/        (Dialogue resource files)
│
├── core/                (Game-wide systems)
│   ├── autoloads/       (Global singletons)
│   │   ├── physicsManager.gd
│   │   ├── pauseManager.gd
│   │   ├── dialogueManager.gd
│   │   └── GUIDE.md
│   ├── dialogue/        (Dialogue system)
│   │   ├── dialogueResource.gd
│   │   └── GUIDE.md
│   ├── main_menu/       (Startup menu)
│   ├── game_over/       (End state)
│   └── physics/         (Physics system)
│       ├── physicsManager.gd
│       └── GUIDE.md
│
├── entities/            (Game objects)
│   ├── player/          (First-person controller)
│   │   ├── playerController.gd
│   │   ├── player.tscn
│   │   └── GUIDE.md
│   ├── enemies/         (Enemy types & AI)
│   ├── loot/            (Items, drops)
│   ├── placeholders/    (Cube, platform for testing)
│   ├── shared/          (Reusable entity scripts)
│   │   ├── interactable.gd
│   │   └── GUIDE.md
│   └── [more entity types]
│
├── levels/              (Game levels)
│   ├── test/
│   │   └── world.tscn
│   ├── [other levels]
│   └── GUIDE.md
│
├── ui/                  (User interface)
│   ├── dialogue/        (NPC dialogue UI)
│   │   ├── dialogueUI.gd
│   │   ├── dialogueUI.tscn
│   │   └── [part of dialogue system]
│   ├── inventory/       (Item display)
│   │   ├── inventoryUI.gd
│   │   ├── inventoryUI.tscn
│   │   └── GUIDE.md
│   ├── skill/           (Ability bar)
│   │   ├── skillUI.gd
│   │   ├── skillUI.tscn
│   │   └── GUIDE.md
│   ├── hud/             (Debug display)
│   │   ├── debugHUD.gd
│   │   ├── hud.tscn
│   │   └── [expandable]
│   ├── pause_menu/      (Game pause)
│   ├── main_menu/       (Startup)
│   ├── GUIDE.md         (General UI patterns)
│   └── [more UI systems]
│
├── project.godot        (Project config, input bindings, autoloads)
├── CLAUDE.md            (Project rules & constraints)
└── ARCHITECTURE.md      (This file)
```

---
a
## How Systems Work Together

### Example: Player Picks Up Item

```
Player walks into item pickup area
↓
Player presses E (p0_interact action)
↓
DialogueManager detects interaction
↓
[If entity has dialogue]
  → DialogueUI appears
  → Player selects option
  → Dialogue progresses
[If entity has loot]
  → Item added to inventory
  → InventoryUI updated
  → Item removed from world
```

### Example: Combat Flow (when implemented)

```
Player sees enemy → Enemy takes damage
↓
HealthSystem.take_damage() called
↓
Health decreased → Signals emitted
↓
UI updated (health bar)
↓
Health ≤ 0 → LootSystem.drop()
↓
Items spawn in world
```

---

## Common Tasks

### Add Dialogue to an NPC
1. Read `core/dialogue/GUIDE.md`
2. Create dialogue resource: `res://assets/dialogue/npc_name.gd`
3. Attach Interactable script to NPC
4. Set dialogue_resource property

### Add Item to Inventory
1. Read `ui/inventory/GUIDE.md`
2. Call `inventory_ui.setItemName(slot_index, "Item Name")`

### Create New Enemy Type
1. Read `entities/shared/GUIDE.md`
2. Attach HealthSystem and MovementSystem
3. Optional: Add Interactable for dialogue
4. Instance in level

### Create New Level
1. Read `levels/GUIDE.md`
2. Create folder: `res://levels/my_level/`
3. Create scene: `world.tscn` with Player + environment
4. Instance UI (HUD, SkillUI, InventoryUI)

### Modify Player Movement
1. Read `entities/player/GUIDE.md`
2. Edit constants in `playerController.gd`:
   - `MOVE_SPEED`
   - `MOUSE_SENSITIVITY`
   - `JUMP_FORCE`
   - `GRAVITY`

---

## Key Concepts

### Autoloads (Singletons)
Global scripts that load at startup. Used for:
- Physics management
- Pause/menu handling
- Dialogue management
- Game state management

See `core/autoloads/GUIDE.md` for details.

### Scenes vs Scripts
- **Scenes** (.tscn): Visual layouts, node hierarchies (use for UI, levels)
- **Scripts** (.gd): Logic, behavior (use for systems, controllers)
- Most systems combine both

### Signals
Events that scripts emit and listen to:
```gdscript
signal item_equipped
signal enemy_defeated

# Emit: item_equipped.emit()
# Listen: item_equipped.connect(callback)
```

### CharacterBody3D
Built-in physics for player movement. Handles:
- Collision detection
- Movement with move_and_slide()
- Gravity integration

---

## Input Actions

Defined in `project.godot`:

### Player (p0) Actions
- `p0_move_forward` (W)
- `p0_move_back` (S)
- `p0_move_left` (A)
- `p0_move_right` (D)
- `p0_interact` (E) — Dialogue, pickups
- `p0_attack` (Mouse Click)
- `p0_roll` (Space)
- `p0_pause` (ESC)
- `p0_inventory` (I)
- `p0_quest_log` (J)

### Player 2 (p1) Actions
Same as p0, with different key bindings (for multiplayer support).

Add more actions by editing `project.godot` [input] section.

---

## Debugging

### Debug HUD
Shows player position and velocity (top-left).
Useful for verifying movement and physics.

### Console Output
Add to any script:
```gdscript
print("Message: ", variable)
print_debug("Debug info")
```

View in Godot's Output panel or terminal.

### Pause Menu Testing
Press ESC to pause and open menu.
Buttons: Resume, Save, Settings, Quit.

---

## Performance Considerations

1. **Cache References** — Don't do get_node() every frame
2. **Use @onready** — Loads references in _ready() once
3. **Batch Physics** — Register bodies in PhysicsManager
4. **Cull Distant Objects** — Disable rendering for far entities
5. **Use LOD** — Lower quality models at distance

See relevant GUIDE.md for optimization tips.

---

## Extensibility

### Add New System
1. Create script in appropriate folder
2. Follow naming: `mySystemName.gd` (class_name MySystemName)
3. Extend reusable base (Node, Node3D, etc.)
4. Use signals for communication
5. Write GUIDE.md documenting usage

### Add New Entity Type
1. Create folder: `entities/my_entity_type/`
2. Create scene and script
3. Compose using shared systems (HealthSystem, MovementSystem, etc.)
4. Write GUIDE.md with example

### Add New Level
1. Create folder: `levels/my_level/`
2. Copy structure from `levels/test/world.tscn`
3. Populate with enemies, NPCs, items
4. Update level progression in GameManager (if exists)

---

## Best Practices

1. **One responsibility per file** — Each script handles one thing
2. **Use signals for communication** — Avoid direct script references
3. **Cache expensive queries** — Store references in @onready
4. **Modular & extractable** — Code should work in isolation
5. **Clear naming** — `player_health`, not `h`
6. **Document with GUIDE.md** — Every system gets a guide
7. **Version control friendly** — Don't commit editor-generated UIDs

---

## Troubleshooting

### Game won't load
- Check `project.godot` syntax
- Verify autoload paths exist
- Check scene paths are correct

### Player can't move
- Check PlayerController has Camera3D child
- Verify input actions exist in project.godot
- Check process_mode is not disabled

### Dialogue not appearing
- Check DialogueManager autoload is registered
- Verify Player has InteractionArea child
- Check entity has Interactable script
- Ensure dialogue_resource is assigned

### UI broken/misaligned
- Check Control node anchors
- Verify mouse_filter settings
- Ensure CanvasLayer layer value is correct

**See individual GUIDE.md files for system-specific troubleshooting.**

---

## Next Steps

1. **Read the relevant GUIDE.md** for the system you want to work on
2. **Follow the examples** provided in each guide
3. **Extend incrementally** — Add one feature at a time
4. **Test frequently** — Use debug HUD and console
5. **Document new systems** — Create GUIDE.md for new code

---

## Additional Resources

- **CLAUDE.md** — Project rules, constraints, conventions
- **Individual GUIDE.md files** — Detailed system documentation
- **Godot 4.6 Docs** — Engine-specific features: https://docs.godotengine.org/

---

## Contact & Support

For specific system questions, refer to the corresponding GUIDE.md:
- Dialogue issues → `core/dialogue/GUIDE.md`
- UI issues → `ui/GUIDE.md`
- Player/movement → `entities/player/GUIDE.md`
- Level issues → `levels/GUIDE.md`

Good luck! 🎮
