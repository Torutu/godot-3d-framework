# Player Controller Guide

## Overview
First-person player controller with WASD movement, mouse look rotation, jumping, and gravity. Integrates with dialogue system via interaction area.

---

## Files
- `playerController.gd` — Input handling, movement, camera control
- `player.tscn` — Scene hierarchy with CharacterBody3D, Camera, collision, UI elements

---

## How to Modify Movement

### Change Movement Speed
Edit `playerController.gd`:
```gdscript
const MOVE_SPEED = 5.0  # Change this value (units per second)

# Example speeds:
# 3.0 = slow walk
# 5.0 = normal pace
# 8.0 = running
```

### Change Camera Sensitivity
Edit `playerController.gd`:
```gdscript
const MOUSE_SENSITIVITY = 0.003  # Lower = less sensitive, Higher = more sensitive

# Example sensitivities:
# 0.001 = very slow (precise aim)
# 0.003 = normal
# 0.008 = fast (arcade-like)
```

### Change Jump Force
Edit `playerController.gd`:
```gdscript
const JUMP_FORCE = 12.0  # Initial upward velocity

# Example forces:
# 8.0 = low jump
# 12.0 = normal jump
# 20.0 = high jump
```

### Change Gravity
Edit `playerController.gd`:
```gdscript
const GRAVITY = 20.0  # Downward acceleration

# Example gravities:
# 10.0 = low gravity (floaty)
# 20.0 = normal gravity
# 30.0 = high gravity (heavy)
```

---

## How to Add New Input Actions

### Step 1: Define Action in project.godot
```ini
[input]

p0_sprint={
"deadzone": 0.2,
"events": [Object(InputEventKey,"physical_keycode":4194326)]  # Left Shift
}
```

### Step 2: Handle in playerController.gd
```gdscript
func _process(delta: float) -> void:
	# ... existing code ...
	
	if Input.is_action_pressed("p0_sprint"):
		_current_speed = MOVE_SPEED * 1.5  # 50% faster
	else:
		_current_speed = MOVE_SPEED
```

---

## How to Add Abilities/Actions

### Example: Dash Ability
```gdscript
# In playerController.gd

const DASH_SPEED = 20.0
const DASH_DURATION = 0.2
var _dash_remaining = 0.0

func _process(delta: float) -> void:
	# ... existing movement code ...
	
	if Input.is_action_just_pressed("p0_roll") and _dash_remaining <= 0:
		_dash_remaining = DASH_DURATION
	
	if _dash_remaining > 0:
		_dash_remaining -= delta
		var dash_direction = global_transform.basis * Vector3(0, 0, -_get_movement_direction().length())
		velocity = dash_direction.normalized() * DASH_SPEED
	else:
		# Normal movement
		_apply_movement(delta)
```

---

## Node Structure

```
World (Node3D)
├── ... other nodes
└── Player (Node3D)
    └── CharacterBody3D
        ├── HUD (CanvasLayer)
        │   └── DebugLabel
        ├── SkillUI (Control)
        ├── InventoryUI (Control)
        ├── Camera3D
        ├── CollisionShape3D (CapsuleShape3D)
        ├── MeshInstance3D (player visual)
        └── InteractionArea (Area3D)
            └── CollisionShape3D (SphereShape3D, 5.0 radius)
```

---

## How Movement Works

### WASD Movement
```
W → Move forward (relative to camera direction)
A → Move left
S → Move backward
D → Move right

Movement is player-relative, not world-relative
If camera faces north and you press D, you move east (relative to camera)
```

### Mouse Look
```
Move mouse → Rotates camera
X-axis (horizontal) → Rotates player (Yaw)
Y-axis (vertical) → Tilts camera (Pitch, clamped ±90°)

Prevents flipping upside down
```

### Jumping & Gravity
```
Space → Jump (applies upward velocity)
Gravity constantly pulls down

Physics handled by CharacterBody3D.move_and_slide()
Player stays on ground when not jumping
```

---

## How It Looks When Implemented

**First-person view:**
```
┌─────────────────────────────────────┐
│                                     │
│      Blue capsule shape             │
│      (visible from behind)          │
│                                     │
│  WASD moves, Mouse looks around     │
│  Space jumps                        │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ Pos: (0.0, 18.1, 0.0)           │ │
│ │ Vel: (X 5.0, Y 0.0, Z 0.0)      │ │
│ └─────────────────────────────────┘ │ (Debug HUD, top-left)
└─────────────────────────────────────┘
```

---

## API Reference

### playerController.gd

```gdscript
# Get player's current velocity (local space, relative to camera)
func get_local_velocity() -> Vector3:
	return global_transform.basis.inverse() * velocity

# Get movement direction (normalized)
func _get_movement_direction() -> Vector3:
	var direction = Vector3.ZERO
	direction.x = Input.get_action_strength("p0_move_right") - Input.get_action_strength("p0_move_left")
	direction.z = Input.get_action_strength("p0_move_back") - Input.get_action_strength("p0_move_forward")
	return direction.normalized()

# Check if player is on ground
func _is_grounded() -> bool:
	return is_on_floor()
```

---

## Complete Example: Sprint Mechanic

```gdscript
# Add to playerController.gd

const SPRINT_MULTIPLIER = 1.5
var _is_sprinting = false

func _process(delta: float) -> void:
	# ... existing code ...
	
	_handle_sprint()
	_apply_movement(delta)

func _handle_sprint() -> void:
	if Input.is_action_pressed("p0_sprint"):
		_is_sprinting = true
	else:
		_is_sprinting = false

func _apply_movement(delta: float) -> void:
	var movement_dir = _get_movement_direction()
	var current_speed = MOVE_SPEED * (SPRINT_MULTIPLIER if _is_sprinting else 1.0)
	
	var direction = (global_transform.basis * Vector3(movement_dir.x, 0, movement_dir.z)).normalized()
	velocity.x = direction.x * current_speed
	velocity.z = direction.z * current_speed
	
	# ... gravity and jumping code ...
	move_and_slide()
```

Also add to project.godot:
```ini
[input]
p0_sprint={
"deadzone": 0.2,
"events": [Object(InputEventKey,"physical_keycode":4194326)]  # Shift
}
```

---

## Customization Tips

1. **Adjust movement feel** → Change MOVE_SPEED and GRAVITY together
   - Higher speed + lower gravity = floaty/arcade
   - Lower speed + higher gravity = heavy/realistic

2. **Camera sensitivity** → Match to your preference
   - Test different values: 0.001, 0.005, 0.01

3. **Interaction radius** → Edit InteractionArea's SphereShape3D radius
   - Smaller = need to be closer to NPCs
   - Larger = can interact from further away

4. **Player height** → Adjust CapsuleShape3D height in CollisionShape3D
   - Taller capsule = player hits ceiling sooner
   - Shorter capsule = can fit in tighter spaces

---

## Troubleshooting

**Player falls through ground:**
- Check CharacterBody3D has CollisionShape3D child with valid shape
- Check ground/platforms have collision shapes

**Camera rotates wildly with mouse:**
- Mouse sensitivity is too high
- Lower MOUSE_SENSITIVITY constant

**Can't interact with NPCs:**
- Ensure InteractionArea exists in CharacterBody3D
- Check InteractionArea has CollisionShape3D child with SphereShape3D (radius 5.0)

**Movement feels wrong:**
- Check GRAVITY and MOVE_SPEED values
- Ensure _apply_movement() is called every frame
