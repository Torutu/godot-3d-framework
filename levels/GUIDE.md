# Levels Guide

## Overview
Each level is a separate scene file in the `levels/` folder. Contains the world, player, enemies, interactive objects, and environmental elements.

---

## Level Structure

### Current Level
- `res://levels/test/world.tscn` — Test level with player, platform, and cube

### Level Anatomy
```
World (Node3D)
├── Player (Node3D, instanced from player.tscn)
├── Ground (StaticBody3D with platform mesh)
├── Cube (placeholders/cube.tscn instance)
├── Platform (placeholders/platform.tscn instance)
├── Enemies (Node3D, container for all enemies)
│   ├── Goblin1
│   ├── Goblin2
│   └── Boss
├── Items (Node3D, container for loot/pickups)
│   ├── HealthPotion1
│   └── GoldCoin1
├── Dialogue (Node3D, container for NPCs with dialogue)
│   ├── Guard
│   ├── Merchant
│   └── Elder
├── Environment (Node3D)
│   ├── DirectionalLight3D
│   ├── WorldEnvironment
│   └── Sky
└── UI (CanvasLayer)
    ├── HUD (instance)
    ├── SkillUI (instance)
    └── InventoryUI (instance)
```

---

## How to Create a New Level

### Step 1: Create Level Folder
Create a new folder in `res://levels/`:
```
levels/
├── test/
│   └── world.tscn
└── forest/  ← New level
    └── world.tscn
```

### Step 2: Create World Scene
Create a new scene:

```
Forest (Node3D)
├── Player (instanced from res://entities/player/player.tscn)
├── Ground (StaticBody3D)
│   ├── CollisionShape3D
│   └── MeshInstance3D
├── Lighting (Node3D)
│   ├── DirectionalLight3D
│   └── WorldEnvironment
└── UI Layer (CanvasLayer)
    ├── HUD
    ├── SkillUI
    └── InventoryUI
```

### Step 3: Set Up Ground/Platform
```gdscript
# In world.tscn:
# Ground = StaticBody3D
# └── CollisionShape3D (WorldBoundaryShape3D)
# └── MeshInstance3D (PlaneMesh)
```

### Step 4: Add Lighting
```gdscript
# DirectionalLight3D for sun
# Set transform to angle down from above
# Set shadow_enabled = true

# WorldEnvironment
# Set sky to ProceduralSkyMaterial
# Set ambient_light_energy for overall brightness
```

### Step 5: Instance Player
```
Drag res://entities/player/player.tscn into scene
Position at spawn point
```

### Step 6: Add Enemies/NPCs
```gdscript
# Create enemy scene or instance placeholder
var goblin = load("res://entities/enemies/goblin.tscn").instantiate()
goblin.global_position = Vector3(10, 5, 0)
get_node("Enemies").add_child(goblin)
```

### Step 7: Add UI
Instance the UI systems in a CanvasLayer:
```
CanvasLayer (layer = 10)
├── HUD (instance from res://ui/hud/hud.tscn)
├── SkillUI (instance from res://ui/skill/skillUI.tscn)
└── InventoryUI (instance from res://ui/inventory/inventoryUI.tscn)
```

---

## Complete Level Creation Example

```gdscript
# res://levels/forest/world.tscn
# Manually in the editor:

# 1. Create Root
[node name="Forest" type="Node3D"]

# 2. Add Player
[node name="Player" parent="." instance=ExtResource("player.tscn")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 2, 0)

# 3. Add Ground
[node name="Ground" type="StaticBody3D" parent="."]
[node name="CollisionShape3D" type="CollisionShape3D" parent="Ground"]
shape = SubResource("WorldBoundaryShape3D")
[node name="MeshInstance3D" type="MeshInstance3D" parent="Ground"]
mesh = SubResource("PlaneMesh")
scale = Vector3(10, 1, 10)

# 4. Add Lighting
[node name="DirectionalLight3D" type="DirectionalLight3D" parent="."]
transform = Transform3D(...rotate downward...)
shadow_enabled = true

[node name="WorldEnvironment" type="WorldEnvironment" parent="."]
environment = SubResource("Environment")

# 5. Add UI
[node name="UI" type="CanvasLayer" parent="."]
layer = 10
[node name="HUD" parent="UI" instance=ExtResource("hud.tscn")]
[node name="SkillUI" parent="UI" instance=ExtResource("skillUI.tscn")]
[node name="InventoryUI" parent="UI" instance=ExtResource("inventoryUI.tscn")]

# 6. Add Enemies
[node name="Enemies" type="Node3D" parent="."]
[node name="Goblin1" parent="Enemies" instance=ExtResource("goblin.tscn")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 5, 2, 5)

# 7. Add NPCs
[node name="Dialogue" type="Node3D" parent="."]
[node name="Merchant" parent="Dialogue" instance=ExtResource("merchant.tscn")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -5, 2, 0)
```

