# Attack on Goblins — Complete Documentation

This documentation assumes you are **completely new** to this codebase. Each guide starts from the absolute beginning and shows you **exactly what to do and why**.

---

## What This Game Is

A **3D first-person game** where you:
- **Move** using WASD keys
- **Look around** by moving your mouse
- **Talk to NPCs** by pressing E (they can have branching dialogue)
- **Collect items** in your inventory
- **Use abilities** from your skill bar

Everything is modular and reusable, designed so you can add new features without breaking existing ones.

---

## Quick Navigation

| System | What It Does | Guide |
|--------|-------------|-------|
| **Dialogue** | Makes NPCs speak with branching conversations | [01-dialogue.md](01-dialogue.md) |
| **Inventory** | Shows items you're carrying (3×3 grid UI) | [02-inventory.md](02-inventory.md) |
| **Skills** | Quick access to 5 abilities (bottom-center bar) | [03-skills.md](03-skills.md) |
| **Player** | How the character moves and looks around | [04-player.md](04-player.md) |
| **Physics** | Gravity, jumping, collision detection | [05-physics.md](05-physics.md) |
| **Autoloads** | Global systems that run everywhere (menus, pause, etc) | [06-autoloads.md](06-autoloads.md) |
| **UI** | How to create menus and panels | [07-ui.md](07-ui.md) |
| **Entities** | Reusable building blocks (health, movement, loot) | [08-entities.md](08-entities.md) |
| **Levels** | How to build new game worlds | [09-levels.md](09-levels.md) |

---

## Project Folders Explained

```
attack-on-goblins/
│
├── assets/                          ← Art, audio, fonts
│   ├── sprites/                     (Images, textures)
│   ├── audio/
│   │   ├── sfx/                     (Sound effects)
│   │   └── music/                   (Background music)
│   ├── fonts/                       (Text fonts)
│   └── dialogue/                    (NPC conversation data)
│
├── core/                            ← Game-wide systems
│   ├── autoloads/                   (Global things that run everywhere)
│   │   ├── physicsManager.gd        (Controls gravity)
│   │   ├── pauseManager.gd          (Pause menu, ESC key)
│   │   ├── dialogueManager.gd       (NPC conversation system)
│   │   └── GUIDE.md                 (How to create more)
│   ├── dialogue/                    (Dialogue system files)
│   │   ├── dialogueResource.gd      (Dialogue data structure)
│   │   └── GUIDE.md
│   ├── physics/                     (Physics system)
│   │   ├── physicsManager.gd
│   │   └── GUIDE.md
│   ├── main_menu/                   (Game startup menu)
│   └── game_over/                   (End game state)
│
├── entities/                        ← Game objects
│   ├── player/                      (The player character)
│   │   ├── playerController.gd      (Movement, camera)
│   │   ├── player.tscn              (Player scene)
│   │   └── GUIDE.md
│   ├── enemies/                     (Enemy types)
│   ├── loot/                        (Items, treasure)
│   ├── placeholders/                (Cube, platform for testing)
│   ├── shared/                      (Reusable scripts)
│   │   ├── interactable.gd          (Makes things talkable)
│   │   └── GUIDE.md
│   └── [other entity types]
│
├── levels/                          ← Game maps
│   ├── test/                        (Test level - already made)
│   │   └── world.tscn
│   ├── forest/                      (Your new levels)
│   │   └── world.tscn
│   └── GUIDE.md                     (How to make levels)
│
├── ui/                              ← All menus and HUD
│   ├── dialogue/                    (NPC dialogue box UI)
│   │   ├── dialogueUI.gd
│   │   ├── dialogueUI.tscn
│   ├── inventory/                   (3×3 item grid)
│   │   ├── inventoryUI.gd
│   │   ├── inventoryUI.tscn
│   │   └── GUIDE.md
│   ├── skill/                       (5-slot ability bar)
│   │   ├── skillUI.gd
│   │   ├── skillUI.tscn
│   │   └── GUIDE.md
│   ├── hud/                         (Debug display, health bars)
│   │   ├── debugHUD.gd
│   │   └── hud.tscn
│   ├── pause_menu/                  (ESC menu)
│   ├── main_menu/                   (Title screen)
│   ├── GUIDE.md                     (How to make custom UI)
│   └── [other UI systems]
│
├── docs/                            ← All documentation (you are here)
│   ├── README.md                    (This file)
│   ├── 01-dialogue.md
│   ├── 02-inventory.md
│   ├── 03-skills.md
│   ├── 04-player.md
│   ├── 05-physics.md
│   ├── 06-autoloads.md
│   ├── 07-ui.md
│   ├── 08-entities.md
│   └── 09-levels.md
│
├── project.godot                    ← Godot settings (input keys, autoloads)
├── CLAUDE.md                        ← Project rules
└── ARCHITECTURE.md                  ← System overview
```

---

## How Everything Works Together

### Example 1: Player Talks to NPC

```
1. Player walks near NPC
   └─ NPC has Interactable script + dialogue data

2. Player presses E (p0_interact key)
   └─ DialogueManager detects the press

3. DialogueManager finds nearest NPC
   └─ Reads NPC's dialogue data

4. DialogueUI appears on screen
   └─ Shows what NPC says + options

5. Player clicks option or presses E again
   └─ Dialogue advances to next line

6. Player walks away
   └─ Dialogue closes automatically
```

### Example 2: Player Picks Up Item

```
1. Item is in world (has ItemPickup script)

2. Player walks over it

3. ItemPickup detects player collision

4. Calls: InventoryUI.setItemName(slot, "Item Name")
   └─ Item appears in inventory grid

5. Item object disappears from world
```

### Example 3: Player Uses Skill

