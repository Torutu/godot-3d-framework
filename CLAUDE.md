# Attack on Goblins — Godot Project Guide

## Project Overview
- **Engine**: Godot 4.6 (Forward Plus, Jolt Physics)
- **Type**: Linear dungeon crawler with loot, enemies, player(s), UI, and core systems
- **Perspective**: 3D first-person (player controlled via WASD + mouse)
- **Multiplayer**: Supports 2 players (p0 and p1 input mappings configured)

---

## AI Agent Constraints

**Only script existing nodes and scenes.** Before adding any new nodes, scenes, or resources, **ask the user first**. Do not assume what should be created.

**Focus**: Logic, math, and physics only. No creative writing, drawing, or artistic decisions. Let the user own those choices.

**Optimization is non-negotiable.** Every system must be written with performance in mind from the start — not as an afterthought. Expensive operations belong in `_ready()`, not `_process()`. If a solution works but wastes cycles, it is not acceptable. See the Optimization section below for specific rules.

---

## Directory Structure (Maintained)

```
attack-on-goblins/
├── assets/
│   ├── sprites/         (textures, sprite sheets)
│   ├── audio/
│   │   ├── sfx/         (one-shot effects)
│   │   └── music/       (looping tracks)
│   └── fonts/
├── core/                (game-wide systems and bootstrap)
│   ├── autoloads/       (singletons: EventBus, InputManager, AudioManager, etc.)
│   ├── main_menu/       (startup & scene navigation)
│   └── game_over/       (end-state scenes)
├── levels/              (level_01, level_02, … scenes)
├── entities/
│   ├── player/          (player scene, controller, stats)
│   ├── enemies/         (enemy types, AI, stats)
│   └── loot/            (items, drops, pickup logic)
└── ui/
    ├── hud/             (health bar, resources, counters)
    ├── inventory/       (item display, equipment)
    └── menus/           (pause, settings, overlays)
```

---

## Autoloads (Singletons)
Already registered in `project.godot`:
- **EventBus**: Central event dispatcher for loose coupling
- **InputManager**: Centralized input handling for both players
- **AudioManager**: Music and SFX playback
- **SaveManager**: Game persistence
- **QuestManager**: Quest tracking and progression
- **UIManager**: UI state and updates
- **SceneManager**: Level loading and transitions
- **GameManager**: Overall game state

These must exist before scripting any game logic that depends on them.

---

## Coding Conventions

### Naming
- **Variables/Functions**: `camelCase`
- **Classes/Resources**: `PascalCase`
- **Constants**: `UPPER_CASE`
- **Private**: Prefix with `_` (e.g., `_internalState`)

### Script Structure
1. Class variables at top
2. `_ready()` and `_process()`
3. Game logic functions
4. Helper/utility functions at bottom

### Comments
- Only explain **why**, not what (well-named code explains itself)
- Mark workarounds or non-obvious invariants only

### Optimization (mandatory — not optional)
- **Cache in `_ready()`**: node references, loaded resources, computed values that don't change
- **Nothing expensive in `_process()`**: no `get_node()`, no `load()`, no allocations per frame
- **Prefer direct node access**: `@onready var _x = $X` over repeated `get_node("X")`
- **Batch physics queries**: one raycast or overlap check per system per frame maximum
- **No per-frame string formatting** unless behind a debug flag
- **Use signals over polling**: don't check a condition every frame if a signal can fire once
- **Debug code must use `DebugManager.log()`** — never bare `print()` calls in committed code

### Physics Sync (mandatory — prevents jitter)
Physics interpolation is enabled project-wide (`physics/common/physics_interpolation=true`). Every node that moves with or is driven by a physics body **must** update at the physics rate, not the render rate. Violating this causes visual jitter and desync.

- **`move_and_slide()` belongs in `_physics_process()`** — never `_process()`
- **`apply_force` / `apply_impulse` belong in `_physics_process()`** — never `_process()`
- **AnimationPlayer and AnimationTree driving physics-attached nodes must use `ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS`** — set in `_ready()` via code, not in the Inspector or .tscn (Godot strips those values on save)
- **Any script that sets `position`, `rotation`, or `transform` on a node attached to a physics body must do so in `_physics_process()`**
- **Jump / one-shot inputs detected in `_input()`** must be buffered via a flag and consumed in `_physics_process()` to avoid missed frames
- **Mouse look**: pitch (camera X) can be applied immediately in `_input()` as it is local and visual only. Yaw (body Y rotation via `rotate_y`) must be accumulated into a float in `_input()` and applied in `_physics_process()`, then cleared — otherwise the body transform changes outside physics snapshots and causes jitter
- **Physics tick rate is 120Hz** (`common/physics_ticks_per_second=120`) — do not lower it; smaller steps = smoother contact resolution

### Modularity & Extractability
Every system must be independently extractable into a reusable library. This means:

- **One feature per file**: Loot system, leveling system, dialogue system each get their own `.gd` file with clear naming (e.g., `lootSystem.gd`, `levelUpSystem.gd`, `dialogueSystem.gd`)
- **Clear grouping**: Related files live in their own subfolder (`entities/loot/`, `core/quest_system/`, etc.)
- **No cross-system dependencies**: Systems communicate via EventBus or explicit interfaces, not direct references
- **Standalone logic**: A system's core logic should be usable without the rest of the game (testable in isolation)
- **Resource-based configs**: Use `.tres` (Resource) files for drop tables, dialogue trees, stat progressions — never hardcode these in scripts

---

## Key Files & Patterns

| File | Purpose |
|------|---------|
| `entities/player/playerFirstPerson.gd` | Player controller (input → movement, camera, actions) |
| `core/autoloads/*.gd` | Singletons (already configured in project.godot) |
| `levels/` | One `.tscn` per level; contains tilemap, spawns, events |

---

## Before Starting
- **Existing scenes**: Check if a `.tscn` or `.gd` file exists before writing
- **Node assumptions**: Ask before adding new nodes to an existing scene
- **Physics setup**: Verify collision layers/masks before writing movement code
- **Input bindings**: Input is pre-mapped in `project.godot`; use `InputManager` for centralized handling

---

## When to Ask the User
- Adding a new node type to an existing scene
- Creating a new singleton/autoload (coordinate with project.godot)
- Adding UI elements beyond those already defined
- Creating new resources (stats, drop tables, configs)

---

## What NOT to Handle
- Dialogue writing or narrative design
- 3D model creation or art asset decisions
- UI design or visual styling
- Audio editing or soundtrack curation

---

Generated: 2026-05-23 | Update directory tree on major structural changes.
