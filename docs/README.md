# Godot 4.6 Game Framework

A 3D first-person framework.

---

## Architecture

```
attack-on-goblins/
├── assets/
│   ├── dialogue/        NPC conversation data (.gd)
│   ├── sprites/
│   ├── audio/
│   └── fonts/
├── core/
│   ├── autoloads/       Global singletons (registered in project.godot)
│   ├── dialogue/        Dialogue data structure + per-player session
│   ├── main_menu/
│   └── physics/
├── entities/
│   ├── player/          Controller, scene, collision
│   ├── npcs/            NPC scenes (each has Interactable script)
│   ├── shared/          Reusable scripts (interactable.gd)
│   └── placeholders/    Cube, platform for testing
├── levels/
│   └── test/            world.tscn — starting level
├── ui/
│   ├── dialogue/        Dialogue box
│   ├── hud/             HUD, debug overlay
│   ├── interaction_prompt/
│   ├── inventory/
│   ├── pause_menu/
│   └── skill/
├── docs/                You are here
├── CLAUDE.md            AI agent rules
└── project.godot        Input map, autoload order
```

---

## Autoloads

Registered in `project.godot` in load order:

| Singleton | File | Role |
|-----------|------|------|
| PhysicsManager | `core/physics/physicsManager.gd` | Gravity constants |
| PauseManager | `core/autoloads/pauseManager.gd` | ESC pause, scene quit |
| DialogueManager | `core/autoloads/dialogueManager.gd` | Signal bus for dialogue events |
| DebugManager | `core/autoloads/debugManager.gd` | F3 toggle, `DebugManager.log()` |

---

## Systems

| System | Guide |
|--------|-------|
| Dialogue | [01-dialogue.md](01-dialogue.md) |
| Inventory | [02-inventory.md](02-inventory.md) |
| Skills | [03-skills.md](03-skills.md) |
| Player | [04-player.md](04-player.md) |
| Physics | [05-physics.md](05-physics.md) |
| Autoloads | [06-autoloads.md](06-autoloads.md) |
| UI | [07-ui.md](07-ui.md) |
| Entities | [08-entities.md](08-entities.md) |
| Levels | [09-levels.md](09-levels.md) |
| Classes | [10-classes.md](10-classes.md) |

---

## Input Map (P0)

| Key | Action |
|-----|--------|
| F3 | Toggle debug |
| WASD | Move |
| Mouse | Look |
| E | Interact |
| Space | Jump |
| ESC | Pause |
| J | Quest log | not mapped
| alt + 1-9| Inventory slots| not mapped