```
1. SkillUI shows 5 ability slots at bottom

2. Player equips "Fireball" to slot 1

3. Player presses "1" key

4. SkillManager.use_skill(0) is called

5. Fireball executes
   └─ (Logic would be in your skill system)
```

---

## Key Concepts Explained

### **Scenes** (.tscn files)
A blueprint for game objects. Like a Lego instruction diagram.

Example: `player.tscn` contains:
- Node hierarchy (what's connected to what)
- Visual layout (where things are positioned)
- Properties (size, color, etc)

**You use scenes for:**
- UI panels (menus, HUD, dialogs)
- Complete objects (enemies, NPCs, items)
- Levels (the whole game world)

### **Scripts** (.gd files)
Code that makes things *do* something. The actual behavior.

Example: `playerController.gd` handles:
- Reading keyboard input (WASD)
- Moving the player
- Rotating the camera with mouse

**You use scripts for:**
- Game logic (what happens when)
- Input handling (keys, mouse clicks)
- Communication between systems

### **Autoloads** (Singletons)
Scripts that load once when the game starts and run **everywhere** at all times.

Example: `DialogueManager` is an autoload that:
- Listens for E key globally
- Detects which NPC you're near
- Shows dialogue UI

**You use autoloads for:**
- Global input handling (pause menu, interact)
- Game state (score, level, inventory)
- Manager systems (pause, dialogue, physics)

### **Signals** (Events)
A way for one script to say "Hey! Something happened!" and have other scripts listen.

Example:
```gdscript
# NPC's script says:
signal dialogue_started
dialogue_started.emit()  # "Dialogue is starting!"

# Inventory's script listens:
npc.dialogue_started.connect(_on_dialogue_started)
```

---

## How to Use These Guides

### Step 1: Read the First Section
Each guide starts by explaining **what** the system does and **why** it matters.

### Step 2: Follow the Complete Guide
The guide shows you **exactly what to do** with:
- File paths (where to create files)
- Complete code (copy-paste ready)
- Line-by-line explanation

### Step 3: Test Immediately
Each guide includes a working example you can test right now.

### Step 4: Customize
Once it works, the guide shows how to change it.

---

## Starting Your First Task

### Task 1: Add Dialogue to an NPC (Beginner)
1. Open [01-dialogue.md](01-dialogue.md)
2. Follow "Complete Guide" section
3. You'll have a talking NPC in 15 minutes

### Task 2: Customize Player Movement (Easy)
1. Open [04-player.md](04-player.md)
2. Find "Change Movement Speed" section
3. Edit one number and test

### Task 3: Create a New Level (Medium)
1. Open [09-levels.md](09-levels.md)
2. Follow the 7 steps
3. You'll have a new playable world

### Task 4: Build a Skill System (Advanced)
1. Open [06-autoloads.md](06-autoloads.md)
2. Open [03-skills.md](03-skills.md)
3. Combine both into a working system

---

## Common Questions

**Q: Where do I write code?**
A: In `.gd` files (GDScript files). Use any text editor or Godot's built-in editor.

**Q: How do I test what I made?**
A: Press Play in Godot. The game starts from the scene in `project.godot` under `run/main_scene`.

**Q: What if I break something?**
A: Use `Ctrl+Z` (undo) or reload the file. Git is also set up for version control.

**Q: Can I add new nodes to scenes?**
A: Yes, but read `CLAUDE.md` first for the project rules.

**Q: Where's the actual game?**
A: `levels/test/world.tscn` - the starting level. Press Play to run it.

---

## Input Keys

All defined in `project.godot`:

| Key | Action | Purpose |
|-----|--------|---------|
| W | `p0_move_forward` | Move forward |
| A | `p0_move_left` | Move left |
| S | `p0_move_back` | Move backward |
| D | `p0_move_right` | Move right |
| E | `p0_interact` | Talk to NPCs, pick up items |
| Space | `p0_roll` | Jump |
| Mouse | (built-in) | Look around |
| ESC | `p0_pause` | Pause game, show menu |
| I | `p0_inventory` | Open inventory (placeholder) |
| J | `p0_quest_log` | Quest log (placeholder) |
| 1-5 | (not mapped) | Skills (you can add) |

---

## File Locations Quick Reference

| What You Want | File Path |
|---------------|-----------|
| Player movement speed | `entities/player/playerController.gd` line 3 |
| Gravity/jumping | `entities/player/playerController.gd` line 6 |
| Camera sensitivity | `entities/player/playerController.gd` line 4 |
| Input key bindings | `project.godot` [input] section |
| Pause menu code | `core/autoloads/pauseManager.gd` |
| Dialogue system | `core/dialogue/dialogueResource.gd` |
| Inventory script | `ui/inventory/inventoryUI.gd` |
| Skill bar script | `ui/skill/skillUI.gd` |
| Physics | `core/physics/physicsManager.gd` |
| Main menu | `core/main_menu/mainMenu.gd` |
| Test level | `levels/test/world.tscn` |

---

## Before You Start

1. **Open the project** in Godot 4.6
2. **Press Play** (top-right) to run the game
3. **Test the controls:**
   - WASD to move
   - Mouse to look
   - Space to jump
   - E to interact (nothing set up yet)
   - ESC to pause

4. **If it doesn't work:** Check that `project.godot` isn't corrupted

---

## Next Steps

Pick one:

1. **[Add NPC dialogue](01-dialogue.md)** ← Start here if you want talking NPCs
2. **[Modify player movement](04-player.md)** ← Start here to change game feel
3. **[Create a new level](09-levels.md)** ← Start here to build a new world
4. **[Understand the architecture](ARCHITECTURE.md)** ← Read if you want the full picture first

---

**Good luck! Ask questions if anything is unclear. Each guide assumes you know nothing.** 🎮
