# Physics System — Complete Guide

## SECTION 1: What Is This & Why Do You Need It?

### What It Does
The **physics system** controls how objects fall, collide, and move through the world. It makes gravity work so the player falls down instead of floating, and it makes walls solid so you can't walk through them.

### What Physics Handles

- **Gravity** — pulls the player downward every frame
- **Jumping** — a burst of upward velocity that gravity then cancels out
- **Collision** — prevents the player from walking through walls and floors
- **Different body types** — player vs platforms vs thrown objects each behave differently

### Real Example

```
Player jumps:
  Frame 1: velocity.y = +12 (jump)
  Frame 2: velocity.y = +11.3 (gravity reduces it)
  Frame 3: velocity.y = +10.6 ...
  Frame 8: velocity.y = 0 (peak of jump)
  Frame 9: velocity.y = -0.7 (now falling)
  ...
  Frame N: player touches ground → velocity.y = 0
```

### Why This Exists
Without a physics system:
1. Players would float in midair
2. Falling would have no feel or weight
3. Walking through walls would be possible
4. Jump height and gravity could not be tuned

---

## SECTION 2: Complete Guide (0 to 100%)

### Part A: The Three Physics Body Types

Godot has three types of physics bodies. You need to know which to use when.

#### 1. CharacterBody3D (Player)
Use this for things the **player controls directly**.

```
Player (Node3D)
└── CharacterBody3D          ← This is CharacterBody3D
    ├── CollisionShape3D     ← Required — defines the player's shape
    └── Camera3D
```

The player controller calls `move_and_slide()` every frame. This function:
- Moves the player by its velocity
- Detects walls, floors, and ceilings
- Adjusts velocity when hitting something (slides along surfaces)

#### 2. StaticBody3D (Level Geometry)
Use this for things that **never move**: floors, walls, platforms, tables.

```
Ground (StaticBody3D)
├── CollisionShape3D         ← Required — defines what you can stand on
└── MeshInstance3D           ← Optional — the visible mesh
```

StaticBody3D never moves itself. It just sits there for other things to collide with.

#### 3. RigidBody3D (Physics Objects)
Use this for things that **react to physics**: a barrel you can push, a crate that falls.

```
TestBarrel (RigidBody3D)
├── CollisionShape3D
└── MeshInstance3D
```

RigidBody3D is fully physics-driven. You don't control it; physics does.

---

### Part B: How the Player's Physics Works

Open `entities/player/playerController.gd`. The physics work like this:

```gdscript
const GRAVITY = 20.0
const JUMP_FORCE = 12.0
const MOVE_SPEED = 5.0

func _physics_process(delta: float) -> void:
	# 1. Apply gravity every frame
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	
	# 2. Handle jump
	if Input.is_action_just_pressed("p0_roll") and is_on_floor():
		velocity.y = JUMP_FORCE
	
	# 3. Handle horizontal movement
	var direction = _get_movement_direction()
	velocity.x = direction.x * MOVE_SPEED
	velocity.z = direction.z * MOVE_SPEED
	
	# 4. Apply everything (moves player and handles collision)
	move_and_slide()
```

**Step by step:**

1. If the player is in the air, velocity.y decreases by `GRAVITY * delta` each frame (pulls down)
2. If player presses Space and is on the floor, velocity.y gets set to `JUMP_FORCE` (launches up)
3. WASD input creates a horizontal direction vector
4. `move_and_slide()` moves the player and handles any collisions

---

### Part C: Setting Up a Platform (StaticBody3D)

A platform is a flat surface the player can stand on. Here is how to make one from scratch.

#### Step 1: Create the Platform Scene

1. In `entities/placeholders/` (or wherever you want)
2. Right-click → "New Scene"
3. Root node type: **StaticBody3D**
4. Name it: `testPlatform`
5. Save as: `entities/placeholders/testPlatform.tscn`

#### Step 2: Add the Collision Shape

1. Right-click `testPlatform` → "Create Child Node"
2. Type "CollisionShape3D" → Create
3. Select `CollisionShape3D` in the scene tree
4. In Inspector → Shape → click the empty slot → "New BoxShape3D"
5. Set the shape's Size to match your platform, example: `Vector3(10, 1, 10)`

