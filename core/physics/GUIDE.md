# Physics System Guide

## Overview
Basic physics manager that applies gravity to all registered bodies. Currently minimal—just handles gravity application. Can be expanded for collision detection, physics events, and advanced physics behavior.

---

## Files
- `physicsManager.gd` — Autoload that manages physics bodies and gravity

---

## How Physics Works Currently

### Gravity
Constant downward force applied every frame:

```gdscript
const GRAVITY = 20.0  # units per second²

# Applied to all bodies each frame
body.velocity.y -= GRAVITY * delta
```

### Ground Detection
Bodies stop falling when they reach y=0:

```gdscript
if body.global_position.y <= 0:
	body.global_position.y = 0
	body.velocity.y = 0
```

---

## How to Register Physics Bodies

### Method 1: Automatic (for CharacterBody3D)
CharacterBody3D automatically handles physics through move_and_slide():

```gdscript
# In player controller
func _process(delta: float) -> void:
	# ... apply velocity ...
	move_and_slide()  # Built-in physics
```

### Method 2: Manual Registration
For custom physics bodies:

```gdscript
# In your entity script
extends Node3D

var _rigid_body: RigidBody3D

func _ready() -> void:
	_rigid_body = RigidBody3D.new()
	_rigid_body.mass = 1.0
	add_child(_rigid_body)
	
	# Register with physics manager
	PhysicsManager.register_body(_rigid_body)

func _exit_tree() -> void:
	PhysicsManager.unregister_body(_rigid_body)
```

---

## How to Modify Physics

### Change Global Gravity
Edit `physicsManager.gd`:

```gdscript
const GRAVITY = 20.0  # Change this

# Example gravities:
# 10.0 = low gravity (moon-like)
# 20.0 = normal gravity (Earth-like)
# 30.0 = high gravity (Jupiter-like)
```

Also update player controller to match:

```gdscript
# In playerController.gd
const GRAVITY = 20.0  # Keep in sync!
```

### Add Air Drag/Air Resistance
```gdscript
# In physicsManager.gd
const DRAG = 0.1  # 0 = no drag, 1 = full drag

func _apply_gravity(body: Node3D, delta: float) -> void:
	body.velocity.y -= GRAVITY * delta
	
	# Apply air drag to horizontal movement
	body.velocity.x *= (1.0 - DRAG * delta)
	body.velocity.z *= (1.0 - DRAG * delta)
	
	# Stop at ground
	if body.global_position.y <= 0:
		body.global_position.y = 0
		body.velocity.y = 0
```

### Add Wind Force
```gdscript
# In physicsManager.gd
const WIND_STRENGTH = 2.0
var _wind_direction: Vector3 = Vector3.RIGHT

func _apply_gravity(body: Node3D, delta: float) -> void:
	body.velocity.y -= GRAVITY * delta
	
	# Apply wind to falling objects
	if not is_grounded(body):
		body.velocity += _wind_direction * WIND_STRENGTH * delta
	
	if body.global_position.y <= 0:
		body.global_position.y = 0
		body.velocity.y = 0

func set_wind(direction: Vector3, strength: float) -> void:
	_wind_direction = direction.normalized()
	_wind_strength = strength
```

---

## Node Structure (Physics Bodies)

### CharacterBody3D (Player)
```
Player
└── CharacterBody3D
    ├── Camera3D
    ├── CollisionShape3D (CapsuleShape3D)
    └── MeshInstance3D
```

### RigidBody3D (Dynamic Objects)
```
DynamicObject
└── RigidBody3D
    ├── CollisionShape3D (BoxShape3D/SphereShape3D)
    └── MeshInstance3D
```

### StaticBody3D (Platforms, Terrain)
```
Platform
└── StaticBody3D
    ├── CollisionShape3D (BoxShape3D)
    └── MeshInstance3D
```

---

## How Physics Looks When Implemented

**Gravity in action:**
```
t=0s: Object at y=20
↓
t=0.5s: Object at y=15 (falling)
↓
t=1s: Object at y=8 (falling faster)
↓
t=1.5s: Object at y=0 (hits ground, stops)
```

**With jump:**
```
t=0s: Player velocity.y = +12 (jumping up)
↓ (gravity reduces upward velocity each frame)
t=0.5s: Player velocity.y = +2 (still going up, slowing)
t=0.6s: Player velocity.y = 0 (peak of jump)
↓ (now gravity pulls down)
t=1s: Player velocity.y = -8 (falling)
t=1.2s: Player velocity.y = 0 (hits ground)
```

---

## API Reference

### physicsManager.gd

```gdscript
# Register a body to be affected by physics
func register_body(body: Node3D) -> void:
	_bodies.append(body)

# Unregister a body
func unregister_body(body: Node3D) -> void:
	_bodies.erase(body)

# Check if body is on ground
func is_grounded(body: Node3D) -> bool:
	return body.global_position.y <= 0.1  # Small tolerance
```

---

## Complete Example: Falling Platform

```gdscript
# res://entities/platforms/falling_platform.gd
extends StaticBody3D

@export var fall_delay: float = 2.0
@export var respawn_height: float = 20.0

var _original_position: Vector3
var _is_falling: bool = false
var _fall_timer: float = 0.0

func _ready() -> void:
	_original_position = global_position

func _process(delta: float) -> void:
	if not _is_falling:
		# Check if player is on top
		var collisions = get_overlapping_areas()
		if not collisions.is_empty():
			_is_falling = true
			_fall_timer = fall_delay

func _process(delta: float) -> void:
	if _is_falling:
		_fall_timer -= delta
		if _fall_timer <= 0:
			# Start falling (switch to RigidBody3D mode or move down)
			global_position.y -= 10.0 * delta
		
		# Reset if too low
		if global_position.y < -20:
			global_position = _original_position
			_is_falling = false
```

---

## Expanding the Physics System

The current system is basic. Here are ways to expand it:

### 1. Add Collision Events
```gdscript
signal body_collided(body1: Node3D, body2: Node3D)

func _process_collisions() -> void:
	for i in range(_bodies.size()):
		for j in range(i + 1, _bodies.size()):
			if _check_collision(_bodies[i], _bodies[j]):
				body_collided.emit(_bodies[i], _bodies[j])
```

### 2. Add Velocity Damping
```gdscript
const DAMPING = 0.95  # Reduce velocity over time

func _apply_gravity(body: Node3D, delta: float) -> void:
	body.velocity *= DAMPING
	body.velocity.y -= GRAVITY * delta
```

### 3. Add Buoyancy (for water)
```gdscript
var _water_bodies: Array[Area3D] = []

func register_water(water_area: Area3D) -> void:
	_water_bodies.append(water_area)

func _apply_buoyancy(body: Node3D, delta: float) -> void:
	for water in _water_bodies:
		if water.overlaps_area(body):
			body.velocity.y += 15.0 * delta  # Push up
```

---

## Troubleshooting

**Objects falling through ground:**
- Check global_position.y is being clamped at 0
- Ensure _apply_gravity() is called every frame

**Physics feels wrong/floaty:**
- Adjust GRAVITY constant
- Check if move_and_slide() is called for CharacterBody3D

**Bodies not registered:**
- Call register_body() in _ready()
- Make sure body is added to scene tree

**Gravity not affecting object:**
- Check object extends Node3D (not Node2D)
- Verify object is registered with PhysicsManager
- Check process_mode is not disabled