---

## Level Navigation

### Loading a Level
```gdscript
# In a script (e.g., pause menu)
func _on_level_select(level_path: String) -> void:
	get_tree().change_scene_to_file(level_path)

# Example:
_on_level_select("res://levels/forest/world.tscn")
```

### Level Progression
```gdscript
# res://core/autoloads/levelManager.gd
extends Node

var levels: Array[String] = [
	"res://levels/test/world.tscn",
	"res://levels/forest/world.tscn",
	"res://levels/cave/world.tscn",
	"res://levels/castle/world.tscn",
]

var current_level: int = 0

func next_level() -> void:
	if current_level < levels.size() - 1:
		current_level += 1
		load_level(current_level)

func load_level(index: int) -> void:
	get_tree().change_scene_to_file(levels[index])
```

---

## Lighting Setup

### Sunlight (DirectionalLight3D)
```gdscript
# Simulate sun
var light = DirectionalLight3D.new()
light.light_energy = 1.5
light.shadow_enabled = true
light.transform.basis = Basis.from_euler(Vector3.ZERO).rotated(Vector3(1, 0, 0), -PI/4)
add_child(light)
```

### World Environment
```gdscript
# Create environment
var env = Environment.new()
env.background_mode = Environment.BG_COLOR
env.background_color = Color.DARK_BLUE
env.ambient_light_source = Environment.AMBIENT_LIGHT_DISABLED
env.ambient_light_energy = 0.8

var world_env = WorldEnvironment.new()
world_env.environment = env
add_child(world_env)
```

### Sky
```gdscript
# Add procedural sky
var sky_mat = ProceduralSkyMaterial.new()
sky_mat.sky_type = ProceduralSkyMaterial.SKY_NATHRAK
sky_mat.sun_angle = PI / 4

var sky = Sky.new()
sky.sky_material = sky_mat

var env = Environment.new()
env.background_mode = Environment.BG_SKY
env.sky = sky
```

---

## Spawn Point System

### Player Spawn
```gdscript
# In world.tscn, set Player position on load:
var player = get_node("Player/CharacterBody3D")
player.global_position = Vector3(0, 2, 0)  # Spawn location
```

### Enemy Spawns
```gdscript
# Create spawn points (Node3D with no visuals)
[node name="SpawnPoints" type="Node3D" parent="."]
[node name="Spawn1" type="Node3D" parent="SpawnPoints"]
transform = Transform3D(..., 5, 2, 5)
[node name="Spawn2" type="Node3D" parent="SpawnPoints"]
transform = Transform3D(..., -5, 2, -5)

# Script: Spawn enemies at these points
func _spawn_enemies() -> void:
	var spawn_points = get_node("SpawnPoints").get_children()
	for spawn in spawn_points:
		var enemy = preload("res://entities/enemies/goblin.tscn").instantiate()
		enemy.global_position = spawn.global_position
		get_node("Enemies").add_child(enemy)
```

---

## Performance Tips

### 1. Use Batching for Static Objects
```gdscript
# Instead of many MeshInstance3D nodes, use MultiMesh
var multi_mesh = MultiMesh.new()
multi_mesh.mesh = BoxMesh.new()
var mmi = MultiMeshInstance3D.new()
mmi.multimesh = multi_mesh
add_child(mmi)
```

### 2. Cull Distant Objects
```gdscript
# Disable rendering for far objects
func _process(delta: float) -> void:
	for obj in distant_objects:
		obj.visible = obj.global_position.distance_to(player) < 100
```

### 3. Use LOD (Level of Detail)
```gdscript
# High quality mesh when close, simple mesh when far
if distance < 20:
	show_high_quality_mesh()
else:
	show_low_quality_mesh()
```

---

## Testing Levels

### Quick Test
```gdscript
# In project.godot:
[application]
run/main_scene="res://levels/test/world.tscn"  # Set test level
```

### Load Different Level
```gdscript
# In scene or script:
func _ready() -> void:
	get_tree().change_scene_to_file("res://levels/forest/world.tscn")
```

---

## Troubleshooting

**Player falls through ground:**
- Check Ground has CollisionShape3D with valid shape
- Ensure CollisionShape3D is direct child of Ground
- Player needs to start above ground (y > 0)

**Enemies not spawning:**
- Check enemy scene path is correct
- Verify Enemies node exists in scene
- Check enemy scripts have _ready() implemented

**Lighting too dark/bright:**
- Adjust light_energy on DirectionalLight3D
- Adjust ambient_light_energy on Environment
- Add PointLight3D for local light sources

**UI not showing:**
- Check UI CanvasLayer layer property (should be 10+)
- Ensure UI scenes are instanced, not just scripts
- Check visible property is true