**Why this matters:** Without `CollisionShape3D`, the player falls straight through.

#### Step 3: Add the Visible Mesh

1. Right-click `testPlatform` → "Create Child Node"
2. Type "MeshInstance3D" → Create
3. In Inspector → Mesh → "New BoxMesh"
4. Set BoxMesh size to match the collision shape: `Vector3(10, 1, 10)`

**The collision shape and mesh must be the same size.** If they don't match, the player will appear to collide with invisible walls or float above the surface.

#### Step 4: Save and Add to Level

Press **Ctrl+S**, then drag the scene into `levels/test/world.tscn`.

---

### Part D: Tuning the Feel

#### Gravity Examples

```gdscript
const GRAVITY = 10.0   # Floaty — like low-gravity moon
const GRAVITY = 20.0   # Normal — default setting
const GRAVITY = 35.0   # Heavy — feels grounded and serious
```

#### Jump Examples

```gdscript
const JUMP_FORCE = 6.0    # Small hop
const JUMP_FORCE = 12.0   # Normal jump — default
const JUMP_FORCE = 20.0   # High jump — floaty arc
```

**Rule of thumb:** High `GRAVITY` + high `JUMP_FORCE` = snappy feeling (rises fast, falls fast). Low `GRAVITY` + low `JUMP_FORCE` = floaty feeling (rises slowly, falls slowly).

---

### Part E: Making a Thrown Object (RigidBody3D)

If you want an object you can throw or that falls with physics:

```gdscript
# res://entities/placeholders/testObject.gd
extends RigidBody3D

func _ready() -> void:
	# Apply a launch force when spawned
	apply_central_impulse(Vector3(5, 8, 0))
```

Node structure:
```
testObject (RigidBody3D)
├── CollisionShape3D (SphereShape3D)
└── MeshInstance3D (SphereMesh)
```

To spawn it:

```gdscript
var obj = load("res://entities/placeholders/testObject.tscn").instantiate()
obj.global_position = Vector3(0, 5, 0)
get_tree().root.add_child(obj)
```

---

## SECTION 3: Quick Reference

### Body Types

| Type | Use Case | Moves? | How Controlled? |
|------|----------|--------|-----------------|
| `CharacterBody3D` | Player | Yes | Your script + move_and_slide() |
| `StaticBody3D` | Ground, walls | No | Never moves |
| `RigidBody3D` | Props, debris | Yes | Physics engine |

### Physics Constants (in playerController.gd)

```gdscript
const GRAVITY = 20.0      # How fast you fall (units/sec²)
const JUMP_FORCE = 12.0   # Upward speed when jumping (units/sec)
const MOVE_SPEED = 5.0    # Horizontal speed (units/sec)
```

### Minimum Platform Setup

```
testPlatform (StaticBody3D)
├── CollisionShape3D → BoxShape3D (size = Vector3(10, 1, 10))
└── MeshInstance3D   → BoxMesh    (size = Vector3(10, 1, 10))
```

Collision shape and mesh must have matching sizes.

### Collision Layers

Collision layers control which objects can collide with each other. Layers are numbers 1-32. Two objects only collide if one is on a layer the other is set to detect.

Default (don't change unless you know what you're doing):
- Player: layer 1, mask 1
- Ground: layer 1, mask 0
- Interactable areas: layer 0, mask 0

---

## Troubleshooting

**Player falls through the floor:**
- The floor's `StaticBody3D` needs a `CollisionShape3D` child with a valid shape
- Make sure `CollisionShape3D` has a shape assigned (it can't be empty)
- Check the shape size isn't 0

**Player floats above the floor:**
- The collision shape is larger than the visual mesh
- Match `CollisionShape3D` size exactly to `MeshInstance3D` size

**Jumping doesn't work:**
- The player must be on the floor (`is_on_floor()` must return true)
- Check that floor collision is set up correctly
- Try increasing `JUMP_FORCE`

**Physics feel is wrong:**
- Adjust `GRAVITY` and `JUMP_FORCE` together
- Start from default (20.0 / 12.0) and change one at a time

---

## See Also
- [04-player.md](04-player.md) — Player controller details
- [09-levels.md](09-levels.md) — Setting up level ground
