# Autoload Singletons Guide

## Overview
Autoloads (singletons) are scripts that load automatically when the game starts. They persist across scene changes and can be accessed globally. Useful for managing game-wide systems.

---

## Existing Autoloads

| Name | File | Purpose |
|------|------|---------|
| PhysicsManager | `physicsManager.gd` | Manages physics bodies and gravity |
| PauseManager | `pauseManager.gd` | Handles pause menu and game pausing |
| DialogueManager | `dialogueManager.gd` | Manages dialogue interactions and UI |

---

## How to Create a New Autoload

### Step 1: Create the Script
Create a new script in `res://core/autoloads/`:

```gdscript
# res://core/autoloads/myManager.gd
extends Node
class_name MyManager

func _ready() -> void:
	print("MyManager loaded!")

func do_something() -> void:
	print("Doing something")
```

### Step 2: Register in project.godot
Edit `project.godot` and add to [autoload] section:

```ini
[autoload]

PhysicsManager="*res://core/physics/physicsManager.gd"
PauseManager="*res://core/autoloads/pauseManager.gd"
DialogueManager="*res://core/autoloads/dialogueManager.gd"
MyManager="*res://core/autoloads/myManager.gd"
```

### Step 3: Access from Anywhere
```gdscript
# In any script
MyManager.do_something()
```

---

## How to Edit Autoloads

### PauseManager Example
This autoload listens for ESC key globally:

```gdscript
# res://core/autoloads/pauseManager.gd
extends Node

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS  # Important: still processes when paused

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("p0_pause"):
		get_tree().root.set_input_as_handled()
		_toggle_pause()

func _toggle_pause() -> void:
	var is_paused = get_tree().paused
	get_tree().paused = !is_paused
	
	if not is_paused:
		# Pause just activated
		_show_pause_menu()
	else:
		# Resume game
		_close_pause_menu()

func _show_pause_menu() -> void:
	var menu = load("res://ui/pause_menu/pauseMenu.tscn").instantiate()
	get_tree().root.add_child(menu)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _close_pause_menu() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
```

To modify pause behavior:
```gdscript
# Make pause menu appear at a different position
func _show_pause_menu() -> void:
	var menu = load("res://ui/pause_menu/pauseMenu.tscn").instantiate()
	menu.position = Vector2(640, 200)  # Center position
	get_tree().root.add_child(menu)

# Add pause fade effect
func _toggle_pause() -> void:
	var is_paused = get_tree().paused
	get_tree().paused = !is_paused
	
	if not is_paused:
		var tween = create_tween()
		tween.tween_callback(func(): _show_pause_menu())
```

---

## Best Practices for Autoloads

### 1. Set process_mode Correctly
```gdscript
func _ready() -> void:
	# Processes even when game is paused
	process_mode = PROCESS_MODE_ALWAYS
	
	# OR
	
	# Only processes when game is not paused
	process_mode = PROCESS_MODE_INHERIT
```

### 2. Use Signals for Communication
```gdscript
# res://core/autoloads/eventBus.gd
extends Node

signal item_collected(item_name: String)
signal enemy_defeated(enemy_name: String)
signal level_completed

# In another script:
EventBus.item_collected.emit("Health Potion")
EventBus.item_collected.connect(_on_item_collected)

func _on_item_collected(item_name: String) -> void:
	print("Collected: ", item_name)
```

### 3. Keep State Minimal
Only track what's essential. Move complex logic to dedicated systems:

```gdscript
# Good: Simple state
class_name GameManager extends Node

var current_level: int = 1
var player_health: int = 100

# Bad: Too much in one autoload
# ... 500 lines of dialogue, inventory, skills, enemies, etc.
```

### 4. Avoid Circular Dependencies
```gdscript
# Bad: Autoload 1 requires Autoload 2, Autoload 2 requires Autoload 1
# Instead: Use signals or create a dedicated manager

# Good: All systems communicate through EventBus
signal game_started
signal game_ended
```

---

## Complete Example: GameManager Autoload

```gdscript
# res://core/autoloads/gameManager.gd
extends Node
class_name GameManager

signal level_started(level_number: int)
signal level_completed
signal player_died
signal checkpoint_reached(checkpoint_id: String)

var current_level: int = 1
var player_alive: bool = true
var total_playtime: float = 0.0

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	print("GameManager initialized")

func _process(delta: float) -> void:
	if player_alive:
		total_playtime += delta

func start_level(level_num: int) -> void:
	current_level = level_num
	player_alive = true
	level_started.emit(level_num)
	print("Starting level %d" % level_num)

func complete_level() -> void:
	level_completed.emit()
	print("Level %d completed!" % current_level)

func player_death() -> void:
	player_alive = false
	player_died.emit()
	print("Player died at level %d" % current_level)

func save_checkpoint(checkpoint_id: String) -> void:
	checkpoint_reached.emit(checkpoint_id)
	print("Checkpoint saved: ", checkpoint_id)

func reset_game() -> void:
	current_level = 1
	player_alive = true
	total_playtime = 0.0
	print("Game reset")
```

Usage:
```gdscript
# In player controller
func _on_health_depleted() -> void:
	GameManager.player_death()

# In level script
func _ready() -> void:
	GameManager.start_level(1)
	GameManager.level_completed.connect(_on_level_complete)

func _on_level_complete() -> void:
	get_tree().change_scene_to_file("res://levels/level_02/world.tscn")

# In pause menu
func _on_quit_pressed() -> void:
	GameManager.reset_game()
	get_tree().change_scene_to_file("res://core/main_menu/mainMenu.tscn")
```

---

## Autoload Load Order

In `project.godot`, autoloads load in the order listed:

```ini
[autoload]
PhysicsManager="*res://core/physics/physicsManager.gd"     # Loads first
PauseManager="*res://core/autoloads/pauseManager.gd"       # Loads second
DialogueManager="*res://core/autoloads/dialogueManager.gd" # Loads third
```

If autoload 2 depends on autoload 1, make sure autoload 1 is listed first.

---

## Troubleshooting

**Autoload not loading:**
- Check spelling in project.godot matches file name
- Ensure path uses forward slashes: `*res://core/autoloads/myManager.gd`
- Restart Godot editor after adding autoload

**Can't access autoload from script:**
- Check autoload name matches class_name in script
- Use full autoload name: `MyManager.do_something()` not `MyManager.some_function()`

**Autoload not receiving input:**
- Set `process_mode = PROCESS_MODE_ALWAYS` in _ready()
- Check input actions are defined in project.godot

**Autoload persists after changing scenes:**
- This is intentional - autoloads are global
- Use `queue_free()` in _ready() if you want to destroy it
- Or use a regular scene node instead of autoload
