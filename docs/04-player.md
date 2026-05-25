# Player Controller — Complete Guide

## SECTION 1: What Is This & Why Do You Need It?

### What It Does
The **player controller** is the code that makes the player character move and look around. It reads keyboard and mouse input every frame and turns that input into movement in the game world.

### What the Player Can Do

| Input | Action |
|-------|--------|
| W | Move forward |
| A | Strafe left |
| S | Move backward |
| D | Strafe right |
| Space | Jump |
| Mouse | Look around (camera rotates) |
| E | Interact with nearby entities |
| ESC | Pause the game |
| I | Open inventory (placeholder) |

### Why This Exists
Without this script, the player character would just sit there. This script is what makes the camera follow the mouse, what makes WASD move the character, what applies gravity so the player falls, and what detects the E key for interactions.

---

## SECTION 2: Complete Guide (0 to 100%)

### Part A: Understanding the Files

Two files make the player work:

1. **`entities/player/playerController.gd`**
   - All movement and camera code
   - Constants at the top you can change to feel different
   - Already attached to the player scene

2. **`entities/player/player.tscn`**
   - The player scene with its node structure
   - Already placed in `levels/test/world.tscn`
   - You don't need to create this — it already exists

---

### Part B: The Constants You Can Change

Open `entities/player/playerController.gd`. At the top you will see:

```gdscript
const MOVE_SPEED = 5.0
const MOUSE_SENSITIVITY = 0.003
const JUMP_FORCE = 12.0
const GRAVITY = 20.0
```

**What each does:**

| Constant | Default | Lower = ? | Higher = ? |
|----------|---------|-----------|------------|
| `MOVE_SPEED` | 5.0 | Walks slowly | Runs fast |
| `MOUSE_SENSITIVITY` | 0.003 | Camera turns slowly | Camera whips around |
| `JUMP_FORCE` | 12.0 | Short hop | Floats high |
| `GRAVITY` | 20.0 | Floats down | Falls fast |

#### To change movement speed:

1. Open `entities/player/playerController.gd`
2. Find line: `const MOVE_SPEED = 5.0`
3. Change to: `const MOVE_SPEED = 8.0`
4. Press Play and test

---

### Part C: The Player's Node Structure

The player scene (`player.tscn`) looks like this in the scene tree:

```
Player (Node3D)                    ← Root node
└── CharacterBody3D                ← Handles physics and collision
    ├── Camera3D                   ← What you see (first-person view)
    ├── CollisionShape3D           ← Player's physical shape (capsule)
    ├── MeshInstance3D             ← Player's visible body
    ├── InteractionArea (Area3D)   ← Detects nearby NPCs for dialogue
    │   └── CollisionShape3D      ← Sphere (radius 5) — interaction range
    ├── HUD (CanvasLayer)          ← Debug display
    ├── SkillUI (Control)          ← Skill bar
    └── InventoryUI (Control)      ← Inventory grid
```

**What each node does:**
- `CharacterBody3D` — Godot's built-in physics body. `move_and_slide()` makes it handle collisions
- `Camera3D` — The player's eyes. When this rotates, your view rotates
- `CollisionShape3D` (capsule) — The invisible shape that bumps into walls and floors
- `InteractionArea` — An invisible sphere. When you press E, the game checks what's inside this sphere

---

### Part D: How to Add Sprint

#### Step 1: Add a Sprint input binding

1. Open `project.godot` in any text editor
2. Find the `[input]` section
3. Add this line (this maps Left Shift to the sprint action):

```ini
p0_sprint={ "deadzone": 0.5, "events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":4194326,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)] }
```

#### Step 2: Add Sprint to playerController.gd

Open `entities/player/playerController.gd`. Find the movement section and add:

```gdscript
const SPRINT_SPEED = 10.0  # Add near the other constants at the top

# Inside the movement function, change the speed calculation:
var speed = MOVE_SPEED
if Input.is_action_pressed("p0_sprint"):
	speed = SPRINT_SPEED
```

---

### Part E: How to Add a Dash

```gdscript
# Add these constants at top of playerController.gd
const DASH_SPEED = 25.0
const DASH_DURATION = 0.15

# Add this variable below the constants
var _dash_remaining: float = 0.0

# Add to _input() function
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("p0_roll"):
		_dash_remaining = DASH_DURATION

# Add to _process() or _physics_process()
func _physics_process(delta: float) -> void:
	if _dash_remaining > 0:
		_dash_remaining -= delta
		velocity = -global_transform.basis.z * DASH_SPEED
		move_and_slide()
		return
	# ... rest of normal movement
```

---

### Part F: Debug Information

A small panel appears in the top-left corner when the game runs:

```
Pos: (0.0, 18.1, 0.0)
Vel: (X 5.0, Y 0.0, Z 0.0)
```

- **Pos** = where the player is in the world (X, Y, Z coordinates)
- **Vel** = how fast the player is moving in each direction

If the player is falling, Y velocity will be a negative number getting bigger.

---

### Part G: Changing the Interaction Range

The interaction range is the sphere around the player that detects nearby NPCs. By default it is 5 units.

1. Open `entities/player/player.tscn`
2. In the scene tree, find `InteractionArea` → `CollisionShape3D`
3. In Inspector → Shape → Radius, change from `5.0` to your desired value
4. Save with **Ctrl+S**

---

## SECTION 3: Quick Reference

### Constants (in playerController.gd)

```gdscript
const MOVE_SPEED = 5.0           # Walking speed
const MOUSE_SENSITIVITY = 0.003  # How fast camera turns
const JUMP_FORCE = 12.0          # How high the jump goes
const GRAVITY = 20.0             # How fast the player falls
```

### Input Actions (in project.godot)

| Key | Action Name | Used For |
|-----|-------------|---------|
| W | `p0_move_forward` | Move forward |
| A | `p0_move_left` | Strafe left |
| S | `p0_move_back` | Move backward |
| D | `p0_move_right` | Strafe right |
| Space | `p0_roll` | Jump |
| E | `p0_interact` | Interact (dialogue, pickup) |
| ESC | `p0_pause` | Pause game |
| I | `p0_inventory` | Inventory |

### Player Node Path

From any script, you can find the player like this:

```gdscript
var player = get_tree().root.get_node("World/Player/CharacterBody3D")
var player_position = player.global_position
```

---

## Troubleshooting

**Player falls through the ground:**
- Check the Ground in your level has a `CollisionShape3D` with a valid shape
- Make sure the player's Y position is above the ground at start

**Camera spins wildly when moving the mouse:**
- Lower `MOUSE_SENSITIVITY` from 0.003 to 0.001 or less

**Player can't jump:**
- Make sure `JUMP_FORCE` is positive (not zero or negative)
- Player must be on the ground to jump

**E key doesn't start dialogue:**
- See [01-dialogue.md](01-dialogue.md) — the NPC needs `interactable.gd` attached
- Player needs `InteractionArea` (Area3D) child under `CharacterBody3D`

---

## See Also
- [05-physics.md](05-physics.md) — How gravity and jumping work
- [01-dialogue.md](01-dialogue.md) — Using E key with NPCs
